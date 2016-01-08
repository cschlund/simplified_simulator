;-------------------------------------------------------------------
;-- read sea surface temperature from ERA-Interim netCDF file
;
; in : ncfile, grd
; out: sst_scaled, void
; 
;-------------------------------------------------------------------
PRO READ_ERA_SSTFILE, ncfile, grd, sst_scaled, void, map=map

    fileID = NCDF_OPEN(ncfile)

    varID=NCDF_VARID(fileID,'latitude') 
    NCDF_VARGET,fileID,varID,lat

    varID=NCDF_VARID(fileID,'longitude') 
    NCDF_VARGET,fileID,varID,lon
    
    varID=NCDF_VARID(fileID,'sst') 

    varinq_struct = NCDF_VARINQ(fileID, varID)
    variable_name = varinq_struct.name
    numatts       = varinq_struct.natts
    
    NCDF_VARGET, fileID, varID, sst
    
    IF (numatts GT 0) THEN BEGIN 
        FOR i=0, numatts-1 DO BEGIN 
            attname = NCDF_ATTNAME(fileID, varID, i) 
            NCDF_ATTGET, fileID, varID, attname, value
            ;PRINT, attname, value 
            IF i EQ 0 THEN sst_att = CREATE_STRUCT(attname,value) $ 
                ELSE sst_att = CREATE_STRUCT(sst_att,attname,value) 
        ENDFOR
    ENDIF
    
    NCDF_CLOSE,(fileID)

    sst_scaled = sst * sst_att.SCALE_FACTOR + sst_att.ADD_OFFSET

    void = WHERE(sst EQ sst_att._FILLVALUE OR $
                 sst EQ sst_att.MISSING_VALUE, nvoid)

    IF KEYWORD_SET(map) THEN BEGIN
        base = FSC_Base_Filename(ncfile)
        units = ' ['+STRING(sst_att.UNITS)+']'
        title = 'ERA-Interim '+STRING(sst_att.LONG_NAME) + units 
        PLOT_ERA_SST, base, sst_scaled, grd.LAT2D, grd.LON2D, void
    ENDIF

END
