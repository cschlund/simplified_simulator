@/home/cschlund/Programme/idl/vali_gui_rv/vali_pre_compile.pro
@/home/cschlund/Programme/idl/simplified_simulator/pre_compile.pro
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
;   C. Schlundt, Jan 2016: implementation of ireff, lreff as func(T,IWC/LWC)
;   C. Schlundt, Jan 2016: implementation of hist1d_ref
;   C. Schlundt, Jan 2016: quite a bunch of code improvements
;
; ToDo:
;       (1) cloud overlap
;
;*******************************************************************************
PRO CLOUDCCI_SIMULATOR, VERBOSE=verbose, LOGFILE=logfile, TEST=test, MAP=map, $
                        FIXED_REFFS=fixed_reffs, HPLOT=hplot, HELP=help
;*******************************************************************************
    clock = TIC('TOTAL')

    IF KEYWORD_SET(help) THEN BEGIN
        PRINT, ""
        PRINT, " *** THIS PROGRAM READS ERA-INTERIM REANALYSIS FILES AND",$
               " SIMULATES CLOUD_CCI CLOUD PARAMETERS ***"
        PRINT, ""
        PRINT, " Please, first copy the cfg template to config_simulator.pro",$
               " and modify the settings for your needs."
        PRINT, ""
        PRINT, " USAGE: CLOUDCCI_SIMULATOR"
        PRINT, " USAGE: CLOUDCCI_SIMULATOR, /test, /log, /ver"
        PRINT, ""
        PRINT, " Optional Keywords:"
        PRINT, " FIXED_REFFS    using constant eff. radii for COT calculation."
        PRINT, " VERBOSE        increase output verbosity."
        PRINT, " LOGFILE        creates journal logfile."
        PRINT, " TEST           output based on the first day only."
        PRINT, " MAP            creates some intermediate results."
        PRINT, " HPLOT          creates HISTOS_1D plots of final HIST results."
        PRINT, " HELP           prints this message."
        PRINT, ""
        RETURN
    ENDIF


    IF KEYWORD_SET(verbose) THEN PRINT, '** Import user setttings'
    CONFIG_SIMULATOR, pwd, tim, thv, his, reff


    DEFSYSV, '!SAVE_DIR', pwd.FIG


    IF KEYWORD_SET(logfile) THEN $
        JOURNAL, pwd.out + 'journal_' + thv.str + cgTimeStamp() + '.pro'


    IF KEYWORD_SET(test) THEN BEGIN
        pwd.inp = '/data/cschlund/MARS_data/ERA_simulator_testdata/'
        pwd.out = pwd.out + 'testrun/'
        validres = VALID_DIR( pwd.out)
        IF(validres EQ 0) THEN creatres = CREATE_DIR( pwd.out )
    ENDIF


    IF KEYWORD_SET(verbose) THEN BEGIN
        PRINT, FORMAT='(A, A-100)', '** INP:     ', pwd.INP
        PRINT, FORMAT='(A, A-100)', '** OUT:     ', pwd.OUT
        PRINT, FORMAT='(A, A-100)', '** FIG:     ', pwd.FIG
        PRINT, FORMAT='(A, F8.3)', '** ERA-thv: ', thv.ERA
        PRINT, FORMAT='(A, F8.3)', '** SAT-thv: ', thv.SAT
        PRINT, FORMAT='(A, A)', '** STR-thv: ', thv.STR
    ENDIF

    IF KEYWORD_SET(fixed_reffs) THEN BEGIN 
        mess = "** CWP & COT based on FIXED reffs [um]"
        fmt = '(A, " ! ", "reff_water =", F5.1, "; reff_ice =", F5.1)'
        PRINT, FORMAT=fmt, mess, [reff.water, reff.ice]
    ENDIF ELSE BEGIN
        mess = "** CWP & COT based on ERA-I: reffs(T,CWC) [um]"
        PRINT, FORMAT='(A, " ! ")', mess
    ENDELSE


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
            PRINT, ''

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
                        PRINT, '** ',strcnt,'.LOADED: ', input.file 

                        ; -- initialize grid and arrays for monthly mean output:
                        IF(counti EQ 0) THEN BEGIN
                            INIT_ERA_GRID, input, grid 
                            READ_ERA_SSTFILE, pwd.SST, grid, sst, void, map=map
                            lsm2d = INIT_LSM_ARRAY( grid, sst, void, map=map )
                            INIT_OUT_ARRAYS, grid, his, mean_era, cnts_era
                            INIT_OUT_ARRAYS, grid, his, mean_sat, cnts_sat
                        ENDIF
                        counti++

                        ; -- initialize solar zenith angle 2D array
                        pfil = file1
                        sza2d = INIT_SZA_ARRAY( pfil, grid, map=map )

                        ; -- lwc and iwc weighted by cc
                        CWC_INCLOUD, input, grid, cwc_inc

                        ;; -- grid mean per layer
                        ;CALC_CLD_VARS, LWC=input.lwc, IWC=input.iwc, $
                        ;               INPUT=input, GRID=grid, LSM=lsm2d, REFF=reff, $
                        ;               FIXED_REFFS=fixed_reffs, VERBOSE=verbose, $
                        ;               CWP=cwp_lay, COT=cot_lay, CER=cer_lay

                        ; -- in-cloud per layer based on L(I)WC[z]/CC[z]
                        CALC_CLD_VARS, LWC=cwc_inc.lwc, IWC=cwc_inc.iwc, $
                                       INPUT=input, GRID=grid, LSM=lsm2d, REFF=reff, $
                                       FIXED_REFFS=fixed_reffs, VERBOSE=verbose, $
                                       CWP=cwp_lay_inc, COT=cot_lay_inc, $
                                       CER=cer_lay_inc

                        ; -- search for upper-most cloud layer
                        SEARCH4CLOUD, INPUT=input, GRID=grid, CWP=cwp_lay_inc, $
                                      COT=cot_lay_inc, CER=cer_lay_inc, $
                                      FLAG='ori', THRESHOLD=thv.era, TEMP=tmp_era

                        SEARCH4CLOUD, INPUT=input, GRID=grid, CWP=cwp_lay_inc, $
                                      COT=cot_lay_inc, CER=cer_lay_inc, $
                                      FLAG='sat', THRESHOLD=thv.sat, TEMP=tmp_sat

                        ; -- scale COT and thus CWP like in CC4CL for tmp_sat only
                        SCALE_COT_CWP, tmp_sat, grid

                        ; -- sunlit region only for COT & CWP & CER
                        pf = file1
                        SOLAR_VARS, tmp_sat, sza2d, grid, pf, map=map

                        ; -- sum up cloud parameters
                        SUMUP_VARS, 'ori', mean_era, cnts_era, tmp_era, his
                        SUMUP_VARS, 'sat', mean_sat, cnts_sat, tmp_sat, his

                        ; -- check intermediate results: current_time_slot
                        IF KEYWORD_SET(map) THEN BEGIN
                            PLOT_INTER_HISTOS, VARNAME='cot', INTER=tmp_sat, $ 
                                HISINFO=his, OFILE=file1, FIXED_REFFS=fixed_reffs
                            PLOT_INTER_HISTOS, VARNAME='cer', INTER=tmp_sat, $ 
                                HISINFO=his, OFILE=file1, FIXED_REFFS=fixed_reffs
                            PLOT_HISTOS_1D, FINAL=mean_sat, HISINFO=his, $
                                OFILE=file1, FIXED_REFFS=fixed_reffs
                        ENDIF

                        ; -- count number of files
                        cnts_era.raw++
                        cnts_sat.raw++

                        ; -- delete tmp arrays
                        UNDEFINE, sza2d, tmp_era, tmp_sat
                        UNDEFINE, cwp_lay, cot_lay, cer_lay
                        UNDEFINE, cwp_lay_inc, cot_lay_inc, cer_lay_inc

                    ENDIF ;end of IF(is_file(file1))

                ;---------------------------------------------------------------
                ENDFOR ;end of file loop
                ;---------------------------------------------------------------

                ; -- calculate averages
                MEAN_VARS, mean_era, cnts_era
                MEAN_VARS, mean_sat, cnts_sat

                ; -- plot final hist1d results: ctp, cwp, cer, cot
                IF KEYWORD_SET(hplot) THEN BEGIN 
                    ofile = 'ERA_Interim_'+year+month
                    PLOT_HISTOS_1D, FINAL=mean_sat, HISINFO=his, $
                        OFILE=ofile, FIXED_REFFS=fixed_reffs
                ENDIF

                ; -- write output files
                WRITE_MONTHLY_MEAN, pwd.out, year, month, grid, input, thv, $
                                    his, mean_era, cnts_era, mean_sat, cnts_sat

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
