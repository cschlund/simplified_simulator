;-------------------------------------------------------------------
;-- from bottom-up find liquid and ice COT from lwc & iwc
;-------------------------------------------------------------------
;
; in : lwc, iwc, inp, grd(structure)
; out: cwp_lay, cot_lay
;
; IDL> help, lwc ... liquid water content at each pressure level (grd.zdim)
; LWC             FLOAT     = Array[720, 361, 27]
;
; IDL> help, iwc ... ice water content at each pressure level (grd.zdim)
; IWC             FLOAT     = Array[720, 361, 27]
;
; IDL> help, inp.dpres ... pressure increment between 2 layers in the atmosphere
; PRES_DIFF       DOUBLE    = Array[26]
;
; IDL> help, inp.temp ... temperature per pressure level [K]
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
FUNCTION GET_DENSITY_OF_AIR, air_temp, air_pres
    ; --- https://en.wikipedia.org/wiki/Density_of_air
    ; rho = air density (kg/m^3)
    ; p = absolute pressure (Pa)
    ; T = absolute temperature (K)
    ; R_{specific} = specific gas constant for dry air (J/(kg*K))
    ; The specific gas constant for dry air is 287.058 J/(kg·K) in SI units
    ; 1 J = 1 N m = 1 kg m^2 s^-2
    ; 1 Pa = 1 N m^-2 = 1 kg m^-1 s^-2

    R_SPECIFIC = 287.058
    RHO = air_pres / ( R_SPECIFIC * air_temp )
    RETURN, RHO
END


FUNCTION GET_IREFF, air_temperature, ice_water_content, air_pressure, $
                    verbose=verbose

    ; convert iwc [kg/kg] -> [kg/m3] -> [g/m3]
    RHO_AIR = GET_DENSITY_OF_AIR(air_temperature, air_pressure)
    iwc_gm3 = ice_water_content * RHO_AIR * 1000.

    PT = air_temperature ;[K]
    RTT = 273.15 ;[K]
    ZIWC = iwc_gm3 ;[g/m3]
    ZRefDe = 0.64952
    ;ZRADIP = effective size [microns]

    ZTEMPC = PT - 83.15
    ZTCELS = PT - RTT
    ZFSR = 1.2351 + 0.0105 * ZTCELS

    ; Sun, 2001 (corrected from Sun & Rikus, 1999)
    ZAIWC = 45.8966 * ( ZIWC^0.2214 )
    ZBIWC = 0.7957 * ( ZIWC^0.2535 )
    ZDESR = ZFSR * ( ZAIWC + ZBIWC * ZTEMPC )
    ZDESR = (30. > ZDESR < 155.)
    ZRADIP = ZRefDe * ZDESR

    ;flg = WHERE(ice_water_content LE 0.0, cnt)
    ;IF (cnt GT 0) THEN ZRADIP[flg] = 1.

    IF KEYWORD_SET(verbose) THEN BEGIN 
        fmt = '(A25, " : ", 2E12.4)'
        fmt2 = '(A25, " : ", 2F12.4)'
        PRINT, FORMAT=fmt2, "ZTCELS [C]", minmax(ZTCELS)
        PRINT, FORMAT=fmt2, "ZTEMPC [K]", minmax(ZTEMPC)
        PRINT, FORMAT=fmt2, "RHO_AIR [kg/m3]", minmax(RHO_AIR)
        PRINT, FORMAT=fmt, "ZIWC [kg/kg]", minmax(ice_water_content)
        PRINT, FORMAT=fmt, "ZIWC [g/m3]", minmax(ZIWC)
        PRINT, FORMAT=fmt2, "ZRADIP (LIMITED) [um]", minmax(ZRADIP)
        PRINT, FORMAT=fmt2, "ZRADIP (unlimited) [um]", $
            minmax(ZRefDe * (ZFSR * ( ZAIWC + ZBIWC * ZTEMPC )))
    ENDIF

    RETURN, ZRADIP

END


