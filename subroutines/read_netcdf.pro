;-------------------------------------------------------------------
; IN  : FILE
; OUT : DATA
;-------------------------------------------------------------------
PRO READ_ERA_NCFILE, file, data
;-------------------------------------------------------------------

    fileID = NCDF_OPEN(file)

    ; pressure level [Pa]: 1 Pa = 1 kg m**-1 s**-2
    varID=NCDF_VARID(fileID,'lev')    & NCDF_VARGET,fileID,varID,plevel

    ; longitude
    varID=NCDF_VARID(fileID,'lon')    & NCDF_VARGET,fileID,varID,lon 
    
    ; latitude
    varID=NCDF_VARID(fileID,'lat')    & NCDF_VARGET,fileID,varID,lat
    
    ; liquid water content [kg kg**-1] 
    ; [mass of condensate / mass of moist air]
    varID=NCDF_VARID(fileID,'var246') & NCDF_VARGET,fileID,varID,lwc
    
    ; ice water content [kg kg**-1]
    ; [mass of condensate / mass of moist air]
    varID=NCDF_VARID(fileID,'var247') & NCDF_VARGET,fileID,varID,iwc
    
    ; cloud cover
    varID=NCDF_VARID(fileID,'var248') & NCDF_VARGET,fileID,varID,cc
    
    ; geopotential height [m2/s2]
    varID=NCDF_VARID(fileID,'var129') & NCDF_VARGET,fileID,varID,geop
    ; temperature [K]
    varID=NCDF_VARID(fileID,'var130') & NCDF_VARGET,fileID,varID,temp
    
    NCDF_CLOSE,(fileID)
    
    ; pressure increment between 2 layer in the atmosphere
    diff_pressure = plevel[1:N_ELEMENTS(plevel)-1] - $
                    plevel[0:N_ELEMENTS(plevel)-2]

    ; check for negative values in: cc, lwc, iwc
    lwc_idx = WHERE(lwc LT 0., nlwc) 
    IF (nlwc GT 0) THEN lwc[lwc_idx] = 0.

    iwc_idx = WHERE(iwc LT 0., niwc)
    IF (niwc GT 0) THEN iwc[iwc_idx] = 0.

    cc_idx = WHERE(cc LT 0., ncc)
    IF (ncc GT 0) THEN cc[cc_idx] = 0.


    ; get filename information
    SPLIT_ERA_FILENAME, FILE=file, BASE=basename, DIR=dir, EXT=ext, $
                        YEAR=year, MONTH=month, DAY=day, HOUR=hour, $
                        UTC=utc


    ; era interim structure
    data={era_interim_input, file:file, $
          filename:basename, directory:dir, extension:ext, $
          year:year, month:month, day:day, hour:hour, utc:utc, $
          plevel:plevel, dpres:diff_pressure, $
          lon:lon, lat:lat, $
          lwc:lwc, iwc:iwc, cc:cc, $
          geop:geop, temp:temp}

END


;-------------------------------------------------------------------
; IN : FILE, GRID
; OUT: DATA, VOID, MAP
;-------------------------------------------------------------------
PRO READ_ERA_SSTFILE, file, grd, sst_scaled, void, MAP=map
;-------------------------------------------------------------------

    fileID = NCDF_OPEN(file)

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

        units = ' ['+STRING(sst_att.UNITS)+']'
        title = 'ERA-Interim '+STRING(sst_att.LONG_NAME) + units 

        PLOT_ERA_SST, FILENAME=FSC_Base_Filename(file), $
                      DATA=sst_scaled, LATITUDE=grd.LAT2D, $
                      LONGITUDE=grd.LON2D, VOID=void

    ENDIF

END


;-----------------------------------------------------------------------------
 PRO READ_SIM_NCDF, variable, FILE=file, VAR_NAME = varname, $
                    GLOB_ATTR = globattr, VAR_ATTR = varattr
;-----------------------------------------------------------------------------

	fileID = NCDF_OPEN(file)

	fileinq_struct = NCDF_INQUIRE(fileID)

	IF (fileinq_struct.ngatts GT 0) THEN BEGIN
		FOR i=0, fileinq_struct.ngatts-1 DO BEGIN
			att_name = NCDF_ATTNAME(fileID, /GLOBAL, i) 
			NCDF_ATTGET, fileID, /GLOBAL, att_name, att_value
; 			PRINT, att_name, STRING(att_value)
			IF i EQ 0 THEN globattr = CREATE_STRUCT(att_name,STRING(att_value)) $
			ELSE globattr = CREATE_STRUCT(globattr, att_name,STRING(att_value))
		ENDFOR
	ENDIF

	varID = NCDF_VARID(fileID,varname)

	varinq_struct = NCDF_VARINQ(fileID, varID)
	variable_name = varinq_struct.name
	numatts       = varinq_struct.natts

	NCDF_VARGET,fileID,varID,variable

	IF (numatts GT 0) THEN BEGIN
		FOR i=0, numatts-1 DO BEGIN
			attname = NCDF_ATTNAME(fileID, varID, i) 
			NCDF_ATTGET, fileID, varID, attname, value
	; 		PRINT, attname, value
			IF i EQ 0 THEN varattr = CREATE_STRUCT(attname,value) $
			ELSE varattr = CREATE_STRUCT(varattr,attname,value)
		ENDFOR
	ENDIF

	NCDF_CLOSE, fileID

 END
