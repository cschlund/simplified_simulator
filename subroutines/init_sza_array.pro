;---------------------------------------------------------------
; init_sza_array: 
;   create 2D array containing the solar zenith angles
;   based on year, month, day, time (UTC), lat, lon
;---------------------------------------------------------------

FUNCTION INIT_SZA_ARRAY, fil, grd, map=map 

    base = FSC_Base_Filename(fil,Directory=dir,Extension=ext)

    splt = STRSPLIT(base, /EXTRACT, '_')
    time = STRSPLIT(splt[4],/EXTRACT,'+')
    hour = FIX(time[0])
    yyyy = FIX(STRMID(splt[3],0,4))
    mm = FIX(STRMID(splt[3],4,2))
    dd = FIX(STRMID(splt[3],6,2))

    day = DOY(yyyy, mm, dd)

    utc2d = FLTARR(grd.xdim,grd.ydim) & utc2d[*,*] = hour
    day2d = FLTARR(grd.xdim,grd.ydim) & day2d[*,*] = day

    ZENSUN, day2d, utc2d, grd.lat2d, grd.lon2d, sza2d

    IF KEYWORD_SET(map)  THEN BEGIN
        tit ='SZA for '+splt[3]+' UTC '+splt[4]
        fil = base+'_sza'
        PLOT_SZA2D, sza2d, grd.lat2d, grd.lon2d, tit, fil
    ENDIF

    RETURN, sza2d

END
