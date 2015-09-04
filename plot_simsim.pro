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
FUNCTION GET_BARFORMAT, varname
	IF STREGEX(varname, '^cc', /FOLD_CASE) EQ 0 THEN RETURN, ('(F8.2)')
	IF STREGEX(varname, '^cph', /FOLD_CASE) EQ 0 THEN RETURN, ('(F8.2)')
	IF STREGEX(varname, '^nobs', /FOLD_CASE) EQ 0 THEN RETURN, ('(I)')
	IF STREGEX(varname, '^ctp', /FOLD_CASE) EQ 0 THEN RETURN, ('(I)')
	IF STREGEX(varname, '^cth', /FOLD_CASE) EQ 0 THEN RETURN, ('(F8.2)')
	IF STREGEX(varname, '^ctt', /FOLD_CASE) EQ 0 THEN RETURN, ('(I)')
	IF STREGEX(varname, '^lwp', /FOLD_CASE) EQ 0 THEN RETURN, ('(F8.2)')
	IF STREGEX(varname, '^iwp', /FOLD_CASE) EQ 0 THEN RETURN, ('(F8.2)')
END

FUNCTION GET_DISCRETE_RANGE, varname
	IF STREGEX(varname, '^cc', /FOLD_CASE) EQ 0 THEN RETURN, FINDGEN(11)/10.
	IF STREGEX(varname, '^cph', /FOLD_CASE) EQ 0 THEN RETURN, FINDGEN(11)/10.
	IF STREGEX(varname, '^nobs', /FOLD_CASE) EQ 0 THEN RETURN, [0, 25, 50, 75, 100, 125]
	IF STREGEX(varname, '^ctp', /FOLD_CASE) EQ 0 THEN RETURN, FINDGEN(11)*100+10.
	IF STREGEX(varname, '^cth', /FOLD_CASE) EQ 0 THEN RETURN, FINDGEN(10)*2
	IF STREGEX(varname, '^ctt', /FOLD_CASE) EQ 0 THEN RETURN, FINDGEN(11)*10+180
	IF STREGEX(varname, '^lwp', /FOLD_CASE) EQ 0 THEN RETURN, FINDGEN(11)/10.;FINDGEN(11)/10.*0.6
	IF STREGEX(varname, '^iwp', /FOLD_CASE) EQ 0 THEN RETURN, FINDGEN(11)/10./10 +0.1;0.05
END

FUNCTION GET_VAR_UNIT, varname
	IF STREGEX(varname, '^cc', /FOLD_CASE) EQ 0 THEN RETURN, ''
	IF STREGEX(varname, '^cph', /FOLD_CASE) EQ 0 THEN RETURN, ''
	IF STREGEX(varname, '^nobs', /FOLD_CASE) EQ 0 THEN RETURN, ''
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


; -- main program -------------------------------------------------------------------------------
; 
; alternative: use ncdf_browser from Stefan
;	which can plot simulator results, except two things (so far):
;		1) compare two variables from one file (diffplot)
;		2) compare one variable with reference data
;
; KEYWORDS
;	verbose:	increase screen output
;	dir:		set input directory, where ncfiles are located
;	limit:		map_image limit
;	normal:		plot one variable onto single page
;	compare:	compare two variables from same file and make difference plot (blue-to-red)
;				compare=2 ... compare a pre-defined set of variables
;	niter:		number of iterations, i.e. how many variables from the ncfile to be plotted
;	plotall:	instead selecting one parameter, all parameters of the file will be plotted
;	mini:		set minrange for /normal
;	maxi:		set maxrange for /normal
;	suboutdir:	set subdirectory, where EPS plots should be saved, e.g. 'sim/run4/'
;
PRO PLOT_SIMSIM, verbose=verbose, dir=dir, $
		LIMIT=limit, PORTRAIT=portrait, EPS=eps, $
		COMPARE=compare, NITER=niter, PLOTALL=plotall, $
		NORMAL=normal, MINI=mini, MAXI=maxi, $
		SUBOUTDIR=suboutdir


	; -- set options for difference plotting
	IF KEYWORD_SET(compare) THEN BEGIN
		IF (compare EQ 1) THEN vlist1 = 1. & vlist2 = 1.
		IF (compare EQ 2) THEN BEGIN

			vlist1 = ['cph','cc_total','lwp','iwp','lwp_inc','iwp_inc']
			vlist2 = ['cph_bin','cc_total_bin','lwp_bin','iwp_bin',$
					'lwp_inc_bin','iwp_inc_bin']

			; attach *_ori variables
			FOR k=0, N_ELEMENTS(vlist1)-1 DO BEGIN
				vlist1 = [[vlist1], vlist1[k]+'_ori']
				vlist2 = [[vlist2], vlist2[k]+'_ori']
			ENDFOR

			; attach (ori MINUS satellite-like) difference options
			vlist1 = [[vlist1],'ctp_ori','ctt_ori','cth_ori','cph_ori',$
						'cc_total_ori']
			vlist2 = [[vlist2],'ctp','ctt','cth','cph','cc_total']

			PRINT, ' * These difference plots will be produced now: '
			FOR k=0, N_ELEMENTS(vlist1)-1 DO BEGIN
				PRINT, '   ', STRTRIM(STRING(k),2),'. ',vlist1[k]+'-'+vlist2[k]
			ENDFOR

		ENDIF
	ENDIF


	; CHARSIZE
	chars = 2.4

	; -- path to reference data
