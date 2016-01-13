;---------------------------------------------------------------
FUNCTION INIT_LSM_ARRAY, GRID=grd, DATA=sst, VOID=void, MAP=map 
;---------------------------------------------------------------

    lsm2d = INTARR(grd.xdim,grd.ydim)
    lsm2d[*,*] = -999

    land = WHERE( sst EQ MAX(sst[void]) )
    sea  = WHERE( SST GT MAX(sst[void]) )

    lsm2d[land] = 1
    lsm2d[sea] = 0

    IF KEYWORD_SET(map)  THEN BEGIN

        tit = 'Land/Sea Mask for ERA-Interim grid 0.5 x 0.5'
        fil = 'lsm_era_interim_0.5_0.5'

        PLOT_LSM2D, FILENAME=fil, DATA=lsm2d, TITLE=tit, $
                    LATITUDE=grd.lat2d, LONGITUDE=grd.lon2d

    ENDIF

    RETURN, lsm2d

END


;-----------------------------------------------------------------------------
FUNCTION INIT_SZA_ARRAY, DATA=data, GRID=grd, MAP=map 
;-----------------------------------------------------------------------------

    jul_day = DOY(data.YEAR, data.MONTH, data.DAY)

    utc2d = FLTARR(grd.xdim,grd.ydim) & utc2d[*,*] = data.HOUR
    day2d = FLTARR(grd.xdim,grd.ydim) & day2d[*,*] = jul_day

    ZENSUN, day2d, utc2d, grd.lat2d, grd.lon2d, sza2d

    IF KEYWORD_SET(map)  THEN BEGIN

        date  = data.YEAR + data.MONTH + data.DAY
        title ='Solar Zenith Angle for ' + date + ' UTC  ' + data.UTC

        PLOT_SZA2D, FILENAME=data.FILENAME, DATA=sza2d, $
                    LATITUDE=grd.lat2d, LONGITUDE=grd.lon2d, $
                    TITLE=title

    ENDIF

    stop
    RETURN, sza2d

END


;-------------------------------------------------------------------
; IN  : DATA
; OUT : GRID
;-------------------------------------------------------------------
PRO INIT_ERA_GRID, DATA=data, GRID=grid
;-------------------------------------------------------------------

    ; set x,y,z dimensions using liquid water content variable
    xdim = FIX(N_ELEMENTS(data.lwc[*,0,0]))
    ydim = FIX(N_ELEMENTS(data.lwc[0,*,0]))
    zdim = FIX(N_ELEMENTS(data.lwc[0,0,*]))
    
    ; define longitude & latitude arrays ;[cols, rows]
    longrd=FLTARR(xdim,ydim)
    latgrd=FLTARR(xdim,ydim)
    
    ; create lat/lon grid arrays using lon & lat from ncfile
    FOR loi=0,xdim-1 DO longrd[loi,*]=data.lon[loi]
    FOR lai=0,ydim-1 DO latgrd[*,lai]=data.lat[lai]

    grid = { era_grid, $
             lon2d:longrd, lat2d:latgrd, $
             xdim:xdim, ydim:ydim, zdim:zdim }

END


;-------------------------------------------------------------------
; IN : GRIS, HIST_INFO
; OUT: ARRAYS, COUNTS
;-------------------------------------------------------------------
PRO INIT_OUT_ARRAYS, GRID=grid, HIST_INFO=hist, $
                     ARRAYS=arrays, COUNTS=counts
