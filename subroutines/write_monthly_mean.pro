;-------------------------------------------------------------------
;-- write netcdf histograms & monthly mean (average) output
;-------------------------------------------------------------------

PRO WRITE_MONTHLY_MEAN, path_out, year, month, grd, inp, thv, $
                        hist, ave_era, cnt_era, ave_sat, cnt_sat

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

    file_out = 'SimpSimu_MM'+year+month+'_'+thv.str+'.nc'
    clobber  = 1

    lon = inp.lon ;degrees_east
    lat = inp.lat ;degrees_north

    ; -- Create netCDF output file
    id = NCDF_CREATE(path_out + file_out, CLOBBER = clobber)

    NCDF_ATTPUT, id, /GLOBAL, "Source" , "ERA-Interim" ;
    NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_START" , "" + year + month
    NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_RESOLUTION", "P1M"
    NCDF_ATTPUT, id, /GLOBAL, "cot_thv_ori", thv.era
    NCDF_ATTPUT, id, /GLOBAL, "cot_thv", thv.sat
    NCDF_ATTPUT, id, /GLOBAL, "number_of_files", cnt_era.raw

    ; -- dimensions
    dim_x_id  = NCDF_DIMDEF(id, 'lon', grd.xdim)
    dim_y_id  = NCDF_DIMDEF(id, 'lat', grd.ydim)
    time_id   = NCDF_DIMDEF(id, 'time', dim_time)
    dim_phase = NCDF_DIMDEF(id, 'phase_dim', hist.phase_dim)
    dim_ctp1d = NCDF_DIMDEF(id, 'ctp1d_dim', hist.ctp1d_dim)
    dim_ctp_bin1d = NCDF_DIMDEF(id, 'ctp_bin1d_dim', hist.ctp_bin1d_dim)
    dim_ctt1d = NCDF_DIMDEF(id, 'ctt1d_dim', hist.ctt1d_dim)
    dim_ctt_bin1d = NCDF_DIMDEF(id, 'ctt_bin1d_dim', hist.ctt_bin1d_dim)
    dim_cot1d = NCDF_DIMDEF(id, 'cot1d_dim', hist.cot1d_dim)
    dim_cot_bin1d = NCDF_DIMDEF(id, 'cot_bin1d_dim', hist.cot_bin1d_dim)
    dim_cwp1d = NCDF_DIMDEF(id, 'cwp1d_dim', hist.cwp1d_dim)
    dim_cwp_bin1d = NCDF_DIMDEF(id, 'cwp_bin1d_dim', hist.cwp_bin1d_dim)

    ; -- time: monthly mean output
    vid  = NCDF_VARDEF(id, 'time', [time_id], /DOUBLE)

    ; -- longitude
    vid  = NCDF_VARDEF(id, 'lon', [dim_x_id], /FLOAT)
    NCDF_ATTPUT, id, 'lon', 'long_name', 'longitude'
    NCDF_ATTPUT, id, 'lon', 'units', 'degrees_east'

    ; -- latitude
    vid  = NCDF_VARDEF(id, 'lat', [dim_y_id], /FLOAT)
    NCDF_ATTPUT, id, 'lat', 'long_name', 'latitude'
    NCDF_ATTPUT, id, 'lat', 'units', 'degrees_north'


    ; === HISTOGRAMS ===

    vid  = NCDF_VARDEF(id, 'hist_phase', [dim_phase], /DOUBLE)
    NCDF_ATTPUT, id, 'hist_phase', 'long_name', 'phase histogram bins'
    NCDF_ATTPUT, id, 'hist_phase', 'units', ' '

    vid  = NCDF_VARDEF(id, 'hist_cot', [dim_cot1d], /DOUBLE)
    NCDF_ATTPUT, id, 'hist_cot', 'long_name', 'cot histogram border values'
    NCDF_ATTPUT, id, 'hist_cot', 'units', ' '

    vid  = NCDF_VARDEF(id, 'hist_cot_bin', [dim_cot_bin1d], /DOUBLE)
    NCDF_ATTPUT, id, 'hist_cot_bin', 'long_name', 'cot histogram bins'
    NCDF_ATTPUT, id, 'hist_cot_bin', 'units', ' '

    vid  = NCDF_VARDEF(id, 'hist_ctp', [dim_ctp1d], /DOUBLE)
    NCDF_ATTPUT, id, 'hist_ctp', 'long_name', 'ctp histogram border values'
    NCDF_ATTPUT, id, 'hist_ctp', 'units', ' '

    vid  = NCDF_VARDEF(id, 'hist_ctp_bin', [dim_ctp_bin1d], /DOUBLE)
    NCDF_ATTPUT, id, 'hist_ctp_bin', 'long_name', 'ctp histogram bins'
    NCDF_ATTPUT, id, 'hist_ctp_bin', 'units', ' '


    ; -- cloud top pressure 1d histogram --------------------------------------
    vid  = NCDF_VARDEF(id, 'hist_ctp1d_axis', [dim_ctp1d], /FLOAT)
    NCDF_ATTPUT, id, 'hist_ctp1d_axis', 'long_name', 'histogram_ctp1d'
    NCDF_ATTPUT, id, 'hist_ctp1d_axis', 'units', ' '

    vid  = NCDF_VARDEF(id, 'hist_ctp_bin1d_axis', [dim_ctp_bin1d], /FLOAT)
    NCDF_ATTPUT, id, 'hist_ctp_bin1d_axis', 'long_name', 'histogram_ctp_bin1d'
    NCDF_ATTPUT, id, 'hist_ctp_bin1d_axis', 'units', ' '

    vid  = NCDF_VARDEF(id, 'hist1d_ctp', $
        [dim_x_id, dim_y_id, dim_ctp_bin1d, dim_phase, time_id], /LONG)
    NCDF_ATTPUT, id, 'hist1d_ctp', 'long_name', 'hist1d_ctp'
    NCDF_ATTPUT, id, 'hist1d_ctp', 'units', 'counts'
    NCDF_ATTPUT, id, 'hist1d_ctp', '_FillValue', -999l, /LONG


    ; -- cloud top temperature 1d histogram ------------------------------------
    vid  = NCDF_VARDEF(id, 'hist_ctt1d_axis', [dim_ctt1d], /FLOAT)
    NCDF_ATTPUT, id, 'hist_ctt1d_axis', 'long_name', 'histogram_ctt1d'
    NCDF_ATTPUT, id, 'hist_ctt1d_axis', 'units', ' '

    vid  = NCDF_VARDEF(id, 'hist_ctt_bin1d_axis', [dim_ctt_bin1d], /FLOAT)
    NCDF_ATTPUT, id, 'hist_ctt_bin1d_axis', 'long_name', 'histogram_ctt_bin1d'
    NCDF_ATTPUT, id, 'hist_ctt_bin1d_axis', 'units', ' '

    vid  = NCDF_VARDEF(id, 'hist1d_ctt', $
        [dim_x_id, dim_y_id, dim_ctt_bin1d, dim_phase, time_id], /LONG)
    NCDF_ATTPUT, id, 'hist1d_ctt', 'long_name', 'hist1d_ctt'
    NCDF_ATTPUT, id, 'hist1d_ctt', 'units', 'counts'
    NCDF_ATTPUT, id, 'hist1d_ctt', '_FillValue', -999l, /LONG


    ; -- cloud water path 1d histogram ----------------------------------------
    vid  = NCDF_VARDEF(id, 'hist_cwp1d_axis', [dim_cwp1d], /FLOAT)
    NCDF_ATTPUT, id, 'hist_cwp1d_axis', 'long_name', 'histogram_cwp1d'
    NCDF_ATTPUT, id, 'hist_cwp1d_axis', 'units', ' '

    vid  = NCDF_VARDEF(id, 'hist_cwp_bin1d_axis', [dim_cwp_bin1d], /FLOAT)
    NCDF_ATTPUT, id, 'hist_cwp_bin1d_axis', 'long_name', 'histogram_cwp_bin1d'
    NCDF_ATTPUT, id, 'hist_cwp_bin1d_axis', 'units', ' '

    vid  = NCDF_VARDEF(id, 'hist1d_cwp_ori', $
        [dim_x_id, dim_y_id, dim_cwp_bin1d, dim_phase, time_id], /LONG)
    NCDF_ATTPUT, id, 'hist1d_cwp_ori', 'long_name', 'hist1d_cwp (era)'
    NCDF_ATTPUT, id, 'hist1d_cwp_ori', 'units', 'counts'
    NCDF_ATTPUT, id, 'hist1d_cwp_ori', '_FillValue', -999l, /LONG

    vid  = NCDF_VARDEF(id, 'hist1d_cwp', $
        [dim_x_id, dim_y_id, dim_cwp_bin1d, dim_phase, time_id], /LONG)
    NCDF_ATTPUT, id, 'hist1d_cwp', 'long_name', 'hist1d_cwp'
    NCDF_ATTPUT, id, 'hist1d_cwp', 'units', 'counts'
    NCDF_ATTPUT, id, 'hist1d_cwp', '_FillValue', -999l, /LONG


    ; -- cloud optical thickness 1d histogram ----------------------------------
    vid  = NCDF_VARDEF(id, 'hist_cot1d_axis', [dim_cot1d], /FLOAT)
    NCDF_ATTPUT, id, 'hist_cot1d_axis', 'long_name', 'histogram_cot1d'
    NCDF_ATTPUT, id, 'hist_cot1d_axis', 'units', ' '

    vid  = NCDF_VARDEF(id, 'hist_cot_bin1d_axis', [dim_cot_bin1d], /FLOAT)
    NCDF_ATTPUT, id, 'hist_cot_bin1d_axis', 'long_name', 'histogram_cot_bin1d'
    NCDF_ATTPUT, id, 'hist_cot_bin1d_axis', 'units', ' '

    vid  = NCDF_VARDEF(id, 'hist1d_cot_ori', $
        [dim_x_id, dim_y_id, dim_cot_bin1d, dim_phase, time_id], /LONG)
    NCDF_ATTPUT, id, 'hist1d_cot_ori', 'long_name', 'hist1d_cot (era)'
    NCDF_ATTPUT, id, 'hist1d_cot_ori', 'units', 'counts'
    NCDF_ATTPUT, id, 'hist1d_cot_ori', '_FillValue', -999l, /LONG

    vid  = NCDF_VARDEF(id, 'hist1d_cot', $
        [dim_x_id, dim_y_id, dim_cot_bin1d, dim_phase, time_id], /LONG)
    NCDF_ATTPUT, id, 'hist1d_cot', 'long_name', 'hist1d_cot'
    NCDF_ATTPUT, id, 'hist1d_cot', 'units', 'counts'
    NCDF_ATTPUT, id, 'hist1d_cot', '_FillValue', -999l, /LONG
    
    ; -- hist2d_cot_ctp
    vid  = NCDF_VARDEF(id, 'hist2d_cot_ctp', $
        [dim_x_id, dim_y_id, dim_cot_bin1d, dim_ctp_bin1d, dim_phase, time_id], /LONG)
    NCDF_ATTPUT, id, 'hist2d_cot_ctp', 'long_name', 'hist2d_cot_ctp'
    NCDF_ATTPUT, id, 'hist2d_cot_ctp', 'units', 'counts'
    NCDF_ATTPUT, id, 'hist2d_cot_ctp', '_FillValue', -999l, /LONG



    ; === MONTHLY MEANS ===

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

    ; -- histograms
    NCDF_VARPUT, id, 'hist_phase',hist.phase
    NCDF_VARPUT, id, 'hist_cot',hist.cot1d
    NCDF_VARPUT, id, 'hist_cot_bin',hist.cot_bin1d
    NCDF_VARPUT, id, 'hist_ctp',hist.ctp1d
    NCDF_VARPUT, id, 'hist_ctp_bin',hist.ctp_bin1d
    NCDF_VARPUT, id, 'hist2d_cot_ctp',ave_sat.hist2d_cot_ctp
    NCDF_VARPUT, id, 'hist_ctp1d_axis', hist.ctp1d
    NCDF_VARPUT, id, 'hist_ctp_bin1d_axis', hist.ctp_bin1d
    NCDF_VARPUT, id, 'hist1d_ctp',ave_sat.hist1d_ctp
    NCDF_VARPUT, id, 'hist_ctt1d_axis', hist.ctt1d
    NCDF_VARPUT, id, 'hist_ctt_bin1d_axis', hist.ctt_bin1d
    NCDF_VARPUT, id, 'hist1d_ctt',ave_sat.hist1d_ctt
    NCDF_VARPUT, id, 'hist_cwp1d_axis', hist.cwp1d
    NCDF_VARPUT, id, 'hist_cwp_bin1d_axis', hist.cwp_bin1d
    NCDF_VARPUT, id, 'hist1d_cwp_ori',ave_era.hist1d_cwp
    NCDF_VARPUT, id, 'hist1d_cwp',ave_sat.hist1d_cwp
    NCDF_VARPUT, id, 'hist_cot1d_axis', hist.cot1d
    NCDF_VARPUT, id, 'hist_cot_bin1d_axis', hist.cot_bin1d
    NCDF_VARPUT, id, 'hist1d_cot_ori',ave_era.hist1d_cot
    NCDF_VARPUT, id, 'hist1d_cot',ave_sat.hist1d_cot

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
    NCDF_VARPUT, id, 'cph', ave_sat.cph
    NCDF_VARPUT, id, 'cc_total', ave_sat.cfc
    ; lwp_inc_bin + iwp_inc_bin
    NCDF_VARPUT, id, 'cwp', ave_sat.cwp
    ; cot_liq_bin + cot_ice_bin
    NCDF_VARPUT, id, 'cot', ave_sat.cot
    NCDF_VARPUT, id, 'cot_liq', ave_sat.cot_liq
    NCDF_VARPUT, id, 'cot_ice', ave_sat.cot_ice
    NCDF_VARPUT, id, 'lwp', ave_sat.lwp
    NCDF_VARPUT, id, 'iwp', ave_sat.iwp
    NCDF_VARPUT, id, 'nobs', cnt_sat.ctp
    NCDF_VARPUT, id, 'nobs_lwp', cnt_sat.lwp
    NCDF_VARPUT, id, 'nobs_iwp', cnt_sat.iwp

    NCDF_CLOSE, id ;Close netCDF output file

    PRINT, '** CREATED: ', path_out + file_out

END
