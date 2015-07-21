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
;   Written by Dr. Martin Stengel, 2014
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
    PRINT,'*** era_simulator'
    PRINT,'    Calculates monthly means of cloud parameters based on ERA-Interim reanalysis'
    PRINT, ''
    RETURN
  ENDIF
  
  ;-----------------------------------------------------------------------------
  ;-- input and output paths
  ;-----------------------------------------------------------------------------
  
  out_base = 'MM_martin_v1.1/'
  era_path = '/cmsaf/cmsaf-cld1/mstengel/ERA_Interim/ERA_simulator/MARS_data/ERA_simulator/'
  ;path_out = '/cmsaf/cmsaf-cld1/mstengel/ERA_Interim/ERA_simulator/MM2/'
  path_out = '/cmsaf/cmsaf-cld6/cschlund/cloud_cci/ERA_simulator/'+out_base
  
  ;-----------------------------------------------------------------------------
  ;-- Set list of years to be processed
  ;-----------------------------------------------------------------------------
  
  ;RANGE_YY=['1979','1980',$
  ;          '1981','1982','1983','1984','1985','1986','1987','1988','1989','1990',$
  ;          '1991','1992','1993','1994','1995','1996','1997','1998','1999','2000',$
  ;          '2001','2002','2003','2004','2005','2006','2007','2008','2009','2010',$
  ;          '2011','2012','2013','2014']
  RANGE_YY=['2008']
  nyy=n_elements(RANGE_YY)
  
  ;-----------------------------------------------------------------------------
  ;-- Set list of month to be processed
  ;-----------------------------------------------------------------------------
  
  ; RANGE_MM=['01','02','03','04','05','06','07','08','09','10','11','12']
  RANGE_MM=['01']
  nmonths=n_elements(RANGE_MM)
  
  ;-----------------------------------------------------------------------------
  ;-- Set cloud top pressure limits for 1D and 2D output, same as in Cloud_cci
  ;-----------------------------------------------------------------------------
  
  ctp_limits_final1d=[ 1.0, 90.0, 180.0, 245.0, 310.0, 375.0, 440.0, 500.0, $
    560.0, 620.0, 680.0, 740.0, 800.0, 950., 1100.0]
  ctp_limits_final2d=fltarr(2,n_elements(ctp_limits_final1d)-1)
  
  FOR gu=0,n_elements(ctp_limits_final2d[0,*])-1 DO BEGIN
    ctp_limits_final2d[0,gu]=ctp_limits_final1d[gu]
    ctp_limits_final2d[1,gu]=ctp_limits_final1d[gu+1]
  ENDFOR
  
  dim_ctp=n_elements(ctp_limits_final1d)-1
  
  
  ;-----------------------------------------------------------------------------
  ;-- loop over years and months
  ;-----------------------------------------------------------------------------
  
  FOR ii1=0,nyy-1 DO BEGIN
    FOR jj1=0,nmonths-1 DO BEGIN
    
      year=RANGE_YY[ii1]
      month=RANGE_MM[jj1]
      
      counti=0
      
      ff=findfile(era_path+year+month+'/'+'*'+year+month+'*plev')
      help, ff
      
      IF(n_elements(ff) GT 1) THEN BEGIN
      
        ;-----------------------------------------------------------------------
        ;loop over files
        ;-----------------------------------------------------------------------
        
        FOR fidx=0,n_elements(ff)-1,1 DO BEGIN
        
          file0=ff[fidx]
          file1=file0+'.nc'
          
          IF(is_file(file0) AND (NOT is_file(file1))) THEN BEGIN
            PRINT,'converting: '+file0
            SPAWN,'cdo -f nc copy '+file0+' '+file1
          ENDIF
          
          IF(is_file(file1)) THEN BEGIN
            PRINT,'processing '+file1
            fileID = ncdf_open(file1)
            varID=ncdf_varid(fileID,'lev') & ncdf_varget,fileID,varID,plevel  ;pressure level [Pa]
            varID=ncdf_varid(fileID,'lon') & ncdf_varget,fileID,varID,lon     ;longitude
            varID=ncdf_varid(fileID,'lat') & ncdf_varget,fileID,varID,lat     ;latitude
            varID=ncdf_varid(fileID,'var246') & ncdf_varget,fileID,varID,lwc  ;clwc	kg kg**-1
            varID=ncdf_varid(fileID,'var247') & ncdf_varget,fileID,varID,iwc  ;ciwc	kg kg**-1
            varID=ncdf_varid(fileID,'var248') & ncdf_varget,fileID,varID,cc   ;cloud cover
            varID=ncdf_varid(fileID,'var129') & ncdf_varget,fileID,varID,geop ;geopotential height
            varID=ncdf_varid(fileID,'var130') & ncdf_varget,fileID,varID,temp ;temperature
            ncdf_close,(fileID)
            
            ; pressure increment between 2 layer in the atmosphere
            dpres=plevel[1:n_elements(plevel)-1]-plevel[0:n_elements(plevel)-2]
            ; PLEVEL DOUBLE = Array[37]
            ; DPRES  DOUBLE = Array[36]
            
            IF(counti EQ 0) THEN BEGIN
            
              ; set x,y,z dimensions using liquid water content variable
              xdim=n_elements(lwc[*,0,0])
              ydim=n_elements(lwc[0,*,0])
              zdim=n_elements(lwc[0,0,*])
              
              ; define longitude & latitude arrays
              ; [cols, rows]
              lon2d=fltarr(xdim,ydim)
              lat2d=fltarr(xdim,ydim)
              ; LON2D FLOAT = Array[720, 361]
              ; LAT2D FLOAT = Array[720, 361]
              
              ; create lat/lon grid arrays using lon & lat from ncfile
              ; lat[-90;90]
              ; lon[0;359.5] or lon[-180;179.5]
              FOR loi=0,xdim-1 DO lon2d[loi,*]=lon[loi]-180.
              FOR lai=0,ydim-1 DO lat2d[*,lai]=lat[lai]
              
              ; -- temporary arrays --
              
              ; cloud top pressure, height, temperature
              ctp_tmp=fltarr(xdim,ydim)
              cth_tmp=fltarr(xdim,ydim)
              ctt_tmp=fltarr(xdim,ydim)
              ctp_tmp_cot=fltarr(xdim,ydim)
              cth_tmp_cot=fltarr(xdim,ydim)
              ctt_tmp_cot=fltarr(xdim,ydim)
              
              ; layer liquid,ice water path
              lwp_lay_tmp=fltarr(xdim,ydim)
              iwp_lay_tmp=fltarr(xdim,ydim)
              lwp_tmp=fltarr(xdim,ydim)
              iwp_tmp=fltarr(xdim,ydim)
              lwp_tmp_cot=fltarr(xdim,ydim)
              iwp_tmp_cot=fltarr(xdim,ydim)
              
              ; cloud phase
              cph_tmp=fltarr(xdim,ydim)
              cph_tmp_cot=fltarr(xdim,ydim)
              
              ; cloud fraction
              cfc_tmp=fltarr(xdim,ydim)
              cfc_tmp_cot=fltarr(xdim,ydim)
              
              ; 1d parameters (monthly means)
              cfc_mean=fltarr(xdim,ydim)
              cfc_mean[*,*]=0.
              cfc_mean_cot=fltarr(xdim,ydim)
              cfc_mean_cot[*,*]=0.
              ctt_mean=fltarr(xdim,ydim)
              ctt_mean[*,*]=0.
              cth_mean=fltarr(xdim,ydim)
              cth_mean[*,*]=0.
              ctp_mean=fltarr(xdim,ydim)
              ctp_mean[*,*]=0.
              lwp_mean=fltarr(xdim,ydim)
              lwp_mean[*,*]=0.
              iwp_mean=fltarr(xdim,ydim)
              iwp_mean[*,*]=0.
              ctt_mean_cot=fltarr(xdim,ydim)
              ctt_mean_cot[*,*]=0.
              cth_mean_cot=fltarr(xdim,ydim)
              cth_mean_cot[*,*]=0.
              ctp_mean_cot=fltarr(xdim,ydim)
              ctp_mean_cot[*,*]=0.
              lwp_mean_cot=fltarr(xdim,ydim)
              lwp_mean_cot[*,*]=0.
              iwp_mean_cot=fltarr(xdim,ydim)
              iwp_mean_cot[*,*]=0.
              cph_mean=fltarr(xdim,ydim)
              cph_mean[*,*]=0.
              cph_mean_cot=fltarr(xdim,ydim)
              cph_mean_cot[*,*]=0.
              
              ; 2d parameters (histograms)
              ctp_hist=lonarr(xdim,ydim,dim_ctp)
              ctp_hist[*,*,*]=0l
              ctp_hist_cot=lonarr(xdim,ydim,dim_ctp)
              ctp_hist_cot[*,*,*]=0l
              lwp_lay=fltarr(xdim,ydim,zdim-1)
              iwp_lay=fltarr(xdim,ydim,zdim-1)
              lcot_lay=fltarr(xdim,ydim,zdim-1)
              icot_lay=fltarr(xdim,ydim,zdim-1)
              numb=lonarr(xdim,ydim)
              numb[*,*]=0
              numb_tmp=intarr(xdim,ydim)
              numb_cot=lonarr(xdim,ydim)
              numb_cot[*,*]=0
              numb_raw=0l
              found=0
              
            ; end of IF(counti EQ 0) THEN BEGIN
            ENDIF
            
            counti++
            
            ; temp. arrays filled with fill_values
            ctp_tmp[*,*]=-999.
            cth_tmp[*,*]=-999.
            ctt_tmp[*,*]=-999.
            ctp_tmp_cot[*,*]=-999.
            cth_tmp_cot[*,*]=-999.
            ctt_tmp_cot[*,*]=-999.
            lwp_lay_tmp[*,*]=-999.
            iwp_lay_tmp[*,*]=-999.
            lwp_tmp[*,*]=0.
            iwp_tmp[*,*]=0.
            lwp_tmp_cot[*,*]=0.
            iwp_tmp_cot[*,*]=0.
            cph_tmp[*,*]=-999.
            cph_tmp_cot[*,*]=-999.
            cfc_tmp[*,*]=0.
            cfc_tmp_cot[*,*]=0.
            
            ;-------------------------------------------------------
            ;-- thresholds for ERA-Interim and Satellite-like product
            ;   ori = 0.01 (ERA)
            ;   cci = 1.0 (Cloud_cci calipso cloud mask)
            ;-------------------------------------------------------
            crit_str='0.01'
            cc_crit=float(crit_str)
            cwc_crit=1.0E-07 & crit_str='lwc_crit_'+strtrim(cwc_crit,1)
            cot_crit=1.0 & crit_str='cot_crit_'+strtrim(cot_crit,1)
            cot_crit=0.3 & crit_str='cot_crit_'+strtrim(cot_crit,1)
            cot_crit=1.0 & cot_crit0=0.01 & crit_str='cot_crit_'+strtrim(cot_crit,1)
            
            
            ;-------------------------------------------------------------------
            ;-- loop top-down in order to get liquid and ice COT from lwc & iwc
            ;-------------------------------------------------------------------
            FOR z=zdim-2,0,-1 DO BEGIN
            
              ;PLEVEL DOUBLE = Array[37]; range[100, 200, ..., 97500, 100000]
              ;print, z, z+1, zdim
              ;          35          36          37
              ;          34          35          37
              ; ...
              ;           1           2          37
              ;           0           1          37
              ;     
   
              ; liquid water content between two pressure levels,
              ; i.e., LWC of the layer between the levels (middle)
              lwc_lay=lwc[*,*,z]*0.5 + lwc[*,*,z+1]*0.5
              iwc_lay=iwc[*,*,z]*0.5 + iwc[*,*,z+1]*0.5
                       
              ; http://en.wikipedia.org/wiki/Liquid_water_path#cite_note-2
              lwp_lay[*,*,z]=lwc_lay*dpres[z]/9.81
              iwp_lay[*,*,z]=iwc_lay*dpres[z]/9.81
              
              ; density and effective radius for liquid and ice water clouds
              ro_water=1000           ;kg/m3
              ro_ice=930              ;kg/m3
              reff_water=10.*1.0E-6   ;10 microns
              reff_ice=20.*1.0E-6     ;20 microns
                            
              ; LWP = 2./3. * (rho_water * Liquid_COT * reff)
              ; Liquid_COT = 3. * LWP / (2. * rho_water * reff) 
              lcot_lay[*,*,z]=lwp_lay[*,*,z]*3./(2.*reff_water*ro_water)
              ;icot_lay[*,*,z]=iwp_lay[*,*,z]*3./(2.*reff_ice*ro_ice)
              
              ; Heymsfield "Ice Water Path–Optical Depth Relationships 
              ; for Cirrus and Deep Stratiform Ice Cloud Layers"
              ; IWP = (COT (1/0.84))/0.065
              ; Fig. 7 (a): Observed TAU_vis vs. IWP points, dotted line
              ; composite curve produced by combining the midlatitude + tropcial datasets
              ; cot_ice=0.065*(IWP)^0.84
              
              iwp_tmp=reform(iwp_lay[*,*,z])
              ; IWP_LAY  FLOAT  = Array[720, 361, 36]
              ; IWP_TMP  FLOAT  = Array[720, 361]

              ; define icot_tmp, same size as iwp_tmp but filled with zeros
              icot_tmp=iwp_tmp*0.
              wo_iwp=where(iwp_tmp GT 0.,n_wo_iwp)
              IF(n_wo_iwp GT 0) THEN icot_tmp[wo_iwp]=(iwp_tmp[wo_iwp]*1000*0.065)^(0.84)
              icot_lay[*,*,z]=icot_tmp
              
            ; end of loop to get COTs for liquid and ice water clouds
            ENDFOR
            
            
            ;-------------------------------------------------------------------
            ;-- search top-down, where is a cloud?
            ;-------------------------------------------------------------------
            FOR z=zdim-2,1,-1 DO BEGIN
              
              ; ERA cot_threshold=0.01
              wo_cot0=where(total((lcot_lay+icot_lay)[*,*,0:z],3) GT cot_crit0,nwo_cot0)
              
              ; CCI cot_threshold=1.0
              wo_cot=where(total((lcot_lay+icot_lay)[*,*,0:z],3) GT cot_crit,nwo_cot)
              
              IF(nwo_cot0 GT 0 or nwo_cot GT 0) THEN BEGIN
                geop_tmp=reform(geop[*,*,z])/9.81
                temp_tmp=reform(temp[*,*,z])
                lwp_lay_tmp=reform(lwp_lay[*,*,z])
                iwp_lay_tmp=reform(iwp_lay[*,*,z])
              ENDIF
              
              ; ERA-Interim original
              IF(nwo_cot0 GT 0) THEN BEGIN
              
                ctp_tmp[wo_cot0]=plevel[z]/100.
                cth_tmp[wo_cot0]=geop_tmp[wo_cot0]
                ctt_tmp[wo_cot0]=temp_tmp[wo_cot0]
                cph_tmp[wo_cot0]=(0. > (lwp_lay_tmp[wo_cot0]/(lwp_lay_tmp[wo_cot0]+iwp_lay_tmp[wo_cot0])) < 1.0)
                
                IF(z LT zdim-2) THEN BEGIN
                  ; below upper most layer
                  lwp_tmp[wo_cot0]=(total(lwp_lay[*,*,z:*],3))[wo_cot0]
                  iwp_tmp[wo_cot0]=(total(iwp_lay[*,*,z:*],3))[wo_cot0]
                  cfc_tmp[wo_cot0]=(max(cc[*,*,z:*],dimension=3))[wo_cot0]
                ENDIF ELSE BEGIN
                  ; upper most layer
                  lwp_tmp[wo_cot0]=(lwp_lay[*,*,z])[wo_cot0]
                  iwp_tmp[wo_cot0]=(iwp_lay[*,*,z])[wo_cot0]
                  cfc_tmp[wo_cot0]=(cc[*,*,z])[wo_cot0]
                ENDELSE
                
              ENDIF
              
              ; Cloud_cci like (what a satellite would be able to detect)
              IF(nwo_cot GT 0) THEN BEGIN
              
                ctp_tmp_cot[wo_cot]=plevel[z]/100.
                cth_tmp_cot[wo_cot]=geop_tmp[wo_cot]
                ctt_tmp_cot[wo_cot]=temp_tmp[wo_cot]
                cph_tmp_cot[wo_cot]=(0. > (lwp_lay_tmp[wo_cot]/(lwp_lay_tmp[wo_cot]+iwp_lay_tmp[wo_cot])) < 1.0)
                
                IF(z LT zdim-2) THEN BEGIN
                  ; below upper most layer
                  lwp_tmp_cot[wo_cot]=(total(lwp_lay[*,*,z:*],3))[wo_cot]
                  iwp_tmp_cot[wo_cot]=(total(iwp_lay[*,*,z:*],3))[wo_cot]
                  cfc_tmp_cot[wo_cot]=(max(cc[*,*,z:*],dimension=3))[wo_cot]
                ENDIF ELSE BEGIN
                  ; upper most layer
                  lwp_tmp_cot[wo_cot]=(lwp_lay[*,*,z])[wo_cot]
                  iwp_tmp_cot[wo_cot]=(iwp_lay[*,*,z])[wo_cot]
                  cfc_tmp_cot[wo_cot]=(cc[*,*,z])[wo_cot]
                ENDELSE
                
              ENDIF
              
            ENDFOR
            
            
            IF KEYWORD_SET(verbose) THEN BEGIN
              PRINT, ' *** MINMAX(satellite-like - original)'
              PRINT, '     IWP : ', minmax(iwp_tmp_cot-iwp_tmp)
              PRINT, '     LWP : ', minmax(lwp_tmp_cot-lwp_tmp)
              PRINT, '     CFC : ', minmax(cfc_tmp_cot-cfc_tmp)
            ENDIF

            
            ;-------------------------------------------------------------------
            ; -- get cloud top pressure/height/temperature
            ;-------------------------------------------------------------------

            ; sum up ERA-results for each file, which has been processed
            wo_ctp=where(ctp_tmp GT 10.,nwo_ctp)
            ctp_mean[wo_ctp] = ctp_mean[wo_ctp] + ctp_tmp[wo_ctp]
            cth_mean[wo_ctp] = cth_mean[wo_ctp] + cth_tmp[wo_ctp]
            ctt_mean[wo_ctp] = ctt_mean[wo_ctp] + ctt_tmp[wo_ctp]
            lwp_mean = lwp_mean + lwp_tmp
            iwp_mean = iwp_mean + iwp_tmp
            cfc_mean = cfc_mean + cfc_tmp
            cph_mean[wo_ctp]=cph_mean[wo_ctp]+cph_tmp[wo_ctp]
            numb[wo_ctp]=numb[wo_ctp]+1l
            
            ; sum up CCI-results for each file, which has been processed
            wo_ctp_cot=where(ctp_tmp_cot GT 10.,nwo_ctp_cot)
            ctp_mean_cot[wo_ctp_cot] = ctp_mean_cot[wo_ctp_cot] + ctp_tmp_cot[wo_ctp_cot]
            cth_mean_cot[wo_ctp_cot] = cth_mean_cot[wo_ctp_cot] + cth_tmp_cot[wo_ctp_cot]
            ctt_mean_cot[wo_ctp_cot] = ctt_mean_cot[wo_ctp_cot] + ctt_tmp_cot[wo_ctp_cot]
            lwp_mean_cot = lwp_mean_cot + lwp_tmp_cot
            iwp_mean_cot = iwp_mean_cot + iwp_tmp_cot
            cfc_mean_cot = cfc_mean_cot + cfc_tmp_cot
            cph_mean_cot[wo_ctp_cot] = cph_mean_cot[wo_ctp_cot] + cph_tmp_cot[wo_ctp_cot]
            numb_cot[wo_ctp_cot] = numb_cot[wo_ctp_cot] + 1l
            
            numb_raw++
            
            ; sum up ORI (ERA) histogram product
            FOR gu=0,dim_ctp-1 DO BEGIN
              numb_tmp[*,*] = 0
              wohi=where(ctp_tmp GE ctp_limits_final2d[0,gu] AND ctp_tmp LT ctp_limits_final2d[1,gu],nwohi)
              IF(nwohi GT 0) THEN numb_tmp[wohi] = 1
              ctp_hist[*,*,gu]=ctp_hist[*,*,gu] + numb_tmp
            ENDFOR
            
            ; sum up CCI histogram product
            FOR gu=0,dim_ctp-1 DO BEGIN
              numb_tmp[*,*] = 0
              wohi=where(ctp_tmp_cot GE ctp_limits_final2d[0,gu] AND ctp_tmp_cot LT ctp_limits_final2d[1,gu],nwohi_cot)
              IF(nwohi_cot GT 0) THEN numb_tmp[wohi] = 1
              ctp_hist_cot[*,*,gu]=ctp_hist_cot[*,*,gu] + numb_tmp
            ENDFOR
            
            ;view2d,ctp_mean/numb,/cool,/color,min=100,no_data_idx=where(ctp_mean lt 1)
            ;PRINT, minmax(ctt_tmp)
            ;PRINT, minmax(ctt_mean/numb)
            ;PRINT, minmax(numb)
            ;map_image,ctt_mean/numb,lat2d,lon2d,ctable=33,limit=[-90,-180,90,180],min=200,max=300
            
          ENDIF
          
          IF KEYWORD_SET(verbose) THEN BEGIN
            PRINT, ' *** counti vs. numb_raw: ', counti, numb_raw
            PRINT, ' *** MINMAX(satellite grid mean):'
            PRINT, '     IWP : ', minmax(iwp_mean_cot/numb_raw)
            PRINT, '     LWP : ', minmax(lwp_mean_cot/numb_raw)
            PRINT, '     CFC : ', minmax(cfc_mean_cot/numb_raw)
            PRINT, ' *** MINMAX(model grid mean):'
            PRINT, '     IWP : ', minmax(iwp_mean/numb_raw)
            PRINT, '     LWP : ', minmax(lwp_mean/numb_raw)
            PRINT, '     CFC : ', minmax(cfc_mean/numb_raw)
            PRINT, ''
          ENDIF


        ;-----------------------------------------------------------------------
        ; end of loop over files
        ;-----------------------------------------------------------------------           
        ENDFOR
        
        
        
        ;-----------------------------------------------------------------------
        ; -- all files for year and month collected - final calcs and save
        ;-----------------------------------------------------------------------
        
        ; ERA-Interim (original)
        wo_numi  = where(numb GT 0, n_wo_numi)
        wo_numi0 = where(numb EQ 0, n_wo_numi0)
        
        ; weight mean with number of observations
        IF(n_wo_numi GT 0) THEN ctp_mean[wo_numi] = ctp_mean[wo_numi] / numb[wo_numi]
        IF(n_wo_numi GT 0) THEN cth_mean[wo_numi] = cth_mean[wo_numi] / numb[wo_numi]
        IF(n_wo_numi GT 0) THEN ctt_mean[wo_numi] = ctt_mean[wo_numi] / numb[wo_numi]
        IF(n_wo_numi GT 0) THEN cph_mean[wo_numi] = cph_mean[wo_numi] / numb[wo_numi]
        lwp_mean = lwp_mean / numb_raw
        iwp_mean = iwp_mean / numb_raw
        cfc_mean = cfc_mean / numb_raw
        
        ; fill_value for grid cells with no observations
        IF(n_wo_numi0 GT 0) THEN ctp_mean[wo_numi0] = -999.
        IF(n_wo_numi0 GT 0) THEN cth_mean[wo_numi0] = -999.
        IF(n_wo_numi0 GT 0) THEN ctt_mean[wo_numi0] = -999.
        IF(n_wo_numi0 GT 0) THEN lwp_mean[wo_numi0] = -999.
        IF(n_wo_numi0 GT 0) THEN iwp_mean[wo_numi0] = -999.
        IF(n_wo_numi0 GT 0) THEN cph_mean[wo_numi0] = -999.
        
        
        ; cloud_cci
        wo_numi_cot  = where(numb_cot GT 0, n_wo_numi_cot)
        wo_numi0_cot = where(numb_cot EQ 0, n_wo_numi0_cot)
        
        ; weight mean with number of observations
        IF(n_wo_numi_cot GT 0) THEN ctp_mean_cot[wo_numi_cot] = ctp_mean_cot[wo_numi_cot] / numb_cot[wo_numi_cot]
        IF(n_wo_numi_cot GT 0) THEN cth_mean_cot[wo_numi_cot] = cth_mean_cot[wo_numi_cot] / numb_cot[wo_numi_cot]
        IF(n_wo_numi_cot GT 0) THEN ctt_mean_cot[wo_numi_cot] = ctt_mean_cot[wo_numi_cot] / numb_cot[wo_numi_cot]
        IF(n_wo_numi_cot GT 0) THEN cph_mean_cot[wo_numi_cot] = cph_mean_cot[wo_numi_cot] / numb_cot[wo_numi_cot]
        lwp_mean_cot = lwp_mean_cot / numb_raw
        iwp_mean_cot = iwp_mean_cot / numb_raw
        cfc_mean_cot = cfc_mean_cot / numb_raw
        
        ; fill_value for grid cells with no observations
        IF(n_wo_numi0_cot GT 0) THEN ctp_mean_cot[wo_numi0_cot] = -999.
        IF(n_wo_numi0_cot GT 0) THEN cth_mean_cot[wo_numi0_cot] = -999.
        IF(n_wo_numi0_cot GT 0) THEN ctt_mean_cot[wo_numi0_cot] = -999.
        IF(n_wo_numi0_cot GT 0) THEN cph_mean_cot[wo_numi0_cot] = -999.
        IF(n_wo_numi0_cot GT 0) THEN lwp_mean_cot[wo_numi0_cot] = -999.
        IF(n_wo_numi0_cot GT 0) THEN iwp_mean_cot[wo_numi0_cot] = -999.
        
        ; map_image,ctt_mean,lat2d,lon2d,ctable=33,limit=[-90,-180,90,180],min=200,max=300
        
        fyear=float(year)
        fmonth=float(month)
        dayi_start=1
        dayi_end=daysinmonth(fyear,fmonth)
        tbo=dblarr(2,1)
        tref=julday(1,1,1970,0,0,0)
        tttt=julday(fmonth,dayi_start,fyear,0,0,0)
        tttt2=julday(fmonth,dayi_end,fyear,23,59,59)
        tbo[0,0]=tttt-tref
        tbo[1,0]=tttt2-tref
        titi=tttt-tref
        erg_plev=ctp_limits_final1d[1:n_elements(ctp_limits_final1d)-1] * 0.5 + $
                 ctp_limits_final1d[0:n_elements(ctp_limits_final1d)-2] * 0.5
        erg_plev_bnds=ctp_limits_final2d;*100.
        
        ;dim_ctp=nctp_new
        dim_time=1
        
        ;-----------------------------------------------------------------------
        ; -- write monthly mean output file --
        ;-----------------------------------------------------------------------
        
        file_out='ERA_Interim_MM'+year+month+'_'+crit_str+'_CTP.nc'
        clobber=1
        PRINT,'creating netcdf file: '+file_out
        
        id = NCDF_CREATE(path_out+file_out, CLOBBER = clobber) ;Create netCDF output file
        
        NCDF_ATTPUT, id, /GLOBAL, "Source" , "ERA-Interim" ;
        NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_START" , ""+year+month ;
        NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_RESOLUTION", "P1M"
        
        dim_x_id  = NCDF_DIMDEF(id, 'lon', xdim) 	;Define x-dimension
        dim_y_id  = NCDF_DIMDEF(id, 'lat', ydim) 	;Define y-dimension
        time_id  = NCDF_DIMDEF(id, 'time', dim_time)	;Define time-dimension
        
        vid  = NCDF_VARDEF(id, 'lon', [dim_x_id], /FLOAT)     ;Define data variable
        vid  = NCDF_VARDEF(id, 'lat', [dim_y_id], /FLOAT)     ;Define data variable
        vid  = NCDF_VARDEF(id, 'time', [time_id], /DOUBLE)    ;Define data variable
        
        ; model like grid mean values: thv_cot = 0.01
        vid  = NCDF_VARDEF(id, 'ctp_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
        NCDF_ATTPUT, id, 'ctp_era', '_FillValue', -999.

        vid  = NCDF_VARDEF(id, 'cth_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
        NCDF_ATTPUT, id, 'cth_era', '_FillValue', -999.
        
        vid  = NCDF_VARDEF(id, 'ctt_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
        NCDF_ATTPUT, id, 'ctt_era', '_FillValue', -999.
        
        vid  = NCDF_VARDEF(id, 'cph_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
        NCDF_ATTPUT, id, 'cph_era', '_FillValue', -999.
        
        vid  = NCDF_VARDEF(id, 'lwp_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
        NCDF_ATTPUT, id, 'lwp_era', '_FillValue', -999.
        
        vid  = NCDF_VARDEF(id, 'iwp_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
        NCDF_ATTPUT, id, 'iwp_era', '_FillValue', -999.
        
        vid  = NCDF_VARDEF(id, 'cc_total_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
        NCDF_ATTPUT, id, 'cc_total_era', '_FillValue', -999.
        
        vid  = NCDF_VARDEF(id, 'nobs_era', [dim_x_id,dim_y_id,time_id], /LONG)


        ; satellite like grid mean values: thv_cot = 1.0
        vid  = NCDF_VARDEF(id, 'ctp_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
        NCDF_ATTPUT, id, 'ctp_sat', '_FillValue', -999.
        
        vid  = NCDF_VARDEF(id, 'cth_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
        NCDF_ATTPUT, id, 'cth_sat', '_FillValue', -999.
        
        vid  = NCDF_VARDEF(id, 'ctt_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
        NCDF_ATTPUT, id, 'ctt_sat', '_FillValue', -999.
        
        vid  = NCDF_VARDEF(id, 'cc_total_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
        NCDF_ATTPUT, id, 'cc_total_sat', '_FillValue', -999.
        
        vid  = NCDF_VARDEF(id, 'lwp_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
        NCDF_ATTPUT, id, 'lwp_sat', '_FillValue', -999.
        
        vid  = NCDF_VARDEF(id, 'iwp_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
        NCDF_ATTPUT, id, 'iwp_sat', '_FillValue', -999.
        
        vid  = NCDF_VARDEF(id, 'cph_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
        NCDF_ATTPUT, id, 'cph_sat', '_FillValue', -999.
        
        vid  = NCDF_VARDEF(id, 'nobs_sat', [dim_x_id,dim_y_id,time_id], /LONG)
        
        
        PRINT,'counti (number of files read)',counti

        
        NCDF_CONTROL, id, /ENDEF ;Exit define mode

        NCDF_VARPUT, id, 'time',titi ;Write data to file
        ;NCDF_VARPUT, id, 'time_bnds',tbo
        NCDF_VARPUT, id, 'lon',lon
        NCDF_VARPUT, id, 'lat',lat

        NCDF_VARPUT, id, 'ctp_era',ctp_mean
        NCDF_VARPUT, id, 'cth_era',cth_mean
        NCDF_VARPUT, id, 'ctt_era',ctt_mean
        NCDF_VARPUT, id, 'cph_era',cph_mean
        NCDF_VARPUT, id, 'lwp_era',lwp_mean
        NCDF_VARPUT, id, 'iwp_era',iwp_mean
        NCDF_VARPUT, id, 'nobs_era',numb
        NCDF_VARPUT, id, 'cc_total_era',cfc_mean ;(numb*1.0)/counti

        NCDF_VARPUT, id, 'ctp_sat',ctp_mean_cot
        NCDF_VARPUT, id, 'cth_sat',cth_mean_cot
        NCDF_VARPUT, id, 'ctt_sat',ctt_mean_cot
        NCDF_VARPUT, id, 'cph_sat',cph_mean_cot
        NCDF_VARPUT, id, 'lwp_sat',lwp_mean_cot
        NCDF_VARPUT, id, 'iwp_sat',iwp_mean_cot
        NCDF_VARPUT, id, 'nobs_sat',numb_cot
        NCDF_VARPUT, id, 'cc_total_sat',cfc_mean_cot ;(numb_cot*1.0)/counti

        NCDF_CLOSE, id ;Close netCDF output file
        
        ;-----------------------------------------------------------------------
        ;-- write monthly histogram output --
        ;-----------------------------------------------------------------------
        
        file_out='ERA_Interim_MH'+year+month+'_'+crit_str+'_CTP.nc'
        clobber=1
        PRINT,'creating netcdf file: '+file_out
        
        id = NCDF_CREATE(path_out+file_out, CLOBBER = clobber)
        
        NCDF_ATTPUT, id, /GLOBAL, "Source" , "ERA-Interim" ;
        NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_START" , ""+year+month ;
        NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_RESOLUTION", "P1M"
        
        dim_tb_id  = NCDF_DIMDEF(id, 'gsize', 2)
        dim_p_id  = NCDF_DIMDEF(id, 'plev', dim_ctp)
        dim_x_id  = NCDF_DIMDEF(id, 'lon', xdim)
        dim_y_id  = NCDF_DIMDEF(id, 'lat', ydim)
        dim_b_id  = NCDF_DIMDEF(id, 'bnds', 2)
        time_id  = NCDF_DIMDEF(id, 'time', dim_time)
        
        vid  = NCDF_VARDEF(id, 'lon', [dim_x_id], /FLOAT)
        vid  = NCDF_VARDEF(id, 'lat', [dim_y_id], /FLOAT)
        vid  = NCDF_VARDEF(id, 'time', [time_id], /DOUBLE)
        vid  = NCDF_VARDEF(id, 'ctp', [dim_p_id], /FLOAT)
        vid  = NCDF_VARDEF(id, 'ctp_bnds', [dim_b_id,dim_p_id], /FLOAT)
        vid  = NCDF_VARDEF(id, 'ctp_hist_era', [dim_x_id,dim_y_id,dim_p_id,time_id], /LONG)
        vid  = NCDF_VARDEF(id, 'ctp_hist_sat', [dim_x_id,dim_y_id,dim_p_id,time_id], /LONG)
        
        NCDF_CONTROL, id, /ENDEF
        NCDF_VARPUT, id, 'time',titi
        ;NCDF_VARPUT, id, 'time_bnds',tbo
        NCDF_VARPUT, id, 'lon',lon
        NCDF_VARPUT, id, 'lat',lat
        NCDF_VARPUT, id, 'ctp',erg_plev
        NCDF_VARPUT, id, 'ctp_bnds',erg_plev_bnds
        NCDF_VARPUT, id, 'ctp_hist_era',ctp_hist
        NCDF_VARPUT, id, 'ctp_hist_sat',ctp_hist_cot
        NCDF_CLOSE, id
        
      ;end of IF(n_elements(ff) GT 1) THEN BEGIN
      ENDIF
      
    ;end of month loop
    ENDFOR
  ;end of year loop
  ENDFOR 
    
;end of program
END
