
;-------------------------------------------------------------------
;--  era_simulator: initialize grid and temporary arrays
;-------------------------------------------------------------------

PRO INIT_ERA_GRID, input, output

    ; set x,y,z dimensions using liquid water content variable
    xdim = FIX(N_ELEMENTS(input.lwc[*,0,0]))
    ydim = FIX(N_ELEMENTS(input.lwc[0,*,0]))
    zdim = FIX(N_ELEMENTS(input.lwc[0,0,*]))
    
    ; define longitude & latitude arrays ;[cols, rows]
    longrd=FLTARR(xdim,ydim)
    latgrd=FLTARR(xdim,ydim)
    
    ; create lat/lon grid arrays using lon & lat from ncfile
    FOR loi=0,xdim-1 DO longrd[loi,*]=input.lon[loi]-180.
    FOR lai=0,ydim-1 DO latgrd[*,lai]=input.lat[lai]

    output = {lon2d:longrd, lat2d:latgrd, $
              xdim:xdim, ydim:ydim, zdim:zdim}

;     HELP, output, /structure

END