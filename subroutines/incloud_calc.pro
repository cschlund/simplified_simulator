
;---------------------------------------------------------------
; incloud_calc: lwc and iwc weighting by means of cc at plevels
;               i.e. cloud-cover weighted cloud water content
;
; in : inp, grd
; out: cwc_inc
;
;---------------------------------------------------------------
;
; inp.lwc ... liquid water content
; inp.iwc ... ice water content
; inp.cc  ... cloud cover
; grd.grd.xdim .. x-dimension (longitude)
; grd.grd.ydim .. y-dimension (latitude)
; grd.grd.zdim .. z-dimension (pressure levels)
;
; cwc_inc.lwc_inc ... incloud liquid water content
; cwc_inc.iwc_inc ... incloud ice water content
;
;---------------------------------------------------------------

PRO INCLOUD_CALC, inp, grd, cwc_inc

    lwc_inc = FLTARR(grd.xdim,grd.ydim,grd.zdim) & lwc_inc[*,*,*] = 0.
    iwc_inc = FLTARR(grd.xdim,grd.ydim,grd.zdim) & iwc_inc[*,*,*] = 0.
    lwc_inc_tmp = FLTARR(grd.xdim,grd.ydim) & lwc_inc_tmp[*,*] = 0.
    iwc_inc_tmp = FLTARR(grd.xdim,grd.ydim) & iwc_inc_tmp[*,*] = 0.

    FOR z=grd.zdim-1,0,-1 DO BEGIN
    
      zidx_l = WHERE(inp.cc[*,*,z] GT 0. AND inp.lwc[*,*,z] GT 0.,num_zidx_l)
      zidx_i = WHERE(inp.cc[*,*,z] GT 0. AND inp.iwc[*,*,z] GT 0.,num_zidx_i)

      IF(num_zidx_l GT 0 OR num_zidx_i GT 0) THEN BEGIN
        lwc_2dtmp = REFORM(inp.lwc[*,*,z])
        iwc_2dtmp = REFORM(inp.iwc[*,*,z])
        cfc_2dtmp = REFORM(inp.cc[*,*,z])
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

    ; output structure
    cwc_inc = {lwc:lwc_inc, iwc:iwc_inc}

END
