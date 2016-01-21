;------------------------------------------------------------------------------
; IN : DATA, GRID, CWP, COT, CER, THRESHOLD
; OUT: TEMP
; search bottom-up, where is a cloud using COT threshold value
;------------------------------------------------------------------------------
FUNCTION SEARCH4CLOUD, inp, grd, scops_type, cwp, cot, cer, thv
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


    ; loop over individual grid cells
    FOR xi=0, grd.xdim-1, 1 DO BEGIN ;longitude
        FOR yi=0, grd.ydim-1, 1 DO BEGIN ;latitude

            cot_prof_total = 0. > (REFORM(cot.LIQ[xi,yi,*]+cot.ICE[xi,yi,*]))
            cwp_prof_total = 0. > (REFORM(cwp.LIQ[xi,yi,*]+cwp.ICE[xi,yi,*]))
            cfc_lay_prof = inp.CC[xi,yi,0:N_ELEMENTS(inp.CC[0,0,*])-2]*0.5 + $
                           inp.CC[xi,yi,1:N_ELEMENTS(inp.CC[0,0,*])-1]*0.5
            cfc_lay_prof = 0. > REFORM(cfc_lay_prof[*])
            nlev = N_ELEMENTS(cfc_lay_prof)
            ncol = 20
            
            matrix_cot = FLTARR(ncol,nlev)*0.
            matrix_cwp = FLTARR(ncol,nlev)*0.
            matrix_cfc = FLTARR(ncol,nlev)*0.
            
            first = -1
            lastcloud = -1

            FOR zi=0, nlev-1 DO BEGIN

                nfb = FLOOR(ncol * cfc_lay_prof[zi]) ;nfilledboxes

                IF (nfb GT 0 AND TOTAL(cot_prof_total[0:zi]) GT thv) THEN BEGIN

                    IF (first EQ -1) THEN BEGIN
                        first = 0
                        ctp_tmp[xi,yi]  = inp.PLEVEL[zi]/100.
                        cth_tmp[xi,yi]  = inp.GEOP[xi,yi,zi]/9.81
                        ctt_tmp[xi,yi]  = inp.TEMP[xi,yi,zi]
                        lcer_tmp[xi,yi] = cer.LIQ[xi,yi,zi]
                        icer_tmp[xi,yi] = cer.ICE[xi,yi,zi]
                        lwp_lay = cwp.LIQ[xi,yi,zi]
                        iwp_lay = cwp.ICE[xi,yi,zi]
                        cwp_lay = lwp_lay+iwp_lay
                        IF (cwp_lay GT 0.) THEN cph_tmp_bin[xi,yi] = 0. > $
                            ROUND((0.0 > (lwp_lay/(cwp_lay) ) < 1.0)) < 1.0
                    ENDIF
                    
                    IF (lastcloud NE (zi-1) OR scops_type EQ 1) THEN BEGIN
                        x = LINDGEN(ncol)
                        y = RANDOMU(dseed, ncol)
                        ci = x[SORT(y)]
                    ENDIF
                    
                    matrix_cot[ci[0:nfb-1],zi] = cot_prof_total[zi]
                    matrix_cwp[ci[0:nfb-1],zi] = cwp_prof_total[zi]
                    matrix_cfc[ci[0:nfb-1],zi] = 1.0
                    lastcloud = zi
                ENDIF
            ENDFOR
            
            ; 1.) TOTAL over individual subcolumns: result = ncol values
            ; 2.) MEAN over ncol values: result = 1 value
            cot_tmp[xi,yi] = MEAN( TOTAL( matrix_cot, 2 ) )
            cwp_tmp[xi,yi] = MEAN( TOTAL( matrix_cwp, 2 ) )

            ; 3.) ROUND cloud fraction: either 0 or 1 (binary cloud mask)
            cfc_tmp_bin[xi,yi] = 0. > ROUND( $
                MEAN( 0. > (TOTAL(matrix_cfc,2) ) < 1.0) ) < 1.0

        ENDFOR
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
