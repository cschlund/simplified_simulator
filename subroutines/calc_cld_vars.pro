;------------------------------------------------------------------------------
;-- from bottom-up compute CWP, COT and CER for each atm. layer
;   i.e. between 2 pressure levels
;------------------------------------------------------------------------------
;
; ====== INPUT ======
;
; LWC ... liquid water content at each pressure level (grd.zdim)
; LWC  FLOAT     = Array[720, 361, 27]
;
; IWC ... ice water content at each pressure level (grd.zdim)
; IWC  FLOAT     = Array[720, 361, 27]
;
; INPUT ... original ERA-Interim reanalysis data from file
; ** Structure ERA_INPUT, 10 tags, length=140365888, data length=140365888:
;    FILE     STRING '/path/to/ERA_Interim_an_20080701_00+00_plev.nc'
;    PLEVEL   DOUBLE    Array[27]
;    DPRES    DOUBLE    Array[26]
;    LON      DOUBLE    Array[720]
;    LAT      DOUBLE    Array[361]
;    LWC      FLOAT     Array[720, 361, 27]
;    IWC      FLOAT     Array[720, 361, 27]
;    CC       FLOAT     Array[720, 361, 27]
;    GEOP     FLOAT     Array[720, 361, 27]
;    TEMP     FLOAT     Array[720, 361, 27]
; 
; GRID ... ERA-I grid
; ** Structure <752c68>, 5 tags, length=2079368, data length=2079366, refs=1:
;    LON2D           FLOAT     Array[720, 361]
;    LAT2D           FLOAT     Array[720, 361]
;    XDIM            INT            720
;    YDIM            INT            361
;    ZDIM            INT             27
;
; LSM ... land/sea mask based on ERA-Interim SST: water=0, land=1
; LSM  INT  = Array[720, 361]
;
; REFF ... cloudcci a priori eff. radii
; ** Structure EFFECTIVE_RADII_MICRONS, 2 tags, length=8, data length=8:
; WATER           FLOAT           12.0000
; ICE             FLOAT           30.0000
;
;
; ====== OUTPUT ======
;
; IDL> help, cwp_lay
; ** Structure CLOUD_WATER_PATH, 2 tags, length=54063360, data length=54063360:
;    LWP             FLOAT     Array[720, 361, 26]
;    IWP             FLOAT     Array[720, 361, 26]
;
; IDL> help, cot_lay
; ** Structure CLOUD_OPTICAL_DEPTH, 2 tags, length=54063360, data length=54063360:
;    LIQ             FLOAT     Array[720, 361, 26]
;    ICE             FLOAT     Array[720, 361, 26]
;
; IDL> help, cer_lay
; ** Structure CLOUD_EFFECTIVE_RADIUS, 2 tags, length=54063360, data length=54063360:
;    LIQ             FLOAT     Array[720, 361, 26]
;    ICE             FLOAT     Array[720, 361, 26]
; 
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
FUNCTION GET_DENSITY_OF_AIR, air_temp, air_pres
;------------------------------------------------------------------------------
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


;------------------------------------------------------------------------------
FUNCTION GET_LREFF, air_temperature, liquid_water_content, $
                    air_pressure, lsmask, grid, VERBOSE=ver