; 	refdata_dir = '/cmsaf/cmsaf-cld6/esa_cci_cloud_data/data'
	refdata_dir = '/cmsaf/cmsaf-cld1/esa_cci_cloud_data/data/temp'

	; -- eps plots here
	outdir = '/cmsaf/cmsaf-cld6/cschlund/figs/cci_wp5001/'
	IF KEYWORD_SET(suboutdir) THEN outdir = outdir + suboutdir

	; -- number of parameters to be plotted
	IF ~KEYWORD_SET(niter) THEN niter = 1

	; -- if no limit keyword is set
	IF ~KEYWORD_SET(limit) THEN limit=[-90.,-180.,90.,180.]

    ; -- define path to search for files
    IF ~KEYWORD_SET(dir) THEN dir='/cmsaf/cmsaf-cld6/cschlund/cci_wp5001/ERA_simulator'


    ; -- Select file
	ncfile = DIALOG_PICKFILE(/READ, PATH=dir, FILTER='*.nc', TITLE='Select File!')
	result = FILE_TEST(ncfile)
	PRINT, ' *** File Selection: ', result ? 'successful' : 'failed'


	; -- Get list of variables in file
	variableList = GET_NCDF_VARLIST( ncfile )
	
	; -- Get cot_thv_sat
	ncbase = FSC_Base_Filename(ncfile,Directory=dir,Extension=ext)
	ncsplit = STRSPLIT(ncbase,'_',/EXTRACT)
	cot_thv_sat = STRMID(ncsplit(N_ELEMENTS(ncsplit)-2),0,3)
	cot_thv_era = '0.01'



	; ---------------------------------------------------------------------------------------
	; -- difference plot onto single page
	IF KEYWORD_SET(compare) THEN BEGIN

		ntimes =  N_ELEMENTS(vlist1)

		; -- loop over the number of parameters from the same ncfile
		FOR i=0, ntimes-1 DO BEGIN

			; -- select blue-white-red color table
			rainbow = 0 & bwr = 1

			; -- choose first variable
			IF (ntimes EQ 1) THEN BEGIN
				variableList = GET_NCDF_VARLIST( ncfile )
				dropListValues = variableList.ToArray()
				varname = Choose_Item(dropListValues, CANCEL=cancelled)
			ENDIF ELSE BEGIN
				varname = vlist1[i]
			ENDELSE
			varoutf = '_DIFF_'+varname

			; -- choose second variable
			IF (ntimes EQ 1) THEN BEGIN
				variableList = GET_NCDF_VARLIST( ncfile )
				dropListValues = variableList.ToArray()
				varname2 = Choose_Item(dropListValues, CANCEL=cancelled)
			ENDIF ELSE BEGIN
				varname2 = vlist2[i]
			ENDELSE
			varoutf = varoutf+'-'+varname2


			PRINT, ' *** Difference plot: ', varoutf


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
					DEVICE, /Helvetica, /ISOLATIN1, $
						_Extra=deviceKeyword, font_size = 8
				ENDELSE

			ENDIF ELSE BEGIN

				SET_PLOT, 'X'
	; 			    !P.BACKGROUND=-1.
				DEVICE, RETAIN=2, DECOMPOSED=1
				DEVICE, SET_FONT='Helvetica Bold',/TT_FONT
				window,  xsize = 1200, ysize = 1000
				col=255

			ENDELSE


			; -- Read variable from ncfile
			READ_SIM_NCDF, img, FILE=ncfile, VAR_NAME = varname, VAR_ATTR = img_att
			READ_SIM_NCDF, img2, FILE=ncfile, VAR_NAME = varname2, VAR_ATTR = img_att2
			READ_SIM_NCDF, lon, FILE=ncfile, VAR_NAME = 'lon', GLOB_ATTR = glob_att
			READ_SIM_NCDF, lat, FILE=ncfile, VAR_NAME = 'lat'
			PRINT, ' *** MINMAX(img) : ', MINMAX(img)
			PRINT, ' *** MINMAX(img2): ', MINMAX(img2)

			make_geo, lon, lat, grid=0.5
			lat = ROTATE(lat,2)
			lon = lon + 180.
			img  = congrid(img,(size(lon,/dim))[0],(size(lon,/dim))[1],/interp)
			img2 = congrid(img2,(size(lon,/dim))[0],(size(lon,/dim))[1],/interp)


			; -- flag negative values with FILLVALUE
			bad = WHERE(img LT 0 OR img2 LT 0, nbad)
			PRINT, ' *** ', STRTRIM(nbad,2), ' bad pixels flagged with FILLVALUE'
			IF (nbad GT 0) THEN BEGIN
				img[bad] = img_att._FILLVALUE
				img2[bad] = img_att._FILLVALUE
			ENDIF

			PRINT, ' *** MINMAX of '+varname+'-'+varname2+' :', MINMAX(img-img2)

			; -- some info written onto plot
			long_name = STRING(img_att.long_name)
			unit  = GET_VAR_UNIT(varname)
			minmax_range = MINMAX(img-img2)
			minstr = STRTRIM(STRING(minmax_range[0], FORMAT='(E10.3)'),2)
			maxstr = STRTRIM(STRING(minmax_range[1], FORMAT='(E10.3)'),2)

			IF (minmax_range[0] EQ 0.) THEN ctable = 62 
			IF (minmax_range[1] EQ 0.) THEN ctable = 1 

			; -- Plot settings
			btitle = varname+'-'+varname2+unit
			ptitle = long_name
			IF (N_TAGS(glob_att) NE 0) THEN BEGIN
				cot_thv_era = STRTRIM(STRING(glob_att.cot_thv_ori, FORMAT='(F5.2)'),2)
				cot_thv_sat = STRTRIM(STRING(glob_att.cot_thv, FORMAT='(F5.2)'),2)
				ptitle = glob_att.SOURCE +': '+ ptitle + ' for ' + glob_att.TIME_COVERAGE_START
			ENDIF


			position = [0.10, 0.25, 0.90, 0.90]
			xlat=0.05 & ylat=0.53
			xlon=0.46 & ylon=0.17
			xtit=0.11 & ytit=0.96

			barformat = ('(F8.2)')
			IF STREGEX(varname, '^lwp', /FOLD_CASE) EQ 0 THEN barformat = ('(E10.3)')
			IF STREGEX(varname, '^iwp', /FOLD_CASE) EQ 0 THEN barformat = ('(E10.3)')

			IF(ISA(img_att) NE 0) THEN void_index = WHERE(img EQ img_att._FILLVALUE)

			; -- map_image (single)
			IF (ISA(ctable) EQ 0) THEN BEGIN
				m = obj_new("map_image", (img-img2), lat, lon, $
					rainbow=rainbow, /no_draw, /BOX_AXES, /MAGNIFY, $
					bwr=bwr, /GRID, GLINETHICK=2., MLINETHICK=2., $
					n_lev=6, TITLE=btitle, $
					MINI=minmax_range[0], MAXI=minmax_range[1], $
					CHARSIZE=chars, /HORIZON, POSITION=position, $
					/CONTINENTS, LIMIT=limit, $
					FORMAT=barformat, VOID_INDEX=void_index)
			ENDIF ELSE BEGIN
				m = obj_new("map_image", (img-img2), lat, lon, $
					/no_draw, /BOX_AXES, /MAGNIFY, $
					/GRID, GLINETHICK=2., MLINETHICK=2., $
					n_lev=6, ctable = ctable, TITLE=btitle, $
					MINI=minmax_range[0], MAXI=minmax_range[1], $
					CHARSIZE=chars, /HORIZON, POSITION=position, $
					/CONTINENTS, LIMIT=limit, $
					FORMAT=barformat, VOID_INDEX=void_index)
			ENDELSE
			m -> project, image=(img-img2), lon=lon, lat=lat, $
				/no_erase, /no_draw
			m -> display
			obj_destroy, m

			MAP_CONTINENTS, /CONTINENTS, /HIRES, COLOR=0, GLINETHICK=2.2
			MAP_GRID, COLOR=0, MLINETHICK=2.2

			; -- annotations
			XYOUTS, xtit, ytit, ptitle, $
				/norm, CHARSIZE=chars, CHARTHICK=chars, COLOR=col


			v1 = STRPOS(varname, 'ori')
			v2 = STRPOS(varname2, 'ori')

			IF (v1 GT 0 AND v2 GT 0) THEN BEGIN
				thv = 0
			ENDIF ELSE IF (v1 LT 0 AND v2 LT 0) THEN BEGIN
				thv = 1
			ENDIF ELSE BEGIN
				thv = 2
			ENDELSE

			IF(thv EQ 0) THEN BEGIN
				XYOUTS, 0.78, 0.155, 'cot_thv_ori='+cot_thv_era, $
				COLOR=col, /norm, CHARSIZE=2., CHARTHICK=chars
			ENDIF
			IF (thv EQ 1) THEN BEGIN
				XYOUTS, 0.78, 0.155, 'cot_thv='+cot_thv_sat, $
				COLOR=col, /norm, CHARSIZE=2., CHARTHICK=chars
			ENDIF
			IF (thv EQ 2) THEN BEGIN
				XYOUTS, 0.78, 0.155, 'cot_thv_ori='+cot_thv_era,$
					COLOR=col, /norm, CHARSIZE=2., CHARTHICK=chars
				XYOUTS, 0.78, 0.185, 'cot_thv='+cot_thv_sat, $
					COLOR=col, /norm, CHARSIZE=2., CHARTHICK=chars
			ENDIF


			IF KEYWORD_SET(eps) THEN BEGIN
				DEVICE, /Close_file
				!P.MULTI = 0
				end_plot
				end_eps
				SPAWN, 'convert '+outf+'.eps '+outf+'.png'
			ENDIF

		ENDFOR

	ENDIF




	; ---------------------------------------------------------------------------------------
	; -- normal plot onto single page

	IF KEYWORD_SET(normal) THEN BEGIN

		; -- determine number of variables to be plotted
		IF KEYWORD_SET(plotall) THEN niter = N_ELEMENTS(variableList.ToArray())

		; -- loop over the number of parameters from the same ncfile
		FOR i=0, niter-1 DO BEGIN

			IF KEYWORD_SET(plotall) THEN varname = variableList[i]

			IF ~KEYWORD_SET(plotall) THEN BEGIN
				; -- Select item from List
				dropListValues = variableList.ToArray()
				varname = Choose_Item(dropListValues, CANCEL=cancelled)
			ENDIF

			varoutf = '_'+varname
			rainbow=1 & bwr=0


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
					DEVICE, /Helvetica, /ISOLATIN1, $
						_Extra=deviceKeyword, font_size = 8
				ENDELSE

			ENDIF ELSE BEGIN

				SET_PLOT, 'X'
