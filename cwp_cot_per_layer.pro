
;-------------------------------------------------------------------
;-- from top-down find liquid and ice COT from lwc & iwc
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

    iwp_tmp  = FLTARR(xdim,ydim) & iwp_tmp[*,*] = 0.
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
      

      ; density and effective radius for liquid and ice water clouds
      ro_water=1000           ;kg/m3
      ro_ice=930              ;kg/m3
      reff_water=10.*1.0E-6   ;10 microns
      reff_ice=20.*1.0E-6     ;20 microns
                    

      ; LWP = 2./3. * (rho_water * Liquid_COT * reff)
      ; Liquid_COT = 3. * LWP / (2. * rho_water * reff) 
      lcot_lay[*,*,z]=lwp_lay[*,*,z]*3./(2.*reff_water*ro_water)
      
      
      ; Heymsfield "Ice Water Path–Optical Depth Relationships 
      ; for Cirrus and Deep Stratiform Ice Cloud Layers"
      ; IWP = (COT (1/0.84))/0.065
      ; Fig. 7 (a): Observed TAU_vis vs. IWP points, dotted line
      ; composite curve produced by combining the midlatitude + tropcial datasets
      ; cot_ice=0.065*(IWP)^0.84
      
      iwp_tmp=reform(iwp_lay[*,*,z])
    
      icot_tmp=iwp_tmp*0.
      wo_iwp=where(iwp_tmp GT 0.,n_wo_iwp)
      IF(n_wo_iwp GT 0) THEN icot_tmp[wo_iwp]=(iwp_tmp[wo_iwp]*1000*0.065)^(0.84)
      icot_lay[*,*,z]=icot_tmp
      
    ENDFOR

END