PRO CWP_COT_LAYERS, lwc, iwc, inp, grd, reff, cwp_lay, cot_lay, $
                    fixed_reffs=const_reff, verbose=verbose

    line = STRARR(80)
    line[*] = "="
    lfmt = '(A3, 80(A))'
    fmt  = '(A25, " : ", F12.4)'
    fmt2 = '(A25, " : ", 2F12.4)'

    ; liquid and ice water paths per layer
    lwp_lay   = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)
    iwp_lay   = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)
    ; using constant reff (cloud_cci a priori values)
    lcot_lay  = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)
    icot_lay  = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)
    ; using reff(Temperature,cloud_water_content)
    lcot_lay2 = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)
    icot_lay2 = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)

    FOR z=grd.zdim-2,0,-1 DO BEGIN

      IF KEYWORD_SET(verbose) THEN BEGIN
          PRINT, ''
          PRINT, ' +++ MINMAX at z=',strtrim(string(z),2),' +++'
      ENDIF


      ; -- liquid/ice water content (lwc/iwc) between two pressure levels,
      ;    i.e., LWC of the layer between the levels (middle)
      lwc_lay=lwc[*,*,z]*0.5 + lwc[*,*,z+1]*0.5
      iwc_lay=iwc[*,*,z]*0.5 + iwc[*,*,z+1]*0.5


      ; -- temperature per layer [K]
      temp_lay = inp.temp[*,*,z]*0.5 + inp.temp[*,*,z+1]*0.5


      ; -- pressure per layer [Pa]
      ;    PLEVEL  DOUBLE   Array[27]
      pressure_lay = inp.plevel[z]*0.5 + inp.plevel[z+1]*0.5


      ; -- ice crystal effective radius per layer [meters]
      ireff_lay = GET_IREFF(temp_lay, iwc_lay, pressure_lay,verbose=verbose)


      ; -- http://en.wikipedia.org/wiki/Liquid_water_path#cite_note-2
      ;    pressure [Pa], Earth-surface gravitational acceleration 9.80665 m/s2
      lwp_lay[*,*,z]=lwc_lay*inp.dpres[z]/9.81
      iwp_lay[*,*,z]=iwc_lay*inp.dpres[z]/9.81


      ; -- cloud water path calculation using the method of Han et al. (1994)
      ; CWP = (4 * COT * R_eff * rho) / (3 * Q_ext)
      ; COT = (3 * CWP * Q_ext) / (4 * R_eff * rho)

      ; -- CC4CL parameter settings
      rho_water  = 1. * 1000.       ;kg/m3 density for water
      rho_ice    = 0.9167 * 1000.   ;kg/m3 density for ice
      qext_water = 2.               ;extinction coefficient for water
      qext_ice   = 2.1              ;extinction coefficient for ice
      ; defined in config file in [microns]
      ;reff_water = 12.*1.0E-6       ;12 microns a priori in CC4CL [m]
      ;reff_ice   = 30.*1.0E-6       ;30 microns a priori in CC4CL [m]

      ; -- LWP using constant reff_water
      lcot_lay[*,*,z] = (3. * lwp_lay[*,*,z] * qext_water) / $
                        (4. * reff.water*1.0E-6 * rho_water)

      ; -- IWP using constant reff_ice
      icot_lay[*,*,z] = (3. * iwp_lay[*,*,z] * qext_ice) / $
                        (4. * reff.ice*1.0E-6 * rho_ice)


      ; -- IWP using reff_ice(T,IWC)
      icot_lay2[*,*,z] = (3. * iwp_lay[*,*,z] * qext_ice) / $
                         (4. * ireff_lay[*,*]*1.0E-6 * rho_ice)


      IF KEYWORD_SET(verbose) THEN BEGIN 
          PRINT, FORMAT=fmt, "plevel [Pa]", pressure_lay
          PRINT, FORMAT=fmt2, "inp.temp [K]", minmax(inp.temp[*,*,z])
          PRINT, FORMAT=fmt2, "temp_lay [K]", minmax(temp_lay)
          PRINT, FORMAT=fmt2, "ireff_lay [um]", minmax(ireff_lay)
          PRINT, FORMAT=fmt2, "LWP_lay [kg/m2]", minmax(lwp_lay[*,*,z])
          PRINT, FORMAT=fmt2, "IWP_lay [kg/m2]", minmax(iwp_lay[*,*,z])
          PRINT, FORMAT=fmt2, "lcot_lay (fixed_lreff)", minmax(lcot_lay[*,*,z])
          PRINT, FORMAT=fmt2, "icot_lay (fixed_ireff)", minmax(icot_lay[*,*,z])
          PRINT, FORMAT=fmt2, "icot_lay2 (ireff(T,IWC))", minmax(icot_lay2[*,*,z])
          PRINT, ''
      ENDIF

    ENDFOR

    ; -- output structures
    cwp_lay = {cloud_water_path, lwp:lwp_lay, iwp:iwp_lay}

    IF KEYWORD_SET(const_reff) THEN BEGIN 
        cot_lay = {cloud_optical_depth, liq:lcot_lay, ice:icot_lay}
    ENDIF ELSE BEGIN 
        cot_lay = {cloud_optical_depth, liq:lcot_lay, ice:icot_lay2}
    ENDELSE

END
