;+
; NAME:
;   ERA_SIMULATOR
;
; PURPOSE:
;   Calculates monthly means of cloud parameters based on ERA-Interim reanalysis
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
;   era_simulator
;
; MODIFICATION HISTORY:
;   Written by Dr. Martin Stengel, 2014; 
;     grid_mean arrays as output; for comparison with model results
;   C. Schlundt, Juli 2015: program modifications - subroutines added
;   C. Schlundt, Juli 2015: incloud_mean arrays added
;                           (LWP and IWP weighted with CFC)
;
;*******************************************************************************
; Simulator NOTES:
;
; This is what I have so far implemented:
; 1)  Retrieving 6 hourly ERA-Interim analysis fields of
;     Psfc, lwc, iwc, cloud cover, geopotent. height and temperature
; 2)  Calculating LWP and IWP for each layer
; 3)  Calculating COT for each layer assuming effective radius of
;     10mic for water and 20mic for ice using inverted formula
;     we use for LWP/IWP calculation in CC4CL.
; 4)  Finding the uppermost layer for which the total (layer to TOA)
;     COT exceeds a certain threshold (e.g. 0.01, 1.0).
;     Collect CTP, CTH, CTT and liquid cloud fraction from that level.
; 5)  Adding up all layer IWP/LWP for total column IWP/LWP
; 6)  Using collected values for creating monthly means and
;     1-d histograms over all 4*30 files in a month
;
; Things to do:
; - creating monthly mean CFC from binary decision
; - same for phase;
; - calculating monthly mean LWP only over cell that
;   had liquid cloud top (vice verca for IWP)
; - …
;*******************************************************************************
PRO ERA_SIMULATOR, help=help, verbose=verbose
;*******************************************************************************

  IF KEYWORD_SET(help) THEN BEGIN
    PRINT, ''
    PRINT,'*** era_simulator_v2'
    PRINT,'    Calculates monthly means of cloud parameters ', $
          'based on ERA-Interim reanalysis'
    PRINT, ''
    RETURN
  ENDIF
  

  ; -- import settings

  CONFIG_ERA_SIMULATOR, era_path, out_path, years_list, nyears, $
                        months_list, nmonths, dim_ctp, $
                        ctp_limits_final1d, ctp_limits_final2d, $
                        cot_thv_era, cot_thv_sat, crit_str


  ; -- loop over years and months

  FOR ii1=0,nyears-1 DO BEGIN
    FOR jj1=0,nmonths-1 DO BEGIN
    
      year  = years_list[ii1]
      month = months_list[jj1]
      
      counti = 0

      ff = FINDFILE(era_path+year+month+'/'+'*'+year+month+'*plev')
      numff = N_ELEMENTS(ff)

      PRINT, ''
      PRINT, '------------------------------------------'
      PRINT, ' *** ',STRTRIM(numff,2), $
             ' Number of files for ', year, '/', month
      PRINT, '------------------------------------------'
      PRINT, ''
      

      IF(N_ELEMENTS(ff) GT 1) THEN BEGIN
      

        FOR fidx=0,N_ELEMENTS(ff)-1,1 DO BEGIN ;loop over files
        
          file0 = ff[fidx]
          file1 = file0+'.nc'
          
          IF(is_file(file0) AND (NOT is_file(file1))) THEN BEGIN
            PRINT,' *** Converting: ' + file0
            SPAWN,'cdo -f nc copy ' + file0 + ' ' + file1
          ENDIF
          

          IF(is_file(file1)) THEN BEGIN

            ; -- read netCDF file
            PRINT,' *** ',STRTRIM(counti,2),'.File: -> ',file1
            READ_ERA_NCFILE, file1, plevel, dpres, lon, lat, $
                             lwc, iwc, cc, geop, temp


            IF(counti EQ 0) THEN BEGIN

                ; -- initialize grid
                INIT_ERA_GRID, lwc, lon, lat, $ 
                               lon2d, lat2d, xdim, ydim, zdim, verbose

                ; -- initialize mean arrays

                ; model (era) GRID mean
                INIT_OUT_ARRAYS, xdim, ydim, zdim, dim_ctp, $
                                 cph_era, ctt_era, cth_era, $
                                 ctp_era, lwp_era, iwp_era, $
                                 cfc_era, ctp_hist_era, numb_era, $
                                 numb_tmp, numb_raw

                ; satellite GRID mean
                INIT_OUT_ARRAYS, xdim, ydim, zdim, dim_ctp, $
                                 cph_sat, ctt_sat, cth_sat, $
                                 ctp_sat, lwp_sat, iwp_sat, $
                                 cfc_sat, ctp_hist_sat, numb_sat, $
                                 numb_tmp, numb_raw

                ; model (era) INCLOUD mean
                INIT_OUT_ARRAYS, xdim, ydim, zdim, dim_ctp, $
                                 cph_inc_era, ctt_inc_era, cth_inc_era, $
                                 ctp_inc_era, lwp_inc_era, iwp_inc_era, $
                                 cfc_inc_era, ctp_hist_inc_era, $
                                 numb_inc_era, numb_tmp, numb_raw

                ; satellite INCLOUD means
                INIT_OUT_ARRAYS, xdim, ydim, zdim, dim_ctp, $
                                 cph_inc_sat, ctt_inc_sat, cth_inc_sat, $
                                 ctp_inc_sat, lwp_inc_sat, iwp_inc_sat, $
                                 cfc_inc_sat, ctp_hist_inc_sat, $
                                 numb_inc_sat, numb_tmp, numb_raw

            ENDIF
            counti++


            ; -- lwc and iwc weighted by cc
            INCLOUD_CALC, lwc, iwc, cc, xdim, ydim, zdim, $
                          lwc_inc, iwc_inc


            ; -- get liquid & ice COTs

            ; GRID mean
            CWP_COT_PER_LAYER, lwc, iwc, dpres, xdim, ydim, zdim, $
                               liq_cot_lay, ice_cot_lay, $
                               lwp_lay, iwp_lay

            ; INCLOUD mean
            CWP_COT_PER_LAYER, lwc_inc, iwc_inc, dpres, xdim, ydim, zdim, $
                               liq_cot_lay_inc, ice_cot_lay_inc, $
                               lwp_lay_inc, iwp_lay_inc

                           
            ; -- get cloud parameters using COT threshold

            ; model GRID mean
            SEARCH_FOR_CLOUD, liq_cot_lay, ice_cot_lay, cot_thv_era, $
                              xdim, ydim, zdim, geop, temp, $
                              lwp_lay, iwp_lay, plevel, cc, $
                              ctp_tmp_era, cth_tmp_era, ctt_tmp_era, $
                              cph_tmp_era, lwp_tmp_era, iwp_tmp_era, $
                              cfc_tmp_era

            ; satellite GRID mean
            SEARCH_FOR_CLOUD, liq_cot_lay, ice_cot_lay, cot_thv_sat, $
                              xdim, ydim, zdim, geop, temp, $
                              lwp_lay, iwp_lay, plevel, cc, $
                              ctp_tmp_sat, cth_tmp_sat, ctt_tmp_sat, $
                              cph_tmp_sat, lwp_tmp_sat, iwp_tmp_sat, $
                              cfc_tmp_sat

            ; model INCLOUD mean
            SEARCH_FOR_CLOUD, liq_cot_lay_inc, ice_cot_lay_inc, cot_thv_era, $
                              xdim, ydim, zdim, geop, temp, $
                              lwp_lay_inc, iwp_lay_inc, plevel, cc, $
                              ctp_tmp_inc_era, cth_tmp_inc_era, ctt_tmp_inc_era, $
                              cph_tmp_inc_era, lwp_tmp_inc_era, iwp_tmp_inc_era, $
                              cfc_tmp_inc_era

            ; satellite INCLOUD mean
            SEARCH_FOR_CLOUD, liq_cot_lay_inc, ice_cot_lay_inc, cot_thv_sat, $
                              xdim, ydim, zdim, geop, temp, $
                              lwp_lay_inc, iwp_lay_inc, plevel, cc, $
                              ctp_tmp_inc_sat, cth_tmp_inc_sat, ctt_tmp_inc_sat, $
                              cph_tmp_inc_sat, lwp_tmp_inc_sat, iwp_tmp_inc_sat, $
                              cfc_tmp_inc_sat


            ;IF KEYWORD_SET(verbose) THEN BEGIN
            ;  PRINT, ' *** GRID mean MINMAX( SAT minus ERA ):'
            ;  PRINT, '     IWP : ', minmax(iwp_tmp_sat-iwp_tmp_era)
            ;  PRINT, '     LWP : ', minmax(lwp_tmp_sat-lwp_tmp_era)
            ;  PRINT, '     CFC : ', minmax(cfc_tmp_sat-cfc_tmp_era)
            ;  PRINT, ' *** INCLOUD mean MINMAX( SAT minus ERA ):'
            ;  PRINT, '     IWP : ', minmax(iwp_tmp_inc_sat-iwp_tmp_inc_era)
            ;  PRINT, '     LWP : ', minmax(lwp_tmp_inc_sat-lwp_tmp_inc_era)
            ;  PRINT, '     CFC : ', minmax(cfc_tmp_inc_sat-cfc_tmp_inc_era)
            ;ENDIF


            ; -- sum up cloud parameters

            ; model GRID mean
            SUMUP_CLOUD_PARAMS, cph_era, ctt_era, cth_era, ctp_era, $
                                lwp_era, iwp_era, cfc_era, $
                                cph_tmp_era, ctt_tmp_era, cth_tmp_era, $
                                ctp_tmp_era, lwp_tmp_era, iwp_tmp_era, $
                                cfc_tmp_era, ctp_hist_era, numb_era, $
                                numb_tmp, ctp_limits_final2d, dim_ctp

            ; satellite GRID mean
            SUMUP_CLOUD_PARAMS, cph_sat, ctt_sat, cth_sat, ctp_sat, $
                                lwp_sat, iwp_sat, cfc_sat, $
                                cph_tmp_sat, ctt_tmp_sat, cth_tmp_sat, $
                                ctp_tmp_sat, lwp_tmp_sat, iwp_tmp_sat, $
                                cfc_tmp_sat, ctp_hist_sat, numb_sat, $
                                numb_tmp, ctp_limits_final2d, dim_ctp

            ; model INCLOUD mean
            SUMUP_CLOUD_PARAMS, cph_inc_era, ctt_inc_era, cth_inc_era, ctp_inc_era, $
                                lwp_inc_era, iwp_inc_era, cfc_inc_era, $
                                cph_tmp_inc_era, ctt_tmp_inc_era, cth_tmp_inc_era, $
                                ctp_tmp_inc_era, lwp_tmp_inc_era, iwp_tmp_inc_era, $
                                cfc_tmp_inc_era, ctp_hist_inc_era, numb_inc_era, $
                                numb_tmp, ctp_limits_final2d, dim_ctp

            ; satellite INCLOUD mean
            SUMUP_CLOUD_PARAMS, cph_inc_sat, ctt_inc_sat, cth_inc_sat, ctp_inc_sat, $
                                lwp_inc_sat, iwp_inc_sat, cfc_inc_sat, $
                                cph_tmp_inc_sat, ctt_tmp_inc_sat, cth_tmp_inc_sat, $
                                ctp_tmp_inc_sat, lwp_tmp_inc_sat, iwp_tmp_inc_sat, $
                                cfc_tmp_inc_sat, ctp_hist_inc_sat, numb_inc_sat, $
                                numb_tmp, ctp_limits_final2d, dim_ctp


            numb_raw++


            ; delete tmp arrays
            DELVAR, cph_tmp_era, ctt_tmp_era, cth_tmp_era, ctp_tmp_era, $
                    lwp_tmp_era, iwp_tmp_era, cfc_tmp_era, $
                    cph_tmp_sat, ctt_tmp_sat, cth_tmp_sat, ctp_tmp_sat, $
                    lwp_tmp_sat, iwp_tmp_sat, cfc_tmp_sat, $ 
                    cph_tmp_inc_era, ctt_tmp_inc_era, cth_tmp_inc_era, $ 
                    ctp_tmp_inc_era, lwp_tmp_inc_era, iwp_tmp_inc_era, $ 
                    cfc_tmp_inc_era, $ 
                    cph_tmp_inc_sat, ctt_tmp_inc_sat, cth_tmp_inc_sat, $ 
                    ctp_tmp_inc_sat, lwp_tmp_inc_sat, iwp_tmp_inc_sat, $ 
                    cfc_tmp_inc_sat


          ENDIF ;end of IF(is_file(file1))


          IF KEYWORD_SET(verbose) THEN BEGIN
            PRINT, ' *** MINMAX( grid mean ) ********************'
            PRINT, '     IWP Sat: ', minmax(iwp_sat/numb_raw)
            PRINT, '     LWP Sat: ', minmax(lwp_sat/numb_raw)
            PRINT, '     CFC Sat: ', minmax(cfc_sat/numb_raw)
            PRINT, '     ----------------------------------------'
            PRINT, '     IWP Era: ', minmax(iwp_era/numb_raw)
            PRINT, '     LWP Era: ', minmax(lwp_era/numb_raw)
            PRINT, '     CFC Era: ', minmax(cfc_era/numb_raw)
            PRINT, ' *** MINMAX( incloud mean ) *****************'
            PRINT, '     IWP Sat: ', minmax(iwp_inc_sat/numb_raw)
            PRINT, '     LWP Sat: ', minmax(lwp_inc_sat/numb_raw)
            PRINT, '     CFC Sat: ', minmax(cfc_inc_sat/numb_raw)
            PRINT, '     ----------------------------------------'
            PRINT, '     IWP Era: ', minmax(iwp_inc_era/numb_raw)
            PRINT, '     LWP Era: ', minmax(lwp_inc_era/numb_raw)
            PRINT, '     CFC Era: ', minmax(cfc_inc_era/numb_raw)
            PRINT, ''
          ENDIF


        ;-----------------------------------------------------------------------
        ENDFOR ;end of file loop
        ;-----------------------------------------------------------------------

        ; -- calculate averages

        ; model GRID mean 
        CALC_PARAMS_AVERAGES, cph_era, ctt_era, cth_era, ctp_era, $
                              lwp_era, iwp_era, cfc_era, numb_era, numb_raw

        ; satellite GRID mean 
        CALC_PARAMS_AVERAGES, cph_sat, ctt_sat, cth_sat, ctp_sat, $
                              lwp_sat, iwp_sat, cfc_sat, numb_sat, numb_raw

        ; model INCLOUD mean 
        CALC_PARAMS_AVERAGES, cph_inc_era, ctt_inc_era, cth_inc_era, ctp_inc_era, $
                              lwp_inc_era, iwp_inc_era, cfc_inc_era, numb_inc_era, $
                              numb_raw

        ; satellite INCLOUD mean 
        CALC_PARAMS_AVERAGES, cph_inc_sat, ctt_inc_sat, cth_inc_sat, ctp_inc_sat, $
                              lwp_inc_sat, iwp_inc_sat, cfc_inc_sat, numb_inc_sat, $
                              numb_raw


        PRINT,' *** counti (number of files read): ', counti

        ; write monthly global mean netCDF file
        WRITE_MONTHLY_MEAN, out_path, year, month, crit_str, $
                            xdim, ydim, zdim, lon, lat, $
                            cph_era, ctt_era, cth_era, ctp_era,  $
                            lwp_era, iwp_era, cfc_era, numb_era, $
                            cph_sat, ctt_sat, cth_sat, ctp_sat,  $
                            lwp_sat, iwp_sat, cfc_sat, numb_sat, $
                            cph_inc_era, ctt_inc_era, cth_inc_era, $
                            ctp_inc_era, lwp_inc_era, iwp_inc_era, $
                            cfc_inc_era, numb_inc_era, $
                            cph_inc_sat, ctt_inc_sat, cth_inc_sat, $
                            ctp_inc_sat, lwp_inc_sat, iwp_inc_sat, $
                            cfc_inc_sat, numb_inc_sat

        ; write monthly histogram netCDF file
        WRITE_MONTHLY_HIST, out_path, year, month, crit_str, $
                            xdim, ydim, zdim, dim_ctp, lon, lat, $
                            ctp_limits_final1d, ctp_limits_final2d, $
                            ctp_hist_era, ctp_hist_sat, $
                            ctp_hist_inc_era, ctp_hist_inc_sat


        ; delete final arrays before next cycle starts
        DELVAR, cph_era, ctt_era, cth_era, ctp_era, $
                lwp_era, iwp_era, cfc_era,$
                cph_sat, ctt_sat, cth_sat, ctp_sat, $
                lwp_sat, iwp_sat, cfc_sat,$
                ctp_hist_era, ctp_hist_sat, $
                cph_inc_era, ctt_inc_era, cth_inc_era, $
                ctp_inc_era, lwp_inc_era, iwp_inc_era, $
                cfc_inc_era, numb_inc_era, $
                cph_inc_sat, ctt_inc_sat, cth_inc_sat, $
                ctp_inc_sat, lwp_inc_sat, iwp_inc_sat, $
                cfc_inc_sat, numb_inc_sat, $
                ctp_hist_inc_era, ctp_hist_inc_sat, $
                numb_tmp, numb_raw, counti


      ENDIF ;end of IF(N_ELEMENTS(ff) GT 1)

    ;---------------------------------------------------------------------------
    ENDFOR ;end of month loop
  ENDFOR ;end of year loop
  ;-----------------------------------------------------------------------------

END ;end of program
