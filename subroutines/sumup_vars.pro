;-------------------------------------------------------------------
;-- sum up cloud parameters from current file processed
;-------------------------------------------------------------------
;
; in : flag, means, temps, counts, histo
; out: means, counts
;
; flag ... either 'ori' or 'sat'
;           this is required for the sumup total COT & CWP
;           because for model (ori) : cot_liq+cot_ice & lwp+iwp
;                   for simu. (sat) : cot_liq_bin+cot_ice_bin & 
;                                     lwp_inc_bin+iwp_inc_bin
;
; ** Structure FINAL_OUTPUT, 16 tags, length=537514560, data length=537514560:
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
;
; ** Structure FINAL_COUNTS, 8 tags, length=7277764, data length=7277764:
;    RAW             LONG                 0
;    CTP             LONG      Array[720, 361]
;    COT             LONG      Array[720, 361]
;    CWP             LONG      Array[720, 361]
;    LWP             LONG      Array[720, 361]
;    IWP             LONG      Array[720, 361]
;    COT_LIQ         LONG      Array[720, 361]
;    COT_ICE         LONG      Array[720, 361]
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
; ** Structure TEMP_ARRAYS, 19 tags, length=19753920, data length=19753920:
;    CTP             FLOAT     Array[720, 361]
;    CTH             FLOAT     Array[720, 361]
;    CTT             FLOAT     Array[720, 361]
;    CPH             FLOAT     Array[720, 361]
;    LWP             FLOAT     Array[720, 361]
;    IWP             FLOAT     Array[720, 361]
;    CFC             FLOAT     Array[720, 361]
;    COT             FLOAT     Array[720, 361]
;    CWP             FLOAT     Array[720, 361]
;    CFC_BIN         FLOAT     Array[720, 361]
;    CPH_BIN         FLOAT     Array[720, 361]
;    LWP_BIN         FLOAT     Array[720, 361]
;    IWP_BIN         FLOAT     Array[720, 361]
;    LWP_INC_BIN     FLOAT     Array[720, 361]
;    IWP_INC_BIN     FLOAT     Array[720, 361]
;    COT_LIQ         FLOAT     Array[720, 361]
;    COT_ICE         FLOAT     Array[720, 361]
;    COT_LIQ_BIN     FLOAT     Array[720, 361]
;    COT_ICE_BIN     FLOAT     Array[720, 361]
;
;-------------------------------------------------------------------

