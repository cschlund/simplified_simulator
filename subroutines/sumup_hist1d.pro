;---------------------------------------------------------------
; sum up 1d histograms: 
; -- NOTE --
; simulator -> 0=ice,    1=liquid
; cc4cl     -> 0=liquid, 1=ice
; 
; for 'sat' use
;   var_tmp combined with cph_tmp
;   cph_tmp_bin and cfc_tmp_bin (BINARY - 0. or 1. !)
;
; for 'era' use
;   liq_tmp combined with ice_tmp without cph_tmp
;   cph_tmp and cfc_tmp ranging between 0. and 1.
;
;---------------------------------------------------------------

FUNCTION SUMUP_HIST1D, bin_dim=bin1d_dim, $
                       cph_dim=phase_dim, $
                       lim_bin=bbins, $
                       var_tmp=var, $
                       liq_tmp=liq, $
                       ice_tmp=ice, $
                       cfc_tmp=cfc, $
                       cph_tmp=phase

    IF KEYWORD_SET(liq) AND KEYWORD_SET(ice)  $
        AND ~KEYWORD_SET(phase) THEN BEGIN 

        dims = SIZE(liq, /DIM)

    ENDIF ELSE IF KEYWORD_SET(var) $
        AND KEYWORD_SET(phase) THEN BEGIN

        dims = SIZE(var, /DIM)

    ENDIF

    ; counts [lon,lat]
    cnts = LONARR(dims[0],dims[1])
    cnts[*,*] = 0l 

    ; hist1d [lon,lat,bins,phase] = [720,361,15,2]
    vmean = LONARR(dims[0],dims[1],bin1d_dim,phase_dim) 
    vmean[*,*,*,*] = 0l

    ; last bin
    gu_last = bin1d_dim-1

    FOR gu=0, gu_last DO BEGIN 

        ; consider also last bin-border via GE & LE
        IF ( gu EQ gu_last ) THEN BEGIN

            IF KEYWORD_SET(liq) AND KEYWORD_SET(ice) $
                AND ~KEYWORD_SET(phase) THEN BEGIN

                wohi_ice = WHERE( ice GE bbins[0,gu] AND $ 
                                  ice LE bbins[1,gu] AND $
                                  cfc GT 0. , nwohi_ice )

                wohi_liq = WHERE( liq GE bbins[0,gu] AND $ 
                                  liq LE bbins[1,gu] AND $
                                  cfc GT 0. , nwohi_liq )


            ENDIF ELSE IF KEYWORD_SET(var) AND KEYWORD_SET(phase) THEN BEGIN

                wohi_ice = WHERE( var GE bbins[0,gu] AND $ 
                                  var LE bbins[1,gu] AND $
                                  cfc EQ 1. AND phase EQ 0., $
                                  nwohi_ice )

                wohi_liq = WHERE( var GE bbins[0,gu] AND $ 
                                  var LE bbins[1,gu] AND $
                                  cfc EQ 1. AND phase EQ 1., $
                                  nwohi_liq )

            ENDIF

        ; between GE & LT
        ENDIF ELSE BEGIN

            IF KEYWORD_SET(liq) AND KEYWORD_SET(ice) $
                AND ~KEYWORD_SET(phase) THEN BEGIN

                wohi_ice = WHERE( ice GE bbins[0,gu] AND $ 
                                  ice LT bbins[1,gu] AND $
                                  ice GT 0. AND $
                                  cfc GT 0. , nwohi_ice )

                wohi_liq = WHERE( liq GE bbins[0,gu] AND $ 
                                  liq LT bbins[1,gu] AND $
                                  liq GT 0. AND $
                                  cfc GT 0. , nwohi_liq )


            ENDIF ELSE IF KEYWORD_SET(var) AND KEYWORD_SET(phase) THEN BEGIN
                
                wohi_ice = WHERE( var GE bbins[0,gu] AND $ 
                                  var LT bbins[1,gu] AND $
                                  var GT 0. AND $
                                  cfc EQ 1. AND phase EQ 0., $
                                  nwohi_ice )

                wohi_liq = WHERE( var GE bbins[0,gu] AND $ 
                                  var LT bbins[1,gu] AND $
                                  var GT 0. AND $
                                  cfc EQ 1. AND phase EQ 1., $
                                  nwohi_liq )

            ENDIF

        ENDELSE


        IF ( nwohi_ice GT 0 ) THEN BEGIN
            cnts[wohi_ice] = 1l
            vmean[*,*,gu,1] = vmean[*,*,gu,1] + cnts
            cnts[*,*] = 0l 
        ENDIF


        IF ( nwohi_liq GT 0 ) THEN BEGIN
            cnts[wohi_liq] = 1l
            vmean[*,*,gu,0] = vmean[*,*,gu,0] + cnts
            cnts[*,*] = 0l 
        ENDIF


    ENDFOR

    RETURN, vmean

END
