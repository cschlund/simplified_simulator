;---------------------------------------------------------------
; scale_cot_cwp: 
;   CC4CL L2toL3 where COT GT 100. -> scaled to 100 via
;       cot_factor (scaling factor), which is also applied
;       to cwp (due to Han et al. 1994 formula)
;   apply to pseudo-satellite arrays: 
;      lwp_bin, iwp_bin, cot_liq_bin, cot_ice_bin
;---------------------------------------------------------------
;
; in : tmp, grd
; out: tmp
;
;** Structure TEMP_ARRAYS, 15 tags, length=15595200, data length=15595200:
;   CTP             FLOAT     Array[720, 361]
;   CTH             FLOAT     Array[720, 361]
;   CTT             FLOAT     Array[720, 361]
;   CPH             FLOAT     Array[720, 361]
;   LWP             FLOAT     Array[720, 361]
;   IWP             FLOAT     Array[720, 361]
;   CFC             FLOAT     Array[720, 361]
;   CFC_BIN         FLOAT     Array[720, 361]
;   CPH_BIN         FLOAT     Array[720, 361]
;   LWP_BIN         FLOAT     Array[720, 361]
;   IWP_BIN         FLOAT     Array[720, 361]
;   COT_LIQ         FLOAT     Array[720, 361]
;   COT_ICE         FLOAT     Array[720, 361]
;   COT_LIQ_BIN     FLOAT     Array[720, 361]
;   COT_ICE_BIN     FLOAT     Array[720, 361]
;
;** Structure ERA_GRID, 5 tags, length=2079368, data length=2079366:
;   LON2D           FLOAT     Array[720, 361]
;   LAT2D           FLOAT     Array[720, 361]
;   XDIM            INT            720
;   YDIM            INT            361
;   ZDIM            INT             27
;
;---------------------------------------------------------------

PRO SCALE_COT_CWP, tmp, grd

    ;print, " *** SCALE_COT_CWP "
    ;print, " * Before scaling"
    ;print, "   tmp.lwp_bin    : ", MINMAX(tmp.lwp_bin)
    ;print, "   tmp.iwp_bin    : ", MINMAX(tmp.iwp_bin)
    ;print, "   tmp.cot_liq_bin: ", MINMAX(tmp.cot_liq_bin)
    ;print, "   tmp.cot_ice_bin: ", MINMAX(tmp.cot_ice_bin)

    maxcot = 100.
    scale_liq = FLTARR(grd.xdim,grd.ydim) & scale_liq[*,*] = 1.
    scale_ice = FLTARR(grd.xdim,grd.ydim) & scale_ice[*,*] = 1.

    liq = WHERE( tmp.cot_liq_bin GT maxcot, nliq )
    ice = WHERE( tmp.cot_ice_bin GT maxcot, nice )

    IF ( nliq GT 0 ) THEN BEGIN
        scale_liq[liq] = maxcot / tmp.cot_liq_bin[liq]
        tmp.lwp_bin[liq] = tmp.lwp_bin[liq] * scale_liq[liq]
        tmp.cot_liq_bin[liq] = tmp.cot_liq_bin[liq] * scale_liq[liq]
    ENDIF

    IF ( nice GT 0 ) THEN BEGIN
        scale_ice[ice] = maxcot / tmp.cot_ice_bin[ice]
        tmp.iwp_bin[ice] = tmp.iwp_bin[ice] * scale_ice[ice]
        tmp.cot_ice_bin[ice] = tmp.cot_ice_bin[ice] * scale_ice[ice]
    ENDIF

    ;print, " * After scaling"
    ;print, "   nliq: ", nliq
    ;print, "   nice: ", nice
    ;print, "   tmp.lwp_bin    : ", MINMAX(tmp.lwp_bin)
    ;print, "   tmp.iwp_bin    : ", MINMAX(tmp.iwp_bin)
    ;print, "   tmp.cot_liq_bin: ", MINMAX(tmp.cot_liq_bin)
    ;print, "   tmp.cot_ice_bin: ", MINMAX(tmp.cot_ice_bin)

END