PRO SUMUP_VARS, flag, means, counts, temps, histo


    ; === MODEL like output ===

    IF ( flag EQ 'ori' ) THEN BEGIN

        ; no condition for cloud fraction [0;1]: clear or cloudy
        ; fillvalue = 0., thus counts = raw = number of files read
        means.cfc = means.cfc + temps.cfc

        ; -- CTP, CTT, CTH, CPH
        wo_ctp = WHERE((temps.ctp GT 10.) AND $
                       (temps.cth GT 0.)  AND $
                       (temps.cph GE 0.), nwo_ctp)

        means.ctp[wo_ctp] = means.ctp[wo_ctp] + temps.ctp[wo_ctp]
        means.cth[wo_ctp] = means.cth[wo_ctp] + temps.cth[wo_ctp]
        means.ctt[wo_ctp] = means.ctt[wo_ctp] + temps.ctt[wo_ctp]
        means.cph[wo_ctp] = means.cph[wo_ctp] + temps.cph[wo_ctp]
        counts.ctp[wo_ctp] = counts.ctp[wo_ctp] + 1l


        ; -- TOTAL COT (liquid + ice)
        temps.cot = temps.cot_liq + temps.cot_ice
        wo_cot = WHERE(temps.cot GT 0., nwo_cot)
        means.cot[wo_cot] = means.cot[wo_cot] + temps.cot[wo_cot]
        counts.cot[wo_cot] = counts.cot[wo_cot] + 1l


        ; -- COT_LIQ
        wo_lcot = WHERE(temps.cot_liq GT 0., nwo_lcot)
        means.cot_liq[wo_lcot] = means.cot_liq[wo_lcot] + temps.cot_liq[wo_lcot]
        counts.cot_liq[wo_lcot] = counts.cot_liq[wo_lcot] + 1l


        ; -- COT_ICE
        wo_icot = WHERE(temps.cot_ice GT 0., nwo_icot)
        means.cot_ice[wo_icot] = means.cot_ice[wo_icot] + temps.cot_ice[wo_icot]
        counts.cot_ice[wo_icot] = counts.cot_ice[wo_icot] + 1l


        ; -- lwp grid mean
        wo_lwp = WHERE(temps.lwp GT 0., nwo_lwp)
        means.lwp[wo_lwp] = means.lwp[wo_lwp] + temps.lwp[wo_lwp]
        counts.lwp[wo_lwp] = counts.lwp[wo_lwp] + 1l

        ; -- iwp grid mean
        wo_iwp = WHERE(temps.iwp GT 0., nwo_iwp)
        means.iwp[wo_iwp] = means.iwp[wo_iwp] + temps.iwp[wo_iwp]
        counts.iwp[wo_iwp] = counts.iwp[wo_iwp] + 1l


        ; -- TOTAL CWP (liquid + ice)
        temps.cwp = temps.lwp + temps.iwp
        wo_cwp = WHERE(temps.cwp GT 0., nwo_cwp)
        means.cwp[wo_cwp] = means.cwp[wo_cwp] + temps.cwp[wo_cwp]
        counts.cwp[wo_cwp] = counts.cwp[wo_cwp] + 1l


        ; -- hist1d_cot
        res = SUMUP_HIST1D( bin_dim=histo.cot_bin1d_dim, $
                            cph_dim=histo.phase_dim, $
                            lim_bin=histo.cot2d, $
                            liq_tmp=temps.cot_liq, $
                            ice_tmp=temps.cot_ice, $
                            cfc_tmp=temps.cfc )
        means.hist1d_cot = means.hist1d_cot + res
        UNDEFINE, res 

        ; -- hist1d_cwp: bins [g/m2], temps [kg/m2]
        res = SUMUP_HIST1D( bin_dim=histo.cwp_bin1d_dim, $
                            cph_dim=histo.phase_dim, $
                            lim_bin=histo.cwp2d, $
                            liq_tmp=temps.lwp*1000., $
                            ice_tmp=temps.iwp*1000., $
                            cfc_tmp=temps.cfc )
        means.hist1d_cwp = means.hist1d_cwp + res
        UNDEFINE, res


        ;;;;;;;;;;;;;;;;;; DISABLED! ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;; -- hist1d_ctp
        ;res = SUMUP_HIST1D( bin_dim=histo.ctp_bin1d_dim, $
        ;                    cph_dim=histo.phase_dim, $
        ;                    lim_bin=histo.ctp2d, $
        ;                    var_tmp=temps.ctp, $
        ;                    cfc_tmp=temps.cfc, $
        ;                    cph_tmp=temps.cph )
        ;means.hist1d_ctp = means.hist1d_ctp + res
        ;UNDEFINE, res
        ;
        ;; -- hist1d_ctt
        ;res = SUMUP_HIST1D( bin_dim=histo.ctt_bin1d_dim, $
        ;                    cph_dim=histo.phase_dim, $
        ;                    lim_bin=histo.ctt2d, $
        ;                    var_tmp=temps.ctt, $
        ;                    cfc_tmp=temps.cfc, $
        ;                    cph_tmp=temps.cph )
        ;means.hist1d_ctt = means.hist1d_ctt + res
        ;UNDEFINE, res
        ;
        ;; -- hist2d_cot_ctp
        ;res = SUMUP_HIST2D( histo, temps.cot, temps.ctp, $
        ;                    temps.cfc, temps.cph)
        ;means.hist2d_cot_ctp = means.hist2d_cot_ctp + res
        ;UNDEFINE, res
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




    ; === PSEUDO-SATELLITE output ===

    ENDIF ELSE BEGIN

        ; no condition for cloud fraction [0;1]: clear or cloudy
        ; fillvalue = 0., thus counts = raw = number of files read
        means.cfc = means.cfc + temps.cfc_bin

        wo_ctp = WHERE((temps.ctp GT 10.) AND $
                       (temps.cth GT 0.)  AND $
                       (temps.cph_bin GE 0.), nwo_ctp)

        means.ctp[wo_ctp] = means.ctp[wo_ctp] + temps.ctp[wo_ctp]
        means.cth[wo_ctp] = means.cth[wo_ctp] + temps.cth[wo_ctp]
        means.ctt[wo_ctp] = means.ctt[wo_ctp] + temps.ctt[wo_ctp]
        means.cph[wo_ctp] = means.cph[wo_ctp] + temps.cph_bin[wo_ctp]
        counts.ctp[wo_ctp] = counts.ctp[wo_ctp] + 1l


        ; -- TOTAL COT (liquid + ice)
        temps.cot = temps.cot_liq_bin + temps.cot_ice_bin
        wo_cot = WHERE(temps.cot GT 0., nwo_cot)
        means.cot[wo_cot] = means.cot[wo_cot] + temps.cot[wo_cot]
        counts.cot[wo_cot] = counts.cot[wo_cot] + 1l


        ; -- COT_LIQ_BIN
        wo_lcot = WHERE(temps.cot_liq_bin GT 0., nwo_lcot)
        means.cot_liq[wo_lcot] = means.cot_liq[wo_lcot] + temps.cot_liq_bin[wo_lcot]
        counts.cot_liq[wo_lcot] = counts.cot_liq[wo_lcot] + 1l


        ; -- COT_ICE_BIN
        wo_icot = WHERE(temps.cot_ice_bin GT 0., nwo_icot)
        means.cot_ice[wo_icot] = means.cot_ice[wo_icot] + temps.cot_ice_bin[wo_icot]
        counts.cot_ice[wo_icot] = counts.cot_ice[wo_icot] + 1l


        ; -- lwp_inc_bin
        wo_lwp = WHERE(temps.cfc GT 0. AND temps.lwp_bin GT 0., nwo_lwp)
        IF (nwo_lwp GT 0) THEN BEGIN
            temps.lwp_inc_bin[wo_lwp] = temps.lwp_bin[wo_lwp] / temps.cfc[wo_lwp]
            means.lwp[wo_lwp] = means.lwp[wo_lwp] + temps.lwp_inc_bin[wo_lwp]
            counts.lwp[wo_lwp] = counts.lwp[wo_lwp] + 1l
        ENDIF


        ; -- iwp_inc_bin
        wo_iwp = WHERE(temps.cfc GT 0. AND temps.iwp_bin GT 0., nwo_iwp)
        IF (nwo_iwp GT 0) THEN BEGIN
            temps.iwp_inc_bin[wo_iwp] = temps.iwp_bin[wo_iwp] / temps.cfc[wo_iwp]
            means.iwp[wo_iwp] = means.iwp[wo_iwp] + temps.iwp_inc_bin[wo_iwp]
            counts.iwp[wo_iwp] = counts.iwp[wo_iwp] + 1l
        ENDIF


        ; -- TOTAL CWP (liquid + ice)
        temps.cwp = temps.lwp_inc_bin + temps.iwp_inc_bin
        wo_cwp = WHERE(temps.cwp GT 0., nwo_cwp)
        means.cwp[wo_cwp] = means.cwp[wo_cwp] + temps.cwp[wo_cwp]
        counts.cwp[wo_cwp] = counts.cwp[wo_cwp] + 1l



        ; -- hist1d_ctp
        res = SUMUP_HIST1D( bin_dim=histo.ctp_bin1d_dim, $
                            cph_dim=histo.phase_dim, $
                            lim_bin=histo.ctp2d, $
                            var_tmp=temps.ctp, $
                            cfc_tmp=temps.cfc_bin, $
                            cph_tmp=temps.cph_bin )
        means.hist1d_ctp = means.hist1d_ctp + res
        UNDEFINE, res

        ; -- hist1d_ctt
        res = SUMUP_HIST1D( bin_dim=histo.ctt_bin1d_dim, $
                            cph_dim=histo.phase_dim, $
                            lim_bin=histo.ctt2d, $
                            var_tmp=temps.ctt, $
                            cfc_tmp=temps.cfc_bin, $
                            cph_tmp=temps.cph_bin )
        means.hist1d_ctt = means.hist1d_ctt + res
        UNDEFINE, res

        ; -- hist1d_cot
        res = SUMUP_HIST1D( bin_dim=histo.cot_bin1d_dim, $
                            cph_dim=histo.phase_dim, $
                            lim_bin=histo.cot2d, $
                            var_tmp=temps.cot, $
                            cfc_tmp=temps.cfc_bin, $
                            cph_tmp=temps.cph_bin )
        means.hist1d_cot = means.hist1d_cot + res
        UNDEFINE, res 

        ; -- hist1d_cwp: bins [g/m2], temps [kg/m2]
        res = SUMUP_HIST1D( bin_dim=histo.cwp_bin1d_dim, $
                            cph_dim=histo.phase_dim, $
                            lim_bin=histo.cwp2d, $
                            var_tmp=temps.cwp*1000., $
                            cfc_tmp=temps.cfc_bin, $
                            cph_tmp=temps.cph_bin )
        means.hist1d_cwp = means.hist1d_cwp + res
        UNDEFINE, res


        ; -- hist2d_cot_ctp
        res = SUMUP_HIST2D( histo, temps.cot, temps.ctp, $
                            temps.cfc_bin, temps.cph_bin)
        means.hist2d_cot_ctp = means.hist2d_cot_ctp + res
        UNDEFINE, res


    ENDELSE


END
