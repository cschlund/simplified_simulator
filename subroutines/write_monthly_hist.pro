;-------------------------------------------------------------------
;-- write netcdf monthly histogram output
;-------------------------------------------------------------------
;
; ** Structure FINAL_OUTPUT, 16 tags, length=537514560, data length=537514560:
;    HIST2D_COT_CTP  LONG      Array[720, 361, 13, 15, 2]
;    HIST1D_CTP      LONG      Array[720, 361, 15, 2]
;    HIST1D_CTT      LONG      Array[720, 361, 16, 2]
;    HIST1D_CWP      LONG      Array[720, 361, 14, 2]
;    HIST1D_COT      LONG      Array[720, 361, 13, 2]
;
; ** Structure HISTOGRAMS, 22 tags, length=984, data length=966:
;    PHASE           INT       Array[2]
;    PHASE_DIM       INT              2
;    CTP2D           FLOAT     Array[2, 15]
;    CTP1D           FLOAT     Array[16]
;    CTP1D_DIM       INT             16
;    CTP_BIN1D       FLOAT     Array[15]
;    CTP_BIN1D_DIM   INT             15
;    COT2D           FLOAT     Array[2, 13]
;    COT1D           FLOAT     Array[14]
;    COT1D_DIM       INT             14
;    COT_BIN1D       FLOAT     Array[13]
;    COT_BIN1D_DIM   INT             13
;    CTT2D           FLOAT     Array[2, 16]
;    CTT1D           FLOAT     Array[17]
;    CTT1D_DIM       INT             17
;    CTT_BIN1D       FLOAT     Array[16]
;    CTT_BIN1D_DIM   INT             16
;    CWP2D           FLOAT     Array[2, 14]
;    CWP1D           FLOAT     Array[15]
;    CWP1D_DIM       INT             15
;    CWP_BIN1D       FLOAT     Array[14]
;    CWP_BIN1D_DIM   INT             14
;
;-------------------------------------------------------------------

