
;-------------------------------------------------------------------
;-- search bottom-up, where is a cloud using COT threshold value
;-------------------------------------------------------------------
;
; in : inp, grd, cwp, cot, thv
; out: tmp
;
; inp ... input era interim 3d reanalysis fields
; grd ... era interim grid information
; cwp ... liquid and ice water path per layer
; cot ... incloud liquid and ice cloud optical thickness per layer
; thv ... COT threshold
; tmp ... temporary arrays
;
;-------------------------------------------------------------------

PRO SEARCH_FOR_CLOUD, inp, grd, cwp, cot, thv, tmp


    ; initialize arrays
    ctp_tmp = FLTARR(grd.xdim,grd.ydim) & ctp_tmp[*,*] = -999.
    cth_tmp = FLTARR(grd.xdim,grd.ydim) & cth_tmp[*,*] = -999.
    ctt_tmp = FLTARR(grd.xdim,grd.ydim) & ctt_tmp[*,*] = -999.
    cph_tmp = FLTARR(grd.xdim,grd.ydim) & cph_tmp[*,*] = -999.
    lwp_tmp = FLTARR(grd.xdim,grd.ydim) & lwp_tmp[*,*] = 0.
    iwp_tmp = FLTARR(grd.xdim,grd.ydim) & iwp_tmp[*,*] = 0.
    cfc_tmp = FLTARR(grd.xdim,grd.ydim) & cfc_tmp[*,*] = 0.
    ; binary based cfc and cph
    cfc_tmp_bin = FLTARR(grd.xdim,grd.ydim) & cfc_tmp_bin[*,*] = 0.
    cph_tmp_bin = FLTARR(grd.xdim,grd.ydim) & cph_tmp_bin[*,*] = -999.
    ; lwp and iwp based on binary decision of cph
    lwp_tmp_bin = FLTARR(grd.xdim,grd.ydim) & lwp_tmp_bin[*,*] = 0.
    iwp_tmp_bin = FLTARR(grd.xdim,grd.ydim) & iwp_tmp_bin[*,*] = 0.


    FOR z=grd.zdim-2,1,-1 DO BEGIN

      total_cot = total((cot.liq + cot.ice)[*,*,0:z],3)
      where_cot = where(total_cot GT thv, cnt)


      IF(cnt GT 0) THEN BEGIN

        geop_tmp    = reform(inp.geop[*,*,z])/9.81
        temp_tmp    = reform(inp.temp[*,*,z])
        lwp_lay_tmp = reform(cwp.lwp[*,*,z])
        iwp_lay_tmp = reform(cwp.iwp[*,*,z])

        ctp_tmp[where_cot] = inp.plevel[z]/100.
        cth_tmp[where_cot] = geop_tmp[where_cot]
        ctt_tmp[where_cot] = temp_tmp[where_cot]


        ; avoiding -NaN output due to 0./(0.+ 0.)
        ; % Program caused arithmetic error: Floating illegal operand
        lwp_idx = WHERE(lwp_lay_tmp[where_cot] GT 0., cnt_lwp_idx)

        ; cloud top phase
        cph_tmp[where_cot[lwp_idx]] = (0.0 > $
            ( lwp_lay_tmp[where_cot[lwp_idx]] / $
            ( lwp_lay_tmp[where_cot[lwp_idx]] + iwp_lay_tmp[where_cot[lwp_idx]] ) ) < 1.0)

        nanidx = WHERE( ~FINITE(cph_tmp), cnt_nan )
        IF (cnt_nan GT 0) THEN cph_tmp[nanidx] = -999.

        ; cloud top phase via binary decision
        cph_tmp_bin[where_cot[lwp_idx]] = ROUND( cph_tmp[where_cot[lwp_idx]] )


        ; layer between two levels
        IF(z LT grd.zdim-2) THEN BEGIN

          lwp_tmp[where_cot] = (total(cwp.lwp[*,*,z:*],3))[where_cot]
          iwp_tmp[where_cot] = (total(cwp.iwp[*,*,z:*],3))[where_cot]
          cfc_tmp[where_cot] = (0. > ( (max(inp.cc[*,*,z:*],dimension=3))[where_cot] ) < 1.0)
          cfc_tmp_bin[where_cot] = ROUND( (0. > ( (max(inp.cc[*,*,z:*],dimension=3))[where_cot] ) < 1.0) )


        ; lowest layer, to be checked
        ENDIF ELSE BEGIN

          lwp_tmp[where_cot] = (cwp.lwp[*,*,z])[where_cot]
          iwp_tmp[where_cot] = (cwp.iwp[*,*,z])[where_cot]
          cfc_tmp[where_cot] = (0. > ( (inp.cc[*,*,z])[where_cot] ) < 1.0 )
          cfc_tmp_bin[where_cot] = ROUND( (0. > ( (inp.cc[*,*,z])[where_cot] ) < 1.0 ) )

        ENDELSE


      ENDIF


    ENDFOR


    ; ---
    ; LWP and IWP calculation based on cph_tmp_bin & lwp_tmp & iwp_tmp
    ; cloud top: 0=ice, 1=liquid
    ; ---

    wo_liq = WHERE(cph_tmp_bin EQ 1., nliq)
    wo_ice = WHERE(cph_tmp_bin EQ 0., nice)

    IF (nliq GT 0) THEN BEGIN
        lwp_tmp_bin[wo_liq] = lwp_tmp[wo_liq] + iwp_tmp[wo_liq]
        iwp_tmp_bin[wo_liq] = 0.
    ENDIF

    IF (nice GT 0) THEN BEGIN
        lwp_tmp_bin[wo_ice] = 0.
        iwp_tmp_bin[wo_ice] = lwp_tmp[wo_ice] + iwp_tmp[wo_ice]
    ENDIF


    ; output structure
    tmp = {ctp:ctp_tmp, cth:cth_tmp, ctt:ctt_tmp, cph:cph_tmp,$
           lwp:lwp_tmp, iwp:iwp_tmp, cfc:cfc_tmp, $
           cfc_bin:cfc_tmp_bin, cph_bin:cph_tmp_bin, $
           lwp_bin:lwp_tmp_bin, iwp_bin:iwp_tmp_bin}

END
