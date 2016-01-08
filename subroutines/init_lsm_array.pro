;---------------------------------------------------------------
; init_lsm_array: 
;   create 2D array containing binary land/sea mask information 
;   based on ERA-Interim SST information
; 
; in:  grd, sst, void
; out: lsm
;---------------------------------------------------------------

FUNCTION INIT_LSM_ARRAY, grd, sst, void, map=map 

    lsm2d = INTARR(grd.xdim,grd.ydim) & lsm2d[*,*] = -999
    land = WHERE( sst EQ MAX(sst[void]) )
    sea  = WHERE( SST GT MAX(sst[void]) )
    lsm2d[land] = 1
    lsm2d[sea] = 0

    IF KEYWORD_SET(map)  THEN BEGIN
        tit = 'Land/Sea Mask for ERA-Interim grid 0.5 x 0.5'
        fil = 'lsm_era_interim_0.5grid'
        PLOT_LSM2D, lsm2d, grd.lat2d, grd.lon2d, tit, fil
    ENDIF

    RETURN, lsm2d

END
