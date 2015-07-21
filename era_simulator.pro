;+
; NAME:
;   ERA_SIMULATOR_V2
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
;   era_simulator_v2
;
; MODIFICATION HISTORY:
;   Written by Dr. Martin Stengel, 2014; 
;     grid_mean arrays as output; for comparison with model results
;   C. Schlundt, Juli 2015: program modifications - subroutines added
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
PRO ERA_SIMULATOR_V2, help=help, mapdata=mapdata, verbose=verbose
;*******************************************************************************

  IF KEYWORD_SET(help) THEN BEGIN
    PRINT, ''
    PRINT,'*** era_simulator_v2'
    PRINT,'    Calculates monthly means of cloud parameters ', $
          'based on ERA-Interim reanalysis'
    PRINT, ''
    RETURN
  ENDIF
  

  ;-- input and output paths
  
  out_base = 'MM_conny_v2/'
  era_path = '/cmsaf/cmsaf-cld1/mstengel/ERA_Interim/ERA_simulator/MARS_data/ERA_simulator/'
  path_out = '/cmsaf/cmsaf-cld6/cschlund/cloud_cci/ERA_simulator/'+out_base
  

  ;-- Set list of years to be processed
  
  ;RANGE_YY = ['1979','1980',$
  ;           '1981','1982','1983','1984','1985','1986','1987','1988','1989','1990',$
  ;           '1991','1992','1993','1994','1995','1996','1997','1998','1999','2000',$
  ;           '2001','2002','2003','2004','2005','2006','2007','2008','2009','2010',$
  ;           '2011','2012','2013','2014']
  RANGE_YY = ['2008']
  nyy = N_ELEMENTS(RANGE_YY)
  

  ;-- Set list of month to be processed
  
  ;RANGE_MM = ['01','02','03','04','05','06','07','08','09','10','11','12']
  RANGE_MM = ['01']
  nmonths = N_ELEMENTS(RANGE_MM)
  

  ;-- Set cloud top pressure limits for 1D and 2D output, same as in Cloud_cci
  
  ctp_limits_final1d = [1.0, 90.0, 180.0, 245.0, 310.0, 375.0, 440.0, 500.0, $
                        560.0, 620.0, 680.0, 740.0, 800.0, 950., 1100.0]
  ctp_limits_final2d = FLTARR(2,N_ELEMENTS(ctp_limits_final1d)-1)
  
  FOR gu=0,N_ELEMENTS(ctp_limits_final2d[0,*])-1 DO BEGIN
    ctp_limits_final2d[0,gu] = ctp_limits_final1d[gu]
    ctp_limits_final2d[1,gu] = ctp_limits_final1d[gu+1]
  ENDFOR
  
  dim_ctp = N_ELEMENTS(ctp_limits_final1d)-1
  
  

  ; -- loop over years and months

  FOR ii1=0,nyy-1 DO BEGIN
    FOR jj1=0,nmonths-1 DO BEGIN
    
      year=RANGE_YY[ii1]
      month=RANGE_MM[jj1]
      
      counti=0
      

      ff=FINDFILE(era_path+year+month+'/'+'*'+year+month+'*plev')

      IF KEYWORD_SET(verbose) THEN BEGIN
          PRINT, ' *** Number of files for ', year, ' and month ', month, $
                 ' ===> ', N_ELEMENTS(ff)
      ENDIF
      

      IF(N_ELEMENTS(ff) GT 1) THEN BEGIN
      

        FOR fidx=0,N_ELEMENTS(ff)-1,1 DO BEGIN ;loop over files
        
          file0=ff[fidx]
          file1=file0+'.nc'
          
          IF(is_file(file0) AND (NOT is_file(file1))) THEN BEGIN
            PRINT,' *** converting: '+file0
            SPAWN,'cdo -f nc copy '+file0+' '+file1
          ENDIF
          

          IF(is_file(file1)) THEN BEGIN

            ; -- read netCDF file
            PRINT,' *** processing '+file1
            fileID = NCDF_OPEN(file1)
            ; pressure level [Pa]
            varID=NCDF_VARID(fileID,'lev')    & NCDF_VARGET,fileID,varID,plevel
            ; longitude
            varID=NCDF_VARID(fileID,'lon')    & NCDF_VARGET,fileID,varID,lon 
            ; latitude
            varID=NCDF_VARID(fileID,'lat')    & NCDF_VARGET,fileID,varID,lat
            ; liquid water content
            varID=NCDF_VARID(fileID,'var246') & NCDF_VARGET,fileID,varID,lwc 
            ; ice water content
            varID=NCDF_VARID(fileID,'var247') & NCDF_VARGET,fileID,varID,iwc
            ; cloud cover
            varID=NCDF_VARID(fileID,'var248') & NCDF_VARGET,fileID,varID,cc
            ; geopotential height
            varID=NCDF_VARID(fileID,'var129') & NCDF_VARGET,fileID,varID,geop
            ; temperature
            varID=NCDF_VARID(fileID,'var130') & NCDF_VARGET,fileID,varID,temp
            NCDF_CLOSE,(fileID)
            

            ; -- pressure increment between 2 layer in the atmosphere
            dpres = plevel[1:N_ELEMENTS(plevel)-1] - $
                    plevel[0:N_ELEMENTS(plevel)-2]
            

            IF(counti EQ 0) THEN BEGIN

                ; -- initialize grid
                INIT_ERA_GRID, lwc, lon, lat, $ 
                               lon2d, lat2d, xdim, ydim, zdim, verbose

                ; -- initialize mean arrays: model (era) grid means
                INIT_OUT_ARRAYS, xdim, ydim, zdim, dim_ctp, $
                                 cph_era, ctt_era, cth_era, $
                                 ctp_era, lwp_era, iwp_era, $
                                 cfc_era, ctp_hist_era, numb_era, $
                                 numb_tmp, numb_raw

                ; -- initialize mean arrays: satellite grid means
                INIT_OUT_ARRAYS, xdim, ydim, zdim, dim_ctp, $
                                 cph_sat, ctt_sat, cth_sat, $
                                 ctp_sat, lwp_sat, iwp_sat, $
                                 cfc_sat, ctp_hist_sat, numb_sat, $
                                 numb_tmp, numb_raw

            ENDIF
            counti++


            ; -- set COT thresholds
            cot_thv_era=0.01 ; model = 0.01, e.g. ERA = original input data
            cot_thv_sat=1.0  ; satellite, e.g. Cloud_cci calipso cloud mask
            crit_str='cot_thv_'+strtrim(cot_thv_sat,1)


            ; -- get liquid & ice COTs
            CWP_COT_PER_LAYER, lwc, iwc, dpres, xdim, ydim, zdim, $
                               liq_cot_lay, ice_cot_lay, $
                               lwp_lay, iwp_lay

                           
            ; -- get ERA cloud parameters using cot_thv_era
            SEARCH_FOR_CLOUD, liq_cot_lay, ice_cot_lay, cot_thv_era, $
                              xdim, ydim, zdim, geop, temp, $
                              lwp_lay, iwp_lay, plevel, cc, $
                              ctp_tmp_era, cth_tmp_era, ctt_tmp_era, $
                              cph_tmp_era, lwp_tmp_era, iwp_tmp_era, $
                              cfc_tmp_era

            ; -- get SAT cloud parameters using cot_thv_sat
            SEARCH_FOR_CLOUD, liq_cot_lay, ice_cot_lay, cot_thv_sat, $
                              xdim, ydim, zdim, geop, temp, $
                              lwp_lay, iwp_lay, plevel, cc, $
                              ctp_tmp_sat, cth_tmp_sat, ctt_tmp_sat, $
                              cph_tmp_sat, lwp_tmp_sat, iwp_tmp_sat, $
                              cfc_tmp_sat

            IF KEYWORD_SET(verbose) THEN BEGIN
              PRINT, ' *** MINMAX(SAT minus ERA):'
              PRINT, '     IWP : ', minmax(iwp_tmp_sat-iwp_tmp_era)
              PRINT, '     LWP : ', minmax(lwp_tmp_sat-lwp_tmp_era)
              PRINT, '     CFC : ', minmax(cfc_tmp_sat-cfc_tmp_era)
            ENDIF

            ; model grid means
            SUMUP_CLOUD_PARAMS, cph_era, ctt_era, cth_era, ctp_era, $
                                lwp_era, iwp_era, cfc_era, $
                                cph_tmp_era, ctt_tmp_era, cth_tmp_era, $
                                ctp_tmp_era, lwp_tmp_era, iwp_tmp_era, $
                                cfc_tmp_era, ctp_hist_era, numb_era, $
                                numb_tmp, ctp_limits_final2d, dim_ctp

            ; satellite grid means
            SUMUP_CLOUD_PARAMS, cph_sat, ctt_sat, cth_sat, ctp_sat, $
                                lwp_sat, iwp_sat, cfc_sat, $
                                cph_tmp_sat, ctt_tmp_sat, cth_tmp_sat, $
                                ctp_tmp_sat, lwp_tmp_sat, iwp_tmp_sat, $
                                cfc_tmp_sat, ctp_hist_sat, numb_sat, $
                                numb_tmp, ctp_limits_final2d, dim_ctp

            numb_raw++


            ; delete tmp arrays
            DELVAR, cph_tmp_era, ctt_tmp_era, cth_tmp_era, ctp_tmp_era, $
                    lwp_tmp_era, iwp_tmp_era, cfc_tmp_era, $
                    cph_tmp_sat, ctt_tmp_sat, cth_tmp_sat, ctp_tmp_sat, $
                    lwp_tmp_sat, iwp_tmp_sat, cfc_tmp_sat


          ENDIF ;end of IF(is_file(file1))

          IF KEYWORD_SET(verbose) THEN BEGIN
            PRINT, ' *** counti vs. numb_raw: ', counti, numb_raw
            PRINT, ' *** MINMAX(satellite grid mean):'
            PRINT, '     IWP : ', minmax(iwp_sat/numb_raw)
            PRINT, '     LWP : ', minmax(lwp_sat/numb_raw)
            PRINT, '     CFC : ', minmax(cfc_sat/numb_raw)
            PRINT, ' *** MINMAX(model grid mean):'
            PRINT, '     IWP : ', minmax(iwp_era/numb_raw)
            PRINT, '     LWP : ', minmax(lwp_era/numb_raw)
            PRINT, '     CFC : ', minmax(cfc_era/numb_raw)
            PRINT, ''
          ENDIF


        ;-----------------------------------------------------------------------
        ENDFOR ;end of file loop
        ;-----------------------------------------------------------------------


        ; model grid mean averages 
        CALC_PARAMS_AVERAGES, cph_era, ctt_era, cth_era, ctp_era, $
                              lwp_era, iwp_era, cfc_era, numb_era, numb_raw

        ; satellite grid mean averages 
        CALC_PARAMS_AVERAGES, cph_sat, ctt_sat, cth_sat, ctp_sat, $
                              lwp_sat, iwp_sat, cfc_sat, numb_sat, numb_raw


        ; visualize data
        IF KEYWORD_SET(mapdata) THEN BEGIN
            map_image, ctt_era, lat2d, lon2d, ctable=33, $
                       limit=[-90,-180,90,180], min=200, max=300
            map_image, ctt_sat, lat2d, lon2d, ctable=33, $
                       limit=[-90,-180,90,180], min=200, max=300
        ENDIF


        PRINT,' *** counti (number of files read): ', counti

        ; write monthly global mean netCDF file
        WRITE_MONTHLY_MEAN, path_out, year, month, crit_str, $
                            xdim, ydim, zdim, lon, lat, $
                            cph_era, ctt_era, cth_era, ctp_era,  $
                            lwp_era, iwp_era, cfc_era, numb_era, $
                            cph_sat, ctt_sat, cth_sat, ctp_sat,  $
                            lwp_sat, iwp_sat, cfc_sat, numb_sat

        ; write monthly histogram netCDF file
        WRITE_MONTHLY_HIST, path_out, year, month, crit_str, $
                            xdim, ydim, zdim, dim_ctp, lon, lat, $
                            ctp_limits_final1d, ctp_limits_final2d, $
                            ctp_hist_era, ctp_hist_sat


        ; delete arrays
        DELVAR, cph_era, ctt_era, cth_era, ctp_era, lwp_era, iwp_era, cfc_era,$
                cph_sat, ctt_sat, cth_sat, ctp_sat, lwp_sat, iwp_sat, cfc_sat,$
                ctp_hist_era, ctp_hist_sat


      ENDIF ;end of IF(N_ELEMENTS(ff) GT 1)

    ;---------------------------------------------------------------------------
    ENDFOR ;end of month loop
  ENDFOR ;end of year loop
  ;-----------------------------------------------------------------------------

END ;end of program
