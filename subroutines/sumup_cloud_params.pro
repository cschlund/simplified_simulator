
;-------------------------------------------------------------------
;-- sum up cloud parameters from current file processed
;-------------------------------------------------------------------
;
; in : mean and tmp arrays incl. counters
;
; out: mean arrays incl. counters
;
; cph_mean ... cloud phase
; ctt_mean ... cloud top temperature
; cth_mean ... cloud top height
; ctp_mean ... cloud top pressure
; lwp_mean ... cloud liquid water path
; iwp_mean ... cloud ice water path
; cfc_mean_bin ... binary cloud fraction (0;1)
; cph_mean_bin ... binary cloud phase (0;1)
; lwp_mean_bin ... cloud liquid water path based on binary decision of cph
; iwp_mean_bin ... cloud ice water path based on binary decision of cph
; cfc_mean ... cloud fraction
; lwp_mean_inc ... LWP incloud mean
; iwp_mean_inc ... IWP incloud mean
; lwp_mean_inc_bin ... LWP incloud mean based on lwp_bin
; iwp_mean_inc_bin ... IWP incloud mean based on iwp_bin
; numb_lwp_inc ... count number of occurrences of lwp_mean_inc
; numb_iwp_inc ... count number of occurrences of iwp_mean_inc
; numb_lwp_inc_bin ... count number of occurrences of lwp_mean_inc_bin
; numb_iwp_inc_bin ... count number of occurrences of iwp_mean_inc_bin
; ctp_hist ... cloud top pressure histogram
; numb_lwp ... counter for positive LWP values (GT 0.)
; numb_iwp ... counter for positive IWP values (GT 0.)
; numb_lwp_bin ... counter cph_bin EQ 1. (liquid)
; numb_iwp_bin ... counter cph_bin EQ 0. (ice)
;
;-------------------------------------------------------------------

