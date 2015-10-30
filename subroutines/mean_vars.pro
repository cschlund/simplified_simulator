;-------------------------------------------------------------------
;-- calculate cloud mean values after all files read (monthly mean)
;-------------------------------------------------------------------
;
; in : means, counts
; out: means, counts
;
; ** Structure FINAL_OUTPUT, 25 tags, length=142436160, data length=142436160:
;    HIST1D_CTP      LONG      Array[720, 361, 15, 2]
;    HIST1D_CTT      LONG      Array[720, 361, 16, 2]
;    HIST1D_CWP      LONG      Array[720, 361, 14, 2]
;    HIST1D_COT      LONG      Array[720, 361, 13, 2]
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
; ** Structure FINAL_COUNTS, 17 tags, length=16634884, data length=16634884:
;    CTP             LONG      Array[720, 361]
;    COT             LONG      Array[720, 361]
;    CWP             LONG      Array[720, 361]
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
;-------------------------------------------------------------------

PRO MEAN_VARS, means, counts

    ; -- weight mean with number of observations
    wo_numi  = WHERE(counts.ctp GT 0, n_wo_numi)

    IF(n_wo_numi GT 0) THEN BEGIN
        means.ctp[wo_numi] = means.ctp[wo_numi] / counts.ctp[wo_numi]
        means.cth[wo_numi] = (means.cth[wo_numi] / counts.ctp[wo_numi]) / 1000. ;[km]
        means.ctt[wo_numi] = means.ctt[wo_numi] / counts.ctp[wo_numi]
        means.cph[wo_numi] = means.cph[wo_numi] / counts.ctp[wo_numi]
        means.cph_bin[wo_numi] = means.cph_bin[wo_numi] / counts.ctp[wo_numi]
    ENDIF


    ; -- cloud fraction divided by number of files read = raw
    means.cfc = means.cfc / counts.raw
    means.cfc_bin = means.cfc_bin / counts.raw


    ; -- convert LWP,IWP from 'kg/m2' to 'g/m2' (CCI conform), 
    ;    i.e. multiply with 1000.

    tcwp = WHERE(counts.cwp GT 0, ntcwp)
    IF (ntcwp GT 0) THEN $
        means.cwp[tcwp] = (means.cwp[tcwp] / counts.cwp[tcwp])*1000.

    ; -- LWP & IWP grid mean
    idx_liq = WHERE(counts.lwp GT 0, nidx_liq)
    IF(nidx_liq GT 0) THEN $
        means.lwp[idx_liq] = (means.lwp[idx_liq] / counts.lwp[idx_liq])*1000.

    idx_ice = WHERE(counts.iwp GT 0, nidx_ice)
    IF(nidx_ice GT 0) THEN $
        means.iwp[idx_ice] = (means.iwp[idx_ice] / counts.iwp[idx_ice])*1000.


    ; -- LWP & IWP binary grid mean
    idx_cph_liq = WHERE(counts.lwp_bin GT 0, nidx_cph_liq)
    IF(nidx_cph_liq GT 0) THEN $
        means.lwp_bin[idx_cph_liq] = (means.lwp_bin[idx_cph_liq] / $
                                      counts.lwp_bin[idx_cph_liq])*1000.

    idx_cph_ice = WHERE(counts.iwp_bin GT 0, nidx_cph_ice)
    IF(nidx_cph_ice GT 0) THEN $
        means.iwp_bin[idx_cph_ice] = (means.iwp_bin[idx_cph_ice] / $
                                      counts.iwp_bin[idx_cph_ice])*1000.


    ; -- lwp and iwp incloud based on lwp and iwp
    wo_lwp = WHERE(counts.lwp_inc GT 0, nlwp)
    IF (nlwp GT 0) THEN $
        means.lwp_inc[wo_lwp] = (means.lwp_inc[wo_lwp] / $
                                 counts.lwp_inc[wo_lwp])*1000.

    wo_iwp = WHERE(counts.iwp_inc GT 0, niwp)
    IF (niwp GT 0) THEN $
        means.iwp_inc[wo_iwp] = (means.iwp_inc[wo_iwp] / $
                                 counts.iwp_inc[wo_iwp])*1000.


    ; -- lwp and iwp incloud based on binary decision of cph
    wo_lwp_bin = WHERE(counts.lwp_inc_bin GT 0, nlwp_bin)
    IF (nlwp_bin GT 0) THEN $
        means.lwp_inc_bin[wo_lwp_bin] = (means.lwp_inc_bin[wo_lwp_bin] / $
                                         counts.lwp_inc_bin[wo_lwp_bin])*1000.

    wo_iwp_bin = WHERE(counts.iwp_inc_bin GT 0, niwp_bin)
    IF (niwp_bin GT 0) THEN $
        means.iwp_inc_bin[wo_iwp_bin] = (means.iwp_inc_bin[wo_iwp_bin] / $
                                         counts.iwp_inc_bin[wo_iwp_bin])*1000.


    ; -- cloud optical thickness
    tcot = WHERE(counts.cot GT 0, ntcot)
    IF (ntcot GT 0) THEN $
        means.cot[tcot] = means.cot[tcot] / counts.cot[tcot]

    lcot = WHERE(counts.cot_liq GT 0, nlcot)
    IF (nlcot GT 0) THEN $
        means.cot_liq[lcot] = means.cot_liq[lcot] / counts.cot_liq[lcot]

    icot = WHERE(counts.cot_ice GT 0, nicot)
    IF (nicot GT 0) THEN $
        means.cot_ice[icot] = means.cot_ice[icot] / counts.cot_ice[icot]

    lcotbin = WHERE(counts.cot_liq_bin GT 0, nlcotbin)
    IF (nlcotbin GT 0) THEN $
        means.cot_liq_bin[lcotbin] = means.cot_liq_bin[lcotbin] / $
                                    counts.cot_liq_bin[lcotbin]

    icotbin = WHERE(counts.cot_ice_bin GT 0, nicotbin)
    IF (nicotbin GT 0) THEN $
        means.cot_ice_bin[icotbin] = means.cot_ice_bin[icotbin] / $
                                    counts.cot_ice_bin[icotbin]


    ; -- fill_value for grid cells with no observations

    wo_numi0 = WHERE(counts.ctp EQ 0, n_wo_numi0)
    IF(n_wo_numi0 GT 0) THEN BEGIN
        means.ctp[wo_numi0] = -999.
        means.cth[wo_numi0] = -999.
        means.ctt[wo_numi0] = -999.
        means.cph[wo_numi0] = -999.
        means.cph_bin[wo_numi0] = -999.
    ENDIF

    idx_liq0 = WHERE(counts.lwp EQ 0, nidx_liq0)
    IF(nidx_liq0 GT 0) THEN means.lwp[idx_liq0] = -999.

    idx_ice0 = WHERE(counts.iwp EQ 0, nidx_ice0)
    IF(nidx_ice0 GT 0) THEN means.iwp[idx_ice0] = -999.

    idx_cph_liq0 = WHERE(counts.lwp_bin EQ 0, nidx_cph_liq0)
    IF(nidx_cph_liq0 GT 0) THEN means.lwp_bin[idx_cph_liq0] = -999.

    idx_cph_ice0 = WHERE(counts.iwp_bin EQ 0, nidx_cph_ice0)
    IF(nidx_cph_ice0 GT 0) THEN means.iwp_bin[idx_cph_ice0] = -999.

    wo_lwp_nix = WHERE(counts.lwp_inc EQ 0, nlwp_nix)
    IF (nlwp_nix GT 0) THEN means.lwp_inc[wo_lwp_nix] = -999.

    wo_iwp_nix = WHERE(counts.iwp_inc EQ 0, niwp_nix)
    IF (niwp_nix GT 0) THEN means.iwp_inc[wo_iwp_nix] = -999.

    wo_lwp_nix_bin = WHERE(counts.lwp_inc_bin EQ 0, nlwp_nix_bin)
    IF (nlwp_nix_bin GT 0) THEN means.lwp_inc_bin[wo_lwp_nix_bin] = -999.

    wo_iwp_nix_bin = WHERE(counts.iwp_inc_bin EQ 0, niwp_nix_bin)
    IF (niwp_nix_bin GT 0) THEN means.iwp_inc_bin[wo_iwp_nix_bin] = -999.

    tcwp0 = WHERE(counts.cwp EQ 0, ntcwp0)
    IF (ntcwp0 GT 0) THEN means.cwp[tcwp0] = -999.

    tcot0 = WHERE(counts.cot EQ 0, ntcot0)
    IF (ntcot0 GT 0) THEN means.cot[tcot0] = -999.

    lcot0 = WHERE(counts.cot_liq EQ 0, nlcot0)
    IF (nlcot0 GT 0) THEN means.cot_liq[lcot0] = -999.

    icot0 = WHERE(counts.cot_ice EQ 0, nicot0)
    IF (nicot0 GT 0) THEN means.cot_ice[icot0] = -999.

    lcotbin0 = WHERE(counts.cot_liq_bin EQ 0, nlcotbin0)
    IF (nlcotbin0 GT 0) THEN means.cot_liq_bin[lcotbin0] = -999.

    icotbin0 = WHERE(counts.cot_ice_bin EQ 0, nicotbin0)
    IF (nicotbin0 GT 0) THEN means.cot_ice_bin[icotbin0] = -999.


    ; -- 1D histograms

    ; HIST1D_CTP      LONG      Array[720, 361, 15, 2]
    h1ctp = WHERE(means.hist1d_ctp EQ 0, nh1ctp)
    IF (nh1ctp GT 0) THEN means.hist1d_ctp[h1ctp] = -999l

    ; HIST1D_CTT      LONG      Array[720, 361, 16, 2]
    h1ctt = WHERE(means.hist1d_ctt EQ 0, nh1ctt)
    IF (nh1ctt GT 0) THEN means.hist1d_ctt[h1ctt] = -999l

    ; HIST1D_CWP      LONG      Array[720, 361, 14, 2]
    h1cwp = WHERE(means.hist1d_cwp EQ 0, nh1cwp)
    IF (nh1cwp GT 0) THEN means.hist1d_cwp[h1cwp] = -999l

    ; HIST1D_COT      LONG      Array[720, 361, 13, 2]
    h1cot = WHERE(means.hist1d_cot EQ 0, nh1cot)
    IF (nh1cot GT 0) THEN means.hist1d_cot[h1cot] = -999l

END
