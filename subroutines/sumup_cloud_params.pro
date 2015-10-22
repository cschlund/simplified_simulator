;-------------------------------------------------------------------
;-- sum up cloud parameters from current file processed
;-------------------------------------------------------------------
;
; in : means, temps, counts, histo
; out: means, counts
;
; IDL> help, means ... structure containing the final output arrays
;
; ** Structure <752db8>, 16 tags, length=30150720, data length=30150720, refs=1:
;    CTP_HIST        LONG      Array[720, 361, 14]
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
;
; IDL> help, counts ... structure containing the counters
;
; ** Structure <755128>, 11 tags, length=10396804, data length=10396804, refs=1:
;    CTP             LONG      Array[720, 361]
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
;
; IDL> help, temps ... structure containing the temp. arrays
;
; ** Structure <758958>, 11 tags, length=11436480, data length=11436480, refs=1:
;    CTP             FLOAT     Array[720, 361]
;    CTH             FLOAT     Array[720, 361]
;    CTT             FLOAT     Array[720, 361]
;    CPH             FLOAT     Array[720, 361]
;    LWP             FLOAT     Array[720, 361]
;    IWP             FLOAT     Array[720, 361]
;    CFC             FLOAT     Array[720, 361]
;    CFC_BIN         FLOAT     Array[720, 361]
;    CPH_BIN         FLOAT     Array[720, 361]
;    LWP_BIN         FLOAT     Array[720, 361]
;    IWP_BIN         FLOAT     Array[720, 361]
;
; IDL> help, histo ... structure containing the histogram information
;
; ** Structure <741998>, 3 tags, length=176, data length=176, refs=1:
;    DIM_CTP         LONG                14
;    CTP1D           FLOAT     Array[15]
;    CTP2D           FLOAT     Array[2, 14]
; 
;-------------------------------------------------------------------

PRO SUMUP_CLOUD_PARAMS, means, counts, temps, histo

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
        means.lwp_inc_bin[idx3] = means.lwp_inc_bin[idx3] + temps.lwp_bin[idx3]/temps.cfc[idx3]
        counts.lwp_inc_bin[idx3] = counts.lwp_inc_bin[idx3] + 1l
    ENDIF

    ; iwp_mean_incloud_bin
    idx4 = WHERE(temps.cfc GT 0. AND temps.iwp_bin GT 0., nidx4)
    IF (nidx4 GT 0) THEN BEGIN
        means.iwp_inc_bin[idx4] = means.iwp_inc_bin[idx4] + temps.iwp_bin[idx4]/temps.cfc[idx4]
        counts.iwp_inc_bin[idx4] = counts.iwp_inc_bin[idx4] + 1l
    ENDIF


    FOR gu=0, histo.dim_ctp-1 DO BEGIN
      counts.tmp[*,*] = 0l
      wohi = WHERE(temps.ctp GE histo.ctp2d[0,gu] AND temps.ctp LT histo.ctp2d[1,gu],nwohi)
      IF(nwohi GT 0) THEN counts.tmp[wohi] = 1l
      means.ctp_hist[*,*,gu]=means.ctp_hist[*,*,gu] + counts.tmp
    ENDFOR

    counts.tmp[*,*] = 0l

END
