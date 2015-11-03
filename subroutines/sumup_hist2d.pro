;---------------------------------------------------------------
; sum up 2d histograms: 
; -- NOTE --
; simulator -> 0=ice,    1=liquid
; cc4cl     -> 0=liquid, 1=ice
; 
; ! -- TEMP arrays -- !
; IDL> help, cot, ctp, cfc, cph
; COT  FLOAT  = Array[720, 361]
; CTP  FLOAT  = Array[720, 361]
; CFC  FLOAT  = Array[720, 361]
; CPH  FLOAT  = Array[720, 361]
;
; IDL> help, hist
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
;
;---------------------------------------------------------------

FUNCTION SUMUP_HIST2D, hist, cot, ctp, cfc, cph

    dims = SIZE(cot, /DIM)

    ; counts [lon,lat]
    cnts = LONARR(dims[0],dims[1])
    cnts[*,*] = 0l 

    ; hist2d [lon,lat,cotbins,ctpbins,phase] = [720,361,13,15,2]
    vmean = LONARR(dims[0], dims[1], hist.cot_bin1d_dim, $
                   hist.ctp_bin1d_dim, hist.phase_dim) 
    vmean[*,*,*,*] = 0l

    ; last bins
    ctp_last = hist.ctp_bin1d_dim-1
    cot_last = hist.cot_bin1d_dim-1

    FOR ictp=0, ctp_last DO BEGIN 
        FOR jcot=0, cot_last DO BEGIN

            ; consider also last COT & CTP bin-border via GE & LE
            IF ( jcot EQ cot_last AND ictp EQ ctp_last) THEN BEGIN

                wohi_ice = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LE hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LE hist.ctp2d[1,ictp] AND $
                                  cfc EQ 1. AND cph EQ 0., nwohi_ice )

                wohi_liq = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LE hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LE hist.ctp2d[1,ictp] AND $
                                  cfc EQ 1. AND cph EQ 1., nwohi_liq )


            ; consider also last COT bin-border via GE & LE
            ENDIF ELSE IF ( jcot EQ cot_last ) THEN BEGIN

                wohi_ice = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LE hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LT hist.ctp2d[1,ictp] AND $
                                  cfc EQ 1. AND cph EQ 0., nwohi_ice )

                wohi_liq = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LE hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LT hist.ctp2d[1,ictp] AND $
                                  cfc EQ 1. AND cph EQ 1., nwohi_liq )


            ; consider also last CTP bin-border via GE & LE
            ENDIF ELSE IF ( ictp EQ ctp_last) THEN BEGIN


                wohi_ice = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LT hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LE hist.ctp2d[1,ictp] AND $
                                  cfc EQ 1. AND cph EQ 0., nwohi_ice )

                wohi_liq = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LT hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LE hist.ctp2d[1,ictp] AND $
                                  cfc EQ 1. AND cph EQ 1., nwohi_liq )


            ; between GE & LT
            ENDIF ELSE BEGIN

                wohi_ice = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LT hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LT hist.ctp2d[1,ictp] AND $
                                  cot GT 0. AND ctp GT 0. AND $
                                  cfc EQ 1. AND cph EQ 0., nwohi_ice )

                wohi_liq = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LT hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LT hist.ctp2d[1,ictp] AND $
                                  cot GT 0. AND ctp GT 0. AND $
                                  cfc EQ 1. AND cph EQ 1., nwohi_liq )

            ENDELSE

            ; hist2d [lon,lat,cotbins,ctpbins,phase] = [720,361,13,15,2]

            IF ( nwohi_ice GT 0 ) THEN BEGIN
                cnts[wohi_ice] = 1l
                vmean[*,*,jcot,ictp,1] = vmean[*,*,jcot,ictp,1] + cnts
                cnts[*,*] = 0l 
            ENDIF

            IF ( nwohi_liq GT 0 ) THEN BEGIN
                cnts[wohi_liq] = 1l
                vmean[*,*,jcot,ictp,0] = vmean[*,*,jcot,ictp,0] + cnts
                cnts[*,*] = 0l 
            ENDIF

        ENDFOR
    ENDFOR

    RETURN, vmean

END
