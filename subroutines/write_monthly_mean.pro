
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
    PRINT, ' *** Creating netCDF file: ' + file_out


    ; -- Create netCDF output file
    id = NCDF_CREATE(path_out + file_out, CLOBBER = clobber)

    NCDF_ATTPUT, id, /GLOBAL, "Source" , "ERA-Interim" ;
    NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_START" , "" + year + month
    NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_RESOLUTION", "P1M"
    NCDF_ATTPUT, id, /GLOBAL, "cot_thv_ori", thv.era
    NCDF_ATTPUT, id, /GLOBAL, "cot_thv", thv.sat

    dim_x_id  = NCDF_DIMDEF(id, 'lon', grd.xdim)
    dim_y_id  = NCDF_DIMDEF(id, 'lat', grd.ydim)
    time_id   = NCDF_DIMDEF(id, 'time', dim_time)

    vid  = NCDF_VARDEF(id, 'lon', [dim_x_id], /FLOAT)
    vid  = NCDF_VARDEF(id, 'lat', [dim_y_id], /FLOAT)
    vid  = NCDF_VARDEF(id, 'time', [time_id], /DOUBLE)


    ; -- model like output (original ERA-Interim)
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
    NCDF_ATTPUT, id, 'lwp_ori', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'lwp_bin_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_bin_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_bin_ori', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp_bin_ori', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'iwp_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_ori', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_ori', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'iwp_bin_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_bin_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_bin_ori', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_bin_ori', 'units', 'g/m^2'

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

    vid  = NCDF_VARDEF(id, 'nobs_lwp_bin_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp_bin_ori', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp_bin_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'nobs_iwp_bin_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp_bin_ori', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp_bin_ori', 'units', ' '

    ; -- incloud parameters
    vid  = NCDF_VARDEF(id, 'lwp_inc_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_inc_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_inc_ori', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp_inc_ori', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_lwp_inc_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp_inc_ori', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp_inc_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'iwp_inc_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_inc_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_inc_ori', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_inc_ori', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_iwp_inc_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp_inc_ori', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp_inc_ori', 'units', ' '

    ; -- incloud parameters of binary cph based lwp and iwp arrays
    vid  = NCDF_VARDEF(id, 'lwp_inc_bin_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_inc_bin_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_inc_bin_ori', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp_inc_bin_ori', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_lwp_inc_bin_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp_inc_bin_ori', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp_inc_bin_ori', 'units', ' '

    vid  = NCDF_VARDEF(id, 'iwp_inc_bin_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_inc_bin_ori', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_inc_bin_ori', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_inc_bin_ori', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_iwp_inc_bin_ori', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp_inc_bin_ori', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp_inc_bin_ori', 'units', ' '


    ; -- satellite like output
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
    NCDF_ATTPUT, id, 'lwp', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'lwp_bin', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_bin', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_bin', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp_bin', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'iwp', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'iwp_bin', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_bin', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_bin', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_bin', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'nobs', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs', 'units', ' '

    vid  = NCDF_VARDEF(id, 'nobs_lwp', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp', 'units', ' '

    vid  = NCDF_VARDEF(id, 'nobs_iwp', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp', 'units', ' '

    vid  = NCDF_VARDEF(id, 'nobs_lwp_bin', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp_bin', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp_bin', 'units', ' '

    vid  = NCDF_VARDEF(id, 'nobs_iwp_bin', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp_bin', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp_bin', 'units', ' '

    ; -- incloud parameters
    vid  = NCDF_VARDEF(id, 'lwp_inc', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_inc', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_inc', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp_inc', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_lwp_inc', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp_inc', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp_inc', 'units', ' '

    vid  = NCDF_VARDEF(id, 'iwp_inc', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_inc', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_inc', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_inc', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_iwp_inc', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp_inc', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp_inc', 'units', ' '

    ; -- incloud parameters: lwp and iwp based on binary cph
    vid  = NCDF_VARDEF(id, 'lwp_inc_bin', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'lwp_inc_bin', '_FillValue', -999.
    NCDF_ATTPUT, id, 'lwp_inc_bin', 'long_name', 'cloud liquid water path'
    NCDF_ATTPUT, id, 'lwp_inc_bin', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_lwp_inc_bin', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_lwp_inc_bin', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_lwp_inc_bin', 'units', ' '

    vid  = NCDF_VARDEF(id, 'iwp_inc_bin', [dim_x_id,dim_y_id,time_id], /FLOAT)
    NCDF_ATTPUT, id, 'iwp_inc_bin', '_FillValue', -999.
    NCDF_ATTPUT, id, 'iwp_inc_bin', 'long_name', 'cloud ice water path'
    NCDF_ATTPUT, id, 'iwp_inc_bin', 'units', 'g/m^2'

    vid  = NCDF_VARDEF(id, 'nobs_iwp_inc_bin', [dim_x_id,dim_y_id,time_id], /LONG)
    NCDF_ATTPUT, id, 'nobs_iwp_inc_bin', 'long_name', 'number of observations'
    NCDF_ATTPUT, id, 'nobs_iwp_inc_bin', 'units', ' '


    NCDF_CONTROL, id, /ENDEF ;Exit define mode


    NCDF_VARPUT, id, 'time', itime
    NCDF_VARPUT, id, 'lon', inp.lon
    NCDF_VARPUT, id, 'lat', inp.lat


    ; -- model GRID mean
    NCDF_VARPUT, id, 'ctp_ori', ave_era.ctp
    NCDF_VARPUT, id, 'cth_ori', ave_era.cth
    NCDF_VARPUT, id, 'ctt_ori', ave_era.ctt
    NCDF_VARPUT, id, 'cph_ori', ave_era.cph
    NCDF_VARPUT, id, 'cph_bin_ori', ave_era.cph_bin
    NCDF_VARPUT, id, 'lwp_ori', ave_era.lwp
    NCDF_VARPUT, id, 'iwp_ori', ave_era.iwp
    NCDF_VARPUT, id, 'cc_total_ori', ave_era.cfc
    NCDF_VARPUT, id, 'cc_total_bin_ori', ave_era.cfc_bin
    NCDF_VARPUT, id, 'nobs_ori', cnt_era.numb
    NCDF_VARPUT, id, 'nobs_lwp_ori', cnt_era.numb_lwp
    NCDF_VARPUT, id, 'nobs_iwp_ori', cnt_era.numb_iwp
    NCDF_VARPUT, id, 'lwp_bin_ori', ave_era.lwp_bin
    NCDF_VARPUT, id, 'iwp_bin_ori', ave_era.iwp_bin
    NCDF_VARPUT, id, 'nobs_lwp_bin_ori', cnt_era.numb_lwp_bin
    NCDF_VARPUT, id, 'nobs_iwp_bin_ori', cnt_era.numb_iwp_bin

    ; -- model INCLOUD mean
    NCDF_VARPUT, id, 'lwp_inc_ori', ave_era.lwp_inc
    NCDF_VARPUT, id, 'iwp_inc_ori', ave_era.iwp_inc
    NCDF_VARPUT, id, 'nobs_lwp_inc_ori', cnt_era.numb_lwp_inc
    NCDF_VARPUT, id, 'nobs_iwp_inc_ori', cnt_era.numb_iwp_inc

    ; -- model INCLOUD mean: based on binary cph
    NCDF_VARPUT, id, 'lwp_inc_bin_ori', ave_era.lwp_inc_bin
    NCDF_VARPUT, id, 'iwp_inc_bin_ori', ave_era.iwp_inc_bin
    NCDF_VARPUT, id, 'nobs_lwp_inc_bin_ori', cnt_era.numb_lwp_inc_bin
    NCDF_VARPUT, id, 'nobs_iwp_inc_bin_ori', cnt_era.numb_iwp_inc_bin


    ; -- satellite GRID mean
    NCDF_VARPUT, id, 'ctp', ave_sat.ctp
    NCDF_VARPUT, id, 'cth', ave_sat.cth
    NCDF_VARPUT, id, 'ctt', ave_sat.ctt
    NCDF_VARPUT, id, 'cph', ave_sat.cph
    NCDF_VARPUT, id, 'cph_bin', ave_sat.cph_bin
    NCDF_VARPUT, id, 'lwp', ave_sat.lwp
    NCDF_VARPUT, id, 'iwp', ave_sat.iwp
    NCDF_VARPUT, id, 'nobs', cnt_sat.numb
    NCDF_VARPUT, id, 'nobs_lwp', cnt_sat.numb_lwp
    NCDF_VARPUT, id, 'nobs_iwp', cnt_sat.numb_iwp
    NCDF_VARPUT, id, 'nobs_lwp_bin', cnt_sat.numb_lwp_bin
    NCDF_VARPUT, id, 'nobs_iwp_bin', cnt_sat.numb_iwp_bin
    NCDF_VARPUT, id, 'cc_total', ave_sat.cfc
    NCDF_VARPUT, id, 'cc_total_bin', ave_sat.cfc_bin
    NCDF_VARPUT, id, 'lwp_bin', ave_sat.lwp_bin
    NCDF_VARPUT, id, 'iwp_bin', ave_sat.iwp_bin

    ; -- satellite INCLOUD mean
    NCDF_VARPUT, id, 'lwp_inc', ave_sat.lwp_inc
    NCDF_VARPUT, id, 'iwp_inc', ave_sat.iwp_inc
    NCDF_VARPUT, id, 'nobs_lwp_inc', cnt_sat.numb_lwp_inc
    NCDF_VARPUT, id, 'nobs_iwp_inc', cnt_sat.numb_iwp_inc

    ; -- satellite INCLOUD mean: based on binary cph
    NCDF_VARPUT, id, 'lwp_inc_bin', ave_sat.lwp_inc_bin
    NCDF_VARPUT, id, 'iwp_inc_bin', ave_sat.iwp_inc_bin
    NCDF_VARPUT, id, 'nobs_lwp_inc_bin', cnt_sat.numb_lwp_inc_bin
    NCDF_VARPUT, id, 'nobs_iwp_inc_bin', cnt_sat.numb_iwp_inc_bin

    NCDF_CLOSE, id ;Close netCDF output file

END
