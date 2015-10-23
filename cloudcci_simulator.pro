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
;   C. Schlundt, Juli 2015: program modifications - subroutines added
;   C. Schlundt, Juli 2015: incloud_mean arrays added
;                           (LWP and IWP weighted with CFC)
;   C. Schlundt, September 2015: binary CFC, CPH added and applied to LWP/IWP
;   C. Schlundt, Oktober 2015: implementation of structures
;
; ToDo: (1) add COT as output variable, 
;       (2) COT/LWP/IWP dayside only, 
;       (3) cloud overlap
;
;*******************************************************************************
PRO CLOUDCCI_SIMULATOR, verbose=verbose, logfile=logfile, test=test
;*******************************************************************************
    clock = TIC('TOTAL')

    ; -- import settings
    IF KEYWORD_SET(verbose) THEN $
        PRINT, ' * Import CONFIG_CLOUDCCI_SIMULATOR setttings'
    CONFIG_SIMULATOR, pwd, tim, thv, his


    IF KEYWORD_SET(test) THEN BEGIN
        pwd.inp = '/data/cschlund/MARS_data/ERA_simulator_testdata/'
        pwd.out = pwd.out + 'testrun/'
        validres = VALID_DIR( pwd.out)
        IF(validres EQ 0) THEN creatres = CREATE_DIR( pwd.out )
    ENDIF


    IF KEYWORD_SET(verbose) THEN BEGIN
        HELP, pwd, /structure
        HELP, thv, /structure
    ENDIF


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

            PRINT, ''
            PRINT, ' *** ',STRTRIM(numff,2),' Number of files for ', year, '/', month
            PRINT, ''

            IF(N_ELEMENTS(ff) GT 1) THEN BEGIN

                FOR fidx=0,N_ELEMENTS(ff)-1,1 DO BEGIN ;loop over files

                    file0 = ff[fidx]
                    file1 = file0+'.nc'

                    IF(is_file(file0) AND (NOT is_file(file1))) THEN BEGIN
                        PRINT,' * Converting: ' + file0
                        SPAWN,'cdo -f nc copy ' + file0 + ' ' + file1
                    ENDIF

                    IF(is_file(file1)) THEN BEGIN

                        base = FSC_Base_Filename(file1,Directory=dir,Extension=ext)

                        IF KEYWORD_SET(verbose) AND (counti EQ 0) THEN $
                            PRINT, ' * Input directory: ', dir

                        ; -- read netCDF file
                        IF KEYWORD_SET(verbose) THEN BEGIN
                            PRINT,' * READ_ERA_NCFILE: ',STRTRIM(counti,2),': ',base+'.'+ext
                        ENDIF

                        ; -- returns structure containing the input variables
                        READ_ERA_NCFILE, file1, input

                        ; -- initialize grid and output arrays:
                        IF(counti EQ 0) THEN BEGIN
                            INIT_ERA_GRID, input, grid 
                            INIT_OUT_ARRAYS, grid, his, mean_era, cnts_era
                            INIT_OUT_ARRAYS, grid, his, mean_sat, cnts_sat
                        ENDIF
                        counti++

                        ; -- lwc and iwc weighted by cc
                        INCLOUD_CALC, input, grid, cwc_inc

                        ; -- get LWP/IWP/LCOT/ICOT per layer
                        CWP_COT_PER_LAYER, input.lwc, input.iwc, input.dpres, grid, $
                                           cwp_lay, cot_lay
                        CWP_COT_PER_LAYER, cwc_inc.lwc, cwc_inc.iwc, input.dpres, grid, $
                                           cwp_lay_inc, cot_lay_inc 

                        ; -- get cloud parameters using incloud COT threshold
                        SEARCH_FOR_CLOUD, input, grid, cwp_lay, cot_lay_inc, thv.era, tmp_era
                        SEARCH_FOR_CLOUD, input, grid, cwp_lay, cot_lay_inc, thv.sat, tmp_sat

                        ; -- sum up cloud parameters
                        SUMUP_CLOUD_PARAMS, mean_era, cnts_era, tmp_era, his
                        SUMUP_CLOUD_PARAMS, mean_sat, cnts_sat, tmp_sat, his

                        ; -- count number of files
                        cnts_era.raw++
                        cnts_sat.raw++

                        ; -- delete tmp arrays
                        UNDEFINE, tmp_era, tmp_sat

                    ENDIF ;end of IF(is_file(file1))

                ;-----------------------------------------------------------------------
                ENDFOR ;end of file loop
                ;-----------------------------------------------------------------------

                ; -- calculate averages
                CALC_PARAMS_AVERAGES, mean_era, cnts_era
                CALC_PARAMS_AVERAGES, mean_sat, cnts_sat

                ; -- calculate total cwp, cot: liquid + ice
                res = CALC_TOTAL(mean_era.cwp, mean_era.lwp, mean_era.iwp, -999.)
                mean_era.cwp = res
                res = CALC_TOTAL(mean_sat.cwp, mean_sat.lwp_inc_bin, $
                                 mean_sat.iwp_inc_bin, -999.)
                mean_sat.cwp = res

                ; -- write output files
                IF KEYWORD_SET(verbose) THEN PRINT, ' * WRITE_MONTHLY_MEAN'
                WRITE_MONTHLY_MEAN, pwd.out, year, month, grid, input, thv, $
                                    mean_era, cnts_era, mean_sat, cnts_sat

                IF KEYWORD_SET(verbose) THEN PRINT, ' * WRITE_MONTHLY_HIST'
                WRITE_MONTHLY_HIST, pwd.out, year, month, grid, input, $
                                    thv, his, mean_era, mean_sat


                ; delete final arrays before next cycle starts
                UNDEFINE, mean_era, mean_sat, cnts_era, cnts_sat

            ENDIF ;end of IF(N_ELEMENTS(ff) GT 1)

           TOC, mm_clock

        ENDFOR ;end of month loop
    ENDFOR ;end of year loop

    ; End journaling:
	IF KEYWORD_SET(logfile) THEN JOURNAL

    TOC, clock
END ;end of program