PRO WRITE_MONTHLY_HIST, path_out, year, month, grd, inp, $
                        thvs, hist, ave_era, ave_sat, $
                        cnt_era, cnt_sat

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

    ; inp.lon [0;359.5]
    lon = inp.lon - 180.    ;degrees_east
    lat = inp.lat           ;degrees_north

    file_out='SimpSimu_MH'+year+month+'_'+thvs.str+'_CTP.nc'
    clobber=1

    id = NCDF_CREATE(path_out+file_out, CLOBBER = clobber)

    NCDF_ATTPUT, id, /GLOBAL, "Source" , "ERA-Interim" ;
    NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_START" , ""+year+month ;
    NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_RESOLUTION", "P1M"
    NCDF_ATTPUT, id, /GLOBAL, "cot_thv_ori", thvs.era
    NCDF_ATTPUT, id, /GLOBAL, "cot_thv", thvs.sat
    NCDF_ATTPUT, id, /GLOBAL, "number_of_files", cnt_era.raw
    
    dim_x_id = NCDF_DIMDEF(id, 'lon', grd.xdim)
    dim_y_id = NCDF_DIMDEF(id, 'lat', grd.ydim)
    time_id = NCDF_DIMDEF(id, 'time', dim_time)
    dim_phase = NCDF_DIMDEF(id, 'phase_dim', hist.phase_dim)
    dim_ctp1d = NCDF_DIMDEF(id, 'ctp1d_dim', hist.ctp1d_dim)
    dim_ctp_bin1d = NCDF_DIMDEF(id, 'ctp_bin1d_dim', hist.ctp_bin1d_dim)
    dim_ctt1d = NCDF_DIMDEF(id, 'ctt1d_dim', hist.ctt1d_dim)
    dim_ctt_bin1d = NCDF_DIMDEF(id, 'ctt_bin1d_dim', hist.ctt_bin1d_dim)
    dim_cot1d = NCDF_DIMDEF(id, 'cot1d_dim', hist.cot1d_dim)
    dim_cot_bin1d = NCDF_DIMDEF(id, 'cot_bin1d_dim', hist.cot_bin1d_dim)
    dim_cwp1d = NCDF_DIMDEF(id, 'cwp1d_dim', hist.cwp1d_dim)
    dim_cwp_bin1d = NCDF_DIMDEF(id, 'cwp_bin1d_dim', hist.cwp_bin1d_dim)

    vid  = NCDF_VARDEF(id, 'time', [time_id], /DOUBLE)

    vid  = NCDF_VARDEF(id, 'lon', [dim_x_id], /FLOAT)
    NCDF_ATTPUT, id, 'lon', 'long_name', 'longitude'
    NCDF_ATTPUT, id, 'lon', 'units', 'degrees_east'

    vid  = NCDF_VARDEF(id, 'lat', [dim_y_id], /FLOAT)
    NCDF_ATTPUT, id, 'lat', 'long_name', 'latitude'
    NCDF_ATTPUT, id, 'lat', 'units', 'degrees_north'

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

    vid  = NCDF_VARDEF(id, 'hist1d_ctp_ori', $
        [dim_x_id, dim_y_id, dim_ctp_bin1d, dim_phase, time_id], /LONG)
    NCDF_ATTPUT, id, 'hist1d_ctp_ori', 'long_name', 'hist1d_ctp (era)'
    NCDF_ATTPUT, id, 'hist1d_ctp_ori', 'units', 'counts'
    NCDF_ATTPUT, id, 'hist1d_ctp_ori', '_FillValue', -999l, /LONG

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

    vid  = NCDF_VARDEF(id, 'hist1d_ctt_ori', $
        [dim_x_id, dim_y_id, dim_ctt_bin1d, dim_phase, time_id], /LONG)
    NCDF_ATTPUT, id, 'hist1d_ctt_ori', 'long_name', 'hist1d_ctt (era)'
    NCDF_ATTPUT, id, 'hist1d_ctt_ori', 'units', 'counts'
    NCDF_ATTPUT, id, 'hist1d_ctt_ori', '_FillValue', -999l, /LONG

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
    

    ; hist2d_cot_ctp

    vid  = NCDF_VARDEF(id, 'hist2d_cot_ctp_ori', $
        [dim_x_id, dim_y_id, dim_cot_bin1d, dim_ctp_bin1d, dim_phase, time_id], /LONG)
    NCDF_ATTPUT, id, 'hist2d_cot_ctp_ori', 'long_name', 'hist2d_cot_ctp (era)'
    NCDF_ATTPUT, id, 'hist2d_cot_ctp_ori', 'units', 'counts'
    NCDF_ATTPUT, id, 'hist2d_cot_ctp_ori', '_FillValue', -999l, /LONG

    vid  = NCDF_VARDEF(id, 'hist2d_cot_ctp', $
        [dim_x_id, dim_y_id, dim_cot_bin1d, dim_ctp_bin1d, dim_phase, time_id], /LONG)
    NCDF_ATTPUT, id, 'hist2d_cot_ctp', 'long_name', 'hist2d_cot_ctp'
    NCDF_ATTPUT, id, 'hist2d_cot_ctp', 'units', 'counts'
    NCDF_ATTPUT, id, 'hist2d_cot_ctp', '_FillValue', -999l, /LONG



    NCDF_CONTROL, id, /ENDEF

    NCDF_VARPUT, id, 'time',itime
    NCDF_VARPUT, id, 'lon',lon
    NCDF_VARPUT, id, 'lat',lat

    NCDF_VARPUT, id, 'hist_phase',hist.phase
    NCDF_VARPUT, id, 'hist_cot',hist.cot1d
    NCDF_VARPUT, id, 'hist_cot_bin',hist.cot_bin1d
    NCDF_VARPUT, id, 'hist_ctp',hist.ctp1d
    NCDF_VARPUT, id, 'hist_ctp_bin',hist.ctp_bin1d

    NCDF_VARPUT, id, 'hist2d_cot_ctp_ori',ave_era.hist2d_cot_ctp
    NCDF_VARPUT, id, 'hist2d_cot_ctp',ave_sat.hist2d_cot_ctp

    NCDF_VARPUT, id, 'hist_ctp1d_axis', hist.ctp1d
    NCDF_VARPUT, id, 'hist_ctp_bin1d_axis', hist.ctp_bin1d
    NCDF_VARPUT, id, 'hist1d_ctp_ori',ave_era.hist1d_ctp
    NCDF_VARPUT, id, 'hist1d_ctp',ave_sat.hist1d_ctp

    NCDF_VARPUT, id, 'hist_ctt1d_axis', hist.ctt1d
    NCDF_VARPUT, id, 'hist_ctt_bin1d_axis', hist.ctt_bin1d
    NCDF_VARPUT, id, 'hist1d_ctt_ori',ave_era.hist1d_ctt
    NCDF_VARPUT, id, 'hist1d_ctt',ave_sat.hist1d_ctt

    NCDF_VARPUT, id, 'hist_cwp1d_axis', hist.cwp1d
    NCDF_VARPUT, id, 'hist_cwp_bin1d_axis', hist.cwp_bin1d
    NCDF_VARPUT, id, 'hist1d_cwp_ori',ave_era.hist1d_cwp
    NCDF_VARPUT, id, 'hist1d_cwp',ave_sat.hist1d_cwp

    NCDF_VARPUT, id, 'hist_cot1d_axis', hist.cot1d
    NCDF_VARPUT, id, 'hist_cot_bin1d_axis', hist.cot_bin1d
    NCDF_VARPUT, id, 'hist1d_cot_ori',ave_era.hist1d_cot
    NCDF_VARPUT, id, 'hist1d_cot',ave_sat.hist1d_cot

    NCDF_CLOSE, id

    PRINT,'** CREATED: ', path_out + file_out

END
