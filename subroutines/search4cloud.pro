;-------------------------------------------------------------------
;-- search bottom-up, where is a cloud using COT threshold value
;-------------------------------------------------------------------
;
; ====== INPUT ======
;
; IDL> help, inp ... input era interim 3d reanalysis fields
; ** Structure <752348>, 10 tags, length=140365888, data length=140365888, refs=1:
;    FILE            STRING    '/path/to/data/200807/ERA_Interim_an_20080701_00+00_plev.nc'
;    PLEVEL          DOUBLE    Array[27]
;    DPRES           DOUBLE    Array[26]
;    LON             DOUBLE    Array[720]
;    LAT             DOUBLE    Array[361]
;    LWC             FLOAT     Array[720, 361, 27]
;    IWC             FLOAT     Array[720, 361, 27]
;    CC              FLOAT     Array[720, 361, 27]
;    GEOP            FLOAT     Array[720, 361, 27]
;    TEMP            FLOAT     Array[720, 361, 27]
;
; IDL> help, grd ... era interim grid information
; ** Structure <7529c8>, 5 tags, length=2079368, data length=2079366, refs=1:
;    LON2D           FLOAT     Array[720, 361]
;    LAT2D           FLOAT     Array[720, 361]
;    XDIM            INT            720
;    YDIM            INT            361
;    ZDIM            INT             27
;
; IDL> help, cwp
; ** Structure CLOUD_WATER_PATH, 2 tags, length=54063360, data length=54063360:
;    LWP             FLOAT     Array[720, 361, 26]
;    IWP             FLOAT     Array[720, 361, 26]
;
; IDL> help, cot
; ** Structure CLOUD_OPTICAL_DEPTH, 2 tags, length=54063360, data length=54063360:
;    LIQ             FLOAT     Array[720, 361, 26]
;    ICE             FLOAT     Array[720, 361, 26]
;
; IDL> help, cer
; ** Structure CLOUD_EFFECTIVE_RADIUS, 2 tags, length=54063360, data length=54063360:
;    LIQ             FLOAT     Array[720, 361, 26]
;    ICE             FLOAT     Array[720, 361, 26]
; 
; IDL> help, flg
; FLG             STRING    = 'ori' ... model
; FLG             STRING    = 'sat' ... simulated
;
; IDL> help, thv ... COT threshold
; THV             FLOAT     =     0.0100000
;
; ====== OUTPUT ======
;
; IDL> help, tmp  ... temporary arrays
; Structure TEMP_ARRAYS, 22 tags, length=22872960, data length=22872960:
;    CTP             FLOAT     Array[720, 361]
;    CTH             FLOAT     Array[720, 361]
;    CTT             FLOAT     Array[720, 361]
;    CPH             FLOAT     Array[720, 361]
;    LWP             FLOAT     Array[720, 361]
;    IWP             FLOAT     Array[720, 361]
;    CFC             FLOAT     Array[720, 361]
;    COT             FLOAT     Array[720, 361]
;    CWP             FLOAT     Array[720, 361]
;    CER             FLOAT     Array[720, 361]
;    CFC_BIN         FLOAT     Array[720, 361]
;    CPH_BIN         FLOAT     Array[720, 361]
;    LWP_BIN         FLOAT     Array[720, 361]
;    IWP_BIN         FLOAT     Array[720, 361]
;    LWP_INC_BIN     FLOAT     Array[720, 361]
;    IWP_INC_BIN     FLOAT     Array[720, 361]
;    COT_LIQ         FLOAT     Array[720, 361]
;    COT_ICE         FLOAT     Array[720, 361]
;    COT_LIQ_BIN     FLOAT     Array[720, 361]
;    COT_ICE_BIN     FLOAT     Array[720, 361]
;    CER_LIQ         FLOAT     Array[720, 361]
;    CER_ICE         FLOAT     Array[720, 361]
;
;-------------------------------------------------------------------

