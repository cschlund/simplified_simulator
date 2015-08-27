
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
    
      zidx = WHERE(cc[*,*,z] GT 0.,num_zidx)
      
      IF(num_zidx GT 0) THEN BEGIN
      
        lwc_2dtmp = REFORM(lwc[*,*,z])
        iwc_2dtmp = REFORM(iwc[*,*,z])
        cfc_2dtmp = REFORM(cc[*,*,z])

        lwc_inc_tmp[zidx] = lwc_2dtmp[zidx] / cfc_2dtmp[zidx]
        iwc_inc_tmp[zidx] = iwc_2dtmp[zidx] / cfc_2dtmp[zidx]

        lwc_inc[*,*,z] = lwc_inc_tmp[*,*]
        iwc_inc[*,*,z] = iwc_inc_tmp[*,*]

        lwc_inc_tmp[*,*] = 0.
        iwc_inc_tmp[*,*] = 0.
        
      ENDIF
        
    ENDFOR

END