;-------------------------------------------------------------------

    ; cloud fraction
    cfc = FLTARR(grid.xdim,grid.ydim) & cfc[*,*] = 0
    ; cloud phase
    cph = FLTARR(grid.xdim,grid.ydim) & cph[*,*] = 0
    ; cloud top temperature
    ctt = FLTARR(grid.xdim,grid.ydim) & ctt[*,*] = 0
    ; cloud top height
    cth = FLTARR(grid.xdim,grid.ydim) & cth[*,*] = 0
    ; cloud top pressure
    ctp = FLTARR(grid.xdim,grid.ydim) & ctp[*,*] = 0
    ; cloud water path = lwp + iwp
    cwp = FLTARR(grid.xdim,grid.ydim) & cwp[*,*] = 0
    ; liquid water path
    lwp = FLTARR(grid.xdim,grid.ydim) & lwp[*,*] = 0
    ; ice water path
    iwp = FLTARR(grid.xdim,grid.ydim) & iwp[*,*] = 0
    ; cloud optical thickness
    cot = FLTARR(grid.xdim,grid.ydim) & cot[*,*] = 0
    cot_liq = FLTARR(grid.xdim,grid.ydim) & cot_liq[*,*] = 0
    cot_ice = FLTARR(grid.xdim,grid.ydim) & cot_ice[*,*] = 0
    ; cloud effective radius
    cer = FLTARR(grid.xdim,grid.ydim) & cer[*,*] = 0
    cer_liq = FLTARR(grid.xdim,grid.ydim) & cer_liq[*,*] = 0
    cer_ice = FLTARR(grid.xdim,grid.ydim) & cer_ice[*,*] = 0

    ; -- hist1d [lon,lat,bins,phase] = [720,361,15,2]
    hist1d_ctp = LONARR(grid.xdim,grid.ydim,hist.ctp_bin1d_dim,hist.phase_dim) 
    hist1d_ctp[*,*,*,*] = 0l
    hist1d_ctt = LONARR(grid.xdim,grid.ydim,hist.ctt_bin1d_dim,hist.phase_dim) 
    hist1d_ctt[*,*,*,*] = 0l
    hist1d_cwp = LONARR(grid.xdim,grid.ydim,hist.cwp_bin1d_dim,hist.phase_dim) 
    hist1d_cwp[*,*,*,*] = 0l
    hist1d_cot = LONARR(grid.xdim,grid.ydim,hist.cot_bin1d_dim,hist.phase_dim) 
    hist1d_cot[*,*,*,*] = 0l
    hist1d_cer = LONARR(grid.xdim,grid.ydim,hist.cer_bin1d_dim,hist.phase_dim) 
    hist1d_cer[*,*,*,*] = 0l

    ; -- hist2d [lon,lat,cotbins,ctpbins,phase] = [720,361,13,15,2]
    hist2d_cot_ctp = LONARR(grid.xdim, grid.ydim, $
                            hist.cot_bin1d_dim, hist.ctp_bin1d_dim, $
                            hist.phase_dim) 
    hist2d_cot_ctp[*,*,*,*] = 0l

    ; -- counts
    numb_raw = 0l ; files & for cfc
    numb_ctp = LONARR(grid.xdim,grid.ydim) & numb_ctp[*,*] = 0
    numb_cwp = LONARR(grid.xdim,grid.ydim) & numb_cwp[*,*] = 0
    numb_lwp = LONARR(grid.xdim,grid.ydim) & numb_lwp[*,*] = 0
    numb_iwp = LONARR(grid.xdim,grid.ydim) & numb_iwp[*,*] = 0
    numb_cot = LONARR(grid.xdim,grid.ydim) & numb_cot[*,*] = 0
    numb_cot_liq = LONARR(grid.xdim,grid.ydim) & numb_cot_liq[*,*] = 0
    numb_cot_ice = LONARR(grid.xdim,grid.ydim) & numb_cot_ice[*,*] = 0
    numb_cer = LONARR(grid.xdim,grid.ydim) & numb_cer[*,*] = 0
    numb_cer_liq = LONARR(grid.xdim,grid.ydim) & numb_cer_liq[*,*] = 0
    numb_cer_ice = LONARR(grid.xdim,grid.ydim) & numb_cer_ice[*,*] = 0


    ; -- create structure
    arrays = { monthly_means, $
               hist2d_cot_ctp:hist2d_cot_ctp, $
               hist1d_ctp:hist1d_ctp, $ 
               hist1d_ctt:hist1d_ctt, $ 
               hist1d_cwp:hist1d_cwp, $ 
               hist1d_cot:hist1d_cot, $ 
               hist1d_cer:hist1d_cer, $ 
               cfc:cfc, cph:cph, ctt:ctt, $
               cth:cth, ctp:ctp, cwp:cwp, $
               lwp:lwp, iwp:iwp, $
               cot:cot, cot_liq:cot_liq, cot_ice:cot_ice, $
               cer:cer, cer_liq:cer_liq, cer_ice:cer_ice }

    counts = { counts_monthly_means,$ 
               raw:numb_raw, $
               ctp:numb_ctp, $
               cwp:numb_cwp, $
               lwp:numb_lwp, $
               iwp:numb_iwp, $ 
               cot:numb_cot, $
               cot_liq:numb_cot_liq, $
               cot_ice:numb_cot_ice, $
               cer:numb_cer, $
               cer_liq:numb_cer_liq, $
               cer_ice:numb_cer_ice }

END
