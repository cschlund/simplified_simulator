
;---------------------------------------------------------------
; incloud_calc: lwc and iwc weighting by means of cc at plevels
;
; in : lwc, iwc, cc, xdim, ydim, zdim
;
; out: lwc_inc, iwc_inc
;
; lwc ... liquid water content
; iwc ... ice water content
;  cc ... cloud cover
; xdim .. x-dimension (longitude)
; ydim .. y-dimension (latitude)
; zdim .. z-dimension (pressure levels)
;
; lwc_inc ... incloud liquid water content
; iwc_inc ... incloud ice water content
;
;---------------------------------------------------------------

PRO INCLOUD_CALC, lwc, iwc, cc, xdim, ydim, zdim, $
                  lwc_inc, iwc_inc

    lwc_inc = FLTARR(xdim,ydim,zdim) & lwc_inc[*,*,*] = 0.
    iwc_inc = FLTARR(xdim,ydim,zdim) & iwc_inc[*,*,*] = 0.
    lwc_inc_tmp = FLTARR(xdim,ydim)  & lwc_inc_tmp[*,*] = 0.
    iwc_inc_tmp = FLTARR(xdim,ydim)  & iwc_inc_tmp[*,*] = 0.

    FOR z=zdim-1,0,-1 DO BEGIN
    
      zidx_l = WHERE(cc[*,*,z] GT 0. AND lwc[*,*,z] GT 0.,num_zidx_l)
      zidx_i = WHERE(cc[*,*,z] GT 0. AND iwc[*,*,z] GT 0.,num_zidx_i)

      IF(num_zidx_l GT 0 OR num_zidx_i GT 0) THEN BEGIN
        lwc_2dtmp = REFORM(lwc[*,*,z])
        iwc_2dtmp = REFORM(iwc[*,*,z])
        cfc_2dtmp = REFORM(cc[*,*,z])
      ENDIF

      IF(num_zidx_l GT 0) THEN BEGIN
        lwc_inc_tmp[zidx_l] = lwc_2dtmp[zidx_l] / cfc_2dtmp[zidx_l]
        lwc_inc[*,*,z] = lwc_inc_tmp[*,*]
        lwc_inc_tmp[*,*] = 0.
      ENDIF

      IF(num_zidx_i GT 0) THEN BEGIN
        iwc_inc_tmp[zidx_i] = iwc_2dtmp[zidx_i] / cfc_2dtmp[zidx_i]
        iwc_inc[*,*,z] = iwc_inc_tmp[*,*]
        iwc_inc_tmp[*,*] = 0.
      ENDIF

    ENDFOR

END
