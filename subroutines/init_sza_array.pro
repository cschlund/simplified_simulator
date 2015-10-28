;---------------------------------------------------------------
; init_sza_array: 
;   create 2D array containing the solar zenith angles
;   based on year, month, day, time (UTC), lat, lon
;---------------------------------------------------------------

FUNCTION INIT_SZA_ARRAY, fil, grd

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

    ;; Save device settings and tell IDL to use a color table
    ;DEVICE, GET_DECOMPOSED=old_decomposed
    ;DEVICE, DECOMPOSED=0
    ;cgLoadCT, 33, /REVERSE

    ;; Create an image and display it
    ;WINDOW, 0, XSIZE=1200, YSIZE=800, TITLE='SZA2d'
    ;MAP_IMAGE, sza2d, grd.lat2d, grd.lon2d, $
    ;    /BOX_AXES, /MAGNIFY, /GRID, $
    ;    MINI=0., MAXI=180., CHARSIZE=3., $
    ;    TITLE='SZA for '+splt[3]+' UTC '+splt[4]

    ;; Write a PNG file to the temporary directory
    ;; Note the use of the TRUE keyword to TVRD
    ;filename = '/data/cschlund/figs/'+base+'_sza.png'
    ;WRITE_PNG, filename, TVRD(/TRUE)
    ;PRINT, 'File written to ', filename

    ;; Restore device settings.
    ;DEVICE, DECOMPOSED=old_decomposed

    RETURN, sza2d

END
