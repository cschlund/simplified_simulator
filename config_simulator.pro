;-------------------------------------------------------------------
; ** PURPOSE: configure cloud-cci simulator run
;
; ** OUT:io_paths, time_frame, cot_thresholds, ctp_histinfo
;-------------------------------------------------------------------

PRO CONFIG_SIMULATOR, io_paths, time_frame, cot_thresholds, ctp_histinfo

    ;-- era simulator output directory
    out_base = 'v8_IDL_structs/run2/'
    pwd_base = '/cmsaf/cmsaf-cld6/cschlund/cci_wp5001/ERA_simulator/'
    out_path = pwd_base + out_base
    validres = VALID_DIR( out_path )
    IF(validres EQ 0) THEN creatres = CREATE_DIR( out_path )

    ;-- ERA-Interim input files
;     era_base = '/cmsaf/cmsaf-cld1/mstengel/ERA_Interim/ERA_simulator/'
    era_base = '/data/cschlund/'
    era_path = era_base  + 'MARS_data/ERA_simulator/'


    ;-- Set list of years to be processed
    ;years_list = ['1979','1980',$
    ;           '1981','1982','1983','1984','1985','1986','1987','1988','1989','1990',$
    ;           '1991','1992','1993','1994','1995','1996','1997','1998','1999','2000',$
    ;           '2001','2002','2003','2004','2005','2006','2007','2008','2009','2010',$
    ;           '2011','2012','2013','2014']
    years_list = ['2008']
    nyears = N_ELEMENTS(years_list)


    ;-- Set list of month to be processed
    ;months_list = ['01','02','03','04','05','06','07','08','09','10','11','12']
    months_list = ['07']
    nmonths = N_ELEMENTS(months_list)


    ;-- Set cloud top pressure limits for 1D and 2D output, same as in Cloud_cci
    ctp_limits_final1d = [1.0, 90.0, 180.0, 245.0, 310.0, 375.0, 440.0, 500.0, $
                          560.0, 620.0, 680.0, 740.0, 800.0, 950., 1100.0]
    ctp_limits_final2d = FLTARR(2,N_ELEMENTS(ctp_limits_final1d)-1)

    FOR gu=0,N_ELEMENTS(ctp_limits_final2d[0,*])-1 DO BEGIN
      ctp_limits_final2d[0,gu] = ctp_limits_final1d[gu]
      ctp_limits_final2d[1,gu] = ctp_limits_final1d[gu+1]
    ENDFOR

    dim_ctp = N_ELEMENTS(ctp_limits_final1d)-1


    ;-- model = 0.01, e.g. ERA = original input data
    cot_thv_era = 0.01 

    ;-- satellite sensitivity threshold
    IF KEYWORD_SET(cot_thv_sat) THEN BEGIN
	cot_thv_sat = cot_thv_sat
    ENDIF ELSE BEGIN
	cot_thv_sat = 0.3
    ENDELSE

    ;-- crit_str = 'cot_thv_'+strtrim(cot_thv_sat,1)
    crit_str = 'cot_thv_'+STRTRIM(STRING(cot_thv_sat, FORMAT='(F4.2)'),2)


    ;-- create output structures
    io_paths = {inp:era_path, out:out_path}
    time_frame = {yyyy:years_list, mm:months_list, ny:nyears, nm:nmonths}
    cot_thresholds = {era:cot_thv_era, sat:cot_thv_sat, str:crit_str}
    ctp_histinfo = {dim_ctp:dim_ctp, ctp1d:ctp_limits_final1d, ctp2d:ctp_limits_final2d}

END