;------------------------------------------------------------------------------

    line = STRARR(60)
    line[*] = "-"
    fmt = '(A25, " : ", 2E12.4)'
    fmt2 = '(A25, " : ", 2F12.4)'

    ; convert lwc [kg/kg] -> [kg/m3] -> [g/m3]
    RHO_AIR = GET_DENSITY_OF_AIR(air_temperature, air_pressure)
    lwc_gm3 = liquid_water_content * RHO_AIR * 1000.
    ZLWC = lwc_gm3 ;[g/m3]
    is = WHERE(ZLWC GT 0., nis, COMPLEMENT=lwc0, NCOMPLEMENT=nlwc0)

    IF KEYWORD_SET(ver) THEN BEGIN 
        PRINT, STRJOIN(line)
        PRINT, FORMAT='(1X,A35)', "get WATER DROPLET effective radius"
        PRINT, STRJOIN(line)
        PRINT, FORMAT=fmt2, "RHO_AIR [kg/m3]", minmax(RHO_AIR)
        PRINT, FORMAT=fmt, "ZLWC [kg/kg]", minmax(liquid_water_content)
        PRINT, FORMAT=fmt, "ZLWC [g/m3]", minmax(ZLWC)
    ENDIF

    ; The liquid water effective radius in ERA-Interim follows 
    ; Martin et al. (1994) and is defined
    ; ZRADLP = effective radius (microns)
    ZRADLP = FLTARR(grid.xdim, grid.ydim) & ZRADLP[*,*] = 1.

    IF (nis GT 0) THEN BEGIN

        ; ZNTOT = cloud droplet number concentration 
        ; dependent on wind speed in ERAI parametrization
        ; fixed values used here
        ZNTOT = FLTARR(grid.xdim, grid.ydim) & ZNTOT[*,*] = 0.
        ZNTOT[WHERE(lsmask EQ 0)] = 100. ; ocean
        ZNTOT[WHERE(lsmask EQ 1)] = 300. ; land

        ZD = FLTARR(grid.xdim, grid.ydim) & ZD[*,*] = 0.
        ZD[WHERE(lsmask EQ 0)] = 0.33 ; ocean
        ZD[WHERE(lsmask EQ 1)] = 0.43 ; land
        
        ZNUM  = 3.0 * ZLWC * ( 1.0 + 3.0 * ZD * ZD )^2
        ZDEN  = 4.0 * !PI * ZNTOT * ( 1.0 + ZD * ZD )^3
        ZTEMP = 1.0 / ZDEN
        
        ; Check on reasonable number for exponent
        yes = WHERE( (ZNUM * ZTEMP) > 1.E-12, nyes, $
                      COMPLEMENT=no, NCOMPLEMENT=nno)

        IF (nno GT 0) THEN ZRADLP[no[is]] = 4.0

        IF (nyes GT 0) THEN BEGIN 
            ZRADLP[yes[is]] = 100. * EXP ( 0.333 * $
                              ALOG( ZNUM[yes[is]] * ZTEMP[yes[is]] ) )

            IF KEYWORD_SET(ver) THEN PRINT, FORMAT=fmt2, $
                "ZRADLP (unlimited) [um]", minmax(ZRADLP[is])

            ZRADLP[yes[is]] = (4.0 > ZRADLP[yes[is]] < 16.)

        ENDIF

    ENDIF

    IF KEYWORD_SET(ver) THEN $
        PRINT, FORMAT=fmt2, "ZRADLP (LIMITED) [um]", minmax(ZRADLP[is])

    RETURN, ZRADLP
END


;------------------------------------------------------------------------------
FUNCTION GET_IREFF, air_temperature, ice_water_content, $
                    air_pressure, VERBOSE=ver
;------------------------------------------------------------------------------

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

    IF KEYWORD_SET(ver) THEN BEGIN 
        line = STRARR(60)
        line[*] = "-"
        fmt = '(A25, " : ", 2E12.4)'
        fmt2 = '(A25, " : ", 2F12.4)'
        PRINT, STRJOIN(line)
        PRINT, FORMAT='(1X,A35)', "get ICE CRYSTAL effective radius"
        PRINT, STRJOIN(line)
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

;------------------------------------------------------------------------------
PRO CALC_CLD_VARS, LWC=lwc, IWC=iwc, INPUT=inp, $
                   GRID=grd, LSM=lsm, REFF=reff, $
                   FIXED_REFFS=const_reff, VERBOSE=ver, $
                   CWP=cwp_lay, COT=cot_lay, CER=cer_lay
