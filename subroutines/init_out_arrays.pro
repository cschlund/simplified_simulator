
;-------------------------------------------------------------------
;--  era_simulator: initialize output arrays
;-------------------------------------------------------------------
;
; in : grid, histo
; out: arrays, counts
;
;-------------------------------------------------------------------
;
; arrays.cph ... cloud phase
; arrays.ctt ... cloud top temperature
; arrays.cth ... cloud top height
; arrays.ctp ... cloud top pressure
; arrays.lwp ... cloud liquid water path
; arrays.iwp ... cloud ice water path
; arrays.cfc ... cloud fraction
; arrays.cph_bin ... binary cph (0;1)
; arrays.cfc_bin ... binary cfc (0;1)
; arrays.lwp_bin ... cloud liquid water path based on binary decision of cph
; arrays.iwp_bin ... cloud ice water path based on binary decision of cph
; arrays.lwp_inc ... LWP incloud mean
; arrays.iwp_inc ... IWP incloud mean
; arrays.lwp_inc_bin ... LWP incloud mean based on lwp_bin
; arrays.iwp_inc_bin ... IWP incloud mean based on iwp_bin
; arrays.ctp_hist ... cloud top pressure histogram
;
; counts.numb_raw ... number of files read
; counts.numb     ... counter for wo_ctp = WHERE((ctp_tmp GT 10.) AND ...) 
;                     important for ctp, cth, ctt, cph, cph_bin
;
; counts.numb_hist    ... counter for ctp_hist
; counts.numb_lwp     ... counter for lwp_mean
; counts.numb_iwp     ... counter for iwp_mean
; counts.numb_lwp_bin ... counter for lwp_mean_bin (based on binary cph)
; counts.numb_iwp_bin ... counter for iwp_mean_bin (based on binary cph)
;
; counts.numb_lwp_incloud ... number of occurrences for lwp_incloud
; counts.numb_iwp_incloud ... number of occurrences for iwp_incloud
; counts.numb_lwp_incloud_bin ... number of occurrences for lwp_incloud_bin
; counts.numb_iwp_incloud_bin ... number of occurrences for iwp_incloud_bin
;
;-------------------------------------------------------------------

PRO INIT_OUT_ARRAYS, grid, histo, arrays, counts

    cph = FLTARR(grid.xdim,grid.ydim) & cph[*,*] = 0
    ctt = FLTARR(grid.xdim,grid.ydim) & ctt[*,*] = 0
    cth = FLTARR(grid.xdim,grid.ydim) & cth[*,*] = 0
    ctp = FLTARR(grid.xdim,grid.ydim) & ctp[*,*] = 0
    lwp = FLTARR(grid.xdim,grid.ydim) & lwp[*,*] = 0
    iwp = FLTARR(grid.xdim,grid.ydim) & iwp[*,*] = 0
    cfc = FLTARR(grid.xdim,grid.ydim) & cfc[*,*] = 0
    lwp_bin = FLTARR(grid.xdim,grid.ydim) & lwp_bin[*,*] = 0
    iwp_bin = FLTARR(grid.xdim,grid.ydim) & iwp_bin[*,*] = 0
    cfc_bin = FLTARR(grid.xdim,grid.ydim) & cfc_bin[*,*] = 0
    cph_bin = FLTARR(grid.xdim,grid.ydim) & cph_bin[*,*] = 0

    ; -- lwp & iwp incloud, 
    ;    i.e. in sumup_cloud_params: lwp_tmp/cfc_tmp; iwp_tmp/cfc_tmp
    lwp_incloud = FLTARR(grid.xdim,grid.ydim) & lwp_incloud[*,*] = 0
    iwp_incloud = FLTARR(grid.xdim,grid.ydim) & iwp_incloud[*,*] = 0
    lwp_incloud_bin = FLTARR(grid.xdim,grid.ydim) & lwp_incloud_bin[*,*] = 0
    iwp_incloud_bin = FLTARR(grid.xdim,grid.ydim) & iwp_incloud_bin[*,*] = 0

    numb_lwp_incloud = LONARR(grid.xdim,grid.ydim) & numb_lwp_incloud[*,*] = 0
    numb_iwp_incloud = LONARR(grid.xdim,grid.ydim) & numb_iwp_incloud[*,*] = 0
    numb_lwp_incloud_bin = LONARR(grid.xdim,grid.ydim) & numb_lwp_incloud_bin[*,*] = 0
    numb_iwp_incloud_bin = LONARR(grid.xdim,grid.ydim) & numb_iwp_incloud_bin[*,*] = 0

    ctp_hist = LONARR(grid.xdim,grid.ydim,histo.dim_ctp) & ctp_hist[*,*,*] = 0l

    numb = LONARR(grid.xdim,grid.ydim) & numb[*,*] = 0
    numb_lwp = LONARR(grid.xdim,grid.ydim) & numb_lwp[*,*] = 0
    numb_iwp = LONARR(grid.xdim,grid.ydim) & numb_iwp[*,*] = 0
    numb_lwp_bin = LONARR(grid.xdim,grid.ydim) & numb_lwp_bin[*,*] = 0
    numb_iwp_bin = LONARR(grid.xdim,grid.ydim) & numb_iwp_bin[*,*] = 0

    IF(ISA(numb_tmp) EQ 0) THEN numb_tmp = INTARR(grid.xdim,grid.ydim)
    IF(ISA(numb_raw) EQ 0) THEN numb_raw = 0l


    ; create structure
    arrays = {ctp_hist:ctp_hist, $
              cph:cph, ctt:ctt, cth:cth, ctp:ctp, $
              lwp:lwp, iwp:iwp, cfc:cfc, $
              lwp_bin:lwp_bin, iwp_bin:iwp_bin, $
              cfc_bin:cfc_bin, cph_bin:cph_bin, $
              lwp_inc:lwp_incloud, $
              iwp_inc:iwp_incloud, $
              lwp_inc_bin:lwp_incloud_bin, $
              iwp_inc_bin:iwp_incloud_bin}

    counts = {numb:numb, $
              numb_tmp:numb_tmp, $
              numb_raw:numb_raw, $
              numb_lwp:numb_lwp, $
              numb_iwp:numb_iwp, $
              numb_lwp_bin:numb_lwp_bin, $
              numb_iwp_bin:numb_iwp_bin, $
              numb_lwp_inc:numb_lwp_incloud, $
              numb_iwp_inc:numb_iwp_incloud, $
              numb_lwp_inc_bin:numb_lwp_incloud_bin, $
              numb_iwp_inc_bin:numb_iwp_incloud_bin}

END
