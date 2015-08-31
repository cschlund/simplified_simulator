
;-------------------------------------------------------------------
;-- search bottom-up, where is a cloud using COT threshold value
;-------------------------------------------------------------------
;
; in : lcot_lay, icot_lay, cot_thv, xdim, ydim, zdim,
;      geop, temp, lwp_lay, iwp_lay, plevel, cc
;
; out: ctp_tmp, cth_tmp, ctt_tmp, cph_tmp, lwp_tmp, iwp_tmp, cfc_tmp
;
;-------------------------------------------------------------------

PRO SEARCH_FOR_CLOUD, lcot_lay, icot_lay, cot_thv, xdim, ydim, zdim, $
                      geop, temp, lwp_lay, iwp_lay, plevel, cc, $
                      ctp_tmp, cth_tmp, ctt_tmp, cph_tmp, $
                      lwp_tmp, iwp_tmp, cfc_tmp


    ; initialize arrays
    ctp_tmp = FLTARR(xdim,ydim) & ctp_tmp[*,*] = -999.
    cth_tmp = FLTARR(xdim,ydim) & cth_tmp[*,*] = -999.
    ctt_tmp = FLTARR(xdim,ydim) & ctt_tmp[*,*] = -999.
    cph_tmp = FLTARR(xdim,ydim) & cph_tmp[*,*] = -999.
    lwp_tmp = FLTARR(xdim,ydim) & lwp_tmp[*,*] = 0.
    iwp_tmp = FLTARR(xdim,ydim) & iwp_tmp[*,*] = 0.
    cfc_tmp = FLTARR(xdim,ydim) & cfc_tmp[*,*] = 0.


    FOR z=zdim-2,1,-1 DO BEGIN

      total_cot = total((lcot_lay+icot_lay)[*,*,0:z],3)
      where_cot = where(total_cot GT cot_thv, cnt)


      IF(cnt GT 0) THEN BEGIN

        geop_tmp    = reform(geop[*,*,z])/9.81
        temp_tmp    = reform(temp[*,*,z])
        lwp_lay_tmp = reform(lwp_lay[*,*,z])
        iwp_lay_tmp = reform(iwp_lay[*,*,z])

        ctp_tmp[where_cot] = plevel[z]/100.
        cth_tmp[where_cot] = geop_tmp[where_cot]
        ctt_tmp[where_cot] = temp_tmp[where_cot]

        ; cloud top phase via binary decision
        cph_tmp[where_cot] = ROUND( (0. > ( lwp_lay_tmp[where_cot] / $
            (lwp_lay_tmp[where_cot] + iwp_lay_tmp[where_cot]) ) < 1.0) )

        ; cph: if cph = round(0./(0. + 0.)) then round(Nan) = -2.14748e+09
        idx = WHERE(cph_tmp[where_cot] LT -999., nidx)
        IF (nidx GT 0) THEN cph_tmp[where_cot[idx]] = -999.

        ; cloud top: 0=ice, 1=liquid
        wo_ice = WHERE(cph_tmp[where_cot] EQ 0., nice)
        wo_liq = WHERE(cph_tmp[where_cot] EQ 1., nliq)


        ; layer between two levels
        IF(z LT zdim-2) THEN BEGIN

          IF (nliq GT 0) THEN BEGIN
            lwp_tmp[where_cot[wo_liq]] = (total(lwp_lay+iwp_lay[*,*,z:*],3))[where_cot[wo_liq]]
            iwp_tmp[where_cot[wo_liq]] = 0.
          ENDIF

          IF (nice GT 0) THEN BEGIN
            iwp_tmp[where_cot[wo_ice]] = (total(lwp_lay+iwp_lay[*,*,z:*],3))[where_cot[wo_ice]]
            lwp_tmp[where_cot[wo_ice]] = 0.
          ENDIF

          cfc_tmp[where_cot] = ROUND( (0. > ( (max(cc[*,*,z:*],dimension=3))[where_cot] ) < 1.0) )


        ; lowest layer, to be checked
        ENDIF ELSE BEGIN

          IF (nliq GT 0) THEN BEGIN
            lwp_tmp[where_cot[wo_liq]] = (total(lwp_lay+iwp_lay[*,*,z]))[where_cot[wo_liq]]
            iwp_tmp[where_cot[wo_liq]] = 0.
          ENDIF

          IF (nice GT 0) THEN BEGIN
            iwp_tmp[where_cot[wo_ice]] = (total(lwp_lay+iwp_lay[*,*,z]))[where_cot[wo_ice]]
            lwp_tmp[where_cot[wo_ice]] = 0.
          ENDIF

          cfc_tmp[where_cot] = ROUND( (0. > ( (cc[*,*,z])[where_cot] ) < 1.0 ) )

        ENDELSE


      ENDIF


    ENDFOR


END
