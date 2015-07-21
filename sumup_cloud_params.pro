
;-------------------------------------------------------------------
;-- sum up cloud parameters from current file processed
;-------------------------------------------------------------------
;
; in : cph_mean, ctt_mean, cth_mean, ctp_mean, 
;      lwp_mean, iwp_mean, cfc_mean, 
;      cph_tmp, ctt_tmp, cth_tmp, ctp_tmp, 
;      lwp_tmp, iwp_tmp, cfc_tmp, 
;      ctp_hist, numb, numb_tmp, ctp_limits_final2d, dim_ctp
;
; out: cph_mean, ctt_mean, cth_mean, ctp_mean, 
;      lwp_mean, iwp_mean, cfc_mean, ctp_hist,
;      numb
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

PRO SUMUP_CLOUD_PARAMS, cph_mean, ctt_mean, cth_mean, ctp_mean, $
                        lwp_mean, iwp_mean, cfc_mean, $
                        cph_tmp, ctt_tmp, cth_tmp, ctp_tmp, $
                        lwp_tmp, iwp_tmp, cfc_tmp, $
                        ctp_hist, numb, numb_tmp, $
                        ctp_limits_final2d, dim_ctp


    wo_ctp = WHERE(ctp_tmp GT 10., nwo_ctp)

    ctp_mean[wo_ctp] = ctp_mean[wo_ctp] + ctp_tmp[wo_ctp]
    cth_mean[wo_ctp] = cth_mean[wo_ctp] + cth_tmp[wo_ctp]
    ctt_mean[wo_ctp] = ctt_mean[wo_ctp] + ctt_tmp[wo_ctp]

    lwp_mean = lwp_mean + lwp_tmp
    iwp_mean = iwp_mean + iwp_tmp
    cfc_mean = cfc_mean + cfc_tmp

    cph_mean[wo_ctp] = cph_mean[wo_ctp]+cph_tmp[wo_ctp]

    numb[wo_ctp] = numb[wo_ctp]+1l
    
    FOR gu=0,dim_ctp-1 DO BEGIN
      numb_tmp[*,*] = 0
      wohi=where(ctp_tmp GE ctp_limits_final2d[0,gu] AND ctp_tmp LT ctp_limits_final2d[1,gu],nwohi)
      IF(nwohi GT 0) THEN numb_tmp[wohi] = 1
      ctp_hist[*,*,gu]=ctp_hist[*,*,gu] + numb_tmp
    ENDFOR

    ;PRINT, ' *** SUMUP_CLOUD_PARAMS'
    ;PRINT, '     MINMAX(ctt_tmp):       ', minmax(ctt_tmp)
    ;PRINT, '     MINMAX(ctt_mean/numb): ', minmax(ctt_mean/numb)
    ;PRINT, '     MINMAX(numb):          ', minmax(numb)

END
