;-------------------------------------------------------------------
;--  era_simulator: initialize output arrays
;-------------------------------------------------------------------
;
; in : grid, histo
; out: arrays, counts
;
; IDL> help, arrays, /str
; ** Structure <752e68>, 16 tags, length=30150720, data length=30150720, refs=1:
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
; IDL> help, counts, /str
; ** Structure <7551e8>, 11 tags, length=10396804, data length=10396804, refs=1:
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
    ctp_hist = LONARR(grid.xdim,grid.ydim,histo.dim_ctp) & ctp_hist[*,*,*] = 0l

    numb_raw = 0l
    numb_tmp = LONARR(grid.xdim,grid.ydim)
    numb = LONARR(grid.xdim,grid.ydim) & numb[*,*] = 0
    numb_lwp = LONARR(grid.xdim,grid.ydim) & numb_lwp[*,*] = 0
    numb_iwp = LONARR(grid.xdim,grid.ydim) & numb_iwp[*,*] = 0
    numb_lwp_bin = LONARR(grid.xdim,grid.ydim) & numb_lwp_bin[*,*] = 0
    numb_iwp_bin = LONARR(grid.xdim,grid.ydim) & numb_iwp_bin[*,*] = 0

    ; -- lwp & iwp incloud, 
    ;    i.e. in sumup_cloud_params: lwp_tmp/cfc_tmp; iwp_tmp/cfc_tmp
    lwp_inc = FLTARR(grid.xdim,grid.ydim) & lwp_inc[*,*] = 0
    iwp_inc = FLTARR(grid.xdim,grid.ydim) & iwp_inc[*,*] = 0
    lwp_inc_bin = FLTARR(grid.xdim,grid.ydim) & lwp_inc_bin[*,*] = 0
    iwp_inc_bin = FLTARR(grid.xdim,grid.ydim) & iwp_inc_bin[*,*] = 0

    numb_lwp_inc = LONARR(grid.xdim,grid.ydim) & numb_lwp_inc[*,*] = 0
    numb_iwp_inc = LONARR(grid.xdim,grid.ydim) & numb_iwp_inc[*,*] = 0
    numb_lwp_inc_bin = LONARR(grid.xdim,grid.ydim) & numb_lwp_inc_bin[*,*] = 0
    numb_iwp_inc_bin = LONARR(grid.xdim,grid.ydim) & numb_iwp_inc_bin[*,*] = 0


    ; create structure
    arrays = {ctp_hist:ctp_hist, $
              cph:cph, ctt:ctt, cth:cth, ctp:ctp, $
              lwp:lwp, iwp:iwp, cfc:cfc, $
              lwp_bin:lwp_bin, iwp_bin:iwp_bin, $
              cfc_bin:cfc_bin, cph_bin:cph_bin, $
              lwp_inc:lwp_inc, $
              iwp_inc:iwp_inc, $
              lwp_inc_bin:lwp_inc_bin, $
              iwp_inc_bin:iwp_inc_bin}

    counts = {ctp:numb, $
              tmp:numb_tmp, $
              raw:numb_raw, $
              lwp:numb_lwp, $
              iwp:numb_iwp, $
              lwp_bin:numb_lwp_bin, $
              iwp_bin:numb_iwp_bin, $
              lwp_inc:numb_lwp_inc, $
              iwp_inc:numb_iwp_inc, $
              lwp_inc_bin:numb_lwp_inc_bin, $
              iwp_inc_bin:numb_iwp_inc_bin}

END