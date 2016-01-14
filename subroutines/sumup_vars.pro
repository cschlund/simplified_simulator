;------------------------------------------------------------------------------
; IN : DATA, COUNTS, TEMPS, HIST_INFO
; OUT: DATA, COUNTS
;------------------------------------------------------------------------------
PRO SUMUP_VARS, means, counts, temps, histo
;------------------------------------------------------------------------------

    ; no condition for cloud fraction [0;1]: clear or cloudy
    ; fillvalue = 0., thus counts = raw = number of files read
    means.CFC = means.CFC + temps.CFC

    wo_ctp = WHERE( (temps.CTP GT 10.) AND (temps.CTH GT 0.)  AND $
                    (temps.CPH GE 0.), nwo_ctp )

    means.CTP[wo_ctp] = means.CTP[wo_ctp] + temps.CTP[wo_ctp]
    means.CTH[wo_ctp] = means.CTH[wo_ctp] + temps.CTH[wo_ctp]
    means.CTT[wo_ctp] = means.CTT[wo_ctp] + temps.CTT[wo_ctp]
    means.CPH[wo_ctp] = means.CPH[wo_ctp] + temps.CPH[wo_ctp]
    counts.CTP[wo_ctp] = counts.CTP[wo_ctp] + 1l


    ; TOTAL CER (liquid + ice) ------------------------------------------------
    temps.CER = temps.CER_LIQ + temps.CER_ICE
    wo_cer = WHERE(temps.CER GT 0., nwo_cer)
    means.CER[wo_cer] = means.CER[wo_cer] + temps.CER[wo_cer]
    counts.CER[wo_cer] = counts.CER[wo_cer] + 1l

    ; CER_LIQ
    wo_lcer = WHERE(temps.CER_LIQ GT 0., nwo_lcer)
    means.CER_LIQ[wo_lcer] = means.CER_LIQ[wo_lcer] + temps.CER_LIQ[wo_lcer]
    counts.CER_LIQ[wo_lcer] = counts.CER_LIQ[wo_lcer] + 1l

    ; CER_ICE
    wo_icer = WHERE(temps.CER_ICE GT 0., nwo_icer)
    means.CER_ICE[wo_icer] = means.CER_ICE[wo_icer] + temps.CER_ICE[wo_icer]
    counts.CER_ICE[wo_icer] = counts.CER_ICE[wo_icer] + 1l


    ; TOTAL COT (liquid + ice) ------------------------------------------------
    temps.COT = temps.COT_LIQ + temps.COT_ICE
    wo_cot = WHERE(temps.COT GT 0., nwo_cot)
    means.COT[wo_cot] = means.COT[wo_cot] + temps.COT[wo_cot]
    counts.COT[wo_cot] = counts.COT[wo_cot] + 1l

    ; COT_LIQ
    wo_lcot = WHERE(temps.COT_LIQ GT 0., nwo_lcot)
    means.COT_LIQ[wo_lcot] = means.COT_LIQ[wo_lcot] + temps.COT_LIQ[wo_lcot]
    counts.COT_LIQ[wo_lcot] = counts.COT_LIQ[wo_lcot] + 1l

    ; COT_ICE
    wo_icot = WHERE(temps.COT_ICE GT 0., nwo_icot)
    means.COT_ICE[wo_icot] = means.COT_ICE[wo_icot] + temps.COT_ICE[wo_icot]
    counts.COT_ICE[wo_icot] = counts.COT_ICE[wo_icot] + 1l


    ; TOTAL CWP (liquid + ice) ------------------------------------------------
    temps.CWP = temps.LWP + temps.IWP
    wo_cwp = WHERE(temps.CWP GT 0., nwo_cwp)
    means.CWP[wo_cwp] = means.CWP[wo_cwp] + temps.CWP[wo_cwp]
    counts.CWP[wo_cwp] = counts.CWP[wo_cwp] + 1l

    ; LWP
    wo_lwp = WHERE(temps.LWP GT 0., nwo_lwp)
    means.LWP[wo_lwp] = means.LWP[wo_lwp] + temps.LWP[wo_lwp]
    counts.LWP[wo_lwp] = counts.LWP[wo_lwp] + 1l

    ; IWP
    wo_iwp = WHERE(temps.IWP GT 0., nwo_iwp)
    means.IWP[wo_iwp] = means.IWP[wo_iwp] + temps.IWP[wo_iwp]
    counts.IWP[wo_iwp] = counts.IWP[wo_iwp] + 1l


    ; -- HIST1D_CTP
    res = SUMUP_HIST1D( bin_dim=histo.CTP_BIN1D_DIM, $
                        cph_dim=histo.PHASE_DIM, $
                        lim_bin=histo.CTP2D, $
                        var_tmp=temps.CTP, $
                        cfc_tmp=temps.CFC, $
                        cph_tmp=temps.CPH )
    means.HIST1D_CTP = means.HIST1D_CTP + res
    UNDEFINE, res

    ; -- HIST1D_CTT
    res = SUMUP_HIST1D( bin_dim=histo.CTT_BIN1D_DIM, $
                        cph_dim=histo.PHASE_DIM, $
                        lim_bin=histo.CTT2D, $
                        var_tmp=temps.CTT, $
                        cfc_tmp=temps.CFC, $
                        cph_tmp=temps.CPH )
    means.HIST1D_CTT = means.HIST1D_CTT + res
    UNDEFINE, res

    ; -- HIST1D_COT
    res = SUMUP_HIST1D( bin_dim=histo.COT_BIN1D_DIM, $
                        cph_dim=histo.PHASE_DIM, $
                        lim_bin=histo.COT2D, $
                        var_tmp=temps.COT, $
                        cfc_tmp=temps.CFC, $
                        cph_tmp=temps.CPH )
    means.HIST1D_COT = means.HIST1D_COT + res
    UNDEFINE, res 

    ; -- HIST1D_CER
    res = SUMUP_HIST1D( bin_dim=histo.CER_BIN1D_DIM, $
                        cph_dim=histo.PHASE_DIM, $
                        lim_bin=histo.CER2D, $
                        var_tmp=temps.CER, $
                        cfc_tmp=temps.CFC, $
                        cph_tmp=temps.CPH )
    means.HIST1D_CER = means.HIST1D_CER + res
    UNDEFINE, res 

    ; -- HIST1D_CWP: bins [g/m2], temps [kg/m2]
    res = SUMUP_HIST1D( bin_dim=histo.CWP_BIN1D_DIM, $
                        cph_dim=histo.PHASE_DIM, $
                        lim_bin=histo.CWP2D, $
                        var_tmp=temps.CWP*1000., $
                        cfc_tmp=temps.CFC, $
                        cph_tmp=temps.CPH )
    means.HIST1D_CWP = means.HIST1D_CWP + res
    UNDEFINE, res


    ; -- HIST2D_COT_CTP
    res = SUMUP_HIST2D( histo, temps.COT, temps.CTP, temps.CFC, temps.CPH)
    means.HIST2D_COT_CTP = means.HIST2D_COT_CTP + res
    UNDEFINE, res

END

