;------------------------------------------------------------------------------
; IN : DATA, GRID, CWP, COT, CER, THRESHOLD
; OUT: TEMP
;------------------------------------------------------------------------------
FUNCTION SEARCH4CLOUD, inp, grd, cwp, cot, cer, thv
;------------------------------------------------------------------------------
; search bottom-up, where is a cloud using COT threshold value
;------------------------------------------------------------------------------

    ; -- fill_value
    fillvalue = -999.

    ; *_bin ... based on binary decision of the phase=cph_tmp_bin
    ; 2D arrays containing the upper-most cloud information

    ; cloud top pressure
    ctp_tmp = FLTARR(grd.XDIM,grd.YDIM) & ctp_tmp[*,*] = fillvalue
    ; cloud top height
    cth_tmp = FLTARR(grd.XDIM,grd.YDIM) & cth_tmp[*,*] = fillvalue
    ; cloud top temperature
    ctt_tmp = FLTARR(grd.XDIM,grd.YDIM) & ctt_tmp[*,*] = fillvalue
    ; cloud phase
    cph_tmp = FLTARR(grd.XDIM,grd.YDIM) & cph_tmp[*,*] = fillvalue
    cph_tmp_bin = FLTARR(grd.XDIM,grd.YDIM) & cph_tmp_bin[*,*] = fillvalue
    ; cloud fraction
    cfc_tmp = FLTARR(grd.XDIM,grd.YDIM) & cfc_tmp[*,*] = 0.
    cfc_tmp_bin = FLTARR(grd.XDIM,grd.YDIM) & cfc_tmp_bin[*,*] = 0.
    ; liquid and ice water path
    lwp_tmp = FLTARR(grd.XDIM,grd.YDIM) & lwp_tmp[*,*] = 0.
    iwp_tmp = FLTARR(grd.XDIM,grd.YDIM) & iwp_tmp[*,*] = 0.
    lwp_tmp_bin = FLTARR(grd.XDIM,grd.YDIM) & lwp_tmp_bin[*,*] = 0.
    iwp_tmp_bin = FLTARR(grd.XDIM,grd.YDIM) & iwp_tmp_bin[*,*] = 0.
    ; liquid and ice cloud optical thickness
    lcot_tmp = FLTARR(grd.XDIM,grd.YDIM) & lcot_tmp[*,*] = 0.
    icot_tmp = FLTARR(grd.XDIM,grd.YDIM) & icot_tmp[*,*] = 0.
    lcot_tmp_bin = FLTARR(grd.XDIM,grd.YDIM) & lcot_tmp_bin[*,*] = 0.
    icot_tmp_bin = FLTARR(grd.XDIM,grd.YDIM) & icot_tmp_bin[*,*] = 0.
    ; liquid and ice cloud effective radius
    lcer_tmp = FLTARR(grd.XDIM,grd.YDIM) & lcer_tmp[*,*] = 0.
    icer_tmp = FLTARR(grd.XDIM,grd.YDIM) & icer_tmp[*,*] = 0.
    lcer_tmp_bin = FLTARR(grd.XDIM,grd.YDIM) & lcer_tmp_bin[*,*] = 0.
    icer_tmp_bin = FLTARR(grd.XDIM,grd.YDIM) & icer_tmp_bin[*,*] = 0.


    FOR z=grd.ZDIM-2,1,-1 DO BEGIN

      cnt = 0
      total_cot = total((cot.LIQ + cot.ICE)[*,*,0:z],3)
      where_cot = where(total_cot GT thv, cnt)

      IF(cnt GT 0) THEN BEGIN

        geop_tmp    = reform(inp.GEOP[*,*,z])/9.81
        temp_tmp    = reform(inp.TEMP[*,*,z])
        lwp_lay_tmp = reform(cwp.LIQ[*,*,z])
        iwp_lay_tmp = reform(cwp.ICE[*,*,z])

        ctp_tmp[where_cot] = inp.plevel[z]/100.
        cth_tmp[where_cot] = geop_tmp[where_cot]
        ctt_tmp[where_cot] = temp_tmp[where_cot]

        lcer_tmp[where_cot] = (cer.LIQ[*,*,z])[where_cot]
        icer_tmp[where_cot] = (cer.ICE[*,*,z])[where_cot]

        ; cloud top phase
        lisum = lwp_lay_tmp[where_cot] + iwp_lay_tmp[where_cot]
        good = WHERE( lisum GT 0., ngood )

        IF (ngood GT 0) THEN BEGIN

            cph_tmp[where_cot[good]] = ( 0.0 > $
                ( lwp_lay_tmp[where_cot[good]] / $
                ( lwp_lay_tmp[where_cot[good]] + $
                iwp_lay_tmp[where_cot[good]] ) ) < 1.0 )

        ENDIF

        ; cloud top phase via binary decision
        cph_tmp_bin[where_cot] = ROUND( cph_tmp[where_cot] )


        ; layer between two levels
        IF(z LT grd.ZDIM-2) THEN BEGIN

          lwp_tmp[where_cot] = (total(cwp.LIQ[*,*,z:*],3))[where_cot]
          iwp_tmp[where_cot] = (total(cwp.ICE[*,*,z:*],3))[where_cot]

          lcot_tmp[where_cot] = (total(cot.LIQ[*,*,z:*],3))[where_cot]
          icot_tmp[where_cot] = (total(cot.ICE[*,*,z:*],3))[where_cot]

          ; normal cloud fraction
          cfc_tmp[where_cot] = ( 0. > ( $
              (max(inp.cc[*,*,z:*],dimension=3))[where_cot] ) < 1.0)

          ; binary cloud fraction
          cfc_tmp_bin[where_cot] = ROUND( ( 0. > ( $
              (max(inp.cc[*,*,z:*],dimension=3))[where_cot] ) < 1.0) )

        ; lowest layer, to be checked
        ENDIF ELSE BEGIN

          lwp_tmp[where_cot] = (cwp.LIQ[*,*,z])[where_cot]
          iwp_tmp[where_cot] = (cwp.ICE[*,*,z])[where_cot]
          
          lcot_tmp[where_cot] = (cot.LIQ[*,*,z])[where_cot]
          icot_tmp[where_cot] = (cot.ICE[*,*,z])[where_cot]

          ; normal cloud fraction
          cfc_tmp[where_cot] = ( 0. > ( $
              (inp.cc[*,*,z])[where_cot] ) < 1.0 )

          ; binary cloud fraction
          cfc_tmp_bin[where_cot] = ROUND( ( 0. > ( $
              (inp.cc[*,*,z])[where_cot] ) < 1.0 ) )

        ENDELSE

      ENDIF

    ENDFOR


    ; cloud top based on binary phase
    wo_liq = WHERE(cph_tmp_bin EQ 1., nliq)
    wo_ice = WHERE(cph_tmp_bin EQ 0., nice)

    ; TOP = liquid
    IF (nliq GT 0) THEN BEGIN
        ; CWP
        lwp_tmp_bin[wo_liq]  = lwp_tmp[wo_liq] + iwp_tmp[wo_liq]
        iwp_tmp_bin[wo_liq]  = 0.
        ; COT
        lcot_tmp_bin[wo_liq] = lcot_tmp[wo_liq] + icot_tmp[wo_liq] 
        icot_tmp_bin[wo_liq] = 0.
        ; CER
        lcer_tmp_bin[wo_liq] = lcer_tmp[wo_liq]
        icer_tmp_bin[wo_liq] = 0.
    ENDIF

    ; TOP = ice
    IF (nice GT 0) THEN BEGIN
        ; CWP
        lwp_tmp_bin[wo_ice]  = 0.
        iwp_tmp_bin[wo_ice]  = lwp_tmp[wo_ice] + iwp_tmp[wo_ice]
        ; COT
        lcot_tmp_bin[wo_ice] = 0.
        icot_tmp_bin[wo_ice] = lcot_tmp[wo_ice] + icot_tmp[wo_ice]
        ; CER
        lcer_tmp_bin[wo_ice] = 0.
        icer_tmp_bin[wo_ice] = icer_tmp[wo_ice]
    ENDIF

        

    ; conistent output w.r.t. cloud fraction
    f = WHERE(cfc_tmp_bin EQ 0., fcnt)

    IF (fcnt GT 0) THEN BEGIN
        ctp_tmp[f] = fillvalue
        cth_tmp[f] = fillvalue
        ctt_tmp[f] = fillvalue
        cph_tmp_bin[f] = fillvalue
        lwp_tmp_bin[f] = 0.
        iwp_tmp_bin[f] = 0.
        lcot_tmp_bin[f] = 0.
        icot_tmp_bin[f] = 0.
        lcer_tmp_bin[f] = 0.
        icer_tmp_bin[f] = 0.
    ENDIF


    ; ----------------------------------------------------------------------
    ; initialized here but required & used in sumup_vars.pro
    total_cwp_bin = FLTARR(grd.XDIM,grd.YDIM) & total_cwp_bin[*,*] = 0.
    total_cot_bin = FLTARR(grd.XDIM,grd.YDIM) & total_cot_bin[*,*] = 0.
    total_cer_bin = FLTARR(grd.XDIM,grd.YDIM) & total_cer_bin[*,*] = 0.
    ; ----------------------------------------------------------------------

    ; -- output structure
    tmp = {temp_arrays, $
           cfc:cfc_tmp_bin, cph:cph_tmp_bin, $
           ctt:ctt_tmp, cth:cth_tmp, ctp:ctp_tmp, $
           cwp:total_cwp_bin, lwp:lwp_tmp_bin, iwp:iwp_tmp_bin, $
           cot:total_cot_bin, cot_liq:lcot_tmp_bin, cot_ice:icot_tmp_bin, $
           cer:total_cer_bin, cer_liq:lcer_tmp_bin, cer_ice:icer_tmp_bin }

    RETURN, tmp

END
