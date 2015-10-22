
;-------------------------------------------------------------------
;-- write netcdf monthly histogram output
;-------------------------------------------------------------------

PRO WRITE_MONTHLY_HIST, path_out, year, month, grd, inp, $
                        thvs, hist, ave_era, ave_sat

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

    erg_plev = hist.ctp1d[1:n_elements(hist.ctp1d)-1] * 0.5 + $
               hist.ctp1d[0:n_elements(hist.ctp1d)-2] * 0.5

    erg_plev_bnds = hist.ctp2d


    file_out='SimpSimu_MH'+year+month+'_'+thvs.str+'_CTP.nc'
    clobber=1
    PRINT,'creating netcdf file: '+file_out

    id = NCDF_CREATE(path_out+file_out, CLOBBER = clobber)

    NCDF_ATTPUT, id, /GLOBAL, "Source" , "ERA-Interim" ;
    NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_START" , ""+year+month ;
    NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_RESOLUTION", "P1M"
    NCDF_ATTPUT, id, /GLOBAL, "cot_thv_era", thvs.era
    NCDF_ATTPUT, id, /GLOBAL, "cot_thv_sat", thvs.sat
    
    dim_tb_id  = NCDF_DIMDEF(id, 'gsize', 2)
    dim_p_id  = NCDF_DIMDEF(id, 'plev', hist.dim_ctp)
    dim_x_id  = NCDF_DIMDEF(id, 'lon', grd.xdim)
    dim_y_id  = NCDF_DIMDEF(id, 'lat', grd.ydim)
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
    NCDF_VARPUT, id, 'lon',inp.lon
    NCDF_VARPUT, id, 'lat',inp.lat
    NCDF_VARPUT, id, 'ctp',erg_plev
    NCDF_VARPUT, id, 'ctp_bnds',erg_plev_bnds
    NCDF_VARPUT, id, 'ctp_hist_era',ave_era.ctp_hist
    NCDF_VARPUT, id, 'ctp_hist_sat',ave_sat.ctp_hist
    NCDF_CLOSE, id

END
