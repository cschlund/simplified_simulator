;-----------------------------------------------------------------------------
; IN : means, counts
; OUT: means, counts
;-----------------------------------------------------------------------------
PRO MEAN_VARS, means, counts
;-----------------------------------------------------------------------------

    ; -- weight mean with number of observations
    wo_numi  = WHERE(counts.CTP GT 0, n_wo_numi)

    IF(n_wo_numi GT 0) THEN BEGIN
        means.CTP[wo_numi] = means.CTP[wo_numi] / counts.CTP[wo_numi]
        means.CTH[wo_numi] = (means.CTH[wo_numi] / counts.CTP[wo_numi]) / 1000. ;[km]
        means.CTT[wo_numi] = means.CTT[wo_numi] / counts.CTP[wo_numi]
        means.CPH[wo_numi] = means.CPH[wo_numi] / counts.CTP[wo_numi]
    ENDIF


    ; -- cloud fraction divided by number of files read = raw
    means.CFC = means.CFC / counts.RAW


    ; -- convert LWP,IWP from 'kg/m2' to 'g/m2' (CCI conform), 
    ;    i.e. multiply with 1000.

    tcwp = WHERE(counts.CWP GT 0, ntcwp)
    IF (ntcwp GT 0) THEN $
        means.CWP[tcwp] = (means.CWP[tcwp] / counts.CWP[tcwp])*1000.

    ; -- LWP & IWP grid mean
    idx_liq = WHERE(counts.LWP GT 0, nidx_liq)
    IF(nidx_liq GT 0) THEN $
        means.LWP[idx_liq] = (means.LWP[idx_liq] / counts.LWP[idx_liq])*1000.

    idx_ice = WHERE(counts.IWP GT 0, nidx_ice)
    IF(nidx_ice GT 0) THEN $
        means.IWP[idx_ice] = (means.IWP[idx_ice] / counts.IWP[idx_ice])*1000.


    ; -- cloud optical thickness
    tcot = WHERE(counts.COT GT 0, ntcot)
    IF (ntcot GT 0) THEN $
        means.COT[tcot] = means.COT[tcot] / counts.COT[tcot]

    lcot = WHERE(counts.COT_LIQ GT 0, nlcot)
    IF (nlcot GT 0) THEN $
        means.COT_LIQ[lcot] = means.COT_LIQ[lcot] / counts.COT_LIQ[lcot]

    icot = WHERE(counts.COT_ICE GT 0, nicot)
    IF (nicot GT 0) THEN $
        means.COT_ICE[icot] = means.COT_ICE[icot] / counts.COT_ICE[icot]


    ; -- cloud effective radius
    tcer = WHERE(counts.CER GT 0, ntcer)
    IF (ntcer GT 0) THEN $
        means.CER[tcer] = means.CER[tcer] / counts.CER[tcer]

    lcer = WHERE(counts.CER_LIQ GT 0, nlcer)
    IF (nlcer GT 0) THEN $
        means.CER_LIQ[lcer] = means.CER_LIQ[lcer] / counts.CER_LIQ[lcer]

    icer = WHERE(counts.CER_ICE GT 0, nicer)
    IF (nicer GT 0) THEN $
        means.CER_ICE[icer] = means.CER_ICE[icer] / counts.CER_ICE[icer]



    ; -- fill_value for grid cells with no observations

    wo_numi0 = WHERE(counts.CTP EQ 0, n_wo_numi0)
    IF(n_wo_numi0 GT 0) THEN BEGIN
        means.CTP[wo_numi0] = -999.
        means.CTH[wo_numi0] = -999.
        means.CTT[wo_numi0] = -999.
        means.CPH[wo_numi0] = -999.
    ENDIF

    idx_liq0 = WHERE(counts.LWP EQ 0, nidx_liq0)
    IF(nidx_liq0 GT 0) THEN means.LWP[idx_liq0] = -999.

    idx_ice0 = WHERE(counts.IWP EQ 0, nidx_ice0)
    IF(nidx_ice0 GT 0) THEN means.IWP[idx_ice0] = -999.

    tcwp0 = WHERE(counts.CWP EQ 0, ntcwp0)
    IF (ntcwp0 GT 0) THEN means.CWP[tcwp0] = -999.

    tcot0 = WHERE(counts.COT EQ 0, ntcot0)
    IF (ntcot0 GT 0) THEN means.COT[tcot0] = -999.

    lcot0 = WHERE(counts.COT_LIQ EQ 0, nlcot0)
    IF (nlcot0 GT 0) THEN means.COT_LIQ[lcot0] = -999.

    icot0 = WHERE(counts.COT_ICE EQ 0, nicot0)
    IF (nicot0 GT 0) THEN means.COT_ICE[icot0] = -999.

    tcer0 = WHERE(counts.CER EQ 0, ntcer0)
    IF (ntcer0 GT 0) THEN means.CER[tcer0] = -999.

    lcer0 = WHERE(counts.CER_LIQ EQ 0, nlcer0)
    IF (nlcer0 GT 0) THEN means.CER_LIQ[lcer0] = -999.

    icer0 = WHERE(counts.CER_ICE EQ 0, nicer0)
    IF (nicer0 GT 0) THEN means.CER_ICE[icer0] = -999.


    ; HIST1D_CTP      LONG      Array[720, 361, 15, 2]
    h1ctp = WHERE(means.HIST1D_CTP EQ 0, nh1ctp)
    IF (nh1ctp GT 0) THEN means.HIST1D_CTP[h1ctp] = -999l

    ; HIST1D_CTT      LONG      Array[720, 361, 16, 2]
    h1ctt = WHERE(means.HIST1D_CTT EQ 0, nh1ctt)
    IF (nh1ctt GT 0) THEN means.HIST1D_CTT[h1ctt] = -999l

    ; HIST1D_CWP      LONG      Array[720, 361, 14, 2]
    h1cwp = WHERE(means.HIST1D_CWP EQ 0, nh1cwp)
    IF (nh1cwp GT 0) THEN means.HIST1D_CWP[h1cwp] = -999l

    ; HIST1D_COT      LONG      Array[720, 361, 13, 2]
    h1cot = WHERE(means.HIST1D_COT EQ 0, nh1cot)
    IF (nh1cot GT 0) THEN means.HIST1D_COT[h1cot] = -999l

    ; HIST1D_CER      LONG      Array[720, 361, 13, 2]
    h1cer = WHERE(means.HIST1D_CER EQ 0, nh1cer)
    IF (nh1cer GT 0) THEN means.HIST1D_CER[h1cer] = -999l

    ; HIST2D_COT_CTP      LONG      Array[720, 361, 13, 15, 2]
    h2 = WHERE(means.HIST2D_COT_CTP EQ 0, nh2)
    IF (nh2 GT 0) THEN means.HIST2D_COT_CTP[h2] = -999l

END
