
;-------------------------------------------------------------------
;-- calculate cloud mean values after all files read (monthly mean)
;-------------------------------------------------------------------
;
; in : means, counts
; out: means, counts
;
;** means **
;** Structure <74e708>, 16 tags, length=30150720, data length=30150720, refs=1:
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
;** counts **
;** Structure <762c38>, 11 tags, length=9876964, data length=9876964, refs=1:
;    NUMB            LONG      Array[720, 361]
;    NUMB_TMP        INT       Array[720, 361]
;    NUMB_RAW        LONG                 1
;    NUMB_LWP        LONG      Array[720, 361]
;    NUMB_IWP        LONG      Array[720, 361]
;    NUMB_LWP_BIN    LONG      Array[720, 361]
;    NUMB_IWP_BIN    LONG      Array[720, 361]
;    NUMB_LWP_INC    LONG      Array[720, 361]
;    NUMB_IWP_INC    LONG      Array[720, 361]
;    NUMB_LWP_INC_BIN
;                    LONG      Array[720, 361]
;    NUMB_IWP_INC_BIN
;                    LONG      Array[720, 361]
;
;-------------------------------------------------------------------

PRO CALC_PARAMS_AVERAGES, means, counts

    ; -- weight mean with number of observations
    wo_numi  = WHERE(counts.numb GT 0, n_wo_numi)

    IF(n_wo_numi GT 0) THEN BEGIN
        means.ctp[wo_numi] = means.ctp[wo_numi] / counts.numb[wo_numi]
        means.cth[wo_numi] = (means.cth[wo_numi] / counts.numb[wo_numi]) / 1000. ;[km]
        means.ctt[wo_numi] = means.ctt[wo_numi] / counts.numb[wo_numi]
        means.cph[wo_numi] = means.cph[wo_numi] / counts.numb[wo_numi]
        means.cph_bin[wo_numi] = means.cph_bin[wo_numi] / counts.numb[wo_numi]
    ENDIF


    ; -- cloud fraction divided by number of files read = numb_raw
    means.cfc = means.cfc / counts.numb_raw
    means.cfc_bin = means.cfc_bin / counts.numb_raw


    ; -- convert LWP,IWP from 'kg/m2' to 'g/m2' (CCI conform), 
    ;    i.e. multiply with 1000.


    ; -- LWP & IWP grid mean
    idx_liq = WHERE(counts.numb_lwp GT 0, nidx_liq)
    IF(nidx_liq GT 0) THEN $
        means.lwp[idx_liq] = (means.lwp[idx_liq] / counts.numb_lwp[idx_liq])*1000.

    idx_ice = WHERE(counts.numb_iwp GT 0, nidx_ice)
    IF(nidx_ice GT 0) THEN $
        means.iwp[idx_ice] = (means.iwp[idx_ice] / counts.numb_iwp[idx_ice])*1000.


    ; -- LWP & IWP binary grid mean
    idx_cph_liq = WHERE(counts.numb_lwp_bin GT 0, nidx_cph_liq)
    IF(nidx_cph_liq GT 0) THEN $
        means.lwp_bin[idx_cph_liq] = (means.lwp_bin[idx_cph_liq] / $
                                      counts.numb_lwp_bin[idx_cph_liq])*1000.

    idx_cph_ice = WHERE(counts.numb_iwp_bin GT 0, nidx_cph_ice)
    IF(nidx_cph_ice GT 0) THEN $
        means.iwp_bin[idx_cph_ice] = (means.iwp_bin[idx_cph_ice] / $
                                      counts.numb_iwp_bin[idx_cph_ice])*1000.


    ; -- lwp and iwp incloud based on lwp and iwp
    wo_lwp = WHERE(counts.numb_lwp_inc GT 0, nlwp)
    IF (nlwp GT 0) THEN $
        means.lwp_inc[wo_lwp] = (means.lwp_inc[wo_lwp] / $
                                 counts.numb_lwp_inc[wo_lwp])*1000.

    wo_iwp = WHERE(counts.numb_iwp_inc GT 0, niwp)
    IF (niwp GT 0) THEN $
        means.iwp_inc[wo_iwp] = (means.iwp_inc[wo_iwp] / $
                                 counts.numb_iwp_inc[wo_iwp])*1000.


    ; -- lwp and iwp incloud based on binary decision of cph
    wo_lwp_bin = WHERE(counts.numb_lwp_inc_bin GT 0, nlwp_bin)
    IF (nlwp_bin GT 0) THEN $
        means.lwp_inc_bin[wo_lwp_bin] = (means.lwp_inc_bin[wo_lwp_bin] / $
                                         counts.numb_lwp_inc_bin[wo_lwp_bin])*1000.

    wo_iwp_bin = WHERE(counts.numb_iwp_inc_bin GT 0, niwp_bin)
    IF (niwp_bin GT 0) THEN $
        means.iwp_inc_bin[wo_iwp_bin] = (means.iwp_inc_bin[wo_iwp_bin] / $
                                         counts.numb_iwp_inc_bin[wo_iwp_bin])*1000.


    ; -- fill_value for grid cells with no observations

    wo_numi0 = WHERE(counts.numb EQ 0, n_wo_numi0)
    IF(n_wo_numi0 GT 0) THEN BEGIN
        means.ctp[wo_numi0] = -999.
        means.cth[wo_numi0] = -999.
        means.ctt[wo_numi0] = -999.
        means.cph[wo_numi0] = -999.
        means.cph_bin[wo_numi0] = -999.
    ENDIF

    idx_liq0 = WHERE(counts.numb_lwp EQ 0, nidx_liq0)
    IF(nidx_liq0 GT 0) THEN means.lwp[idx_liq0] = -999.

    idx_ice0 = WHERE(counts.numb_iwp EQ 0, nidx_ice0)
    IF(nidx_ice0 GT 0) THEN means.iwp[idx_ice0] = -999.

    idx_cph_liq0 = WHERE(counts.numb_lwp_bin EQ 0, nidx_cph_liq0)
    IF(nidx_cph_liq0 GT 0) THEN means.lwp_bin[idx_cph_liq0] = -999.

    idx_cph_ice0 = WHERE(counts.numb_iwp_bin EQ 0, nidx_cph_ice0)
    IF(nidx_cph_ice0 GT 0) THEN means.iwp_bin[idx_cph_ice0] = -999.

    wo_lwp_nix = WHERE(counts.numb_lwp_inc EQ 0, nlwp_nix)
    IF (nlwp_nix GT 0) THEN means.lwp_inc[wo_lwp_nix] = -999.

    wo_iwp_nix = WHERE(counts.numb_iwp_inc EQ 0, niwp_nix)
    IF (niwp_nix GT 0) THEN means.iwp_inc[wo_iwp_nix] = -999.

    wo_lwp_nix_bin = WHERE(counts.numb_lwp_inc_bin EQ 0, nlwp_nix_bin)
    IF (nlwp_nix_bin GT 0) THEN means.lwp_inc_bin[wo_lwp_nix_bin] = -999.

    wo_iwp_nix_bin = WHERE(counts.numb_iwp_inc_bin EQ 0, niwp_nix_bin)
    IF (niwp_nix_bin GT 0) THEN means.iwp_inc_bin[wo_iwp_nix_bin] = -999.

END
