;---------------------------------------------------------------
; incloud_calc: lwc and iwc weighting by means of cc at plevels
;               i.e. cloud-cover weighted cloud water content
;---------------------------------------------------------------
;
; in : inp, grd
; out: cwc_inc
;
; IDL> help, inp
; ** Structure <7523d8>, 10 tags, length=140365888, data length=140365888, refs=1:
;    FILE            STRING    '/path/to/data/200807/ERA_Interim_an_20080701_00+00_plev.nc'
;    PLEVEL          DOUBLE    Array[27]
;    DPRES           DOUBLE    Array[26]
;    LON             DOUBLE    Array[720]
;    LAT             DOUBLE    Array[361]
;    LWC             FLOAT     Array[720, 361, 27]
;    IWC             FLOAT     Array[720, 361, 27]
;    CC              FLOAT     Array[720, 361, 27]
;    GEOP            FLOAT     Array[720, 361, 27]
;    TEMP            FLOAT     Array[720, 361, 27]
;
; IDL> help, grd
; ** Structure <752a58>, 5 tags, length=2079368, data length=2079366, refs=1:
;    LON2D           FLOAT     Array[720, 361]
;    LAT2D           FLOAT     Array[720, 361]
;    XDIM            INT            720
;    YDIM            INT            361
;    ZDIM            INT             27
;
; IDL> help, cwc_inc ... incloud cloud water content
; ** Structure <753788>, 2 tags, length=56142720, data length=56142720, refs=1:
;    LWC             FLOAT     Array[720, 361, 27]
;    IWC             FLOAT     Array[720, 361, 27]
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
    cwc_inc = {incloud_cloud_water_path, lwc:lwc_inc, iwc:iwc_inc}

END