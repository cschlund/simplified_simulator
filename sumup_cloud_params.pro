
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
                        ctp_limits_final2d, dim_ctp, $
                        what, inputfile


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


    ; -- check for negative values in variable_tmp arrays
    ft = '(F12.4)'

    ctp_idx = WHERE(ctp_tmp[wo_ctp] LT 0., nctp)
    IF (nctp GT 0) THEN  BEGIN
        PRINT, inputfile
        PRINT, what
        PRINT, '   ctp_tmp[wo_ctp] LT 0: ', STRTRIM(nctp,2), ' occurrences'
        PRINT, '   min/max = ', STRING(MINMAX(ctp_tmp[wo_ctp]), FORMAT=ft)
    ENDIF

    ctt_idx = WHERE(ctt_tmp[wo_ctp] LT 0., nctt)
    IF (nctt GT 0) THEN BEGIN
        PRINT, inputfile
        PRINT, what
        PRINT, '   ctt_tmp[wo_ctp] LT 0: ', STRTRIM(nctt,2), ' occurrences'
        PRINT, '   min/max = ', STRING(MINMAX(ctt_tmp[wo_ctp]), FORMAT=ft)
    ENDIF

    cth_idx = WHERE(cth_tmp[wo_ctp] LT 0., ncth)
    IF (ncth GT 0) THEN BEGIN
        PRINT, inputfile
        PRINT, what
        PRINT, '   cth_tmp[wo_ctp] LT 0: ', STRTRIM(ncth,2), ' occurrences'
        PRINT, '   min/max = ', STRING(MINMAX(cth_tmp[wo_ctp]), FORMAT=ft)
    ENDIF

    cph_idx = WHERE(cph_tmp[wo_ctp] LT 0., ncph)
    IF (ncph GT 0) THEN BEGIN
        PRINT, inputfile
        PRINT, what
        PRINT, '   cph_tmp[wo_ctp] LT 0: ', STRTRIM(ncph,2), ' occurrences'
        PRINT, '   min/max = ', STRING(MINMAX(cph_tmp[wo_ctp]), FORMAT=ft)
    ENDIF

    cfc_idx = WHERE(cfc_tmp[wo_ctp] LT 0., ncfc)
    IF (ncfc GT 0) THEN BEGIN
        PRINT, inputfile
        PRINT, what
        PRINT, '   cfc_tmp[wo_ctp] LT 0: ', STRTRIM(ncfc,2), ' occurrences'
        PRINT, '   min/max = ', STRING(MINMAX(cfc_tmp[wo_ctp]), FORMAT=ft)
    ENDIF

    lwp_idx = WHERE(lwp_tmp[wo_ctp] LT 0., nlwp)
    IF (nlwp GT 0) THEN BEGIN
        PRINT, inputfile
        PRINT, what
        PRINT, '   lwp_tmp[wo_ctp] LT 0: ', STRTRIM(nlwp,2), ' occurrences'
        PRINT, '   min/max = ', STRING(MINMAX(lwp_tmp[wo_ctp]), FORMAT=ft)
    ENDIF

    iwp_idx = WHERE(iwp_tmp[wo_ctp] LT 0., niwp)
    IF (niwp GT 0) THEN BEGIN
        PRINT, inputfile
        PRINT, what
        PRINT, '   iwp_tmp[wo_ctp] LT 0: ', STRTRIM(niwp,2), ' occurrences'
        PRINT, '   min/max = ', STRING(MINMAX(iwp_tmp[wo_ctp]), FORMAT=ft)
    ENDIF

    ;PRINT, ' *** SUMUP_CLOUD_PARAMS'
    ;PRINT, '     MINMAX(ctt_tmp):       ', minmax(ctt_tmp)
    ;PRINT, '     MINMAX(ctt_mean/numb): ', minmax(ctt_mean/numb)
    ;PRINT, '     MINMAX(numb):          ', minmax(numb)

    numb_tmp[*,*] = 0

END
