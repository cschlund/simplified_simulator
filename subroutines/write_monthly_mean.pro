;-------------------------------------------------------------------
;-- write netcdf monthly mean (average) output
;-------------------------------------------------------------------

PRO WRITE_MONTHLY_MEAN, path_out, year, month, grd, inp, thv, $
                        ave_era, cnt_era, ave_sat, cnt_sat

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

    file_out = 'SimpSimu_MM'+year+month+'_'+thv.str+'_CTP.nc'
    clobber  = 1

    ; inp.lon [0;359.5]
    lon = inp.lon - 180.    ;degrees_east
    lat = inp.lat           ;degrees_north

    ; -- Create netCDF output file
    id = NCDF_CREATE(path_out + file_out, CLOBBER = clobber)

    NCDF_ATTPUT, id, /GLOBAL, "Source" , "ERA-Interim" ;
    NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_START" , "" + year + month
    NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_RESOLUTION", "P1M"
    NCDF_ATTPUT, id, /GLOBAL, "cot_thv_ori", thv.era
    NCDF_ATTPUT, id, /GLOBAL, "cot_thv", thv.sat
    NCDF_ATTPUT, id, /GLOBAL, "number_of_files", cnt_era.raw

    dim_x_id  = NCDF_DIMDEF(id, 'lon', grd.xdim)
    dim_y_id  = NCDF_DIMDEF(id, 'lat', grd.ydim)
    time_id   = NCDF_DIMDEF(id, 'time', dim_time)

    vid  = NCDF_VARDEF(id, 'time', [time_id], /DOUBLE)

    vid  = NCDF_VARDEF(id, 'lon', [dim_x_id], /FLOAT)
    NCDF_ATTPUT, id, 'lon', 'long_name', 'longitude'
    NCDF_ATTPUT, id, 'lon', 'units', 'degrees_east'

    vid  = NCDF_VARDEF(id, 'lat', [dim_y_id], /FLOAT)
    NCDF_ATTPUT, id, 'lat', 'long_name', 'latitude'
    NCDF_ATTPUT, id, 'lat', 'units', 'degrees_north'

    ; -- model like output (original ERA-Interim)
    vid  = NCDF_VARDEF(id, 'ctp_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'ctp_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'ctp_ori', 'long_name', 'cloud top pressure (era)'
    NCDF_ATTPUT, id, 'ctp_ori', 'units', 'hPa'

    vid  = NCDF_VARDEF(id, 'cth_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cth_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cth_ori', 'long_name', 'cloud top height (era)'
    NCDF_ATTPUT, id, 'cth_ori', 'units', 'km'

    vid  = NCDF_VARDEF(id, 'ctt_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'ctt_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'ctt_ori', 'long_name', 'cloud top temperature (era)'
    NCDF_ATTPUT, id, 'ctt_ori', 'units', 'K'

    vid  = NCDF_VARDEF(id, 'cc_total_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cc_total_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cc_total_ori', 'long_name', 'cloud fraction (era)'
    NCDF_ATTPUT, id, 'cc_total_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'cph_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cph_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cph_ori', 'long_name', 'cloud phase (era)'
    NCDF_ATTPUT, id, 'cph_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'nobs_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_ori', 'long_name', 'number of observations (era)'
    NCDF_ATTPUT, id, 'nobs_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'cot_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cot_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cot_ori', 'long_name', 'cloud optical thickness (era)'
    NCDF_ATTPUT, id, 'cot_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'cot_liq_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cot_liq_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cot_liq_ori', 'long_name', 'liquid cloud optical thickness (era)'
    NCDF_ATTPUT, id, 'cot_liq_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'cot_ice_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cot_ice_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cot_ice_ori', 'long_name', 'ice cloud optical thickness (era)'
    NCDF_ATTPUT, id, 'cot_ice_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'cwp_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cwp_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cwp_ori', 'long_name', 'cloud water path (era)'
    NCDF_ATTPUT, id, 'cwp_ori', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'lwp_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_ori', 'long_name', 'cloud liquid water path (era)'
    NCDF_ATTPUT, id, 'lwp_ori', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_lwp_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp_ori', 'long_name', 'number of observations (era)'
    NCDF_ATTPUT, id, 'nobs_lwp_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'iwp_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_ori', 'long_name', 'cloud ice water path (era)'
    NCDF_ATTPUT, id, 'iwp_ori', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_iwp_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp_ori', 'long_name', 'number of observations (era)'
    NCDF_ATTPUT, id, 'nobs_iwp_ori', 'units', ' '


    ; -- pseudo-satellite (cloud_cci) output
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

    vid  = NCDF_VARDEF(id, 'cc_total', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cc_total', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cc_total', 'long_name', 'cloud fraction'
    NCDF_ATTPUT, id, 'cc_total', 'units', ' '

    vid  = NCDF_VARDEF(id, 'nobs', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs', 'units', ' '

    vid  = NCDF_VARDEF(id, 'cot', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cot', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cot', 'long_name', 'cloud optical thickness'
    NCDF_ATTPUT, id, 'cot', 'units', ' '

    vid  = NCDF_VARDEF(id, 'cot_liq', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cot_liq', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cot_liq', 'long_name', 'liquid cloud optical thickness'
    NCDF_ATTPUT, id, 'cot_liq', 'units', ' '

    vid  = NCDF_VARDEF(id, 'cot_ice', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cot_ice', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cot_ice', 'long_name', 'ice cloud optical thickness'
    NCDF_ATTPUT, id, 'cot_ice', 'units', ' '

    vid  = NCDF_VARDEF(id, 'cwp', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'cwp', '_FillValue', -999.
    NCDF_ATTPUT, id, 'cwp', 'long_name', 'cloud water path'
    NCDF_ATTPUT, id, 'cwp', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'lwp', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_lwp', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp', 'units', ' '

    vid  = NCDF_VARDEF(id, 'iwp', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_iwp', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp', 'units', ' '

    NCDF_CONTROL, id, /ENDEF ;Exit define mode


    ; -- general
    NCDF_VARPUT, id, 'time', itime
    NCDF_VARPUT, id, 'lon', lon
    NCDF_VARPUT, id, 'lat', lat

    ; -- based on thv.era: original model output
    NCDF_VARPUT, id, 'ctp_ori', ave_era.ctp
    NCDF_VARPUT, id, 'cth_ori', ave_era.cth
    NCDF_VARPUT, id, 'ctt_ori', ave_era.ctt
    NCDF_VARPUT, id, 'cph_ori', ave_era.cph
    NCDF_VARPUT, id, 'cc_total_ori', ave_era.cfc
    ; lwp + iwp
    NCDF_VARPUT, id, 'cwp_ori', ave_era.cwp
    ; cot_liq + cot_ice
    NCDF_VARPUT, id, 'cot_ori', ave_era.cot
    NCDF_VARPUT, id, 'cot_liq_ori', ave_era.cot_liq
    NCDF_VARPUT, id, 'cot_ice_ori', ave_era.cot_ice
    NCDF_VARPUT, id, 'lwp_ori', ave_era.lwp
    NCDF_VARPUT, id, 'iwp_ori', ave_era.iwp
    NCDF_VARPUT, id, 'nobs_ori', cnt_era.ctp
    NCDF_VARPUT, id, 'nobs_lwp_ori', cnt_era.lwp
    NCDF_VARPUT, id, 'nobs_iwp_ori', cnt_era.iwp

    ; -- based on thv.sat: pseudo-satellite output
    NCDF_VARPUT, id, 'ctp', ave_sat.ctp
    NCDF_VARPUT, id, 'cth', ave_sat.cth
    NCDF_VARPUT, id, 'ctt', ave_sat.ctt
    NCDF_VARPUT, id, 'cph', ave_sat.cph_bin
    NCDF_VARPUT, id, 'cc_total', ave_sat.cfc_bin
    ; lwp_inc_bin + iwp_inc_bin
    NCDF_VARPUT, id, 'cwp', ave_sat.cwp
    ; cot_liq_bin + cot_ice_bin
    NCDF_VARPUT, id, 'cot', ave_sat.cot
    NCDF_VARPUT, id, 'cot_liq', ave_sat.cot_liq_bin
    NCDF_VARPUT, id, 'cot_ice', ave_sat.cot_ice_bin
    NCDF_VARPUT, id, 'lwp', ave_sat.lwp_inc_bin
    NCDF_VARPUT, id, 'iwp', ave_sat.iwp_inc_bin
    NCDF_VARPUT, id, 'nobs', cnt_sat.ctp
    NCDF_VARPUT, id, 'nobs_lwp', cnt_sat.lwp_inc_bin
    NCDF_VARPUT, id, 'nobs_iwp', cnt_sat.iwp_inc_bin

    NCDF_CLOSE, id ;Close netCDF output file

    PRINT, '** CREATED: ', path_out + file_out

END
