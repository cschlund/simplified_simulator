
;-------------------------------------------------------------------
;--  era_simulator: initialize grid and temporary arrays
;-------------------------------------------------------------------
;
; in : var, lon, lat
;
; out: longrd, latgrd, xdim, ydim, zdim
;
;-------------------------------------------------------------------

PRO INIT_ERA_GRID, varin, lonin, latin, $
                   longrd, latgrd, xdim, ydim, zdim, ver

    ; set x,y,z dimensions using liquid water content variable
    xdim = N_ELEMENTS(varin[*,0,0])
    ydim = N_ELEMENTS(varin[0,*,0])
    zdim = N_ELEMENTS(varin[0,0,*])
    
    ; define longitude & latitude arrays ;[cols, rows]
    longrd=FLTARR(xdim,ydim)
    latgrd=FLTARR(xdim,ydim)
    
    ; create lat/lon grid arrays using lon & lat from ncfile
    FOR loi=0,xdim-1 DO longrd[loi,*]=lonin[loi]-180.
    FOR lai=0,ydim-1 DO latgrd[*,lai]=latin[lai]

    IF KEYWORD_SET(ver) THEN BEGIN
        PRINT, ' *** MINMAX of longitude & latitude'
        PRINT, minmax(longrd), minmax(latgrd)
    ENDIF

END
