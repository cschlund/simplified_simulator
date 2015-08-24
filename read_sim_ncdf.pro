;+
; NAME:
;   READ_SIM_NCDF
;
; PURPOSE:
;   reading of NetCDF files
;
; NCDF_OPEN: Open an existing netCDF file.
; NCDF_INQUIRE: Call this function to find the format of the netCDF file.
; NCDF_DIMINQ: Retrieve the names and sizes of dimensions in the file.
; NCDF_VARINQ: Retrieve the names, types, and sizes of variables in the file.
; NCDF_ATTNAME: Optionally, retrieve attribute names.
; NCDF_ATTINQ: Optionally, retrieve the types and lengths of attributes.
; NCDF_ATTGET: Optionally, retrieve the attributes.
; NCDF_VARGET: Read the data from the variables.
; NCDF_CLOSE: Close the file.
;
; AUTHOR:
;   Dr. Cornelia Schlundt
;   University of Bremen, IUP/IEF
;   cornelia@iup.physik.uni-bremen.de
;
; CATEGORY:
;   I/O
;
; CALLING SEQUENCE:
;   READ_SIM_NCDF, variable, FILE=FILE, GLOB_ATTR = globattr, VAR_NAME=varname, VAR_ATTR=varattr
;
;	FILE: give full qualified filename
;	VAR_NAME: give string of variable_name
;	VAR_ATTR: returns a structure containing the attributes
;	GLOB_ATTR: returns a structure containing the global attributes
;
; MODIFICATION HISTORY:
;   Written by C. Schlundt, JUN 2012
;	19 AUG 2015, keyword /GLOB_ATTR added
;
;********************************************************************
 PRO READ_SIM_NCDF, variable, FILE=file, VAR_NAME = varname, $
                GLOB_ATTR = globattr, VAR_ATTR = varattr
;********************************************************************

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