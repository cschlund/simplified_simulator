@/home/cschlund/Programme/idl/vali_gui_rv/vali_pre_compile.pro
;+
; NAME:
;   CLOUDCCI_SIMULATOR
;
; PURPOSE:
;   Calculates monthly means of cloud-cci like parameters 
;   based on ERA-Interim reanalysis
;
; AUTHOR:
;   Dr. Martin Stengel
;   Deutscher Wetterdienst (DWD)
;   KU22, Climate-based satellite monitoring
;   martin.stengel@dwd.de
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;   cloudcci_simulator
;
; MODIFICATION HISTORY:
;   Written by Dr. Martin Stengel, 2014; 
;     grid_mean arrays as output; for comparison with model results
;   C. Schlundt, Jul 2015: program modifications - subroutines added
;   C. Schlundt, Jul 2015: incloud_mean arrays added
;                          (LWP and IWP weighted with CFC)
;   C. Schlundt, Sep 2015: binary CFC, CPH added and applied to LWP/IWP
;   C. Schlundt, Oct 2015: implementation of structures
;   C. Schlundt, Oct 2015: implementation of CWP
;   C. Schlundt, Oct 2015: implementation of COT
;   C. Schlundt, Oct 2015: implementation of SZA2d
;   C. Schlundt, Oct 2015: implementation of COT/CWP dayside only
;   C. Schlundt, Oct 2015: implementation of 1D Histograms
;   C. Schlundt, Nov 2015: implementation of 2D Histogram COT-CTP
;
; ToDo:
;       (1) cloud overlap
;
;*******************************************************************************
PRO CLOUDCCI_SIMULATOR, verbose=verbose, logfile=logfile, test=test, map=map
;*******************************************************************************
    clock = TIC('TOTAL')

    ; -- import settings
    IF KEYWORD_SET(verbose) THEN PRINT, '** Import user setttings'
    CONFIG_SIMULATOR, pwd, tim, thv, his


    IF KEYWORD_SET(test) THEN BEGIN
        pwd.inp = '/data/cschlund/MARS_data/ERA_simulator_testdata/'
        pwd.out = pwd.out + 'testrun/'
        validres = VALID_DIR( pwd.out)
        IF(validres EQ 0) THEN creatres = CREATE_DIR( pwd.out )
    ENDIF


    IF KEYWORD_SET(verbose) THEN HELP, pwd, /structure
    IF KEYWORD_SET(verbose) THEN HELP, thv, /structure


    IF KEYWORD_SET(logfile) THEN $
        JOURNAL, pwd.out + 'journal_' + thv.str + cgTimeStamp() + '.pro'


    ; -- loop over years and months
    FOR ii1=0, tim.ny-1 DO BEGIN
        FOR jj1=0, tim.nm-1 DO BEGIN

            year  = tim.yyyy[ii1]
            month = tim.mm[jj1]
            mm_clock = TIC(year+'/'+month)
            counti = 0

            ff = FINDFILE(pwd.inp+year+month+'/'+'*'+year+month+'*plev')

            numff = N_ELEMENTS(ff)
            strff = STRTRIM(numff,2)
            strym = STRING(year) + '/' + STRING(month)

            PRINT, '** ', strff, ' ERA-Interim InputFiles for ', strym

            IF(N_ELEMENTS(ff) GT 1) THEN BEGIN

                ;---------------------------------------------------------------
                FOR fidx=0,N_ELEMENTS(ff)-1,1 DO BEGIN ;loop over files
                ;---------------------------------------------------------------

                    file0 = ff[fidx]
                    file1 = file0+'.nc'

                    IF(is_file(file0) AND (NOT is_file(file1))) THEN BEGIN
                        PRINT,'** Converting: ' + file0
                        SPAWN,'cdo -f nc copy ' + file0 + ' ' + file1
                    ENDIF

                    IF(is_file(file1)) THEN BEGIN

                        strcnt = STRTRIM(counti+1,2)

                        ; -- returns structure containing the input variables
                        READ_ERA_NCFILE, file1, input

                        IF KEYWORD_SET(verbose) THEN $
                            PRINT, '** ',strcnt,'.LOADED: ', input.file 

                        ; -- initialize grid and arrays for monthly mean output:
                        IF(counti EQ 0) THEN BEGIN
                            INIT_ERA_GRID, input, grid 
                            INIT_OUT_ARRAYS, grid, his, mean_era, cnts_era
                            INIT_OUT_ARRAYS, grid, his, mean_sat, cnts_sat
                        ENDIF
                        counti++

                        ; -- initialize solar zenith angle 2D array
                        IF KEYWORD_SET(test) AND KEYWORD_SET(map) THEN BEGIN
                            sza2d = INIT_SZA_ARRAY(file1,grid,/map,pwd=pwd.fig)
                        ENDIF ELSE BEGIN
                            sza2d = INIT_SZA_ARRAY(file1,grid)
                        ENDELSE

                        ; -- lwc and iwc weighted by cc
                        CWC_INCLOUD, input, grid, cwc_inc

                        ; -- get LWP/IWP/LCOT/ICOT per layer
                        CWP_COT_LAYERS, input.lwc, input.iwc, input.dpres, $
                                        grid, cwp_lay, cot_lay
                        CWP_COT_LAYERS, cwc_inc.lwc, cwc_inc.iwc, input.dpres, $ 
                                        grid, cwp_lay_inc, cot_lay_inc 

                        ; -- get cloud parameters using incloud COT threshold
                        SEARCH4CLOUD, input, grid, cwp_lay, cot_lay_inc, $
                                      'ori', thv.era, tmp_era
                        SEARCH4CLOUD, input, grid, cwp_lay, cot_lay_inc, $
                                      'sat', thv.sat, tmp_sat

                        ; -- scale COT and thus CWP like in CC4CL for tmp_sat only
                        SCALE_COT_CWP, tmp_sat, grid

                        ; -- sunlit region only for COT and CWP
                        IF KEYWORD_SET(test) AND KEYWORD_SET(map) THEN BEGIN
                            SOLAR_COT_CWP, tmp_sat, sza2d, grid, pwd.fig, file1
                        ENDIF ELSE BEGIN
                            SOLAR_COT_CWP, tmp_sat, sza2d
                        ENDELSE

                        ; -- sum up cloud parameters
                        SUMUP_VARS, 'ori', mean_era, cnts_era, tmp_era, his
                        SUMUP_VARS, 'sat', mean_sat, cnts_sat, tmp_sat, his

                        ; -- count number of files
                        cnts_era.raw++
                        cnts_sat.raw++

                        ; -- delete tmp arrays
                        UNDEFINE, sza2d, tmp_era, tmp_sat
                        UNDEFINE, cwp_lay, cot_lay
                        UNDEFINE, cwp_lay_inc, cot_lay_inc

                    ENDIF ;end of IF(is_file(file1))

                ;---------------------------------------------------------------
                ENDFOR ;end of file loop
                ;---------------------------------------------------------------

                ; -- calculate averages
                MEAN_VARS, mean_era, cnts_era
                MEAN_VARS, mean_sat, cnts_sat

                ; -- write output files
                WRITE_MONTHLY_MEAN, pwd.out, year, month, grid, input, thv, $
                                    mean_era, cnts_era, mean_sat, cnts_sat

                WRITE_MONTHLY_HIST, pwd.out, year, month, grid, input, $
                                    thv, his, mean_era, mean_sat, $
                                    cnts_era, cnts_sat


                ; delete final arrays before next cycle starts
                UNDEFINE, mean_era, mean_sat, cnts_era, cnts_sat

            ENDIF ;end of IF(N_ELEMENTS(ff) GT 1)

           TOC, mm_clock

        ENDFOR ;end of month loop
    ENDFOR ;end of year loop

    ; End journaling:
	IF KEYWORD_SET(logfile) THEN JOURNAL

    TOC, clock

;*******************************************************************************
END ;end of program
;*******************************************************************************
