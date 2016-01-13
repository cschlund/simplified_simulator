;-------------------------------------------------------------------
;-- calculate cloud mean values after all files read (monthly mean)
;-------------------------------------------------------------------
;
; in : means, counts
; out: means, counts
;
; ** Structure FINAL_OUTPUT, 20 tags, length=563506560, data length=563506560:
;    HIST2D_COT_CTP  LONG      Array[720, 361, 13, 15, 2]
;    HIST1D_CTP      LONG      Array[720, 361, 15, 2]
;    HIST1D_CTT      LONG      Array[720, 361, 16, 2]
;    HIST1D_CWP      LONG      Array[720, 361, 14, 2]
;    HIST1D_COT      LONG      Array[720, 361, 13, 2]
;    HIST1D_CER      LONG      Array[720, 361, 13, 2]
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

PRO MEAN_VARS, means, counts

    ; -- weight mean with number of observations
    wo_numi  = WHERE(counts.ctp GT 0, n_wo_numi)

    IF(n_wo_numi GT 0) THEN BEGIN
        means.ctp[wo_numi] = means.ctp[wo_numi] / counts.ctp[wo_numi]
        means.cth[wo_numi] = (means.cth[wo_numi] / counts.ctp[wo_numi]) / 1000. ;[km]
        means.ctt[wo_numi] = means.ctt[wo_numi] / counts.ctp[wo_numi]
        means.cph[wo_numi] = means.cph[wo_numi] / counts.ctp[wo_numi]
    ENDIF


    ; -- cloud fraction divided by number of files read = raw
    means.cfc = means.cfc / counts.raw


    ; -- convert LWP,IWP from 'kg/m2' to 'g/m2' (CCI conform), 
    ;    i.e. multiply with 1000.

    tcwp = WHERE(counts.cwp GT 0, ntcwp)
    IF (ntcwp GT 0) THEN $
        means.cwp[tcwp] = (means.cwp[tcwp] / counts.cwp[tcwp])*1000.

    ; -- LWP & IWP grid mean
    idx_liq = WHERE(counts.lwp GT 0, nidx_liq)
    IF(nidx_liq GT 0) THEN $
        means.lwp[idx_liq] = (means.lwp[idx_liq] / counts.lwp[idx_liq])*1000.

    idx_ice = WHERE(counts.iwp GT 0, nidx_ice)
    IF(nidx_ice GT 0) THEN $
        means.iwp[idx_ice] = (means.iwp[idx_ice] / counts.iwp[idx_ice])*1000.


    ; -- cloud optical thickness
    tcot = WHERE(counts.cot GT 0, ntcot)
    IF (ntcot GT 0) THEN $
        means.cot[tcot] = means.cot[tcot] / counts.cot[tcot]

    lcot = WHERE(counts.cot_liq GT 0, nlcot)
    IF (nlcot GT 0) THEN $
        means.cot_liq[lcot] = means.cot_liq[lcot] / counts.cot_liq[lcot]

    icot = WHERE(counts.cot_ice GT 0, nicot)
    IF (nicot GT 0) THEN $
        means.cot_ice[icot] = means.cot_ice[icot] / counts.cot_ice[icot]


    ; -- cloud effective radius
    tcer = WHERE(counts.cer GT 0, ntcer)
    IF (ntcer GT 0) THEN $
        means.cer[tcer] = means.cer[tcer] / counts.cer[tcer]

    lcer = WHERE(counts.cer_liq GT 0, nlcer)
    IF (nlcer GT 0) THEN $
        means.cer_liq[lcer] = means.cer_liq[lcer] / counts.cer_liq[lcer]

    icer = WHERE(counts.cer_ice GT 0, nicer)
    IF (nicer GT 0) THEN $
        means.cer_ice[icer] = means.cer_ice[icer] / counts.cer_ice[icer]



    ; -- fill_value for grid cells with no observations

    wo_numi0 = WHERE(counts.ctp EQ 0, n_wo_numi0)
    IF(n_wo_numi0 GT 0) THEN BEGIN
        means.ctp[wo_numi0] = -999.
        means.cth[wo_numi0] = -999.
        means.ctt[wo_numi0] = -999.
        means.cph[wo_numi0] = -999.
    ENDIF

    idx_liq0 = WHERE(counts.lwp EQ 0, nidx_liq0)
    IF(nidx_liq0 GT 0) THEN means.lwp[idx_liq0] = -999.

    idx_ice0 = WHERE(counts.iwp EQ 0, nidx_ice0)
    IF(nidx_ice0 GT 0) THEN means.iwp[idx_ice0] = -999.

    tcwp0 = WHERE(counts.cwp EQ 0, ntcwp0)
    IF (ntcwp0 GT 0) THEN means.cwp[tcwp0] = -999.

    tcot0 = WHERE(counts.cot EQ 0, ntcot0)
    IF (ntcot0 GT 0) THEN means.cot[tcot0] = -999.

    lcot0 = WHERE(counts.cot_liq EQ 0, nlcot0)
    IF (nlcot0 GT 0) THEN means.cot_liq[lcot0] = -999.

    icot0 = WHERE(counts.cot_ice EQ 0, nicot0)
    IF (nicot0 GT 0) THEN means.cot_ice[icot0] = -999.

    tcer0 = WHERE(counts.cer EQ 0, ntcer0)
    IF (ntcer0 GT 0) THEN means.cer[tcer0] = -999.

    lcer0 = WHERE(counts.cer_liq EQ 0, nlcer0)
    IF (nlcer0 GT 0) THEN means.cer_liq[lcer0] = -999.

    icer0 = WHERE(counts.cer_ice EQ 0, nicer0)
    IF (nicer0 GT 0) THEN means.cer_ice[icer0] = -999.


    ; HIST1D_CTP      LONG      Array[720, 361, 15, 2]
    h1ctp = WHERE(means.hist1d_ctp EQ 0, nh1ctp)
    IF (nh1ctp GT 0) THEN means.hist1d_ctp[h1ctp] = -999l

    ; HIST1D_CTT      LONG      Array[720, 361, 16, 2]
    h1ctt = WHERE(means.hist1d_ctt EQ 0, nh1ctt)
    IF (nh1ctt GT 0) THEN means.hist1d_ctt[h1ctt] = -999l

    ; HIST1D_CWP      LONG      Array[720, 361, 14, 2]
    h1cwp = WHERE(means.hist1d_cwp EQ 0, nh1cwp)
    IF (nh1cwp GT 0) THEN means.hist1d_cwp[h1cwp] = -999l

    ; HIST1D_COT      LONG      Array[720, 361, 13, 2]
    h1cot = WHERE(means.hist1d_cot EQ 0, nh1cot)
    IF (nh1cot GT 0) THEN means.hist1d_cot[h1cot] = -999l

    ; HIST1D_CER      LONG      Array[720, 361, 13, 2]
    h1cer = WHERE(means.hist1d_cer EQ 0, nh1cer)
    IF (nh1cer GT 0) THEN means.hist1d_cer[h1cer] = -999l

    ; HIST2D_COT_CTP      LONG      Array[720, 361, 13, 15, 2]
    h2 = WHERE(means.hist2d_cot_ctp EQ 0, nh2)
    IF (nh2 GT 0) THEN means.hist2d_cot_ctp[h2] = -999l

END
