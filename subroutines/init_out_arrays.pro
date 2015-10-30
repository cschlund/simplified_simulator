;-------------------------------------------------------------------
;--  era_simulator: initialize output arrays
;-------------------------------------------------------------------
;
; in : grid, hist
; out: arrays, counts
;
; ** Structure ERA_GRID, 5 tags, length=2079368, data length=2079366:
; LON2D           FLOAT     Array[720, 361]
; LAT2D           FLOAT     Array[720, 361]
; XDIM            INT            720
; YDIM            INT            361
; ZDIM            INT             27
;
; ** Structure HISTOGRAMS, 22 tags, length=984, data length=966:
;    PHASE           INT       Array[2]
;    PHASE_DIM       INT              2
;    CTP2D           FLOAT     Array[2, 15]
;    CTP1D           FLOAT     Array[16]
;    CTP1D_DIM       INT             16
;    CTP_BIN1D       FLOAT     Array[15]
;    CTP_BIN1D_DIM   INT             15
;    COT2D           FLOAT     Array[2, 13]
;    COT1D           FLOAT     Array[14]
;    COT1D_DIM       INT             14
;    COT_BIN1D       FLOAT     Array[13]
;    COT_BIN1D_DIM   INT             13
;    CTT2D           FLOAT     Array[2, 16]
;    CTT1D           FLOAT     Array[17]
;    CTT1D_DIM       INT             17
;    CTT_BIN1D       FLOAT     Array[16]
;    CTT_BIN1D_DIM   INT             16
;    CWP2D           FLOAT     Array[2, 14]
;    CWP1D           FLOAT     Array[15]
;    CWP1D_DIM       INT             15
;    CWP_BIN1D       FLOAT     Array[14]
;    CWP_BIN1D_DIM   INT             14
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

PRO INIT_OUT_ARRAYS, grid, hist, arrays, counts

    cot = FLTARR(grid.xdim,grid.ydim) & cot[*,*] = 0
    cwp = FLTARR(grid.xdim,grid.ydim) & cwp[*,*] = 0
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

    ; hist1d [lon,lat,bins,phase] = [720,361,15,2]
    hist1d_ctp = LONARR(grid.xdim,grid.ydim,hist.ctp_bin1d_dim,hist.phase_dim) 
    hist1d_ctp[*,*,*,*] = 0l
    hist1d_ctt = LONARR(grid.xdim,grid.ydim,hist.ctt_bin1d_dim,hist.phase_dim) 
    hist1d_ctt[*,*,*,*] = 0l
    hist1d_cwp = LONARR(grid.xdim,grid.ydim,hist.cwp_bin1d_dim,hist.phase_dim) 
    hist1d_cwp[*,*,*,*] = 0l
    hist1d_cot = LONARR(grid.xdim,grid.ydim,hist.cot_bin1d_dim,hist.phase_dim) 
    hist1d_cot[*,*,*,*] = 0l

    ; counts
    numb_raw = 0l
    numb = LONARR(grid.xdim,grid.ydim) & numb[*,*] = 0
    numb_cot = LONARR(grid.xdim,grid.ydim) & numb_cot[*,*] = 0
    numb_cwp = LONARR(grid.xdim,grid.ydim) & numb_cwp[*,*] = 0
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

    ; counts
    numb_lwp_inc = LONARR(grid.xdim,grid.ydim) & numb_lwp_inc[*,*] = 0
    numb_iwp_inc = LONARR(grid.xdim,grid.ydim) & numb_iwp_inc[*,*] = 0
    numb_lwp_inc_bin = LONARR(grid.xdim,grid.ydim) & numb_lwp_inc_bin[*,*] = 0
    numb_iwp_inc_bin = LONARR(grid.xdim,grid.ydim) & numb_iwp_inc_bin[*,*] = 0


    ; -- cot incloud: because the incloud COT is used in search_for_cloud.pro
    ; incloud ori. model
    cot_liq = FLTARR(grid.xdim,grid.ydim) & cot_liq[*,*] = 0
    cot_ice = FLTARR(grid.xdim,grid.ydim) & cot_ice[*,*] = 0
    ; incloud pseudo-satellite, based on binary cph
    cot_liq_bin = FLTARR(grid.xdim,grid.ydim) & cot_liq_bin[*,*] = 0
    cot_ice_bin = FLTARR(grid.xdim,grid.ydim) & cot_ice_bin[*,*] = 0

    ; counts
    numb_cot_liq = LONARR(grid.xdim,grid.ydim) & numb_cot_liq[*,*] = 0
    numb_cot_ice = LONARR(grid.xdim,grid.ydim) & numb_cot_ice[*,*] = 0
    numb_cot_liq_bin = LONARR(grid.xdim,grid.ydim) & numb_cot_liq_bin[*,*] = 0
    numb_cot_ice_bin = LONARR(grid.xdim,grid.ydim) & numb_cot_ice_bin[*,*] = 0


    ; -- create structure
    arrays = {final_output, $
                hist1d_ctp:hist1d_ctp, $ 
                hist1d_ctt:hist1d_ctt, $ 
                hist1d_cwp:hist1d_cwp, $ 
                hist1d_cot:hist1d_cot, $ 
                cwp:cwp, cot:cot, $ 
                cph:cph, ctt:ctt, cth:cth, ctp:ctp, $ 
                lwp:lwp, iwp:iwp, cfc:cfc, $ 
                lwp_bin:lwp_bin, iwp_bin:iwp_bin, $ 
                cfc_bin:cfc_bin, cph_bin:cph_bin, $ 
                lwp_inc:lwp_inc, iwp_inc:iwp_inc, $ 
                lwp_inc_bin:lwp_inc_bin, iwp_inc_bin:iwp_inc_bin, $
                cot_liq:cot_liq, cot_ice:cot_ice, $
                cot_liq_bin:cot_liq_bin, cot_ice_bin:cot_ice_bin}

    counts = {final_counts,$ 
                ctp:numb, $
                cot:numb_cot, cwp:numb_cwp, $
                raw:numb_raw, $
                lwp:numb_lwp, iwp:numb_iwp, $ 
                lwp_bin:numb_lwp_bin, $ 
                iwp_bin:numb_iwp_bin, $ 
                lwp_inc:numb_lwp_inc, $ 
                iwp_inc:numb_iwp_inc, $ 
                lwp_inc_bin:numb_lwp_inc_bin, $ 
                iwp_inc_bin:numb_iwp_inc_bin, $
                cot_liq:numb_cot_liq, $
                cot_ice:numb_cot_ice, $
                cot_liq_bin:numb_cot_liq_bin, $
                cot_ice_bin:numb_cot_ice_bin}

END
