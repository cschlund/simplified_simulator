;---------------------------------------------------------------
; solar_cot_cwp: 
;   CC4CL: COT retrieved from VIS bands, thus
;       LWP and IWP also for dayside only
;       => where(SZA >= 80) = 0.
;   apply to pseudo-satellite arrays: 
;      lwp_bin, iwp_bin, cot_liq_bin, cot_ice_bin
;
;   CC4CL: day      -- sza < 80
;   CC4CL: twilight -- 80 <= sza < 90
;   CC4CL: night    -- sza >= 90
;---------------------------------------------------------------
;
; in : tmp, sza, grd, pwd, fil
; out: tmp
;
; NOTE: grd, pwd and fil required for map_image only
;
; ** Structure TEMP_ARRAYS, 19 tags, length=19753920, data length=19753920:
;    CTP             FLOAT     Array[720, 361]
;    CTH             FLOAT     Array[720, 361]
;    CTT             FLOAT     Array[720, 361]
;    CPH             FLOAT     Array[720, 361]
;    LWP             FLOAT     Array[720, 361]
;    IWP             FLOAT     Array[720, 361]
;    CFC             FLOAT     Array[720, 361]
;    COT             FLOAT     Array[720, 361]
;    CWP             FLOAT     Array[720, 361]
;    CFC_BIN         FLOAT     Array[720, 361]
;    CPH_BIN         FLOAT     Array[720, 361]
;    LWP_BIN         FLOAT     Array[720, 361]
;    IWP_BIN         FLOAT     Array[720, 361]
;    LWP_INC_BIN     FLOAT     Array[720, 361] ; calc. in sumup_vars.pro: lwp_bin/cfc
;    IWP_INC_BIN     FLOAT     Array[720, 361] ; calc. in sumup_vars.pro: iwp_bin/cfc
;    COT_LIQ         FLOAT     Array[720, 361]
;    COT_ICE         FLOAT     Array[720, 361]
;    COT_LIQ_BIN     FLOAT     Array[720, 361]
;    COT_ICE_BIN     FLOAT     Array[720, 361]
;
;    SZA             FLOAT     = Array[720, 361]
;
;** Structure ERA_GRID, 5 tags, length=2079368, data length=2079366:
;   LON2D           FLOAT     Array[720, 361]
;   LAT2D           FLOAT     Array[720, 361]
;   XDIM            INT            720
;   YDIM            INT            361
;   ZDIM            INT             27
;
;   FIL STRING    = '/pathto/200807/ERA_Interim_an_20080701_00+00_plev.nc'
;
;---------------------------------------------------------------

PRO SOLAR_COT_CWP, tmp, sza, grd, pwd, fil


    isday = WHERE( sza LT 80., nisday )
    noday = WHERE( sza GE 80., nnoday )

    IF ( nnoday GT 0 ) THEN BEGIN

        tmp.lwp_bin[noday] = 0.
        tmp.iwp_bin[noday] = 0.
        tmp.cot_liq_bin[noday] = 0.
        tmp.cot_ice_bin[noday] = 0.

    ENDIF

    IF KEYWORD_SET(grd) AND KEYWORD_SET(fil) $
        AND KEYWORD_SET(pwd) THEN BEGIN

        base = FSC_Base_Filename(fil)

        cgLoadCT, 33
        DEVICE, GET_DECOMPOSED=old_decomposed
        DEVICE, DECOMPOSED=0

        theSize = Get_Screen_Size()
        WINDOW, /FREE, XSIZE=theSize[0], YSIZE=theSize[1]
        
        MAP_IMAGE, tmp.lwp_bin, grd.lat2d, grd.lon2d, $
            /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=3., $
            MINI=0., MAXI=1., VOID_INDEX=noday, $
            TITLE='lwp_bin [kg/m^2]'
        filename = pwd+base+'_solar_tmp_lwp_bin.png'
        WRITE_PNG, filename, TVRD(/TRUE)
        PRINT, 'File written to ', filename

        MAP_IMAGE, tmp.iwp_bin, grd.lat2d, grd.lon2d, $
            /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=3., $
            MINI=0., MAXI=1., VOID_INDEX=noday, $
            TITLE='iwp_bin [kg/m^2]'
        filename = pwd+base+'_solar_tmp_iwp_bin.png'
        WRITE_PNG, filename, TVRD(/TRUE)
        PRINT, 'File written to ', filename

        MAP_IMAGE, tmp.cot_liq_bin, grd.lat2d, grd.lon2d, $
            /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=3., $
            MINI=0., MAXI=100., VOID_INDEX=noday, $
            TITLE='cot_liq_bin '
        filename = pwd+base+'_solar_tmp_cot_liq_bin.png'
        WRITE_PNG, filename, TVRD(/TRUE)
        PRINT, 'File written to ', filename

        MAP_IMAGE, tmp.cot_ice_bin, grd.lat2d, grd.lon2d, $
            /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=3., $
            MINI=0., MAXI=100., VOID_INDEX=noday, $
            TITLE='cot_ice_bin'
        filename = pwd+base+'_solar_tmp_cot_ice_bin.png'
        WRITE_PNG, filename, TVRD(/TRUE)
        PRINT, 'File written to ', filename

        DEVICE, DECOMPOSED=old_decomposed
    ENDIF

END
