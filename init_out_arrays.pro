
;-------------------------------------------------------------------
;--  era_simulator: initialize output arrays
;-------------------------------------------------------------------
;
; in : xdim, ydim, zdim, dim_ctp
;
; out: cph, ctt, cth, ctp, lwp, iwp, cfc, ctp_hist
;      numb, numb_tmp, numb_raw
;
; cph ... cloud phase
; ctt ... cloud top temperature
; cth ... cloud top height
; ctp ... cloud top pressure
; lwp ... cloud liquid water path
; iwp ... cloud ice water path
; cfc ... cloud fraction
; ctp_hist ... cloud top pressure histogram
;
;-------------------------------------------------------------------

PRO INIT_OUT_ARRAYS, xdim, ydim, zdim, dim_ctp, $
                     cph, ctt, cth, ctp, lwp, iwp, cfc, ctp_hist, $
                     numb, numb_tmp, numb_raw

    cph = FLTARR(xdim,ydim) & cph[*,*] = 0
    ctt = FLTARR(xdim,ydim) & ctt[*,*] = 0
    cth = FLTARR(xdim,ydim) & cth[*,*] = 0
    ctp = FLTARR(xdim,ydim) & ctp[*,*] = 0
    lwp = FLTARR(xdim,ydim) & lwp[*,*] = 0
    iwp = FLTARR(xdim,ydim) & iwp[*,*] = 0
    cfc = FLTARR(xdim,ydim) & cfc[*,*] = 0

    ctp_hist = LONARR(xdim,ydim,dim_ctp) & ctp_hist[*,*,*] = 0l

    numb = LONARR(xdim,ydim) & numb[*,*] = 0

    IF(ISA(numb_tmp) EQ 0) THEN numb_tmp = INTARR(xdim,ydim)
    IF(ISA(numb_raw) EQ 0) THEN numb_raw = 0l

END
