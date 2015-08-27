
;-------------------------------------------------------------------
;-- calculate cloud mean values after all files read (monthly mean)
;-------------------------------------------------------------------
;
; in : cph_mean, ctt_mean, cth_mean, ctp_mean, 
;      lwp_mean, iwp_mean, cfc_mean, lwp_incloud, iwp_incloud, 
;      numb_lwp_inc, numb_iwp_inc, numb, numb_raw
;
; out: cph_mean, ctt_mean, cth_mean, ctp_mean, 
;      lwp_mean, iwp_mean, cfc_mean, lwp_incloud, iwp_incloud, 
;      numb_lwp_inc, numb_iwp_inc, numb
;
; cph ... cloud phase
; ctt ... cloud top temperature
; cth ... cloud top height
; ctp ... cloud top pressure
; lwp ... cloud liquid water path
; iwp ... cloud ice water path
; cfc ... cloud fraction
; lwp_incloud ... LWP incloud mean
; iwp_incloud ... IWP incloud mean
; numb_lwp_inc ... counts for lwp_incloud
; numb_iwp_inc ... counts for iwp_incloud
; numb ... number of observations
;
;-------------------------------------------------------------------

PRO CALC_PARAMS_AVERAGES, cph_mean, ctt_mean, cth_mean, ctp_mean, $
                          lwp_mean, iwp_mean, cfc_mean, $
                          lwp_incloud, iwp_incloud, $
                          numb_lwp_inc, numb_iwp_inc, $
                          numb, numb_raw

    ; weight mean with number of observations
    wo_numi  = WHERE(numb GT 0, n_wo_numi)

    IF(n_wo_numi GT 0) THEN ctp_mean[wo_numi] = ctp_mean[wo_numi] / numb[wo_numi]
    IF(n_wo_numi GT 0) THEN cth_mean[wo_numi] = cth_mean[wo_numi] / numb[wo_numi]
    IF(n_wo_numi GT 0) THEN ctt_mean[wo_numi] = ctt_mean[wo_numi] / numb[wo_numi]
    IF(n_wo_numi GT 0) THEN cph_mean[wo_numi] = cph_mean[wo_numi] / numb[wo_numi]

    lwp_mean = lwp_mean / numb_raw
    iwp_mean = iwp_mean / numb_raw
    cfc_mean = cfc_mean / numb_raw

    wo_lwp = WHERE(numb_lwp_inc GT 0, nlwp)
    IF (nlwp GT 0) THEN lwp_incloud[wo_lwp] = lwp_incloud[wo_lwp] / numb_lwp_inc[wo_lwp]

    wo_iwp = WHERE(numb_iwp_inc GT 0, niwp)
    IF (niwp GT 0) THEN iwp_incloud[wo_iwp] = iwp_incloud[wo_iwp] / numb_iwp_inc[wo_iwp]


    ; fill_value for grid cells with no observations
    wo_numi0 = WHERE(numb EQ 0, n_wo_numi0)

    IF(n_wo_numi0 GT 0) THEN ctp_mean[wo_numi0] = -999.
    IF(n_wo_numi0 GT 0) THEN cth_mean[wo_numi0] = -999.
    IF(n_wo_numi0 GT 0) THEN ctt_mean[wo_numi0] = -999.
    IF(n_wo_numi0 GT 0) THEN lwp_mean[wo_numi0] = -999.
    IF(n_wo_numi0 GT 0) THEN iwp_mean[wo_numi0] = -999.
    IF(n_wo_numi0 GT 0) THEN cph_mean[wo_numi0] = -999.

    wo_lwp_nix = WHERE(numb_lwp_inc EQ 0, nlwp_nix)
    IF (nlwp_nix GT 0) THEN lwp_incloud[wo_lwp_nix] = -999.

    wo_iwp_nix = WHERE(numb_iwp_inc EQ 0, niwp_nix)
    IF (niwp_nix GT 0) THEN iwp_incloud[wo_iwp_nix] = -999.


    ; some screen output
	PRINT, '   GLOBAL MEANS' & ft = '(F12.4)'
	good = WHERE(ctp_mean GE 0.)
	PRINT, '   + ctp_mean = ', STRING(MEAN(ctp_mean[good]), FORMAT=ft)
	good = WHERE(cth_mean GE 0.)
	PRINT, '   + cth_mean = ', STRING(MEAN(cth_mean[good]), FORMAT=ft)
	good = WHERE(ctt_mean GE 0.)
	PRINT, '   + ctt_mean = ', STRING(MEAN(ctt_mean[good]), FORMAT=ft)
	good = WHERE(cph_mean GE 0.)
	PRINT, '   + cph_mean = ', STRING(MEAN(cph_mean[good]), FORMAT=ft)
	good = WHERE(cfc_mean GE 0.)
	PRINT, '   + cfc_mean = ', STRING(MEAN(cfc_mean[good]), FORMAT=ft)
	good = WHERE(lwp_mean GE 0.)
	PRINT, '   + lwp_mean = ', STRING(MEAN(lwp_mean[good]), FORMAT=ft)
	good = WHERE(iwp_mean GE 0.)
	PRINT, '   + iwp_mean = ', STRING(MEAN(iwp_mean[good]), FORMAT=ft)
	good = WHERE(lwp_incloud GE 0.)
	PRINT, '   + lwp_incloud = ', STRING(MEAN(lwp_incloud[good]), FORMAT=ft)
	good = WHERE(iwp_incloud GE 0.)
	PRINT, '   + iwp_incloud = ', STRING(MEAN(iwp_incloud[good]), FORMAT=ft)


END
