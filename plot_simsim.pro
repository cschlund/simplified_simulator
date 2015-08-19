;+
; NAME:
;   PLOT_SIMSIM
;
; PURPOSE:
;   Plotting the results of ERA_SIMULATOR.pro,
;   simplified cloud simulator
;
; AUTHOR:
;   Dr. Cornelia Schlundt
;   Deutscher Wetterdienst (DWD)
;   KU22, Climate-based satellite monitoring
;   cornelia.schlundt@dwd.de
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;   plot_simsim
;
; MODIFICATION HISTORY:
;   Written by Dr. Cornelia Schlundt; 
;------------------------------------------------------------------------------
FUNCTION GET_VAR_UNIT, varname

	IF STREGEX(varname, '^cc', /FOLD_CASE) EQ 0 THEN RETURN, ' []'
	IF STREGEX(varname, '^cph', /FOLD_CASE) EQ 0 THEN RETURN, ' []'
	IF STREGEX(varname, '^nobs', /FOLD_CASE) EQ 0 THEN RETURN, ' '
	IF STREGEX(varname, '^ctp', /FOLD_CASE) EQ 0 THEN RETURN, ' [hPa]'
	IF STREGEX(varname, '^cth', /FOLD_CASE) EQ 0 THEN RETURN, ' [km]'
	IF STREGEX(varname, '^ctt', /FOLD_CASE) EQ 0 THEN RETURN, ' [K]'
	IF STREGEX(varname, '^lwp', /FOLD_CASE) EQ 0 THEN RETURN, ' [kg/m^2]'
	IF STREGEX(varname, '^iwp', /FOLD_CASE) EQ 0 THEN RETURN, ' [kg/m^2]'

END

FUNCTION GET_NCDF_VARLIST, fil

    ignoreList = LIST('lon', 'lat', 'time', 'longitude', 'latitude')
    varList = LIST()
    ncid = NCDF_OPEN( fil )
    result = NCDF_INQUIRE( ncid )
    num_vars = result.NVARS

    FOR i = 0, num_vars-1 DO BEGIN
	res = ncdf_varinq(ncid,i)
	varList.ADD, res.NAME
    ENDFOR

    NCDF_CLOSE,(ncid)

    ; remove elements from varList
    FOR i = 0, N_ELEMENTS(ignoreList)-1 DO BEGIN
	res = varList.Where(ignoreList[i])
	IF(ISA(res)) THEN varList.Remove, res
    ENDFOR

    RETURN, varList
END


; -- main program --

