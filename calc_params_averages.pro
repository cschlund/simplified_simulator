
;-------------------------------------------------------------------
;-- calculate cloud mean values after all files read (monthly mean)
;-------------------------------------------------------------------
;
; in : cph_mean, ctt_mean, cth_mean, ctp_mean, 
;      lwp_mean, iwp_mean, cfc_mean, numb, numb_raw
;
; out: cph_mean, ctt_mean, cth_mean, ctp_mean, 
;      lwp_mean, iwp_mean, cfc_mean, numb
;
; cph ... cloud phase
; ctt ... cloud top temperature
; cth ... cloud top height
; ctp ... cloud top pressure
; lwp ... cloud liquid water path
; iwp ... cloud ice water path
; cfc ... cloud fraction
; numb ... number of observations
;
;-------------------------------------------------------------------

PRO CALC_PARAMS_AVERAGES, cph_mean, ctt_mean, cth_mean, ctp_mean, $
                          lwp_mean, iwp_mean, cfc_mean, numb, $
                          numb_raw, verbose

    ; weight mean with number of observations
    wo_numi  = WHERE(numb GT 0, n_wo_numi)

    IF(n_wo_numi GT 0) THEN ctp_mean[wo_numi] = ctp_mean[wo_numi] / numb[wo_numi]
    IF(n_wo_numi GT 0) THEN cth_mean[wo_numi] = cth_mean[wo_numi] / numb[wo_numi]
    IF(n_wo_numi GT 0) THEN ctt_mean[wo_numi] = ctt_mean[wo_numi] / numb[wo_numi]
    IF(n_wo_numi GT 0) THEN cph_mean[wo_numi] = cph_mean[wo_numi] / numb[wo_numi]

    lwp_mean = lwp_mean / numb_raw
    iwp_mean = iwp_mean / numb_raw
    cfc_mean = cfc_mean / numb_raw

    ; fill_value for grid cells with no observations
    wo_numi0 = WHERE(numb EQ 0, n_wo_numi0)

    IF(n_wo_numi0 GT 0) THEN ctp_mean[wo_numi0] = -999.
    IF(n_wo_numi0 GT 0) THEN cth_mean[wo_numi0] = -999.
    IF(n_wo_numi0 GT 0) THEN ctt_mean[wo_numi0] = -999.
    IF(n_wo_numi0 GT 0) THEN lwp_mean[wo_numi0] = -999.
    IF(n_wo_numi0 GT 0) THEN iwp_mean[wo_numi0] = -999.
    IF(n_wo_numi0 GT 0) THEN cph_mean[wo_numi0] = -999.

    ; some screen output
    IF KEYWORD_SET(verbose) THEN BEGIN
        PRINT, '   GLOBAL MEANS' & ft = '(F12.4)'
        good = WHERE(ctp_mean GE 0.)
        PRINT, '   + ctp_mean = ', STRING(MEAN(ctp_mean[good])), FORMAT=ft)
        good = WHERE(cth_mean GE 0.)
        PRINT, '   + cth_mean = ', STRING(MEAN(cth_mean[good])), FORMAT=ft)
        good = WHERE(ctt_mean GE 0.)
        PRINT, '   + ctt_mean = ', STRING(MEAN(ctt_mean[good])), FORMAT=ft)
        good = WHERE(cph_mean GE 0.)
        PRINT, '   + cph_mean = ', STRING(MEAN(cph_mean[good])), FORMAT=ft)
        good = WHERE(cfc_mean GE 0.)
        PRINT, '   + cfc_mean = ', STRING(MEAN(cfc_mean[good])), FORMAT=ft)
        good = WHERE(lwp_mean GE 0.)
        PRINT, '   + lwp_mean = ', STRING(MEAN(lwp_mean[good])), FORMAT=ft)
        good = WHERE(iwp_mean GE 0.)
        PRINT, '   + iwp_mean = ', STRING(MEAN(iwp_mean[good])), FORMAT=ft)
    ENDIF

END