PRO SEARCH4CLOUD, INPUT=inp, GRID=grd, CWP=cwp, COT=cot, CER=cer, $
                  FLAG=flg, THRESHOLD=thv, TEMP=tmp

    ; -- fill_value
    fillvalue = -999.

    ; ----------------------------------------------------------------------
    ; initialize arrays
    ; *_bin ... based on binary decision of the phase=cph_tmp_bin
    ; 2D arrays containing the upper-most cloud information
    ; ----------------------------------------------------------------------
    ; cloud top pressure
    ctp_tmp = FLTARR(grd.xdim,grd.ydim) & ctp_tmp[*,*] = fillvalue
    ; cloud top height
    cth_tmp = FLTARR(grd.xdim,grd.ydim) & cth_tmp[*,*] = fillvalue
    ; cloud top temperature
    ctt_tmp = FLTARR(grd.xdim,grd.ydim) & ctt_tmp[*,*] = fillvalue
    ; cloud phase
    cph_tmp = FLTARR(grd.xdim,grd.ydim) & cph_tmp[*,*] = fillvalue
    cph_tmp_bin = FLTARR(grd.xdim,grd.ydim) & cph_tmp_bin[*,*] = fillvalue
    ; cloud fraction
    cfc_tmp = FLTARR(grd.xdim,grd.ydim) & cfc_tmp[*,*] = 0.
    cfc_tmp_bin = FLTARR(grd.xdim,grd.ydim) & cfc_tmp_bin[*,*] = 0.
    ; liquid and ice water path
    lwp_tmp = FLTARR(grd.xdim,grd.ydim) & lwp_tmp[*,*] = 0.
    iwp_tmp = FLTARR(grd.xdim,grd.ydim) & iwp_tmp[*,*] = 0.
    lwp_tmp_bin = FLTARR(grd.xdim,grd.ydim) & lwp_tmp_bin[*,*] = 0.
    iwp_tmp_bin = FLTARR(grd.xdim,grd.ydim) & iwp_tmp_bin[*,*] = 0.
    ; liquid and ice cloud optical thickness
    lcot_tmp = FLTARR(grd.xdim,grd.ydim) & lcot_tmp[*,*] = 0.
    icot_tmp = FLTARR(grd.xdim,grd.ydim) & icot_tmp[*,*] = 0.
    lcot_tmp_bin = FLTARR(grd.xdim,grd.ydim) & lcot_tmp_bin[*,*] = 0.
    icot_tmp_bin = FLTARR(grd.xdim,grd.ydim) & icot_tmp_bin[*,*] = 0.
    ; liquid and ice cloud effective radius
    lcer_tmp = FLTARR(grd.xdim,grd.ydim) & lcer_tmp[*,*] = 0.
    icer_tmp = FLTARR(grd.xdim,grd.ydim) & icer_tmp[*,*] = 0.
    lcer_tmp_bin = FLTARR(grd.xdim,grd.ydim) & lcer_tmp_bin[*,*] = 0.
    icer_tmp_bin = FLTARR(grd.xdim,grd.ydim) & icer_tmp_bin[*,*] = 0.
    ; ----------------------------------------------------------------------
    ; initialized here but required & used in sumup_vars.pro
    cot_tmp = FLTARR(grd.xdim,grd.ydim) & cot_tmp[*,*] = 0.
    cwp_tmp = FLTARR(grd.xdim,grd.ydim) & cwp_tmp[*,*] = 0.
    cer_tmp = FLTARR(grd.xdim,grd.ydim) & cer_tmp[*,*] = 0.
    lwp_tmp_inc_bin = FLTARR(grd.xdim,grd.ydim) & lwp_tmp_inc_bin[*,*] = 0.
    iwp_tmp_inc_bin = FLTARR(grd.xdim,grd.ydim) & iwp_tmp_inc_bin[*,*] = 0.
    ; ----------------------------------------------------------------------


    FOR z=grd.zdim-2,1,-1 DO BEGIN

      cnt = 0
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

        lcer_tmp[where_cot] = (cer.liq[*,*,z])[where_cot]
        icer_tmp[where_cot] = (cer.ice[*,*,z])[where_cot]

        ; avoiding -NaN output due to 0./(0.+ 0.)
        ; % Program caused arithmetic error: Floating illegal operand
        lwp_idx = WHERE(lwp_lay_tmp[where_cot] GT 0., cnt_lwp_idx)

        ; cloud top phase
        cph_tmp[where_cot[lwp_idx]] = ( 0.0 > $
            ( lwp_lay_tmp[where_cot[lwp_idx]] / $
            ( lwp_lay_tmp[where_cot[lwp_idx]] + $
            iwp_lay_tmp[where_cot[lwp_idx]] ) ) < 1.0 )

        nanidx = WHERE( ~FINITE(cph_tmp), cnt_nan )
        IF (cnt_nan GT 0) THEN cph_tmp[nanidx] = fillvalue

        ; cloud top phase via binary decision
        cph_tmp_bin[where_cot[lwp_idx]] = ROUND( cph_tmp[where_cot[lwp_idx]] )

        ; layer between two levels
        IF(z LT grd.zdim-2) THEN BEGIN

          lwp_tmp[where_cot] = (total(cwp.lwp[*,*,z:*],3))[where_cot]
          iwp_tmp[where_cot] = (total(cwp.iwp[*,*,z:*],3))[where_cot]

          lcot_tmp[where_cot] = (total(cot.liq[*,*,z:*],3))[where_cot]
          icot_tmp[where_cot] = (total(cot.ice[*,*,z:*],3))[where_cot]

          ; normal cloud fraction
          cfc_tmp[where_cot] = ( 0. > ( $
              (max(inp.cc[*,*,z:*],dimension=3))[where_cot] ) < 1.0)

          ; binary cloud fraction
          cfc_tmp_bin[where_cot] = ROUND( ( 0. > ( $
              (max(inp.cc[*,*,z:*],dimension=3))[where_cot] ) < 1.0) )

        ; lowest layer, to be checked
        ENDIF ELSE BEGIN

          lwp_tmp[where_cot] = (cwp.lwp[*,*,z])[where_cot]
          iwp_tmp[where_cot] = (cwp.iwp[*,*,z])[where_cot]
          
          lcot_tmp[where_cot] = (cot.liq[*,*,z])[where_cot]
          icot_tmp[where_cot] = (cot.ice[*,*,z])[where_cot]

          ; normal cloud fraction
          cfc_tmp[where_cot] = ( 0. > ( $
              (inp.cc[*,*,z])[where_cot] ) < 1.0 )

          ; binary cloud fraction
          cfc_tmp_bin[where_cot] = ROUND( ( 0. > ( $
              (inp.cc[*,*,z])[where_cot] ) < 1.0 ) )

        ENDELSE

      ENDIF

    ENDFOR


    ; -- satellite identifies only the upper-most layer!
    IF (flg EQ 'sat') THEN BEGIN

        ; -- cloud top based on binary phase
        wo_liq = WHERE(cph_tmp_bin EQ 1., nliq)
        wo_ice = WHERE(cph_tmp_bin EQ 0., nice)

        ; -- TOP = liquid
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

        ; -- TOP = ice
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

    ENDIF
    

    ; -- conistent output w.r.t. cloud fraction
    IF (flg EQ 'ori') THEN BEGIN
        f = WHERE(cfc_tmp EQ 0., fcnt)
    ENDIF ELSE BEGIN
        f = WHERE(cfc_tmp_bin EQ 0., fcnt)
    ENDELSE 

    IF (fcnt GT 0) THEN BEGIN
        ctp_tmp[f] = fillvalue
        cth_tmp[f] = fillvalue
        ctt_tmp[f] = fillvalue
        cph_tmp[f] = fillvalue
        lwp_tmp[f] = 0.
        iwp_tmp[f] = 0.
        cph_tmp_bin[f] = fillvalue
        lwp_tmp_bin[f] = 0.
        iwp_tmp_bin[f] = 0.
        lcot_tmp[f] = 0.
        icot_tmp[f] = 0.
        lcot_tmp_bin[f] = 0.
        icot_tmp_bin[f] = 0.
        ;;cfc_tmp[f] = 0.
        ;;cfc_tmp_bin[f] = 0.
        ; ---------------------------------------
        ; init here, but used in sumup_vars.pro
        cot_tmp[f] = 0.
        cwp_tmp[f] = 0.
        lwp_tmp_inc_bin[f] = 0.
        iwp_tmp_inc_bin[f] = 0.
        ; ---------------------------------------
    ENDIF



    ; -- output structure
    tmp = {temp_arrays, $
           ctp:ctp_tmp, $
           cth:cth_tmp, $
           ctt:ctt_tmp, $
           cph:cph_tmp, $
           lwp:lwp_tmp, $
           iwp:iwp_tmp, $
           cfc:cfc_tmp, $
           cot:cot_tmp, $
           cwp:cwp_tmp, $
           cer:cer_tmp, $
           cfc_bin:cfc_tmp_bin, $
           cph_bin:cph_tmp_bin, $
           lwp_bin:lwp_tmp_bin, $
           iwp_bin:iwp_tmp_bin, $
           lwp_inc_bin:lwp_tmp_inc_bin, $
           iwp_inc_bin:iwp_tmp_inc_bin, $
           cot_liq:lcot_tmp, $
           cot_ice:icot_tmp, $
           cot_liq_bin:lcot_tmp_bin, $
           cot_ice_bin:icot_tmp_bin, $
           cer_liq:lcer_tmp_bin, $
           cer_ice:icer_tmp_bin }

END