;------------------------------------------------------------------------------

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
    ; cloud water droplet and ice crystal effective radii per layer
    lcer_lay  = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)
    icer_lay  = FLTARR(grd.xdim,grd.ydim,grd.zdim-1)

    FOR z=grd.zdim-2,0,-1 DO BEGIN

      ; cloud water content (lwc/iwc) between two pressure levels
      lwc_z = lwc[*,*,z]*0.5 + lwc[*,*,z+1]*0.5
      iwc_z = iwc[*,*,z]*0.5 + iwc[*,*,z+1]*0.5

      temperature = inp.temp[*,*,z]*0.5 + inp.temp[*,*,z+1]*0.5 ;[K]
      pressure = inp.plevel[z]*0.5 + inp.plevel[z+1]*0.5 ;[Pa]

      ; effective radius [microns] -> ref*1.0E-6 [meters]
      liq_ref = GET_LREFF(temperature, lwc_z, pressure, lsm, grd, VER=0)
      ice_ref = GET_IREFF(temperature, iwc_z, pressure, VER=0)

      ; http://en.wikipedia.org/wiki/Liquid_water_path#cite_note-2
      lwp_lay[*,*,z] = lwc_z*inp.dpres[z]/9.81 ;[kg/m2]
      iwp_lay[*,*,z] = iwc_z*inp.dpres[z]/9.81 ;[kg/m2]

      ; COT computation: method of Han et al. (1994)
      ; CWP = (4 * COT * R_eff * rho) / (3 * Q_ext)
      ; COT = (3 * CWP * Q_ext) / (4 * R_eff * rho)

      rho_water  = 1. * 1000.       ;kg/m3 density for water
      rho_ice    = 0.9167 * 1000.   ;kg/m3 density for ice
      qext_water = 2.               ;extinction coefficient for water
      qext_ice   = 2.1              ;extinction coefficient for ice

      ; based on constant reff_water
      lcot_lay[*,*,z] = (3. * lwp_lay[*,*,z] * qext_water) / $
                        (4. * reff.water*1.0E-6 * rho_water)

      icot_lay[*,*,z] = (3. * iwp_lay[*,*,z] * qext_ice) / $
                        (4. * reff.ice*1.0E-6 * rho_ice)

      ; based on ERA-Interim parametrization
      lcot_lay2[*,*,z] = (3. * lwp_lay[*,*,z] * qext_water) / $
                         (4. * liq_ref*1.0E-6 * rho_water)

      icot_lay2[*,*,z] = (3. * iwp_lay[*,*,z] * qext_ice) / $
                         (4. * ice_ref[*,*]*1.0E-6 * rho_ice)


      ; where lwp_lay is ZERO -> set REF=0.
      lwp0 = WHERE( lwp_lay[*,*,z] EQ 0., nlwp0 )
      IF (nlwp0 GT 0) THEN liq_ref[lwp0] = 0.
      lcer_lay[*,*,z] = liq_ref

      ; where iwp_lay is ZERO -> set REF=0.
      iwp0 = WHERE( iwp_lay[*,*,z] EQ 0., niwp0 )
      IF (niwp0 GT 0) THEN ice_ref[iwp0] = 0.
      icer_lay[*,*,z] = ice_ref


      IF KEYWORD_SET(ver) THEN BEGIN 
          line = STRARR(60)
          line[*] = "-"
          PRINT, STRJOIN(line)
          PRINT, FORMAT='(1X,A40,I3)', "MINMAX of CWP, COT & CER at layer=", z
          PRINT, STRJOIN(line)
          PRINT, FORMAT=fmt,  "pressure [Pa]", pressure
          PRINT, FORMAT=fmt2, "temperature [K]", minmax(temperature)
          PRINT, FORMAT=fmt2, "LWP [kg/m2]", minmax(lwp_lay[*,*,z])
          PRINT, FORMAT=fmt2, "IWP [kg/m2]", minmax(iwp_lay[*,*,z])
          PRINT, FORMAT=fmt2, "liq.REF [microns]", minmax(lcer_lay[*,*,z])
          PRINT, FORMAT=fmt2, "ice.REF [microns]", minmax(icer_lay[*,*,z])
          PRINT, FORMAT=fmt2, "liq.COT, ERA param.", minmax(lcot_lay2[*,*,z])
          PRINT, FORMAT=fmt2, "ice.COT, ERA param.", minmax(icot_lay2[*,*,z])
          PRINT, FORMAT=fmt2, "liq.COT, FIXED_reff", minmax(lcot_lay[*,*,z])
          PRINT, FORMAT=fmt2, "ice.COT, FIXED_reff", minmax(icot_lay[*,*,z])
          PRINT, ''
      ENDIF

    ENDFOR

    ; -- output structures
    cwp_lay = {cloud_water_path, lwp:lwp_lay, iwp:iwp_lay}
    cer_lay = {cloud_effective_radius, liq:lcer_lay, ice:icer_lay}

    IF KEYWORD_SET(const_reff) THEN BEGIN 

        IF KEYWORD_SET(ver) THEN BEGIN 
            mess = "** CWP & COT per layer based on FIXED reffs [um]"
            fmt3 = '(A, " ! ", "reff_water =", F5.1, "; reff_ice =", F5.1)'
            PRINT, FORMAT=fmt3, mess, [reff.water, reff.ice]
            PRINT, ''
        ENDIF

        cot_lay = {cloud_optical_depth, liq:lcot_lay, ice:icot_lay}

    ENDIF ELSE BEGIN 

        IF KEYWORD_SET(ver) THEN BEGIN 
            PRINT, "** CWP & COT per layer based on ERA-Interim parameterizations"
            PRINT, ''
        ENDIF

        cot_lay = {cloud_optical_depth, liq:lcot_lay2, ice:icot_lay2}

    ENDELSE

END
