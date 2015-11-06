;-------------------------------------------------------------------
;-- read ERA-Interim netCDF file
;-------------------------------------------------------------------
;
; in : ncfile
; out: str
; 
; IDL> help, ncfile
; NCFILE          STRING    = '/path/to/data/200807/ERA_Interim_an_20080701_00+00_plev.nc'
;
; IDL> help, str, /str 
; ** Structure <7525f8>, 10 tags, length=140365888, data length=140365888, refs=1:
;    FILE            STRING    '/path/to/data/200807/ERA_Interim_an_20080701_00+00_plev.nc'
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
;-------------------------------------------------------------------

PRO READ_ERA_NCFILE, ncfile, str

    fileID = NCDF_OPEN(ncfile)

    ; -- pressure level [Pa]
    varID=NCDF_VARID(fileID,'lev')    & NCDF_VARGET,fileID,varID,plevel

    ; -- longitude
    varID=NCDF_VARID(fileID,'lon')    & NCDF_VARGET,fileID,varID,lon 
    
    ; -- latitude
    varID=NCDF_VARID(fileID,'lat')    & NCDF_VARGET,fileID,varID,lat
    
    ; -- liquid water content [kg kg**-1] 
    ;    It is typically measured per volume of air (g/m3) or mass of air (g/kg)
    varID=NCDF_VARID(fileID,'var246') & NCDF_VARGET,fileID,varID,lwc
    
    ; -- ice water content [kg kg**-1]
    ;    It is typically measured per volume of air (g/m3) or mass of air (g/kg)
    varID=NCDF_VARID(fileID,'var247') & NCDF_VARGET,fileID,varID,iwc
    
    ; -- cloud cover
    varID=NCDF_VARID(fileID,'var248') & NCDF_VARGET,fileID,varID,cc
    
    ; -- geopotential height [m2/s2]
    varID=NCDF_VARID(fileID,'var129') & NCDF_VARGET,fileID,varID,geop
    
    ; -- temperature [K]
    varID=NCDF_VARID(fileID,'var130') & NCDF_VARGET,fileID,varID,temp
    
    NCDF_CLOSE,(fileID)
    
    ; -- pressure increment between 2 layer in the atmosphere
    diff_pressure = plevel[1:N_ELEMENTS(plevel)-1] - $
                    plevel[0:N_ELEMENTS(plevel)-2]


    ; -- check for negative values in: cc, lwc, iwc
    lwc_idx = WHERE(lwc LT 0., nlwc) 
    IF (nlwc GT 0) THEN lwc[lwc_idx] = 0.

    iwc_idx = WHERE(iwc LT 0., niwc)
    IF (niwc GT 0) THEN iwc[iwc_idx] = 0.

    cc_idx = WHERE(cc LT 0., ncc)
    IF (ncc GT 0) THEN cc[cc_idx] = 0.


    ; -- era interim structure
    str={era_input, $
         file:ncfile, plevel:plevel, dpres:diff_pressure, $
         lon:lon, lat:lat, lwc:lwc, iwc:iwc, cc:cc, $
         geop:geop, temp:temp}

END
