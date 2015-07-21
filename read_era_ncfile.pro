
;-------------------------------------------------------------------
;-- read ERA-Interim netCDF file
;
; in : ncfile
;
; out: plevel, diff_pressure, lon, lat, lwc, iwc, cc, geop, temp
;
;-------------------------------------------------------------------

PRO READ_ERA_NCFILE, ncfile, plevel, diff_pressure, lon, lat, $
                     lwc, iwc, cc, geop, temp

    fileID = NCDF_OPEN(ncfile)

    ; pressure level [Pa]
    varID=NCDF_VARID(fileID,'lev')    & NCDF_VARGET,fileID,varID,plevel

    ; longitude
    varID=NCDF_VARID(fileID,'lon')    & NCDF_VARGET,fileID,varID,lon 
    
    ; latitude
    varID=NCDF_VARID(fileID,'lat')    & NCDF_VARGET,fileID,varID,lat
    
    ; liquid water content
    varID=NCDF_VARID(fileID,'var246') & NCDF_VARGET,fileID,varID,lwc 
    
    ; ice water content
    varID=NCDF_VARID(fileID,'var247') & NCDF_VARGET,fileID,varID,iwc
    
    ; cloud cover
    varID=NCDF_VARID(fileID,'var248') & NCDF_VARGET,fileID,varID,cc
    
    ; geopotential height
    varID=NCDF_VARID(fileID,'var129') & NCDF_VARGET,fileID,varID,geop
    
    ; temperature
    varID=NCDF_VARID(fileID,'var130') & NCDF_VARGET,fileID,varID,temp
    
    NCDF_CLOSE,(fileID)
    
    ; -- pressure increment between 2 layer in the atmosphere
    diff_pressure = plevel[1:N_ELEMENTS(plevel)-1] - $
                    plevel[0:N_ELEMENTS(plevel)-2]

END
