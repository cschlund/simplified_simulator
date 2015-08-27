
;-------------------------------------------------------------------
;-- write netcdf monthly histogram output
;-------------------------------------------------------------------

PRO WRITE_MONTHLY_HIST, path_out, year, month, crit_str, $
                        xdim, ydim, zdim, dim_ctp, lon, lat, $
                        ctp_limits_final1d, ctp_limits_final2d, $
                        ctp_hist_era, ctp_hist_sat

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

    erg_plev = ctp_limits_final1d[1:n_elements(ctp_limits_final1d)-1] * 0.5 + $
               ctp_limits_final1d[0:n_elements(ctp_limits_final1d)-2] * 0.5

    erg_plev_bnds = ctp_limits_final2d;*100.
        

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

    NCDF_VARPUT, id, 'time',itime
    NCDF_VARPUT, id, 'lon',lon
    NCDF_VARPUT, id, 'lat',lat
    NCDF_VARPUT, id, 'ctp',erg_plev
    NCDF_VARPUT, id, 'ctp_bnds',erg_plev_bnds
    NCDF_VARPUT, id, 'ctp_hist_era',ctp_hist_era
    NCDF_VARPUT, id, 'ctp_hist_sat',ctp_hist_sat
    NCDF_CLOSE, id

END