PRO SUMUP_CLOUD_PARAMS, cph_mean, ctt_mean, cth_mean, ctp_mean, $
                        lwp_mean, iwp_mean, cfc_mean, $
                        lwp_mean_inc, iwp_mean_inc, $
                        numb_lwp_inc, numb_iwp_inc, $
                        cph_tmp, ctt_tmp, cth_tmp, ctp_tmp, $
                        lwp_tmp, iwp_tmp, cfc_tmp, $
                        ctp_hist, numb, numb_tmp, $
                        ctp_limits_final2d, dim_ctp, $
                        numb_lwp, numb_iwp, numb_lwp_bin, numb_iwp_bin, $
                        lwp_tmp_bin, lwp_mean_bin, $
                        lwp_mean_inc_bin, numb_lwp_inc_bin, $
                        iwp_tmp_bin, iwp_mean_bin, $
                        iwp_mean_inc_bin, numb_iwp_inc_bin, $
                        cfc_tmp_bin, cfc_mean_bin, $
                        cph_tmp_bin, cph_mean_bin

    ; no condition for cloud fraction [0;1]: clear or cloudy
    cfc_mean = cfc_mean + cfc_tmp
    cfc_mean_bin = cfc_mean_bin + cfc_tmp_bin

    ; cth and cph limitation added because with cpt_tmp GT 10. alone
    ; negative CTH and CPH pixels do occur
    ; cph: lwp_lay / (lwp_lay + iwp_lay) WHERE lwp_lay is positive
    ;      if cph is fill_value, no cloud due to no LWP/IWP
    wo_ctp = WHERE((ctp_tmp GT 10.) AND (cth_tmp GT 0.) AND (cph_tmp GE 0.), nwo_ctp)
    ctp_mean[wo_ctp] = ctp_mean[wo_ctp] + ctp_tmp[wo_ctp]
    cth_mean[wo_ctp] = cth_mean[wo_ctp] + cth_tmp[wo_ctp]
    ctt_mean[wo_ctp] = ctt_mean[wo_ctp] + ctt_tmp[wo_ctp]
    cph_mean[wo_ctp] = cph_mean[wo_ctp] + cph_tmp[wo_ctp]
    cph_mean_bin[wo_ctp] = cph_mean_bin[wo_ctp] + cph_tmp_bin[wo_ctp]
    numb[wo_ctp] = numb[wo_ctp] + 1l


    ; lwp grid mean
    wo_lwp = WHERE(lwp_tmp GT 0., nwo_lwp)
    lwp_mean[wo_lwp] = lwp_mean[wo_lwp] + lwp_tmp[wo_lwp]
    numb_lwp[wo_lwp] = numb_lwp[wo_lwp] + 1l

    ; iwp grid mean
    wo_iwp = WHERE(iwp_tmp GT 0., nwo_iwp)
    iwp_mean[wo_iwp] = iwp_mean[wo_iwp] + iwp_tmp[wo_iwp]
    numb_iwp[wo_iwp] = numb_iwp[wo_iwp] + 1l


    ; lwp and iwp grid mean based on cph_tmp_bin (binary cph)
    wo_cph_bin_liq = WHERE(cph_tmp_bin EQ 1., nwo_cph_bin_liq)
    lwp_mean_bin[wo_cph_bin_liq] = lwp_mean_bin[wo_cph_bin_liq] + lwp_tmp_bin[wo_cph_bin_liq]
    numb_lwp_bin[wo_cph_bin_liq] = numb_lwp_bin[wo_cph_bin_liq] + 1l

    wo_cph_bin_ice = WHERE(cph_tmp_bin EQ 0., nwo_cph_bin_ice)
    iwp_mean_bin[wo_cph_bin_ice] = iwp_mean_bin[wo_cph_bin_ice] + iwp_tmp_bin[wo_cph_bin_ice]
    numb_iwp_bin[wo_cph_bin_ice] = numb_iwp_bin[wo_cph_bin_ice] + 1l


    ; lwp_mean_incloud
    idx1 = WHERE(cfc_tmp GT 0. AND lwp_tmp GT 0., nidx1)
    IF (nidx1 GT 0) THEN BEGIN
        lwp_mean_inc[idx1] = lwp_mean_inc[idx1] + lwp_tmp[idx1]/cfc_tmp[idx1]
        numb_lwp_inc[idx1] = numb_lwp_inc[idx1] + 1l
    ENDIF

    ; iwp_mean_incloud
    idx2 = WHERE(cfc_tmp GT 0. AND iwp_tmp GT 0., nidx2)
    IF (nidx2 GT 0) THEN BEGIN
        iwp_mean_inc[idx2] = iwp_mean_inc[idx2] + iwp_tmp[idx2]/cfc_tmp[idx2]
        numb_iwp_inc[idx2] = numb_iwp_inc[idx2] + 1l
    ENDIF


    ; lwp_mean_incloud_bin
    idx3 = WHERE(cfc_tmp GT 0. AND lwp_tmp_bin GT 0., nidx3)
    IF (nidx3 GT 0) THEN BEGIN
        lwp_mean_inc_bin[idx3] = lwp_mean_inc_bin[idx3] + lwp_tmp_bin[idx3]/cfc_tmp[idx3]
        numb_lwp_inc_bin[idx3] = numb_lwp_inc_bin[idx3] + 1l
    ENDIF

    ; iwp_mean_incloud_bin
    idx4 = WHERE(cfc_tmp GT 0. AND iwp_tmp_bin GT 0., nidx4)
    IF (nidx4 GT 0) THEN BEGIN
        iwp_mean_inc_bin[idx4] = iwp_mean_inc_bin[idx4] + iwp_tmp_bin[idx4]/cfc_tmp[idx4]
        numb_iwp_inc_bin[idx4] = numb_iwp_inc_bin[idx4] + 1l
    ENDIF


    FOR gu=0,dim_ctp-1 DO BEGIN
      numb_tmp[*,*] = 0
      wohi=where(ctp_tmp GE ctp_limits_final2d[0,gu] AND ctp_tmp LT ctp_limits_final2d[1,gu],nwohi)
      IF(nwohi GT 0) THEN numb_tmp[wohi] = 1
      ctp_hist[*,*,gu]=ctp_hist[*,*,gu] + numb_tmp
    ENDFOR

    numb_tmp[*,*] = 0

END
