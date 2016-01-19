;------------------------------------------------------------------------------
; scops-like method in order to collect COT & CWP & CFC
; overlap type: random
; IN & OUT: COT_TMP, CWP_TMP, CFC_TMP
;------------------------------------------------------------------------------
PRO SCOPS, erainp, cotinp, cwpinp, cot_idx, zlev, cot_tmp, cwp_tmp, cfc_tmp

    ; loop over indices where COT exceeded threshold
    FOR iii=0, N_ELEMENTS(cot_idx)-2,1 DO BEGIN 
    
        ; get indices where cot_threshold exceeded
        inds = ARRAY_INDICES( cot_tmp, cot_idx[iii] )
    
        ; get total cot profile
        cot_prof_total = 0. > ( REFORM( $ 
            cotinp.LIQ[inds[0], inds[1], zlev:*] + $ 
            cotinp.ICE[inds[0], inds[1], zlev:*] ) )

        ; get total cwp profile
        cwp_prof_total = 0. > ( REFORM( $ 
            cwpinp.LIQ[inds[0], inds[1], zlev:*] + $ 
            cwpinp.ICE[inds[0], inds[1], zlev:*] ) )
    
        ; get cloud fraction profile, i.e. layer resolved
        cfc_profile = erainp.CC[inds[0], inds[1], $
                                0:N_ELEMENTS(erainp.CC[0,0,*])-2] * 0.5 $
                    + erainp.CC[inds[0], inds[1], $
                                1:N_ELEMENTS(erainp.CC[0,0,*])-1] * 0.5
        cfc_profile = 0. > REFORM( cfc_profile[zlev:*] )
    
        nlev = N_ELEMENTS( cfc_profile ) ; number of zlevels
        ncol = 20 ; number of subcolumns

        ; initiale total cot & cwp matrix
        matrix_cot = FLTARR( ncol, nlev ) * 0.
        matrix_cwp = FLTARR( ncol, nlev ) * 0.
        matrix_cfc = FLTARR( ncol, nlev ) * 0.
    
            FOR jjj=0, nlev-1 DO BEGIN

                nfilledboxes = FLOOR( ncol * cfc_profile[jjj] )

                IF(nfilledboxes GT 0) THEN BEGIN

                    IF(ncol NE nfilledboxes) THEN BEGIN 
                        ; result  = cgRandomIndices(length, number)
                        ; indices = cgRandomIndices(100, 10, SEED=seed)
                        ; To select 10 random indices from a list of 100.
                        ; The seed for the random number generator. 
                        ; Select NFILLEDBOXES random indices from a list of NCOL.
                        xidx = cgRandomIndices( ncol, nfilledboxes, SEED=seed )
                    ENDIF ELSE BEGIN 
                        xidx = ROUND( FINDGEN(ncol) )
                    ENDELSE

                    matrix_cot[xidx,jjj] = cot_prof_total[jjj]
                    matrix_cwp[xidx,jjj] = cwp_prof_total[jjj]
                    matrix_cfc[xidx,jjj] = 1.

                ENDIF

            ENDFOR

        ; 1.) TOTAL over individual subcolumns: res = ncol values
        ; 2.) MEAN over ncol values: res = 1 value
        cot_tmp[cot_idx[iii]] = MEAN( TOTAL( matrix_cot, 2 ) )
        cwp_tmp[cot_idx[iii]] = MEAN( TOTAL( matrix_cwp, 2 ) )
        ; 3.) ROUND cloud fraction: either 0 or 1 (binary cloud mask)
        cfc_tmp[cot_idx[iii]] = ROUND(MEAN(0.>(TOTAL(matrix_cfc,2))<1.0))

    ENDFOR

END


