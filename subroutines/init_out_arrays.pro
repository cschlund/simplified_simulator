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
; ** Structure HISTOGRAMS, 27 tags, length=1172, data length=1150:
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
;    CER2D           FLOAT     Array[2, 11]
;    CER1D           FLOAT     Array[12]
;    CER1D_DIM       INT             12
;    CER_BIN1D       FLOAT     Array[11]
;    CER_BIN1D_DIM   INT             11
;
; ** Structure FINAL_OUTPUT, 19 tags, length=540633600, data length=540633600:
;    HIST2D_COT_CTP  LONG      Array[720, 361, 13, 15, 2]
;    HIST1D_CTP      LONG      Array[720, 361, 15, 2]
;    HIST1D_CTT      LONG      Array[720, 361, 16, 2]
;    HIST1D_CWP      LONG      Array[720, 361, 14, 2]
;    HIST1D_COT      LONG      Array[720, 361, 13, 2]
;    CFC             FLOAT     Array[720, 361]
;    CPH             FLOAT     Array[720, 361]
;    CTT             FLOAT     Array[720, 361]
;    CTH             FLOAT     Array[720, 361]
;    CTP             FLOAT     Array[720, 361]
;    CWP             FLOAT     Array[720, 361]
;    LWP             FLOAT     Array[720, 361]
;    IWP             FLOAT     Array[720, 361]
;    COT             FLOAT     Array[720, 361]
;    COT_LIQ         FLOAT     Array[720, 361]
;    COT_ICE         FLOAT     Array[720, 361]
;    CER             FLOAT     Array[720, 361]
;    CER_LIQ         FLOAT     Array[720, 361]
;    CER_ICE         FLOAT     Array[720, 361]
;
; ** Structure FINAL_COUNTS, 11 tags, length=10396804, data length=10396804:
;    RAW             LONG                 0
;    CTP             LONG      Array[720, 361]
;    COT             LONG      Array[720, 361]
;    CWP             LONG      Array[720, 361]
;    LWP             LONG      Array[720, 361]
;    IWP             LONG      Array[720, 361]
;    COT_LIQ         LONG      Array[720, 361]
;    COT_ICE         LONG      Array[720, 361]
;    CER             LONG      Array[720, 361]
;    CER_LIQ         LONG      Array[720, 361]
;    CER_ICE         LONG      Array[720, 361]
;
;-------------------------------------------------------------------

PRO INIT_OUT_ARRAYS, grid, hist, arrays, counts

    ; -- main output
    cfc = FLTARR(grid.xdim,grid.ydim) & cfc[*,*] = 0
    cph = FLTARR(grid.xdim,grid.ydim) & cph[*,*] = 0
    ctt = FLTARR(grid.xdim,grid.ydim) & ctt[*,*] = 0
    cth = FLTARR(grid.xdim,grid.ydim) & cth[*,*] = 0
    ctp = FLTARR(grid.xdim,grid.ydim) & ctp[*,*] = 0
    cwp = FLTARR(grid.xdim,grid.ydim) & cwp[*,*] = 0
    lwp = FLTARR(grid.xdim,grid.ydim) & lwp[*,*] = 0
    iwp = FLTARR(grid.xdim,grid.ydim) & iwp[*,*] = 0
    cot = FLTARR(grid.xdim,grid.ydim) & cot[*,*] = 0
    cot_liq = FLTARR(grid.xdim,grid.ydim) & cot_liq[*,*] = 0
    cot_ice = FLTARR(grid.xdim,grid.ydim) & cot_ice[*,*] = 0
    cer = FLTARR(grid.xdim,grid.ydim) & cer[*,*] = 0
    cer_liq = FLTARR(grid.xdim,grid.ydim) & cer_liq[*,*] = 0
    cer_ice = FLTARR(grid.xdim,grid.ydim) & cer_ice[*,*] = 0

    ; -- hist1d [lon,lat,bins,phase] = [720,361,15,2]
    hist1d_ctp = LONARR(grid.xdim,grid.ydim,hist.ctp_bin1d_dim,hist.phase_dim) 
    hist1d_ctp[*,*,*,*] = 0l
    hist1d_ctt = LONARR(grid.xdim,grid.ydim,hist.ctt_bin1d_dim,hist.phase_dim) 
    hist1d_ctt[*,*,*,*] = 0l
    hist1d_cwp = LONARR(grid.xdim,grid.ydim,hist.cwp_bin1d_dim,hist.phase_dim) 
    hist1d_cwp[*,*,*,*] = 0l
    hist1d_cot = LONARR(grid.xdim,grid.ydim,hist.cot_bin1d_dim,hist.phase_dim) 
    hist1d_cot[*,*,*,*] = 0l
    hist1d_cer = LONARR(grid.xdim,grid.ydim,hist.cer_bin1d_dim,hist.phase_dim) 
    hist1d_cer[*,*,*,*] = 0l

    ; -- hist2d [lon,lat,cotbins,ctpbins,phase] = [720,361,13,15,2]
    hist2d_cot_ctp = LONARR(grid.xdim, grid.ydim, $
                            hist.cot_bin1d_dim, hist.ctp_bin1d_dim, $
                            hist.phase_dim) 
    hist2d_cot_ctp[*,*,*,*] = 0l

    ; -- counts
    numb_raw = 0l ; files & for cfc
    numb_ctp = LONARR(grid.xdim,grid.ydim) & numb_ctp[*,*] = 0
    numb_cwp = LONARR(grid.xdim,grid.ydim) & numb_cwp[*,*] = 0
    numb_lwp = LONARR(grid.xdim,grid.ydim) & numb_lwp[*,*] = 0
    numb_iwp = LONARR(grid.xdim,grid.ydim) & numb_iwp[*,*] = 0
    numb_cot = LONARR(grid.xdim,grid.ydim) & numb_cot[*,*] = 0
    numb_cot_liq = LONARR(grid.xdim,grid.ydim) & numb_cot_liq[*,*] = 0
    numb_cot_ice = LONARR(grid.xdim,grid.ydim) & numb_cot_ice[*,*] = 0
    numb_cer = LONARR(grid.xdim,grid.ydim) & numb_cer[*,*] = 0
    numb_cer_liq = LONARR(grid.xdim,grid.ydim) & numb_cer_liq[*,*] = 0
    numb_cer_ice = LONARR(grid.xdim,grid.ydim) & numb_cer_ice[*,*] = 0



    ; -- create structure
    arrays = {final_output, $
              hist2d_cot_ctp:hist2d_cot_ctp, $
              hist1d_ctp:hist1d_ctp, $ 
              hist1d_ctt:hist1d_ctt, $ 
              hist1d_cwp:hist1d_cwp, $ 
              hist1d_cot:hist1d_cot, $ 
              hist1d_cer:hist1d_cer, $ 
              cfc:cfc, cph:cph, ctt:ctt, $
              cth:cth, ctp:ctp, cwp:cwp, $
              lwp:lwp, iwp:iwp, $
              cot:cot, cot_liq:cot_liq, cot_ice:cot_ice, $
              cer:cer, cer_liq:cer_liq, cer_ice:cer_ice }

    counts = {final_counts,$ 
              raw:numb_raw, $
              ctp:numb_ctp, $
              cwp:numb_cwp, $
              lwp:numb_lwp, $
              iwp:numb_iwp, $ 
              cot:numb_cot, $
              cot_liq:numb_cot_liq, $
              cot_ice:numb_cot_ice, $
              cer:numb_cer, $
              cer_liq:numb_cer_liq, $
              cer_ice:numb_cer_ice }

END