PRO PLOT_SIMSIM, verbose=verbose, dir=dir, test=test, $
		LIMIT=limit, PORTRAIT=portrait, EPS=eps, $
		COMPARE=compare, NITER=niter


	; -- eps plots here
	outdir = '/cmsaf/cmsaf-cld6/cschlund/figs/cci_wp5001/'

	; -- number of parameters to be plotted
	IF ~KEYWORD_SET(niter) THEN niter = 1

	; -- if no limit keyword is set
	IF ~KEYWORD_SET(limit) THEN limit=[-90.,-180.,90.,180.]

    ; -- define path to search for files
    IF ~KEYWORD_SET(dir) THEN dir='/cmsaf/cmsaf-cld6/cschlund/cci_wp5001/ERA_simulator'


    ; -- Select file
    IF KEYWORD_SET(test) THEN BEGIN
		ncfile = '/cmsaf/cmsaf-cld6/cschlund/cci_wp5001/ERA_simulator/' + $
			'v3-1_MM_erainterim_output_incloud_bugfix/' + $
			'ERA_Interim_MM200801_cot_thv_0.300000_CTP.nc'
    ENDIF ELSE BEGIN
		ncfile = DIALOG_PICKFILE(/READ, PATH=dir, FILTER='*.nc', $
					TITLE='Select ERA-Interim reanalysis file!')
		result = FILE_TEST(ncfile)
		PRINT, ' *** File Selection: ', result ? 'successful' : 'failed'
    ENDELSE


	; -- loop over the number of parameters from the same ncfile
	FOR i=0, niter-1 DO BEGIN

		; -- Get list of variables in file
		variableList = GET_NCDF_VARLIST( ncfile )
		dropListValues = variableList.ToArray()
		varname = Choose_Item(dropListValues, CANCEL=cancelled)
		varoutf = '_'+varname
		rainbow=1
		bwr=0

		; -- compare varname with varname2
		IF KEYWORD_SET(compare) THEN BEGIN
			; -- choose second variable
			variableList = GET_NCDF_VARLIST( ncfile )
			dropListValues = variableList.ToArray()
			varname2 = Choose_Item(dropListValues, CANCEL=cancelled)
			varoutf = varoutf+'-minus-'+varname2
			rainbow=0
			bwr=1
		ENDIF

		; -- set_plot option
		IF KEYWORD_SET(EPS) THEN BEGIN

			base = FSC_Base_Filename(ncfile,Directory=dir,Extension=ext)
			outf = outdir+base+varoutf
			col = 0

			IF KEYWORD_SET(portrait) THEN BEGIN
				start_plot, outf, 'eps', eps_size=[20,30]
			ENDIF ELSE BEGIN
				deviceKeyword={	xsize:30., xoff:0.5, $
					ysize:20., yoff:29.5, $
					filename:outf+'.eps', $
					inches:0, color:1, bits_per_pixel:8, $
					encapsulated:1, landscape:1}
				!P.Font=0
				SET_PLOT, 'ps', /copy
				Device, /Helvetica, /ISOLATIN1, $
					_Extra=deviceKeyword, font_size = 8
			ENDELSE

		ENDIF ELSE BEGIN

			SET_PLOT, 'X'
	; 	    !P.BACKGROUND=-1.
			DEVICE, RETAIN=2, DECOMPOSED=1
			device,SET_font='Helvetica Bold',/tt_font
			window,  xsize = 1200, ysize = 1000
			col=255

		ENDELSE


		; -- Read variable from ncfile
		READ_NCDF, img, FILE=ncfile, VAR_NAME = varname, VAR_ATTR = img_att
		READ_NCDF, lon, FILE=ncfile, VAR_NAME = 'lon', GLOB_ATTR = glob_att
		READ_NCDF, lat, FILE=ncfile, VAR_NAME = 'lat'

		;get_grid_res returns 0 ??? and file = ncfile returns -999.000 incl. error message
		;make_geo,lon,lat,file=ncfile,grid=get_grid_res(img)
		make_geo,lon,lat,grid=0.5
		img = congrid(img,(size(lon,/dim))[0],(size(lon,/dim))[1],/interp)

		IF KEYWORD_SET(compare) THEN BEGIN
			READ_NCDF, img2, FILE=ncfile, VAR_NAME = varname2, VAR_ATTR = img_att2
			img2 = congrid(img2,(size(lon,/dim))[0],(size(lon,/dim))[1],/interp)
			img = 100*(img - img2)/img
			mini = -25.
			maxi = 25.
		ENDIF

		PRINT, ' *** MINMAX of '+varname+' :', MINMAX(img)

		unit = GET_VAR_UNIT(varname)

		IF STREGEX(varname, '^cth', /FOLD_CASE) EQ 0 THEN img = img/1000.


		; -- Plot settings
		IF (N_TAGS(glob_att) NE 0) THEN BEGIN
			ptitle = 'Simplified Simulator: ' + glob_att.TIME_COVERAGE_START $
						+ ' - ' + varname + unit + ' Source: '+glob_att.SOURCE

			IF KEYWORD_SET(compare) THEN $
				ptitle = 'Simplified Simulator: ' + glob_att.TIME_COVERAGE_START + ' ' +$
							varname + ' - ' + varname2 + unit + $
							' Source: '+glob_att.SOURCE

		ENDIF ELSE BEGIN
			ptitle = 'Simplified Simulator: ' + varname + unit
		ENDELSE


		position = [0.10, 0.25, 0.90, 0.90]
		xlat=0.05 & ylat=0.53
		xlon=0.46 & ylon=0.17
		xtit=0.11 & ytit=0.95
		chars = 2.2
		barformat = ('(F8.2)')
		void_index = WHERE(img EQ img_att._FILLVALUE)


		; -- map_image
		m = obj_new("map_image", img, lat, lon, rainbow=rainbow, $
			/no_draw, /BOX_AXES, /MAGNIFY, bwr=bwr, $
			/GRID, GLINETHICK=2., MLINETHICK=2., /AUTOSCALE, $
			CHARSIZE=chars, /HORIZON, MINI=mini, MAXI=maxi, $
			POSITION=position, /CONTINENTS, LIMIT=limit, $
			FORMAT=barformat, VOID_INDEX=void_index)
		m -> project, image=img, lon=lon, lat=lat, $
			/no_erase, /no_draw 
		m -> display
		obj_destroy, m


		; -- annotations
		XYOUTS, xlat, ylat, 'Latitude', $
			COLOR=col, /norm, CHARSIZE=chars, orientation=90, CHARTHICK=chars
		XYOUTS, xlon, ylon, 'Longitude', $
			COLOR=col, /norm, CHARSIZE=chars, CHARTHICK=chars
		XYOUTS, xtit, ytit, ptitle, $
			/norm, CHARSIZE=chars, CHARTHICK=chars, COLOR=col


		IF KEYWORD_SET(eps) THEN BEGIN
			Device, /Close_file
			!P.MULTI=0
			!P.Font=0
			end_plot
			end_eps
		ENDIF

	ENDFOR

END