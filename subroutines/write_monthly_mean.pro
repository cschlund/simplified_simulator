
;-------------------------------------------------------------------
;-- write netcdf monthly mean output
;-------------------------------------------------------------------

PRO WRITE_MONTHLY_MEAN, path_out, year, month, crit_str, $
                        xdim, ydim, zdim, lon, lat, $
                        cph_era, ctt_era, cth_era, ctp_era,  $
                        lwp_era, iwp_era, cfc_era, numb_era, $
                        cph_sat, ctt_sat, cth_sat, ctp_sat,  $
                        lwp_sat, iwp_sat, cfc_sat, numb_sat, $
						lwp_inc_era, iwp_inc_era, $
						numb_lwp_inc_era, numb_iwp_inc_era, $
						lwp_inc_sat, iwp_inc_sat, $
						numb_lwp_inc_sat, numb_iwp_inc_sat, $
                        cot_thv_era, cot_thv_sat


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

    file_out = 'ERA_Interim_MM'+year+month+'_'+crit_str+'_CTP.nc'
    clobber  = 1
    PRINT, ' *** Creating netCDF file: ' + file_out
    
    ; Create netCDF output file
    id = NCDF_CREATE(path_out + file_out, CLOBBER = clobber)
    
    NCDF_ATTPUT, id, /GLOBAL, "Source" , "ERA-Interim" ;
    NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_START" , "" + year + month
    NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_RESOLUTION", "P1M"
    NCDF_ATTPUT, id, /GLOBAL, "cot_thv_era", cot_thv_era
    NCDF_ATTPUT, id, /GLOBAL, "cot_thv_sat", cot_thv_sat
    
    dim_x_id  = NCDF_DIMDEF(id, 'lon', xdim) 	   ;Define x-dimension
    dim_y_id  = NCDF_DIMDEF(id, 'lat', ydim) 	   ;Define y-dimension
    time_id   = NCDF_DIMDEF(id, 'time', dim_time)  ;Define time-dimension
    
    vid  = NCDF_VARDEF(id, 'lon', [dim_x_id], /FLOAT)     ;Define data variable
    vid  = NCDF_VARDEF(id, 'lat', [dim_y_id], /FLOAT)     ;Define data variable
    vid  = NCDF_VARDEF(id, 'time', [time_id], /DOUBLE)    ;Define data variable
    

    ; model like output (original ERA-Interim): thv = 1.0
    vid  = NCDF_VARDEF(id, 'ctp_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'ctp_era', '_FillValue', -999.
    NCDF_ATTPUT, id, 'ctp_era', 'long_name', 'cloud top pressure'
    NCDF_ATTPUT, id, 'ctp_era', 'units', 'hPa'

    vid  = NCDF_VARDEF(id, 'cth_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cth_era', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cth_era', 'long_name', 'cloud top height'
    NCDF_ATTPUT, id, 'cth_era', 'units', 'm'

    vid  = NCDF_VARDEF(id, 'ctt_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'ctt_era', '_FillValue', -999.
    NCDF_ATTPUT, id, 'ctt_era', 'long_name', 'cloud top temperature'
    NCDF_ATTPUT, id, 'ctt_era', 'units', 'K'

    vid  = NCDF_VARDEF(id, 'cc_total_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cc_total_era', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cc_total_era', 'long_name', 'cloud fraction'
    NCDF_ATTPUT, id, 'cc_total_era', 'units', ' '

    vid  = NCDF_VARDEF(id, 'lwp_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_era', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_era', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp_era', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'iwp_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_era', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_era', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_era', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'cph_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cph_era', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cph_era', 'long_name', 'cloud phase'
    NCDF_ATTPUT, id, 'cph_era', 'units', ' '

    vid  = NCDF_VARDEF(id, 'nobs_era', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_era', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_era', 'units', ' '

    ; incloud parameters
    vid  = NCDF_VARDEF(id, 'lwp_inc_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_inc_era', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_inc_era', 'long_name', 'cloud liquid water path (incloud)'
    NCDF_ATTPUT, id, 'lwp_inc_era', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_lwp_inc_era', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp_inc_era', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp_inc_era', 'units', ' '

    vid  = NCDF_VARDEF(id, 'iwp_inc_era', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_inc_era', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_inc_era', 'long_name', 'cloud ice water path (incloud)'
    NCDF_ATTPUT, id, 'iwp_inc_era', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_iwp_inc_era', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp_inc_era', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp_inc_era', 'units', ' '


    ; satellite like output: thv = 1.0
    vid  = NCDF_VARDEF(id, 'ctp_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'ctp_sat', '_FillValue', -999.
    NCDF_ATTPUT, id, 'ctp_sat', 'long_name', 'cloud top pressure'
    NCDF_ATTPUT, id, 'ctp_sat', 'units', 'hPa'

    vid  = NCDF_VARDEF(id, 'cth_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cth_sat', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cth_sat', 'long_name', 'cloud top height'
    NCDF_ATTPUT, id, 'cth_sat', 'units', 'm'

    vid  = NCDF_VARDEF(id, 'ctt_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'ctt_sat', '_FillValue', -999.
    NCDF_ATTPUT, id, 'ctt_sat', 'long_name', 'cloud top temperature'
    NCDF_ATTPUT, id, 'ctt_sat', 'units', 'K'

    vid  = NCDF_VARDEF(id, 'cph_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cph_sat', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cph_sat', 'long_name', 'cloud phase'
    NCDF_ATTPUT, id, 'cph_sat', 'units', ' '

    vid  = NCDF_VARDEF(id, 'cc_total_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cc_total_sat', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cc_total_sat', 'long_name', 'cloud fraction'
    NCDF_ATTPUT, id, 'cc_total_sat', 'units', ' '

    vid  = NCDF_VARDEF(id, 'lwp_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_sat', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_sat', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp_sat', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'iwp_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_sat', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_sat', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_sat', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_sat', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_sat', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_sat', 'units', ' '

    ; incloud parameters
    vid  = NCDF_VARDEF(id, 'lwp_inc_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_inc_sat', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_inc_sat', 'long_name', 'cloud liquid water path (incloud)'
    NCDF_ATTPUT, id, 'lwp_inc_sat', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_lwp_inc_sat', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp_inc_sat', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp_inc_sat', 'units', ' '

    vid  = NCDF_VARDEF(id, 'iwp_inc_sat', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_inc_sat', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_inc_sat', 'long_name', 'cloud ice water path (incloud)'
    NCDF_ATTPUT, id, 'iwp_inc_sat', 'units', 'kg/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_iwp_inc_sat', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp_inc_sat', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp_inc_sat', 'units', ' '


    NCDF_CONTROL, id, /ENDEF ;Exit define mode

    NCDF_VARPUT, id, 'time', itime
    NCDF_VARPUT, id, 'lon', lon
    NCDF_VARPUT, id, 'lat', lat

    ; model GRID mean
    NCDF_VARPUT, id, 'ctp_era',ctp_era
    NCDF_VARPUT, id, 'cth_era',cth_era
    NCDF_VARPUT, id, 'ctt_era',ctt_era
    NCDF_VARPUT, id, 'cph_era',cph_era
    NCDF_VARPUT, id, 'lwp_era',lwp_era
    NCDF_VARPUT, id, 'iwp_era',iwp_era
    NCDF_VARPUT, id, 'nobs_era',numb_era
    NCDF_VARPUT, id, 'cc_total_era',cfc_era ;(numb*1.0)/counti

    ; model INCLOUD mean
    NCDF_VARPUT, id, 'lwp_inc_era',lwp_inc_era
    NCDF_VARPUT, id, 'iwp_inc_era',iwp_inc_era
    NCDF_VARPUT, id, 'nobs_lwp_inc_era',numb_lwp_inc_era
    NCDF_VARPUT, id, 'nobs_iwp_inc_era',numb_iwp_inc_era


    ; satellite GRID mean
    NCDF_VARPUT, id, 'ctp_sat',ctp_sat
    NCDF_VARPUT, id, 'cth_sat',cth_sat
    NCDF_VARPUT, id, 'ctt_sat',ctt_sat
    NCDF_VARPUT, id, 'cph_sat',cph_sat
    NCDF_VARPUT, id, 'lwp_sat',lwp_sat
    NCDF_VARPUT, id, 'iwp_sat',iwp_sat
    NCDF_VARPUT, id, 'nobs_sat',numb_sat
    NCDF_VARPUT, id, 'cc_total_sat',cfc_sat ;(numb_sat*1.0)/counti

    ; satellite INCLOUD mean
    NCDF_VARPUT, id, 'lwp_inc_sat',lwp_inc_sat
    NCDF_VARPUT, id, 'iwp_inc_sat',iwp_inc_sat
    NCDF_VARPUT, id, 'nobs_lwp_inc_sat',numb_lwp_inc_sat
    NCDF_VARPUT, id, 'nobs_iwp_inc_sat',numb_iwp_inc_sat

    NCDF_CLOSE, id ;Close netCDF output file

END
