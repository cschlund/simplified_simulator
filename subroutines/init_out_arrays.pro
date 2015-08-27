
;-------------------------------------------------------------------
;--  era_simulator: initialize output arrays
;-------------------------------------------------------------------
;
; in : xdim, ydim, zdim, dim_ctp
;
; out: cph, ctt, cth, ctp, lwp, iwp, cfc, 
;      lwp_incloud, iwp_incloud,
;      numb_lwp_incloud, numb_iwp_incloud,
;      ctp_hist, numb, numb_tmp, numb_raw
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
; numb_lwp_incloud ... number of occurrences for lwp_incloud
; numb_iwp_incloud ... number of occurrences for iwp_incloud
; ctp_hist ... cloud top pressure histogram
;
;-------------------------------------------------------------------

PRO INIT_OUT_ARRAYS, xdim, ydim, zdim, dim_ctp, $
                     cph, ctt, cth, ctp, lwp, iwp, cfc, $
                     lwp_incloud, iwp_incloud, $
                     numb_lwp_incloud, numb_iwp_incloud, $
                     ctp_hist, numb, numb_tmp, numb_raw

    cph = FLTARR(xdim,ydim) & cph[*,*] = 0
    ctt = FLTARR(xdim,ydim) & ctt[*,*] = 0
    cth = FLTARR(xdim,ydim) & cth[*,*] = 0
    ctp = FLTARR(xdim,ydim) & ctp[*,*] = 0
    lwp = FLTARR(xdim,ydim) & lwp[*,*] = 0
    iwp = FLTARR(xdim,ydim) & iwp[*,*] = 0
    cfc = FLTARR(xdim,ydim) & cfc[*,*] = 0

    ; -- lwp & iwp incloud, 
    ;    i.e. in sumup_cloud_params: lwp_tmp/cfc_tmp; iwp_tmp/cfc_tmp
    lwp_incloud = FLTARR(xdim,ydim) & lwp_incloud[*,*] = 0
    iwp_incloud = FLTARR(xdim,ydim) & iwp_incloud[*,*] = 0

    numb_lwp_incloud = LONARR(xdim,ydim) & numb_lwp_incloud[*,*] = 0
    numb_iwp_incloud = LONARR(xdim,ydim) & numb_iwp_incloud[*,*] = 0

    ctp_hist = LONARR(xdim,ydim,dim_ctp) & ctp_hist[*,*,*] = 0l

    numb = LONARR(xdim,ydim) & numb[*,*] = 0

    IF(ISA(numb_tmp) EQ 0) THEN numb_tmp = INTARR(xdim,ydim)
    IF(ISA(numb_raw) EQ 0) THEN numb_raw = 0l

END
