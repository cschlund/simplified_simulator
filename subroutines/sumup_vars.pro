;-------------------------------------------------------------------
;-- sum up cloud parameters from current file processed
;-------------------------------------------------------------------
;
; in : flag, means, temps, counts, histo
; out: means, counts
;
; flag ... either 'ori' or 'sat'
;           this is required for the sumup total COT & CWP
;           because for model (ori) : cot_liq+cot_ice & lwp+iwp
;                   for simu. (sat) : cot_liq_bin+cot_ice_bin & 
;                                     lwp_inc_bin+iwp_inc_bin
;
; IDL> help, means ... structure containing the final output arrays
;
; ** Structure FINAL_OUTPUT, 22 tags, length=36388800, data length=36388800:
;    CTP_HIST        LONG      Array[720, 361, 14]
;    CWP             FLOAT     Array[720, 361]
;    COT             FLOAT     Array[720, 361]
;    CPH             FLOAT     Array[720, 361]
;    CTT             FLOAT     Array[720, 361]
;    CTH             FLOAT     Array[720, 361]
;    CTP             FLOAT     Array[720, 361]
;    LWP             FLOAT     Array[720, 361]
;    IWP             FLOAT     Array[720, 361]
;    CFC             FLOAT     Array[720, 361]
;    LWP_BIN         FLOAT     Array[720, 361]
;    IWP_BIN         FLOAT     Array[720, 361]
;    CFC_BIN         FLOAT     Array[720, 361]
;    CPH_BIN         FLOAT     Array[720, 361]
;    LWP_INC         FLOAT     Array[720, 361]
;    IWP_INC         FLOAT     Array[720, 361]
;    LWP_INC_BIN     FLOAT     Array[720, 361]
;    IWP_INC_BIN     FLOAT     Array[720, 361]
;    COT_LIQ         FLOAT     Array[720, 361]
;    COT_ICE         FLOAT     Array[720, 361]
;    COT_LIQ_BIN     FLOAT     Array[720, 361]
;    COT_ICE_BIN     FLOAT     Array[720, 361]
;
; IDL> help, counts ... structure containing the counters
;
; ** Structure FINAL_COUNTS, 17 tags, length=16634884, data length=16634884:
;    CTP             LONG      Array[720, 361]
;    COT             LONG      Array[720, 361]
;    CWP             LONG      Array[720, 361]
;    TMP             LONG      Array[720, 361]
;    RAW             LONG                 0
;    LWP             LONG      Array[720, 361]
;    IWP             LONG      Array[720, 361]
;    LWP_BIN         LONG      Array[720, 361]
;    IWP_BIN         LONG      Array[720, 361]
;    LWP_INC         LONG      Array[720, 361]
;    IWP_INC         LONG      Array[720, 361]
;    LWP_INC_BIN     LONG      Array[720, 361]
;    IWP_INC_BIN     LONG      Array[720, 361]
;    COT_LIQ         LONG      Array[720, 361]
;    COT_ICE         LONG      Array[720, 361]
;    COT_LIQ_BIN     LONG      Array[720, 361]
;    COT_ICE_BIN     LONG      Array[720, 361]
;
; IDL> help, temps ... structure containing the temp. arrays
;
; ** Structure TEMP_ARRAYS, 19 tags, length=19753920, data length=19753920:
;    CTP             FLOAT     Array[720, 361]
;    CTH             FLOAT     Array[720, 361]
;    CTT             FLOAT     Array[720, 361]
;    CPH             FLOAT     Array[720, 361]
;    LWP             FLOAT     Array[720, 361]
;    IWP             FLOAT     Array[720, 361]
;    CFC             FLOAT     Array[720, 361]
;    COT             FLOAT     Array[720, 361]
;    CWP             FLOAT     Array[720, 361]
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
;
; IDL> help, histo ... structure containing the histogram information
;
; ** Structure <741998>, 3 tags, length=176, data length=176, refs=1:
;    DIM_CTP         LONG                14
;    CTP1D           FLOAT     Array[15]
;    CTP2D           FLOAT     Array[2, 14]
; 
;-------------------------------------------------------------------

