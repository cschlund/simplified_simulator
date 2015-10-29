;-------------------------------------------------------------------
;-- from bottom-up find liquid and ice COT from lwc & iwc
;-------------------------------------------------------------------
;
; in : lwc, iwc, pres_diff, grd(structure)
; out: cwp_lay, cot_lay
;
; IDL> help, lwc ... liquid water content at each pressure level (grd.zdim)
; LWC             FLOAT     = Array[720, 361, 27]
;
; IDL> help, iwc ... ice water content at each pressure level (grd.zdim)
; IWC             FLOAT     = Array[720, 361, 27]
;
; IDL> help, pres_diff ... pressure increment between 2 layers in the atmosphere
; PRES_DIFF       DOUBLE    = Array[26]
;
; IDL> help, grd
; ** Structure <752c68>, 5 tags, length=2079368, data length=2079366, refs=1:
;    LON2D           FLOAT     Array[720, 361]
;    LAT2D           FLOAT     Array[720, 361]
;    XDIM            INT            720
;    YDIM            INT            361
;    ZDIM            INT             27
;
; IDL> help, cwp_lay ... cloud water path per layer
; ** Structure <756b68>, 2 tags, length=54063360, data length=54063360, refs=1:
;    LWP             FLOAT     Array[720, 361, 26]
;    IWP             FLOAT     Array[720, 361, 26]
; 
; IDL> help, cot_lay ... cloud optical thickness per layer
; ** Structure <756d28>, 2 tags, length=54063360, data length=54063360, refs=1:
;    LIQ             FLOAT     Array[720, 361, 26]
;    ICE             FLOAT     Array[720, 361, 26]
;
;-------------------------------------------------------------------

PRO CWP_COT_LAYERS, lwc, iwc, pres_diff, grd, cwp_lay, cot_lay

    lwp_lay  = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)
    iwp_lay  = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)
    lcot_lay = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)
    icot_lay = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)

    FOR z=grd.zdim-2,0,-1 DO BEGIN

      ; -- liquid/ice water content (lwc/iwc) between two pressure levels,
      ;    i.e., LWC of the layer between the levels (middle)
      lwc_lay=lwc[*,*,z]*0.5 + lwc[*,*,z+1]*0.5
      iwc_lay=iwc[*,*,z]*0.5 + iwc[*,*,z+1]*0.5


      ; -- http://en.wikipedia.org/wiki/Liquid_water_path#cite_note-2
      lwp_lay[*,*,z]=lwc_lay*pres_diff[z]/9.81
      iwp_lay[*,*,z]=iwc_lay*pres_diff[z]/9.81


      ; -- cloud water path calculation using the method of Han et al. (1994)
      ; CWP = (4 * COT * R_eff * rho) / (3 * Q_ext)
      ; COT = (3 * CWP * Q_ext) / (4 * R_eff * rho)

      ; -- CC4CL parameter settings
      rho_water  = 1. * 1000.       ;kg/m3 density for water
      rho_ice    = 0.9167 * 1000.   ;kg/m3 density for ice
      reff_water = 12.*1.0E-6       ;12 microns a priori in CC4CL
      reff_ice   = 30.*1.0E-6       ;30 microns a priori in CC4CL
      qext_water = 2.               ;extinction coefficient for water
      qext_ice   = 2.1              ;extinction coefficient for ice

      ; -- LWP
      lcot_lay[*,*,z] = (3. * lwp_lay[*,*,z] * qext_water) / (4. * reff_water * rho_water)

      ; -- IWP
      icot_lay[*,*,z] = (3. * iwp_lay[*,*,z] * qext_ice) / (4. * reff_ice * rho_ice)

    ENDFOR

    ; -- output structures
    cwp_lay = {cloud_water_path, lwp:lwp_lay, iwp:iwp_lay}
    cot_lay = {cloud_optical_depth, liq:lcot_lay, ice:icot_lay}

END
