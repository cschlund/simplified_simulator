;+
; NAME:
;   COMPARE_ORI_VS_SIM
;
; PURPOSE:
;   Plotting the results of CLOUDCCI_SIMULATOR.PRO,
;   simplified cloud simulator, i.e. plot differences between 
;   original model output and simulated cloud parameters
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
;   compare_ori_vs_sim
;
; MODIFICATION HISTORY:
;   Written by Dr. Cornelia Schlundt; 
;------------------------------------------------------------------------------
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

@/home/cschlund/Programme/idl/vali_gui_rv/plot_l3.pro
; -- main program -------------------------------------------------------------------------------
; 
; Use ncdf_browser from Stefan for comparing with reference data and Cloud_cci results
;
PRO COMPARE_ORI_VS_SIM, verbose=verbose, dir=dir, LIMIT=limit, PORTRAIT=portrait, png=png, $
                        plotlist=plotlist, MINI=mini, MAXI=maxi, OUTDIR=outdir, $
                        ifile=ifile

    IF KEYWORD_SET(plotlist) THEN BEGIN

        vlist1 = ['ctp','ctt','cth','cph','cc_total',$
                  'cwp','lwp','iwp','cot','cot_liq','cot_ice']
        ;vlist1 = ['ctp']
        vlist2 = LIST()

        ; attach *_ori variables
        FOR k=0, N_ELEMENTS(vlist1)-1 DO vlist2.ADD, vlist1[k]+'_ori'

        PRINT, ' * These difference plots will be produced now: '

        FOR k=0, N_ELEMENTS(vlist1)-1 DO BEGIN
            PRINT, '   ', STRTRIM(STRING(k),2),'. ',vlist1[k]+'-'+vlist2[k]
        ENDFOR

    ENDIF ELSE BEGIN
        vlist1 = ['select'] & vlist2 = ['select']
    ENDELSE

    ; CHARSIZE
    chars = 2.4

    ; -- eps plots here
    IF ~KEYWORD_SET(outdir) THEN outdir = '/data/cschlund/figs/'

    ; -- if no limit keyword is set
    IF ~KEYWORD_SET(limit) THEN limit=[-90.,-180.,90.,180.]

    ; -- define path to search for files
    IF ~KEYWORD_SET(dir) THEN dir='/data/cschlund/output/simplified_simulator'

    ; -- Select file
    IF KEYWORD_SET(ifile) THEN BEGIN
        ncfile = ifile
        result = FILE_TEST(ncfile)
        PRINT, ' *** File Selection: ', result ? 'successful' : 'failed'
    ENDIF ELSE BEGIN
        ncfile = DIALOG_PICKFILE(/READ, PATH=dir, FILTER='*.nc', TITLE='Select File!')
        result = FILE_TEST(ncfile)
        PRINT, ' *** File Selection: ', result ? 'successful' : 'failed'
    ENDELSE

    ; -- Get list of variables in file
    variableList = GET_NCDF_VARLIST( ncfile )

    ; -- difference plot onto single page
    ntimes =  N_ELEMENTS(vlist1)

    ; -- loop over the number of parameters from the same ncfile
    FOR i=0, ntimes-1 DO BEGIN

        ; -- select blue-white-red color table
        rainbow = 0 & bwr = 1

        ; -- choose first variable
        IF (vlist1[0] EQ 'select') THEN BEGIN
            variableList = GET_NCDF_VARLIST( ncfile )
            dropListValues = variableList.ToArray()
            varname = Choose_Item(dropListValues, CANCEL=cancelled)
        ENDIF ELSE BEGIN
            varname = vlist1[i]
        ENDELSE
        varoutf = '_DIFF_'+varname
        
        ; -- choose second variable
        IF (vlist2[0] EQ 'select') THEN BEGIN
            variableList = GET_NCDF_VARLIST( ncfile )
            dropListValues = variableList.ToArray()
            varname2 = Choose_Item(dropListValues, CANCEL=cancelled)
        ENDIF ELSE BEGIN
            varname2 = vlist2[i]
        ENDELSE
        varoutf = varoutf+'-'+varname2

        PRINT, ' *** Difference plot: ', varoutf

        ; -- set_plot option
        IF KEYWORD_SET(png) THEN BEGIN 
            base = FSC_Base_Filename(ncfile,Directory=dir,Extension=ext) 
            outf = outdir+base+varoutf 
            col = 0
            si = reverse([21.0, 29.7])
            ;if keyword_set(landscape) then si = reverse(si)
            outeps = outf
            start_plot, outeps, 'eps', eps_size = si
        ENDIF ELSE BEGIN
            SET_PLOT, 'X'
            DEVICE, SET_FONT='Helvetica Bold',/TT_FONT
            window,  xsize = 1200, ysize = 1000
            col=255
        ENDELSE

        ; -- Read variable from ncfile
        READ_SIM_NCDF, img, FILE=ncfile, VAR_NAME = varname, VAR_ATTR = img_att
        READ_SIM_NCDF, img2, FILE=ncfile, VAR_NAME = varname2, VAR_ATTR = img_att2
        READ_SIM_NCDF, lon, FILE=ncfile, VAR_NAME = 'lon', GLOB_ATTR = glob_att
        READ_SIM_NCDF, lat, FILE=ncfile, VAR_NAME = 'lat'
        
        make_geo, lon, lat, grid=0.5
        lat = ROTATE(lat,2)
        lon = lon + 180.

        ; -- nobs does not have an attribute called _FILLVALUE
        ; -- set fillvalue to NANs and set void_index for map_image
        IF STREGEX(varname, '^nobs', /FOLD_CASE) NE 0 THEN BEGIN
            IF(ISA(img_att) NE 0) THEN BEGIN
                j1 = WHERE(img EQ img_att._FILLVALUE, count1)
                IF (count1 GT 0) THEN img[j1] = !VALUES.F_NAN
            ENDIF
            IF(ISA(img_att2) NE 0) THEN BEGIN
                j2 = WHERE(img2 EQ img_att2._FILLVALUE, count2)
                IF (count2 GT 0) THEN img2[j2] = !VALUES.F_NAN
            ENDIF
        ENDIF

        img  = congrid(img,(size(lon,/dim))[0],(size(lon,/dim))[1],/interp)
        img2 = congrid(img2,(size(lon,/dim))[0],(size(lon,/dim))[1],/interp)
        
        ; -- some statistics: latitude-weighted due to equal angular grid
        idx = WHERE(FINITE(img-img2))
        idx1 = WHERE(FINITE(img))
        idx2 = WHERE(FINITE(img2))
        rmse = grmse(img[idx],img2[idx],lat[idx])
        bias = gbias(img[idx],img2[idx],lat[idx])
        ;stdd = stddev(img[idx]-img2[idx]) 
        stdd = sqrt(rmse^2 - bias^2)
        print,' *** Glob. Mean    img1: '+varname+' :', STRING(gmean(img[idx1],lat[idx1]),f='(f11.4)')
        print,' *** Glob. Mean    img2: '+varname2+' :', STRING(gmean(img2[idx2],lat[idx2]),f='(f11.4)')
        print,' *** Glob. BIAS    img1 - img2 :', STRING(bias,f='(f11.4)')
        print,' *** Glob. RMSE    img1 - img2 :', STRING(rmse,f='(f11.4)')
        print,' *** Glob. BC-RMSE img1 - img2 :', STRING(stdd,f='(f11.4)')

        ; -- minmax of image
        text=' *** MINMAX of '+varname+'-'+varname2
        cgMinMax, (img-img2), NAN=nan, TEXT=text

        ; -- some info written onto plot
        long_name = STRING(img_att.long_name)
        unit  = STRING(img_att.units)
        IF(STRLEN(unit) LE 1 and unit NE 'K') THEN unit = unit ELSE unit = ' ['+unit+']'
        minmax_range = MINMAX( (img-img2)[WHERE(FINITE(img-img2))] )

        CASE varname OF
            'ctp'     : minmax=[-300., 300.]
            'ctt'     : minmax=[-50., 50.]
            'cth'     : minmax=[-8., 8.]
            'cph'     : minmax=[-0.5, 0.5]
            'lwp'     : minmax=[-500., 500.]
            'iwp'     : minmax=[-500., 500.]
            'cwp'     : minmax=[-500., 500.]
            'cot'     : minmax=[-50., 50.]
            'cot_liq' : minmax=[-50., 50.]
            'cot_ice' : minmax=[-50., 50.]
            'cc_total': minmax=[-0.5, 0.5]
        ENDCASE

        ; -- Plot settings
        btitle = varname+' - '+varname2+unit
        ptitle = long_name
        IF (N_TAGS(glob_att) NE 0) THEN BEGIN
            IF(ISA(glob_att.cot_thv_ori) NE 0) THEN $
                cot_thv_era = STRTRIM(STRING(glob_att.cot_thv_ori, FORMAT='(F5.2)'),2)
            IF(ISA(glob_att.cot_thv) NE 0) THEN $
                cot_thv_sat = STRTRIM(STRING(glob_att.cot_thv, FORMAT='(F5.2)'),2)
            IF(ISA(glob_att.SOURCE) NE 0) THEN $
                ptitle = glob_att.SOURCE +': '+ ptitle
            IF(ISA(glob_att.TIME_COVERAGE_START) NE 0) THEN $
                ptitle = ptitle + ' for ' + glob_att.TIME_COVERAGE_START
        ENDIF


        position = [0.10, 0.25, 0.90, 0.90]
        xlat=0.05 & ylat=0.53
        xlon=0.46 & ylon=0.17
        xtit=0.11 & ytit=0.96
        barformat = ('(F8.2)')
        void_index = WHERE(~FINITE(img-img2))

        ; -- map_image (single)
        m = obj_new("map_image", (img-img2), lat, lon, $
                    /no_draw, /BOX_AXES, /MAGNIFY, bwr=bwr, $
                    /GRID, GLINETHICK=2., MLINETHICK=2., $
                    n_lev=6, TITLE=btitle, $
                    MINI=minmax[0], MAXI=minmax[1], $
                    CHARSIZE=chars, /HORIZON, POSITION=position, $
                    /CONTINENTS, LIMIT=limit, $
                    FORMAT=barformat, VOID_INDEX=void_index)
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

        XYOUTS, 0.1, 0.185, 'Min. = '+STRTRIM(STRING(minmax_range[0]),2),$
            COLOR=col, /norm, CHARSIZE=2., CHARTHICK=2.
        XYOUTS, 0.1, 0.155, 'Max. = '+STRTRIM(STRING(minmax_range[1]),2), $
            COLOR=col, /norm, CHARSIZE=2., CHARTHICK=2.

        IF KEYWORD_SET(png) THEN BEGIN
            !P.MULTI = 0
            end_plot
            ;SPAWN, 'convert -density 300 '+outf+'.eps -resize 25% -flatten -rotate 270 '+outf+'.png'
            SPAWN, 'convert -density 300 '+outf+'.eps -resize 25% -flatten '+outf+'.png'
            SPAWN, 'rm -f '+outeps
        ENDIF

    ENDFOR


END ; end of program