PRO SUMUP_VARS, flag, means, counts, temps, histo

    ; no condition for cloud fraction [0;1]: clear or cloudy
    means.cfc = means.cfc + temps.cfc
    means.cfc_bin = means.cfc_bin + temps.cfc_bin


    ; cth and cph limitation added because with cpt_tmp GT 10. alone
    ; negative CTH and CPH pixels do occur
    ; cph: lwp_lay / (lwp_lay + iwp_lay) WHERE lwp_lay is positive
    ;      if cph is fill_value, no cloud due to no LWP/IWP

    wo_ctp = WHERE((temps.ctp GT 10.) AND $
                   (temps.cth GT 0.)  AND $
                   (temps.cph GE 0.), nwo_ctp)

    means.ctp[wo_ctp] = means.ctp[wo_ctp] + temps.ctp[wo_ctp]
    means.cth[wo_ctp] = means.cth[wo_ctp] + temps.cth[wo_ctp]
    means.ctt[wo_ctp] = means.ctt[wo_ctp] + temps.ctt[wo_ctp]
    means.cph[wo_ctp] = means.cph[wo_ctp] + temps.cph[wo_ctp]

    means.cph_bin[wo_ctp] = means.cph_bin[wo_ctp] + temps.cph_bin[wo_ctp]

    counts.ctp[wo_ctp] = counts.ctp[wo_ctp] + 1l


    ; TOTAL COT (liquid + ice)
    IF ( flag EQ 'ori' ) THEN BEGIN

        temps.cot = temps.cot_liq + temps.cot_ice

        wo_cot = WHERE(temps.cot GT 0., nwo_cot)
        means.cot[wo_cot] = means.cot[wo_cot] + temps.cot[wo_cot]
        counts.cot[wo_cot] = counts.cot[wo_cot] + 1l

    ENDIF ELSE BEGIN

        temps.cot = temps.cot_liq_bin + temps.cot_ice_bin

        wo_cot = WHERE(temps.cot GT 0., nwo_cot)
        means.cot[wo_cot] = means.cot[wo_cot] + temps.cot[wo_cot]
        counts.cot[wo_cot] = counts.cot[wo_cot] + 1l

    ENDELSE


    ; COT_LIQ (model)
    wo_lcot = WHERE(temps.cot_liq GT 0., nwo_lcot)
    means.cot_liq[wo_lcot] = means.cot_liq[wo_lcot] + temps.cot_liq[wo_lcot]
    counts.cot_liq[wo_lcot] = counts.cot_liq[wo_lcot] + 1l

    ; COT_ICE (model)
    wo_icot = WHERE(temps.cot_ice GT 0., nwo_icot)
    means.cot_ice[wo_icot] = means.cot_ice[wo_icot] + temps.cot_ice[wo_icot]
    counts.cot_ice[wo_icot] = counts.cot_ice[wo_icot] + 1l

    ; COT_LIQ_BIN (pseudo-satellite)
    wo_lcot_bin = WHERE(temps.cot_liq_bin GT 0., nwo_lcot_bin)
    means.cot_liq_bin[wo_lcot_bin] = means.cot_liq_bin[wo_lcot_bin] + $
                                     temps.cot_liq_bin[wo_lcot_bin]
    counts.cot_liq_bin[wo_lcot_bin] = counts.cot_liq_bin[wo_lcot_bin] + 1l

    ; COT_ICE_BIN (pseudo-satellite)
    wo_icot_bin = WHERE(temps.cot_ice_bin GT 0., nwo_icot_bin)
    means.cot_ice_bin[wo_icot_bin] = means.cot_ice_bin[wo_icot_bin] + $
                                     temps.cot_ice_bin[wo_icot_bin]
    counts.cot_ice_bin[wo_icot_bin] = counts.cot_ice_bin[wo_icot_bin] + 1l


    ; lwp grid mean
    wo_lwp = WHERE(temps.lwp GT 0., nwo_lwp)
    means.lwp[wo_lwp] = means.lwp[wo_lwp] + temps.lwp[wo_lwp]
    counts.lwp[wo_lwp] = counts.lwp[wo_lwp] + 1l

    ; iwp grid mean
    wo_iwp = WHERE(temps.iwp GT 0., nwo_iwp)
    means.iwp[wo_iwp] = means.iwp[wo_iwp] + temps.iwp[wo_iwp]
    counts.iwp[wo_iwp] = counts.iwp[wo_iwp] + 1l


    ; lwp and iwp grid mean based on cph_tmp_bin (binary cph)
    wo_cph_bin_liq = WHERE(temps.cph_bin EQ 1., nwo_cph_bin_liq)
    means.lwp_bin[wo_cph_bin_liq] = means.lwp_bin[wo_cph_bin_liq] + temps.lwp_bin[wo_cph_bin_liq]
    counts.lwp_bin[wo_cph_bin_liq] = counts.lwp_bin[wo_cph_bin_liq] + 1l

    wo_cph_bin_ice = WHERE(temps.cph_bin EQ 0., nwo_cph_bin_ice)
    means.iwp_bin[wo_cph_bin_ice] = means.iwp_bin[wo_cph_bin_ice] + temps.iwp_bin[wo_cph_bin_ice]
    counts.iwp_bin[wo_cph_bin_ice] = counts.iwp_bin[wo_cph_bin_ice] + 1l


    ; lwp_mean_incloud
    idx1 = WHERE(temps.cfc GT 0. AND temps.lwp GT 0., nidx1)
    IF (nidx1 GT 0) THEN BEGIN
        means.lwp_inc[idx1] = means.lwp_inc[idx1] + temps.lwp[idx1]/temps.cfc[idx1]
        counts.lwp_inc[idx1] = counts.lwp_inc[idx1] + 1l
    ENDIF

    ; iwp_mean_incloud
    idx2 = WHERE(temps.cfc GT 0. AND temps.iwp GT 0., nidx2)
    IF (nidx2 GT 0) THEN BEGIN
        means.iwp_inc[idx2] = means.iwp_inc[idx2] + temps.iwp[idx2]/temps.cfc[idx2]
        counts.iwp_inc[idx2] = counts.iwp_inc[idx2] + 1l
    ENDIF


    ; lwp_mean_incloud_bin
    idx3 = WHERE(temps.cfc GT 0. AND temps.lwp_bin GT 0., nidx3)
    IF (nidx3 GT 0) THEN BEGIN
        temps.lwp_inc_bin[idx3] = temps.lwp_bin[idx3] / temps.cfc[idx3]
        means.lwp_inc_bin[idx3] = means.lwp_inc_bin[idx3] + temps.lwp_inc_bin[idx3]
        counts.lwp_inc_bin[idx3] = counts.lwp_inc_bin[idx3] + 1l
    ENDIF

    ; iwp_mean_incloud_bin
    idx4 = WHERE(temps.cfc GT 0. AND temps.iwp_bin GT 0., nidx4)
    IF (nidx4 GT 0) THEN BEGIN
        temps.iwp_inc_bin[idx4] = temps.iwp_bin[idx4] / temps.cfc[idx4]
        means.iwp_inc_bin[idx4] = means.iwp_inc_bin[idx4] + temps.iwp_inc_bin[idx4]
        counts.iwp_inc_bin[idx4] = counts.iwp_inc_bin[idx4] + 1l
    ENDIF


    ; TOTAL CWP (liquid + ice)
    IF ( flag EQ 'ori' ) THEN BEGIN

        temps.cwp = temps.lwp + temps.iwp

        wo_cwp = WHERE(temps.cwp GT 0., nwo_cwp)
        means.cwp[wo_cwp] = means.cwp[wo_cwp] + temps.cwp[wo_cwp]
        counts.cwp[wo_cwp] = counts.cwp[wo_cwp] + 1l


    ENDIF ELSE BEGIN

        temps.cwp = temps.lwp_inc_bin + temps.iwp_inc_bin

        wo_cwp = WHERE(temps.cwp GT 0., nwo_cwp)
        means.cwp[wo_cwp] = means.cwp[wo_cwp] + temps.cwp[wo_cwp]
        counts.cwp[wo_cwp] = counts.cwp[wo_cwp] + 1l

    ENDELSE


    FOR gu=0, histo.dim_ctp-1 DO BEGIN
      counts.tmp[*,*] = 0l
      wohi = WHERE(temps.ctp GE histo.ctp2d[0,gu] AND temps.ctp LT histo.ctp2d[1,gu],nwohi)
      IF(nwohi GT 0) THEN counts.tmp[wohi] = 1l
      means.ctp_hist[*,*,gu]=means.ctp_hist[*,*,gu] + counts.tmp
    ENDFOR

    counts.tmp[*,*] = 0l

END