; 			    !P.BACKGROUND=-1.
				DEVICE, RETAIN=2, DECOMPOSED=1
				DEVICE, SET_FONT='Helvetica Bold',/TT_FONT
				window,  xsize = 1200, ysize = 1000
				col=255

			ENDELSE


			; -- Read variable from ncfile
			READ_SIM_NCDF, img, FILE=ncfile, VAR_NAME = varname, VAR_ATTR = img_att
			READ_SIM_NCDF, lon, FILE=ncfile, VAR_NAME = 'lon', GLOB_ATTR = glob_att
			READ_SIM_NCDF, lat, FILE=ncfile, VAR_NAME = 'lat'
			;get_grid_res returns 0 ??? and file = ncfile returns -999.000 incl. error message
			;make_geo,lon,lat,file=ncfile,grid=get_grid_res(img)
			make_geo,lon,lat,grid=0.5
			lat = ROTATE(lat,2)
			lon = lon + 180.
			img = congrid(img,(size(lon,/dim))[0],(size(lon,/dim))[1],/interp)

			PRINT, ' *** MINMAX of '+varname+' :', MINMAX(img)

			IF (N_TAGS(glob_att) NE 0) THEN BEGIN
				cot_thv_era = STRTRIM(STRING(glob_att.cot_thv_ori, FORMAT='(F5.2)'),2)
				cot_thv_sat = STRTRIM(STRING(glob_att.cot_thv, FORMAT='(F5.2)'),2)
			ENDIF

			IF (STRPOS(varname, 'ori') GT 0) THEN cot_thv = cot_thv_era $
				ELSE cot_thv = cot_thv_sat

			long_name = STRING(img_att.long_name)

			; -- flag negative values with FILLVALUE
			wo_bad = WHERE(img LT 0, nbad)
			IF(nbad GT 0) THEN BEGIN
				img[wo_bad] = img_att._FILLVALUE
				PRINT, ' *** ', STRTRIM(nbad,2), ' bad pixels, i.e. negative values'
			ENDIF


			; -- some info written onto plot
			good  = WHERE(img GE 0.)
			imean = MEAN(img[good])
			istdv = STDDEV(img[good])
			unit  = GET_VAR_UNIT(varname)
			minmax_range = MINMAX(img[good])
			minlim = minmax_range[0]
			maxlim = minmax_range[1]
			minstr = 'MIN='+STRTRIM(STRING(minlim, FORMAT='(E10.2)'),2)
			maxstr = 'MAX='+STRTRIM(STRING(maxlim, FORMAT='(E10.2)'),2)
			meastr = 'MEAN='+STRTRIM(STRING(imean, FORMAT='(E10.2)'),2)

			IF KEYWORD_SET(MINI) THEN minlim=mini
			IF KEYWORD_SET(MAXI) THEN maxlim=maxi

			; -- Plot settings
			ptitle = long_name
			IF (N_TAGS(glob_att) NE 0) THEN BEGIN
				ptitle = glob_att.SOURCE+': '+ptitle + $
						 ' for ' + glob_att.TIME_COVERAGE_START
			ENDIF
			ptitle = ptitle + ' (cot_thv=' + cot_thv+') ' + meastr

			position = [0.10, 0.25, 0.90, 0.90]
			xlat=0.05 & ylat=0.53
			xlon=0.46 & ylon=0.17
			xtit=0.08 & ytit=0.96
			barformat = ('(F8.2)')

			IF STREGEX(varname, '^nobs', /FOLD_CASE) NE 0 THEN BEGIN
				IF(ISA(img_att) NE 0) THEN $
					void_index = WHERE(img EQ img_att._FILLVALUE)
			ENDIF

			IF STREGEX(varname, '^lwp', /FOLD_CASE) EQ 0 THEN BEGIN
				minlim = 0. & maxlim = 0.2
			ENDIF
			IF STREGEX(varname, '^iwp', /FOLD_CASE) EQ 0 THEN BEGIN
				minlim = 0. & maxlim = 0.2
			ENDIF

			; -- map_image (single)
			m = obj_new("map_image", img, lat, lon, rainbow=rainbow, $
				/no_draw, /BOX_AXES, /MAGNIFY, bwr=bwr, $
				/GRID, GLINETHICK=2., MLINETHICK=2., $
				n_lev=6, MINI=minlim, MAXI=maxlim, $
; 				discrete=GET_DISCRETE_RANGE(varname), $
				CHARSIZE=chars, /HORIZON,  $
				TITLE=varname + unit, CHARTHICK=chars, $
				POSITION=position, LIMIT=limit, $
				FORMAT=barformat, VOID_INDEX=void_index)
			m -> project, image=img, lon=lon, lat=lat, $
				/no_erase, /no_draw 
			m -> display
			obj_destroy, m

			MAP_CONTINENTS, /CONTINENTS, /HIRES, COLOR=255, GLINETHICK=2.5
			MAP_GRID, COLOR=255, MLINETHICK=2.5

			; -- annotations
			XYOUTS, xtit, ytit, ptitle, $
				/norm, CHARSIZE=chars, CHARTHICK=chars, COLOR=col
			XYOUTS, 0.08, 0.17, minstr, $
				/norm, CHARSIZE=chars, CHARTHICK=chars, COLOR=col
			XYOUTS, 0.76, 0.17, maxstr, $
				/norm, CHARSIZE=chars, CHARTHICK=chars, COLOR=col


			IF KEYWORD_SET(eps) THEN BEGIN
				DEVICE, /Close_file
				!P.MULTI = 0
				end_plot
				end_eps
				SPAWN, 'convert '+outf+'.eps '+outf+'.png'
			ENDIF

		ENDFOR ; end of for loop (niter)

	ENDIF




END ; end of program