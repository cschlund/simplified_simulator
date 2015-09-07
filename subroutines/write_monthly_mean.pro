
;-------------------------------------------------------------------
;-- write netcdf monthly mean output
;-------------------------------------------------------------------

PRO WRITE_MONTHLY_MEAN, path_out, year, month, crit_str, $
                        xdim, ydim, zdim, lon, lat, $
                        cph_era, ctt_era, cth_era, ctp_era,  $
                        lwp_era, iwp_era, cfc_era, numb_era, $
                        numb_lwp_era, numb_iwp_era, numb_cph_bin_era, $
                        cph_sat, ctt_sat, cth_sat, ctp_sat,  $
                        lwp_sat, iwp_sat, cfc_sat, numb_sat, $
                        numb_lwp_sat, numb_iwp_sat, numb_cph_bin_sat, $
                        lwp_inc_era, iwp_inc_era, numb_lwp_inc_era, numb_iwp_inc_era, $
                        lwp_inc_sat, iwp_inc_sat, numb_lwp_inc_sat, numb_iwp_inc_sat, $
                        cot_thv_era, cot_thv_sat, $
                        lwp_bin_era, lwp_inc_bin_era, numb_lwp_inc_bin_era, $
                        iwp_bin_era, iwp_inc_bin_era, numb_iwp_inc_bin_era, $
                        lwp_bin_sat, lwp_inc_bin_sat, numb_lwp_inc_bin_sat, $
                        iwp_bin_sat, iwp_inc_bin_sat, numb_iwp_inc_bin_sat, $
                        cfc_bin_era, cph_bin_era, cfc_bin_sat, cph_bin_sat

	; convert cth form 'm' to 'km'
	idx_era = WHERE(cth_era GT 0., nera)
	IF(nera GT 0) THEN cth_era[idx_era] = cth_era[idx_era] / 1000.
	idx_sat = WHERE(cth_sat GT 0., nsat)
	IF(nsat GT 0) THEN cth_sat[idx_sat] = cth_sat[idx_sat] / 1000.

    dim_time   = 1
    fyear      = FLOAT(year)
    fmonth     = FLOAT(month)
    dayi_start = 1
    dayi_end   = daysinmonth(fyear,fmonth)
    tbo        = DBLARR(2,1)
    tref       = JULDAY(1,1,1970,0,0,0)
    tttt       = JULDAY(fmonth,dayi_start,fyear,0,0,0)
    tttt2      = JULDAY(fmonth,dayi_end,fyear,23,59,59)
    tbo[0,0]   = tttt-tref
    tbo[1,0]   = tttt2-tref
    itime      = tttt-tref

    file_out = 'SimpSimu_MM'+year+month+'_'+crit_str+'_CTP.nc'
    clobber  = 1
    PRINT, ' *** Creating netCDF file: ' + file_out
    
    ; Create netCDF output file
    id = NCDF_CREATE(path_out + file_out, CLOBBER = clobber)
    
    NCDF_ATTPUT, id, /GLOBAL, "Source" , "ERA-Interim" ;
    NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_START" , "" + year + month
    NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_RESOLUTION", "P1M"
    NCDF_ATTPUT, id, /GLOBAL, "cot_thv_ori", cot_thv_era
    NCDF_ATTPUT, id, /GLOBAL, "cot_thv", cot_thv_sat
    
    dim_x_id  = NCDF_DIMDEF(id, 'lon', xdim) 	   ;Define x-dimension
    dim_y_id  = NCDF_DIMDEF(id, 'lat', ydim) 	   ;Define y-dimension
    time_id   = NCDF_DIMDEF(id, 'time', dim_time)  ;Define time-dimension
    
    vid  = NCDF_VARDEF(id, 'lon', [dim_x_id], /FLOAT)     ;Define data variable
    vid  = NCDF_VARDEF(id, 'lat', [dim_y_id], /FLOAT)     ;Define data variable
    vid  = NCDF_VARDEF(id, 'time', [time_id], /DOUBLE)    ;Define data variable
    

    ; model like output (original ERA-Interim)
    vid  = NCDF_VARDEF(id, 'ctp_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'ctp_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'ctp_ori', 'long_name', 'cloud top pressure'
    NCDF_ATTPUT, id, 'ctp_ori', 'units', 'hPa'

    vid  = NCDF_VARDEF(id, 'cth_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cth_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cth_ori', 'long_name', 'cloud top height'
    NCDF_ATTPUT, id, 'cth_ori', 'units', 'km'

    vid  = NCDF_VARDEF(id, 'ctt_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'ctt_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'ctt_ori', 'long_name', 'cloud top temperature'
    NCDF_ATTPUT, id, 'ctt_ori', 'units', 'K'

    vid  = NCDF_VARDEF(id, 'cc_total_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cc_total_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cc_total_ori', 'long_name', 'cloud fraction'
    NCDF_ATTPUT, id, 'cc_total_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'cc_total_bin_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cc_total_bin_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cc_total_bin_ori', 'long_name', 'cloud fraction'
    NCDF_ATTPUT, id, 'cc_total_bin_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'lwp_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_ori', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp_ori', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'lwp_bin_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_bin_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_bin_ori', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp_bin_ori', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'iwp_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_ori', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_ori', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'iwp_bin_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_bin_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_bin_ori', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_bin_ori', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'cph_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cph_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cph_ori', 'long_name', 'cloud phase'
    NCDF_ATTPUT, id, 'cph_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'cph_bin_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cph_bin_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cph_bin_ori', 'long_name', 'cloud phase'
    NCDF_ATTPUT, id, 'cph_bin_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'nobs_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_ori', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'nobs_lwp_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp_ori', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'nobs_iwp_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp_ori', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'nobs_cph_bin_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_cph_bin_ori', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_cph_bin_ori', 'units', ' '

    ; incloud parameters
    vid  = NCDF_VARDEF(id, 'lwp_inc_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_inc_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_inc_ori', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp_inc_ori', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_lwp_inc_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp_inc_ori', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp_inc_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'iwp_inc_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_inc_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_inc_ori', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_inc_ori', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_iwp_inc_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp_inc_ori', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp_inc_ori', 'units', ' '

    ; incloud parameters of binary cph based lwp and iwp arrays
    vid  = NCDF_VARDEF(id, 'lwp_inc_bin_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_inc_bin_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_inc_bin_ori', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp_inc_bin_ori', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_lwp_inc_bin_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp_inc_bin_ori', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp_inc_bin_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'iwp_inc_bin_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_inc_bin_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_inc_bin_ori', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_inc_bin_ori', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_iwp_inc_bin_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp_inc_bin_ori', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp_inc_bin_ori', 'units', ' '


    ; satellite like output
    vid  = NCDF_VARDEF(id, 'ctp', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'ctp', '_FillValue', -999.
    NCDF_ATTPUT, id, 'ctp', 'long_name', 'cloud top pressure'
    NCDF_ATTPUT, id, 'ctp', 'units', 'hPa'

    vid  = NCDF_VARDEF(id, 'cth', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cth', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cth', 'long_name', 'cloud top height'
    NCDF_ATTPUT, id, 'cth', 'units', 'km'

    vid  = NCDF_VARDEF(id, 'ctt', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'ctt', '_FillValue', -999.
    NCDF_ATTPUT, id, 'ctt', 'long_name', 'cloud top temperature'
    NCDF_ATTPUT, id, 'ctt', 'units', 'K'

    vid  = NCDF_VARDEF(id, 'cph', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cph', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cph', 'long_name', 'cloud phase'
    NCDF_ATTPUT, id, 'cph', 'units', ' '

    vid  = NCDF_VARDEF(id, 'cph_bin', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cph_bin', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cph_bin', 'long_name', 'cloud phase'
    NCDF_ATTPUT, id, 'cph_bin', 'units', ' '

    vid  = NCDF_VARDEF(id, 'cc_total', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cc_total', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cc_total', 'long_name', 'cloud fraction'
    NCDF_ATTPUT, id, 'cc_total', 'units', ' '

    vid  = NCDF_VARDEF(id, 'cc_total_bin', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cc_total_bin', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cc_total_bin', 'long_name', 'cloud fraction'
    NCDF_ATTPUT, id, 'cc_total_bin', 'units', ' '

    vid  = NCDF_VARDEF(id, 'lwp', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'lwp_bin', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_bin', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_bin', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp_bin', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'iwp', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'iwp_bin', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_bin', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_bin', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_bin', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'nobs', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs', 'units', ' '

    vid  = NCDF_VARDEF(id, 'nobs_lwp', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp', 'units', ' '

    vid  = NCDF_VARDEF(id, 'nobs_iwp', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp', 'units', ' '

    vid  = NCDF_VARDEF(id, 'nobs_cph_bin', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_cph_bin', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_cph_bin', 'units', ' '

    ; incloud parameters
    vid  = NCDF_VARDEF(id, 'lwp_inc', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_inc', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_inc', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp_inc', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_lwp_inc', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp_inc', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp_inc', 'units', ' '

    vid  = NCDF_VARDEF(id, 'iwp_inc', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_inc', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_inc', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_inc', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_iwp_inc', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp_inc', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp_inc', 'units', ' '

    ; incloud parameters: lwp and iwp based on binary cph
    vid  = NCDF_VARDEF(id, 'lwp_inc_bin', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_inc_bin', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_inc_bin', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp_inc_bin', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_lwp_inc_bin', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp_inc_bin', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp_inc_bin', 'units', ' '

    vid  = NCDF_VARDEF(id, 'iwp_inc_bin', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_inc_bin', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_inc_bin', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_inc_bin', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_iwp_inc_bin', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp_inc_bin', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp_inc_bin', 'units', ' '


    NCDF_CONTROL, id, /ENDEF ;Exit define mode

    NCDF_VARPUT, id, 'time', itime
    NCDF_VARPUT, id, 'lon', lon
    NCDF_VARPUT, id, 'lat', lat

    ; model GRID mean
    NCDF_VARPUT, id, 'ctp_ori',ctp_era
    NCDF_VARPUT, id, 'cth_ori',cth_era
    NCDF_VARPUT, id, 'ctt_ori',ctt_era
    NCDF_VARPUT, id, 'cph_ori',cph_era
    NCDF_VARPUT, id, 'cph_bin_ori',cph_bin_era
    NCDF_VARPUT, id, 'lwp_ori',lwp_era
    NCDF_VARPUT, id, 'iwp_ori',iwp_era
    NCDF_VARPUT, id, 'nobs_ori',numb_era
    NCDF_VARPUT, id, 'nobs_lwp_ori',numb_lwp_era
    NCDF_VARPUT, id, 'nobs_iwp_ori',numb_iwp_era
    NCDF_VARPUT, id, 'nobs_cph_bin_ori',numb_cph_bin_era
    NCDF_VARPUT, id, 'cc_total_ori',cfc_era
    NCDF_VARPUT, id, 'cc_total_bin_ori',cfc_bin_era
    NCDF_VARPUT, id, 'lwp_bin_ori',lwp_bin_era
    NCDF_VARPUT, id, 'iwp_bin_ori',iwp_bin_era

    ; model INCLOUD mean
    NCDF_VARPUT, id, 'lwp_inc_ori',lwp_inc_era
    NCDF_VARPUT, id, 'iwp_inc_ori',iwp_inc_era
    NCDF_VARPUT, id, 'nobs_lwp_inc_ori',numb_lwp_inc_era
    NCDF_VARPUT, id, 'nobs_iwp_inc_ori',numb_iwp_inc_era
    ; model INCLOUD mean: based on binary cph
    NCDF_VARPUT, id, 'lwp_inc_bin_ori',lwp_inc_bin_era
    NCDF_VARPUT, id, 'iwp_inc_bin_ori',iwp_inc_bin_era
    NCDF_VARPUT, id, 'nobs_lwp_inc_bin_ori',numb_lwp_inc_bin_era
    NCDF_VARPUT, id, 'nobs_iwp_inc_bin_ori',numb_iwp_inc_bin_era


    ; satellite GRID mean
    NCDF_VARPUT, id, 'ctp',ctp_sat
    NCDF_VARPUT, id, 'cth',cth_sat
    NCDF_VARPUT, id, 'ctt',ctt_sat
    NCDF_VARPUT, id, 'cph',cph_sat
    NCDF_VARPUT, id, 'cph_bin',cph_bin_sat
    NCDF_VARPUT, id, 'lwp',lwp_sat
    NCDF_VARPUT, id, 'iwp',iwp_sat
    NCDF_VARPUT, id, 'nobs',numb_sat
    NCDF_VARPUT, id, 'nobs_lwp',numb_lwp_sat
    NCDF_VARPUT, id, 'nobs_iwp',numb_iwp_sat
    NCDF_VARPUT, id, 'nobs_cph_bin',numb_cph_bin_sat
    NCDF_VARPUT, id, 'cc_total',cfc_sat
    NCDF_VARPUT, id, 'cc_total_bin',cfc_bin_sat
    NCDF_VARPUT, id, 'lwp_bin',lwp_bin_sat
    NCDF_VARPUT, id, 'iwp_bin',iwp_bin_sat

    ; satellite INCLOUD mean
    NCDF_VARPUT, id, 'lwp_inc',lwp_inc_sat
    NCDF_VARPUT, id, 'iwp_inc',iwp_inc_sat
    NCDF_VARPUT, id, 'nobs_lwp_inc',numb_lwp_inc_sat
    NCDF_VARPUT, id, 'nobs_iwp_inc',numb_iwp_inc_sat
    ; satellite INCLOUD mean: based on binary cph
    NCDF_VARPUT, id, 'lwp_inc_bin',lwp_inc_bin_sat
    NCDF_VARPUT, id, 'iwp_inc_bin',iwp_inc_bin_sat
    NCDF_VARPUT, id, 'nobs_lwp_inc_bin',numb_lwp_inc_bin_sat
    NCDF_VARPUT, id, 'nobs_iwp_inc_bin',numb_iwp_inc_bin_sat

    NCDF_CLOSE, id ;Close netCDF output file

END
