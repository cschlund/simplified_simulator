
;-------------------------------------------------------------------
;-- calculate cloud mean values after all files read (monthly mean)
;-------------------------------------------------------------------
;
; in : mean arrays incl. counters
;
; out: mean arrays incl. counters
;
; cph_mean ... cloud phase
; ctt_mean ... cloud top temperature
; cth_mean ... cloud top height
; ctp_mean ... cloud top pressure
; lwp_mean ... cloud liquid water path
; iwp_mean ... cloud ice water path
; cph_mean_bin ... binary cloud phase
; cfc_mean_bin ... binary cloud fraction
; lwp_mean_bin ... cloud liquid water path based on binary decision of cph
; iwp_mean_bin ... cloud ice water path based on binary decision of cph
; cfc_mean ... cloud fraction
; lwp_incloud ... LWP incloud mean
; iwp_incloud ... IWP incloud mean
; lwp_incloud_bin ... LWP incloud mean based on lwp_mean_bin
; iwp_incloud_bin ... IWP incloud mean based on iwp_mean_bin
; numb_lwp_inc ... counts for lwp_incloud
; numb_iwp_inc ... counts for iwp_incloud
; numb_lwp_inc_bin ... counts for lwp_incloud_bin
; numb_iwp_inc_bin ... counts for iwp_incloud_bin
; numb ... number of observations
; numb_lwp ... counter for valid LWP sumup events
; numb_iwp ... counter for valid IWP sumup events
; numb_lwp_bin ... counter for valid CPH_BIN sumup events for liquid
; numb_iwp_bin ... counter for valid CPH_BIN sumup events for ice
;
;-------------------------------------------------------------------

