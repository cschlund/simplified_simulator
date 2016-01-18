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
;   C. Schlundt, Jan 2016: clean up code
;   C. Schlundt, Jan 2016: scops-like method for COT2d & CWP2d
;
;******************************************************************************
PRO CLOUDCCI_SIMULATOR, VERBOSE=verbose, LOGFILE=logfile, TEST=test, MAP=map, $
                        SYEAR=syear, EYEAR=eyear, $
                        SMONTH=smonth, EMONTH=emonth, $
                        RATIO=ratio, $
                        CONSTANT_CER=constant_cer, HPLOT=hplot, HELP=help
;******************************************************************************
    clock = TIC('TOTAL')

    IF KEYWORD_SET(help) THEN BEGIN
        PRINT, ""
        PRINT, " *** THIS PROGRAM READS ERA-INTERIM REANALYSIS FILES AND",$
               " SIMULATES CLOUD_CCI CLOUD PARAMETERS ***"
        PRINT, ""
        PRINT, " Please, first copy the ""config_simulator.pro.template"" to",$
               " ""config_simulator.pro"" and modify the settings for your needs."
        PRINT, ""
        PRINT, " USAGE: "
        PRINT, " CLOUDCCI_SIMULATOR, /test, /log, /ver, /map, /hplot"
        PRINT, " CLOUDCCI_SIMULATOR, sy=2008, sm=7"
        PRINT, " CLOUDCCI_SIMULATOR, sy=1979, ey=2014, sm=1, em=12"
        PRINT, ""
        PRINT, " Optional Keywords:"
        PRINT, " SYEAR          start year, which should be processed."
        PRINT, " EYEAR          end year."
        PRINT, " SMONTH         start month."
        PRINT, " EMONTH         end month."
        PRINT, " CONSTANT_CER   using constant eff. radii for COT calculation."
        PRINT, " VERBOSE        increase output verbosity."
        PRINT, " LOGFILE        creates journal logfile."
        PRINT, " TEST           output based on the first day only."
        PRINT, " MAP            creates some intermediate results."
        PRINT, " HPLOT          creates HISTOS_1D plots of final HIST results."
        PRINT, " RATIO          adds liquid cloud fraction to HIST1D plot."
        PRINT, " HELP           prints this message."
        PRINT, ""
        RETURN
    ENDIF

    IF KEYWORD_SET(verbose) THEN PRINT, '** Import user setttings'

    CONFIG_SIMULATOR, PATHS=path, TIMES=times, THRESHOLDS=thv, $
                      SYEAR=syear, EYEAR=eyear, $
                      SMONTH=smonth, EMONTH=emonth, $
                      HIST_INFO=his, CER_INFO=cer_info, TEST=test

    ;!EXCEPT=0 ; silence
    !EXCEPT=2 ; detects errors/warnings
    DEFSYSV, '!SAVE_DIR', path.FIG

    IF KEYWORD_SET(logfile) THEN $
        JOURNAL, path.out + 'journal_' + thv.MAX_STR + cgTimeStamp() + '.pro'


    IF KEYWORD_SET(verbose) THEN BEGIN
        PRINT, FORMAT='(A, A-100)', '** INP:     ', path.INP
        PRINT, FORMAT='(A, A-100)', '** OUT:     ', path.OUT
        PRINT, FORMAT='(A, A-100)', '** FIG:     ', path.FIG
        PRINT, FORMAT='(A, F8.3)',  '** MIN-thv: ', thv.MIN
        PRINT, FORMAT='(A, F8.3)',  '** MAX-thv: ', thv.MAX
    ENDIF

    IF KEYWORD_SET(constant_cer) THEN BEGIN 
        mess = "** CWP & COT based on FIXED CER [um]"
        fmt = '(A, " ! ", "cer_water =", F5.1, "; cer_ice =", F5.1)'
        PRINT, FORMAT=fmt, mess, [cer_info.water, cer_info.ice]
    ENDIF ELSE BEGIN
        mess = "** CWP & COT based on ERA-I: CER(T,CWC) [um]"
        PRINT, FORMAT='(A, " ! ")', mess
    ENDELSE


    ; loop over years and months
    FOR ii1=0, times.NY-1 DO BEGIN
        FOR jj1=0, times.NM-1 DO BEGIN

            year  = times.YEARS[ii1]
            month = times.MONTHS[jj1]
            mm_clock = TIC(year+'/'+month)
            counti = 0

            ff = FINDFILE(path.inp+year+month+'/'+'*'+year+month+'*plev')

            numff = N_ELEMENTS(ff)
            strff = STRTRIM(numff,2)
            strym = STRING(year) + '/' + STRING(month)

            PRINT, '** ', strff, ' ERA-Interim InputFiles for ', strym

            IF(N_ELEMENTS(ff) GT 1) THEN BEGIN

                ;--------------------------------------------------------------
                FOR fidx=0,N_ELEMENTS(ff)-1,1 DO BEGIN ;loop over files
                ;--------------------------------------------------------------

                    file0 = ff[fidx]
                    file1 = file0+'.nc'

                    IF(is_file(file0) AND (NOT is_file(file1))) THEN BEGIN
                        PRINT,'** Converting: ' + file0
                        SPAWN,'cdo -f nc copy ' + file0 + ' ' + file1
                    ENDIF

                    IF(is_file(file1)) THEN BEGIN

                        READ_ERA_NCFILE, file1, input

                        PRINT, '** ',STRTRIM(counti+1,2),'. ',input.FILE

                        IF(counti EQ 0) THEN BEGIN

                            INIT_ERA_GRID, input, grid 
                            READ_ERA_SSTFILE, path.SST, grid, sst, void, MAP=map
                            lsm2d = INIT_LSM_ARRAY(grid, sst, void, MAP=map)

                            ; cnt* = counters required for calc. the means
                            ; *min = applying thv.MIN, e.g. 0.01
                            ; *max = applying thv.MAX, e.g. 0.30
                            INIT_OUT_ARRAYS, grid, his, arr_min, cnt_min
                            INIT_OUT_ARRAYS, grid, his, arr_max, cnt_max

                        ENDIF
                        counti++

                        ; initialize solar zenith angle 2D array
                        sza2d = INIT_SZA_ARRAY(input, grid, MAP=map)

                        ; lwc and iwc weighted by cc
                        incloud = CALC_INCLOUD_CWC( input, grid )

                        ; calculate: CWP/COT/CER per layer based in incloud CWC
                        CALC_CLD_VARS, incloud.LWC, incloud.IWC, $
                                       input, grid, lsm2d, cer_info, $
                                       cwp_lay, cot_lay, cer_lay, $
                                       CONSTANT_CER=constant_cer, $
                                       VERBOSE=verbose

                        ; search for upper-most cloud layer for 
                        ; cot_thv.MIN
                        tmp_min = SEARCH4CLOUD( input, grid, cwp_lay, $
                                                cot_lay, cer_lay, thv.MIN )
                        ; cot_thv.MAX
                        tmp_max = SEARCH4CLOUD( input, grid, cwp_lay, $
                                                cot_lay, cer_lay, thv.MAX )

                        ; scale cot & cwp as it is done in Cloud_cci
                        SCALE_COT_CWP, tmp_min, grid
                        SCALE_COT_CWP, tmp_max, grid

                        ; sunlit region only for COT & CWP & CER
                        SOLAR_VARS, tmp_min, sza2d, grid, $
                                    FLAG=thv.MIN_STR, FILE=file1, MAP=map
                        SOLAR_VARS, tmp_max, sza2d, grid, $
                                    FLAG=thv.MAX_STR, FILE=file1, MAP=map

                        ; sum up cloud parameters
                        SUMUP_VARS, arr_min, cnt_min, tmp_min, his
                        SUMUP_VARS, arr_max, cnt_max, tmp_max, his

                        ; check intermediate results: current_time_slot
                        IF KEYWORD_SET(map) THEN BEGIN
                            varnames = ['ctt','cwp','ctp','cot','cer']
                            FOR v=0, N_ELEMENTS(varnames)-1 DO BEGIN
                                PLOT_INTER_HISTOS, tmp_max, varnames[v], $
                                                   his, file1, thv.MAX_STR, $ 
                                                   CONSTANT_CER=constant_cer,$
                                                   RATIO=ratio
                            ENDFOR
                        ENDIF

                        ; count number of files
                        cnt_min.raw++
                        cnt_max.raw++

                        ; delete tmp arrays
                        UNDEFINE, sza2d, tmp_min, tmp_max
                        UNDEFINE, cwp_lay, cot_lay, cer_lay

                    ENDIF ;end of IF(is_file(file1))

                ;--------------------------------------------------------------
                ENDFOR ;end of file loop
                ;--------------------------------------------------------------

                ; calculate averages
                MEAN_VARS, arr_min, cnt_min
                MEAN_VARS, arr_max, cnt_max

                ; plot final hist1d results: ctp, cwp, cer, cot
                IF KEYWORD_SET(hplot) THEN BEGIN 
                    ofile = 'ERA_Interim_'+year+month
                    PLOT_HISTOS_1D, arr_min, ofile, thv.MIN_STR, $
                                    CONSTANT_CER=constant_cer, RATIO=ratio
                    PLOT_HISTOS_1D, arr_max, ofile, thv.MAX_STR, $
                                    CONSTANT_CER=constant_cer, RATIO=ratio
                ENDIF

                ; write output files
                WRITE_MONTHLY_MEAN, path.out, year, month, grid, input, his, $
                                    thv.MIN_STR, thv.MIN, arr_min, cnt_min 
                WRITE_MONTHLY_MEAN, path.out, year, month, grid, input, his, $
                                    thv.MAX_STR, thv.MAX, arr_max, cnt_max 

                ; delete final arrays before next cycle starts
                UNDEFINE, arr_min, arr_max, cnt_min, cnt_max

            ENDIF ;end of IF(N_ELEMENTS(ff) GT 1)

           TOC, mm_clock

        ENDFOR ;end of month loop
    ENDFOR ;end of year loop

    ; End journaling:
    IF KEYWORD_SET(logfile) THEN JOURNAL

    TOC, clock

;******************************************************************************
END ;end of program
;******************************************************************************
