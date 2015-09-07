
;-------------------------------------------------------------------
;--  era_simulator: initialize output arrays
;-------------------------------------------------------------------
;
; in : xdim, ydim, zdim, dim_ctp
;
; out: cph, ctt, cth, ctp, lwp, iwp, cfc, 
;      lwp_incloud, iwp_incloud,
;      numb_lwp_incloud, numb_iwp_incloud,
;      ctp_hist, numb, numb_tmp, numb_raw, 
;      lwp_bin, lwp_incloud_bin, numb_lwp_incloud_bin,
;      iwp_bin, iwp_incloud_bin, numb_iwp_incloud_bin,
;      cfc_bin, cph_bin
;
;
; numb ... counter for wo_ctp = WHERE((ctp_tmp GT 10.) AND ...)
;          important for ctp, cth, ctt, cph, cph_bin
; numb_raw ... number of files read
;
; cph ... cloud phase
; ctt ... cloud top temperature
; cth ... cloud top height
; ctp ... cloud top pressure
; lwp ... cloud liquid water path
; iwp ... cloud ice water path
; cfc ... cloud fraction
; cph_bin ... binary cph (0;1)
; cfc_bin ... binary cfc (0;1)
; lwp_bin ... cloud liquid water path based on binary decision of cph
; iwp_bin ... cloud ice water path based on binary decision of cph
; lwp_incloud ... LWP incloud mean
; iwp_incloud ... IWP incloud mean
; lwp_incloud_bin ... LWP incloud mean based on lwp_bin
; iwp_incloud_bin ... IWP incloud mean based on iwp_bin
; numb_lwp_incloud ... number of occurrences for lwp_incloud
; numb_iwp_incloud ... number of occurrences for iwp_incloud
; numb_lwp_incloud_bin ... number of occurrences for lwp_incloud_bin
; numb_iwp_incloud_bin ... number of occurrences for iwp_incloud_bin
; ctp_hist ... cloud top pressure histogram
; numb_hist ... counter for ctp_hist
;
;-------------------------------------------------------------------

PRO INIT_OUT_ARRAYS, xdim, ydim, zdim, dim_ctp, $
                     cph, ctt, cth, ctp, lwp, iwp, cfc, $
                     lwp_incloud, iwp_incloud, $
                     numb_lwp_incloud, numb_iwp_incloud, $
                     ctp_hist, numb, numb_tmp, numb_raw, $
                     numb_lwp, numb_iwp, numb_cph_bin, $
                     lwp_bin, lwp_incloud_bin, numb_lwp_incloud_bin, $
                     iwp_bin, iwp_incloud_bin, numb_iwp_incloud_bin, $
                     cfc_bin, cph_bin

    cph = FLTARR(xdim,ydim) & cph[*,*] = 0
    ctt = FLTARR(xdim,ydim) & ctt[*,*] = 0
    cth = FLTARR(xdim,ydim) & cth[*,*] = 0
    ctp = FLTARR(xdim,ydim) & ctp[*,*] = 0
    lwp = FLTARR(xdim,ydim) & lwp[*,*] = 0
    iwp = FLTARR(xdim,ydim) & iwp[*,*] = 0
    cfc = FLTARR(xdim,ydim) & cfc[*,*] = 0
    lwp_bin = FLTARR(xdim,ydim) & lwp_bin[*,*] = 0
    iwp_bin = FLTARR(xdim,ydim) & iwp_bin[*,*] = 0
    cfc_bin = FLTARR(xdim,ydim) & cfc_bin[*,*] = 0
    cph_bin = FLTARR(xdim,ydim) & cph_bin[*,*] = 0

    ; -- lwp & iwp incloud, 
    ;    i.e. in sumup_cloud_params: lwp_tmp/cfc_tmp; iwp_tmp/cfc_tmp
    lwp_incloud = FLTARR(xdim,ydim) & lwp_incloud[*,*] = 0
    iwp_incloud = FLTARR(xdim,ydim) & iwp_incloud[*,*] = 0
    lwp_incloud_bin = FLTARR(xdim,ydim) & lwp_incloud_bin[*,*] = 0
    iwp_incloud_bin = FLTARR(xdim,ydim) & iwp_incloud_bin[*,*] = 0

    numb_lwp_incloud = LONARR(xdim,ydim) & numb_lwp_incloud[*,*] = 0
    numb_iwp_incloud = LONARR(xdim,ydim) & numb_iwp_incloud[*,*] = 0
    numb_lwp_incloud_bin = LONARR(xdim,ydim) & numb_lwp_incloud_bin[*,*] = 0
    numb_iwp_incloud_bin = LONARR(xdim,ydim) & numb_iwp_incloud_bin[*,*] = 0

    ctp_hist = LONARR(xdim,ydim,dim_ctp) & ctp_hist[*,*,*] = 0l

    numb = LONARR(xdim,ydim) & numb[*,*] = 0
    numb_lwp = LONARR(xdim,ydim) & numb_lwp[*,*] = 0
    numb_iwp = LONARR(xdim,ydim) & numb_iwp[*,*] = 0
    numb_cph_bin = LONARR(xdim,ydim) & numb_cph_bin[*,*] = 0

    IF(ISA(numb_tmp) EQ 0) THEN numb_tmp = INTARR(xdim,ydim)
    IF(ISA(numb_raw) EQ 0) THEN numb_raw = 0l

END
