;-------------------------------------------------------------------
;-- from bottom-up find liquid and ice COT from lwc & iwc
;-------------------------------------------------------------------
;
; in : lwc, iwc, pres_diff, temp, grd(structure)
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
; IDL> help, temp ... temperature per pressure level [K]
; TEMP            FLOAT     = Array[720, 361, 27]
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

FUNCTION GET_IREFF, temperature

    ZT = temperature
    replicate_inplace, ZT, 0.
    RTICE = 250.
    RTT = 273.15
    ZRefDe = 0.64952

    yep = WHERE(temperature LT RTICE, nyep)
    nop = WHERE(temperature GE RTICE, nnop)

    IF (nyep GT 0) THEN ZT[yep] = temperature[yep] - RTT
    IF (nnop GT 0) THEN ZT[nop] = RTICE - RTT

    ireff = 326.3 + ZT*( 12.42 + ZT*(0.197 + ZT*0.0012) )
    ; unlimited
    ;ireff = ireff * ZRefDe
    ; limited
    ireff = (30. > (ireff * ZRefDe) < 60.)

    RETURN, ireff*1.0E-6

END


PRO CWP_COT_LAYERS, lwc, iwc, pres_diff, temp, grd, cwp_lay, cot_lay

    lwp_lay   = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)
    iwp_lay   = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)
    ; using constant reff
    lcot_lay  = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)
    icot_lay  = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)
    ; using reff(Temperature)
    lcot_lay2 = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)
    icot_lay2 = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)

    FOR z=grd.zdim-2,0,-1 DO BEGIN

      ; -- liquid/ice water content (lwc/iwc) between two pressure levels,
      ;    i.e., LWC of the layer between the levels (middle)
      lwc_lay=lwc[*,*,z]*0.5 + lwc[*,*,z+1]*0.5
      iwc_lay=iwc[*,*,z]*0.5 + iwc[*,*,z+1]*0.5


      ; -- temperature per layer
      temp_lay  = temp[*,*,z]*0.5 + temp[*,*,z+1]*0.5
      ireff_lay = GET_IREFF(temp_lay)


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
      lcot_lay[*,*,z] = (3. * lwp_lay[*,*,z] * qext_water) / $
                        (4. * reff_water * rho_water)
      ; -- IWP
      icot_lay[*,*,z] = (3. * iwp_lay[*,*,z] * qext_ice) / $
                        (4. * reff_ice * rho_ice)
      icot_lay2[*,*,z] = (3. * iwp_lay[*,*,z] * qext_ice) / $
                         (4. * ireff_lay[*,*] * rho_ice)

      ;print, '** MINMAX of z:',strtrim(string(z),2)
      ;print, '   temp      :', minmax(temp[*,*,z])
      ;print, '   temp_lay  :', minmax(temp_lay)
      ;print, '   ireff_lay :', minmax(ireff_lay)/1E-6
      ;print, '   lwp_lay   :', minmax(lwp_lay[*,*,z])
      ;print, '   iwp_lay   :', minmax(iwp_lay[*,*,z])
      ;print, '   lcot_lay  :', minmax(lcot_lay[*,*,z])
      ;print, '   icot_lay  :', minmax(icot_lay[*,*,z])
      ;print, '   icot_lay2 :', minmax(icot_lay2[*,*,z])

    ENDFOR

    ; -- output structures
    cwp_lay = {cloud_water_path, lwp:lwp_lay, iwp:iwp_lay}
    ;cot_lay = {cloud_optical_depth, liq:lcot_lay, ice:icot_lay}
    cot_lay = {cloud_optical_depth, liq:lcot_lay, ice:icot_lay2}

END
