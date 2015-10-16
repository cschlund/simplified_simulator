
;-------------------------------------------------------------------
;-- from bottom-up find liquid and ice COT from lwc & iwc
;-------------------------------------------------------------------
;
; in : lwc, iwc, pres_diff, xdim, ydim, zdim
;
; out: lcot_lay, icot_lay, lwp_lay, iwp_lay
;
;       lwc ... liquid water content at each pressure level (zdim)
;       iwc ... ice water content at each pressure level (zdim)
; pres_diff ... pressure increment between 2 layers in the atmospher
;   lwp_lay ... liquid water path per layer
;   iwp_lay  ... ice water path per layer
;  lcot_lay ... liquid cloud optical thickness per layer
;  icot_lay ... ice cloud optical thickness per layer
;
;-------------------------------------------------------------------

PRO CWP_COT_PER_LAYER, lwc, iwc, pres_diff, xdim, ydim, zdim, $
                       lcot_lay, icot_lay, lwp_lay, iwp_lay

    lwp_lay  = FLTARR(xdim,ydim,zdim-1)
    iwp_lay  = FLTARR(xdim,ydim,zdim-1)
    lcot_lay = FLTARR(xdim,ydim,zdim-1)
    icot_lay = FLTARR(xdim,ydim,zdim-1)

    FOR z=zdim-2,0,-1 DO BEGIN

      ; liquid/ice water content (lwc/iwc) between two pressure levels,
      ; i.e., LWC of the layer between the levels (middle)
      lwc_lay=lwc[*,*,z]*0.5 + lwc[*,*,z+1]*0.5
      iwc_lay=iwc[*,*,z]*0.5 + iwc[*,*,z+1]*0.5


      ; http://en.wikipedia.org/wiki/Liquid_water_path#cite_note-2
      lwp_lay[*,*,z]=lwc_lay*pres_diff[z]/9.81
      iwp_lay[*,*,z]=iwc_lay*pres_diff[z]/9.81


      ; cloud water path calculation using the method of Han et al. (1994)
      ; CWP = (4 * COT * R_eff * rho) / (3 * Q_ext)
      ; COT = (3 * CWP * Q_ext) / (4 * R_eff * rho)

      ; CC4CL parameter settings
      rho_water  = 1. * 1000.       ;kg/m3 density for water
      rho_ice    = 0.9167 * 1000.   ;kg/m3 density for ice
      reff_water = 12.*1.0E-6       ;12 microns a priori in CC4CL
      reff_ice   = 30.*1.0E-6       ;30 microns a priori in CC4CL
      qext_water = 2.               ;extinction coefficient for water
      qext_ice   = 2.1              ;extinction coefficient for ice

      ; LWP
      lcot_lay[*,*,z] = (3. * lwp_lay[*,*,z] * qext_water) / (4. * reff_water * rho_water)

      ; IWP
      icot_lay[*,*,z] = (3. * iwp_lay[*,*,z] * qext_ice) / (4. * reff_ice * rho_ice)

    ENDFOR

END
