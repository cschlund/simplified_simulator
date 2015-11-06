;-------------------------------------------------------------------
;--  era_simulator: initialize grid and temporary arrays
;-------------------------------------------------------------------
;
; IDL> help, input
; ** Structure <752358>, 10 tags, length=140365888, data length=140365888, refs=1:
;    FILE            STRING    '/path/to/era-interim/200807/ERA_Interim.nc'
;    PLEVEL          DOUBLE    Array[27]
;    DPRES           DOUBLE    Array[26]
;    LON             DOUBLE    Array[720]
;    LAT             DOUBLE    Array[361]
;    LWC             FLOAT     Array[720, 361, 27]
;    IWC             FLOAT     Array[720, 361, 27]
;    CC              FLOAT     Array[720, 361, 27]
;    GEOP            FLOAT     Array[720, 361, 27]
;    TEMP            FLOAT     Array[720, 361, 27]
;
; IDL> help, output
; ** Structure <752c28>, 5 tags, length=2079368, data length=2079366, refs=1:
;    LON2D           FLOAT     Array[720, 361]
;    LAT2D           FLOAT     Array[720, 361]
;    XDIM            INT            720
;    YDIM            INT            361
;    ZDIM            INT             27
;
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
    FOR loi=0,xdim-1 DO longrd[loi,*]=input.lon[loi]
    FOR lai=0,ydim-1 DO latgrd[*,lai]=input.lat[lai]

    output = {era_grid, lon2d:longrd, lat2d:latgrd, $
              xdim:xdim, ydim:ydim, zdim:zdim}

END