;------------------------------------------------------------------------------
; IN : DATA, GRID, CWP, COT, CER, THRESHOLD
; OUT: TEMP
; search bottom-up, where is a cloud using COT threshold value
;------------------------------------------------------------------------------
FUNCTION SEARCH4CLOUD, inp, grd, cwp, cot, cer, thv
;------------------------------------------------------------------------------

    ; fill_value
    fillvalue = -999.

    ; 2D arrays containing the upper-most cloud information
    ; *_bin ... based on binary cloud phase decision (liquid=1 OR ice=0)
    ctp_tmp      = FLTARR(grd.XDIM,grd.YDIM) & ctp_tmp[*,*] = fillvalue
    cth_tmp      = FLTARR(grd.XDIM,grd.YDIM) & cth_tmp[*,*] = fillvalue
    ctt_tmp      = FLTARR(grd.XDIM,grd.YDIM) & ctt_tmp[*,*] = fillvalue
    cph_tmp_bin  = FLTARR(grd.XDIM,grd.YDIM) & cph_tmp_bin[*,*] = fillvalue
    cfc_tmp_bin  = FLTARR(grd.XDIM,grd.YDIM) & cfc_tmp_bin[*,*] = 0.
    cwp_tmp      = FLTARR(grd.XDIM,grd.YDIM) & cwp_tmp[*,*] = 0.
    lwp_tmp_bin  = FLTARR(grd.XDIM,grd.YDIM) & lwp_tmp_bin[*,*] = 0.
    iwp_tmp_bin  = FLTARR(grd.XDIM,grd.YDIM) & iwp_tmp_bin[*,*] = 0.
    cot_tmp      = FLTARR(grd.XDIM,grd.YDIM) & cot_tmp[*,*] = 0.
    lcot_tmp_bin = FLTARR(grd.XDIM,grd.YDIM) & lcot_tmp_bin[*,*] = 0.
    icot_tmp_bin = FLTARR(grd.XDIM,grd.YDIM) & icot_tmp_bin[*,*] = 0.
    lcer_tmp     = FLTARR(grd.XDIM,grd.YDIM) & lcer_tmp[*,*] = 0.
    icer_tmp     = FLTARR(grd.XDIM,grd.YDIM) & icer_tmp[*,*] = 0.
    lcer_tmp_bin = FLTARR(grd.XDIM,grd.YDIM) & lcer_tmp_bin[*,*] = 0.
    icer_tmp_bin = FLTARR(grd.XDIM,grd.YDIM) & icer_tmp_bin[*,*] = 0.

    FOR z=grd.ZDIM-2,1,-1 DO BEGIN
        cnt = 0
        total_cot = TOTAL( (cot.LIQ + cot.ICE)[*,*,0:z], 3 )
        true = WHERE( total_cot GT thv, cnt )

        IF ( cnt GT 0 ) THEN BEGIN

            ctp_tmp[true]  = inp.plevel[z] / 100.
            cth_tmp[true]  = (inp.GEOP[*,*,z])[true] / 9.81
            ctt_tmp[true]  = (inp.TEMP[*,*,z])[true]
            lcer_tmp[true] = (cer.LIQ[*,*,z])[true]
            icer_tmp[true] = (cer.ICE[*,*,z])[true]
            lwp_lay_tmp    = REFORM(cwp.LIQ[*,*,z])
            iwp_lay_tmp    = REFORM(cwp.ICE[*,*,z])

            lisum = lwp_lay_tmp[true] + iwp_lay_tmp[true]
            good  = WHERE( lisum GT 0., ngood )
            IF (ngood GT 0) THEN BEGIN
                cph_tmp_bin[true[good]] = ROUND( ( 0.0 > $
                    ( lwp_lay_tmp[true[good]] / ( lwp_lay_tmp[true[good]] $
                    + iwp_lay_tmp[true[good]] ) ) < 1.0 ) )
            ENDIF

            IF(z LT grd.ZDIM-2) THEN BEGIN ; layer between two levels

                SCOPS, inp, cot, cwp, true, z, $       ; IN
                       cot_tmp, cwp_tmp, cfc_tmp_bin   ; IN & OUT

            ENDIF ELSE BEGIN ; lowest layer, to be checked

                cfc_tmp_bin[true] = ROUND( ( 0. > $
                    ( (inp.CC[*,*,z])[true] ) < 1.0 ) )
                cwp_tmp[true] = (cwp.LIQ[*,*,z] + cwp.ICE[*,*,z])[true]
                cot_tmp[true] = (cot.LIQ[*,*,z] + cot.ICE[*,*,z])[true]

            ENDELSE

        ENDIF
    ENDFOR

    ; cloud top based on binary phase
    wo_liq = WHERE(cph_tmp_bin EQ 1., nliq)
    wo_ice = WHERE(cph_tmp_bin EQ 0., nice)

    ; TOP = liquid
    IF (nliq GT 0) THEN BEGIN
        lwp_tmp_bin[wo_liq]  = cwp_tmp[wo_liq]
        iwp_tmp_bin[wo_liq]  = 0.
        lcot_tmp_bin[wo_liq] = cot_tmp[wo_liq] 
        icot_tmp_bin[wo_liq] = 0.
        lcer_tmp_bin[wo_liq] = lcer_tmp[wo_liq]
        icer_tmp_bin[wo_liq] = 0.
    ENDIF

    ; TOP = ice
    IF (nice GT 0) THEN BEGIN
        lwp_tmp_bin[wo_ice]  = 0.
        iwp_tmp_bin[wo_ice]  = cwp_tmp[wo_ice]
        lcot_tmp_bin[wo_ice] = 0.
        icot_tmp_bin[wo_ice] = cot_tmp[wo_ice]
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

    ; output structure
    tmp = {temp_arrays, $
           cfc:cfc_tmp_bin, cph:cph_tmp_bin, $
           ctt:ctt_tmp, cth:cth_tmp, ctp:ctp_tmp, $
           cwp:total_cwp_bin, lwp:lwp_tmp_bin, iwp:iwp_tmp_bin, $
           cot:total_cot_bin, cot_liq:lcot_tmp_bin, cot_ice:icot_tmp_bin, $
           cer:total_cer_bin, cer_liq:lcer_tmp_bin, cer_ice:icer_tmp_bin }

    RETURN, tmp

END