PRO CALC_PARAMS_AVERAGES, cph_mean, ctt_mean, cth_mean, ctp_mean, $
                          lwp_mean, iwp_mean, cfc_mean, $
                          lwp_incloud, iwp_incloud, $
                          numb_lwp_inc, numb_iwp_inc, $
                          numb, numb_raw, $
                          numb_lwp, numb_iwp, numb_lwp_bin, numb_iwp_bin, $
                          lwp_mean_bin, lwp_incloud_bin, numb_lwp_inc_bin, $
                          iwp_mean_bin, iwp_incloud_bin, numb_iwp_inc_bin, $
                          cfc_mean_bin, cph_mean_bin

    ; weight mean with number of observations
    wo_numi  = WHERE(numb GT 0, n_wo_numi)

    IF(n_wo_numi GT 0) THEN ctp_mean[wo_numi] = ctp_mean[wo_numi] / numb[wo_numi]
    IF(n_wo_numi GT 0) THEN cth_mean[wo_numi] = cth_mean[wo_numi] / numb[wo_numi]
    IF(n_wo_numi GT 0) THEN ctt_mean[wo_numi] = ctt_mean[wo_numi] / numb[wo_numi]
    IF(n_wo_numi GT 0) THEN cph_mean[wo_numi] = cph_mean[wo_numi] / numb[wo_numi]
    IF(n_wo_numi GT 0) THEN cph_mean_bin[wo_numi] = cph_mean_bin[wo_numi] / numb[wo_numi]

    ; cloud fraction divided by number of files read = numb_raw
    cfc_mean = cfc_mean / numb_raw
    cfc_mean_bin = cfc_mean_bin / numb_raw


    ; LWP & IWP grid mean
    idx_liq = WHERE(numb_lwp GT 0, nidx_liq)
    IF(nidx_liq GT 0) THEN lwp_mean[idx_liq] = lwp_mean[idx_liq] / numb_lwp[idx_liq]

    idx_ice = WHERE(numb_iwp GT 0, nidx_ice)
    IF(nidx_ice GT 0) THEN iwp_mean[idx_ice] = iwp_mean[idx_ice] / numb_iwp[idx_ice]

    ; LWP & IWP binary grid mean
    idx_cph_liq = WHERE(numb_lwp_bin GT 0, nidx_cph_liq)
    IF(nidx_cph_liq GT 0) THEN lwp_mean_bin[idx_cph_liq] = lwp_mean_bin[idx_cph_liq] / numb_lwp_bin[idx_cph_liq]

    idx_cph_ice = WHERE(numb_iwp_bin GT 0, nidx_cph_ice)
    IF(nidx_cph_ice GT 0) THEN iwp_mean_bin[idx_cph_ice] = iwp_mean_bin[idx_cph_ice] / numb_iwp_bin[idx_cph_ice]


    ; lwp and iwp incloud based on lwp and iwp
    wo_lwp = WHERE(numb_lwp_inc GT 0, nlwp)
    IF (nlwp GT 0) THEN lwp_incloud[wo_lwp] = lwp_incloud[wo_lwp] / numb_lwp_inc[wo_lwp]

    wo_iwp = WHERE(numb_iwp_inc GT 0, niwp)
    IF (niwp GT 0) THEN iwp_incloud[wo_iwp] = iwp_incloud[wo_iwp] / numb_iwp_inc[wo_iwp]


    ; lwp and iwp incloud based on binary decision of cph
    wo_lwp_bin = WHERE(numb_lwp_inc_bin GT 0, nlwp_bin)
    IF (nlwp_bin GT 0) THEN $
        lwp_incloud_bin[wo_lwp_bin] = lwp_incloud_bin[wo_lwp_bin] / numb_lwp_inc_bin[wo_lwp_bin]

    wo_iwp_bin = WHERE(numb_iwp_inc_bin GT 0, niwp_bin)
    IF (niwp_bin GT 0) THEN $
        iwp_incloud_bin[wo_iwp_bin] = iwp_incloud_bin[wo_iwp_bin] / numb_iwp_inc_bin[wo_iwp_bin]


    ; fill_value for grid cells with no observations

    wo_numi0 = WHERE(numb EQ 0, n_wo_numi0)
    IF(n_wo_numi0 GT 0) THEN ctp_mean[wo_numi0] = -999.
    IF(n_wo_numi0 GT 0) THEN cth_mean[wo_numi0] = -999.
    IF(n_wo_numi0 GT 0) THEN ctt_mean[wo_numi0] = -999.
    IF(n_wo_numi0 GT 0) THEN cph_mean[wo_numi0] = -999.
    IF(n_wo_numi0 GT 0) THEN cph_mean_bin[wo_numi0] = -999.

    idx_liq0 = WHERE(numb_lwp EQ 0, nidx_liq0)
    IF(nidx_liq0 GT 0) THEN lwp_mean[idx_liq0] = -999.

    idx_ice0 = WHERE(numb_iwp EQ 0, nidx_ice0)
    IF(nidx_ice0 GT 0) THEN iwp_mean[idx_ice0] = -999.

    idx_cph_liq0 = WHERE(numb_lwp_bin EQ 0, nidx_cph_liq0)
    IF(nidx_cph_liq0 GT 0) THEN lwp_mean_bin[idx_cph_liq0] = -999.

    idx_cph_ice0 = WHERE(numb_iwp_bin EQ 0, nidx_cph_ice0)
    IF(nidx_cph_ice0 GT 0) THEN iwp_mean_bin[idx_cph_ice0] = -999.

    wo_lwp_nix = WHERE(numb_lwp_inc EQ 0, nlwp_nix)
    IF (nlwp_nix GT 0) THEN lwp_incloud[wo_lwp_nix] = -999.

    wo_iwp_nix = WHERE(numb_iwp_inc EQ 0, niwp_nix)
    IF (niwp_nix GT 0) THEN iwp_incloud[wo_iwp_nix] = -999.

    wo_lwp_nix_bin = WHERE(numb_lwp_inc_bin EQ 0, nlwp_nix_bin)
    IF (nlwp_nix_bin GT 0) THEN lwp_incloud_bin[wo_lwp_nix_bin] = -999.

    wo_iwp_nix_bin = WHERE(numb_iwp_inc_bin EQ 0, niwp_nix_bin)
    IF (niwp_nix_bin GT 0) THEN iwp_incloud_bin[wo_iwp_nix_bin] = -999.

END
