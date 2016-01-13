
;--------------------------------------------------------------------
FUNCTION GET_DATE_UTC, basename
;--------------------------------------------------------------------
    splt = STRSPLIT(basename, /EXTRACT, '_')
    time = STRSPLIT(splt[4],/EXTRACT,'+')
    hour = FIX(time[0])
    yyyy = FIX(STRMID(splt[3],0,4))
    mm = FIX(STRMID(splt[3],4,2))
    dd = FIX(STRMID(splt[3],6,2))
    date_utc = ' for '+splt[3]+' UTC '+splt[4]
    RETURN, date_utc
END


;--------------------------------------------------------------------
PRO PLOT_LSM2D, lsm, lat, lon, title, filename
;--------------------------------------------------------------------

    filepwd = !SAVE_DIR + filename
    IF(is_file(filepwd+'.png')) THEN return
    save_as = filepwd + '.eps'
    start_save, save_as, size='A4', /LANDSCAPE

    limit = [-90., -180., 90., 180.]
    bar_tickname = ['Water', 'Land']
    nlev = N_ELEMENTS(bar_tickname)
    discrete = FINDGEN(N_ELEMENTS(bar_tickname)+1)

    MAP_IMAGE, lsm, lat, lon, LIMIT=limit, $
               CTABLE=33, /BOX_AXES, /MAGNIFY, /GRID, $
               DISCRETE=discrete, N_LEV=nlev, $
               BAR_TICKNAME=bar_tickname, $
               MINI=MIN(lsm), MAXI=MAX(lsm), $
               CHARSIZE=2.2, VOID_INDEX=void_index, $
               FIGURE_TITLE=title;+'!C'
    MAP_CONTINENTS, /CONTINENTS, /HIRES, $
        COLOR=cgcolor('Black'), GLINETHICK=2.2
    MAP_GRID, COLOR=cgcolor('Black'), MLINETHICK=2.2

    end_save, save_as
    cs_eps2png, save_as

END


;--------------------------------------------------------------------
PRO PLOT_ERA_SST, filename, sst, lat, lon, void_index
;--------------------------------------------------------------------

    filepwd = !SAVE_DIR + filename
    IF(is_file(filepwd+'.png')) THEN return
    save_as = filepwd + '.eps'
    start_save, save_as, size='A4', /LANDSCAPE

    limit = [-90., -180., 90., 180.]

    MAP_IMAGE, sst, lat, lon, LIMIT=limit, $
               CTABLE=33, /BOX_AXES, /MAGNIFY, /GRID, $
               FORMAT=('(f5.1)'), N_LEV=6, $
               MINI=MIN(sst), MAXI=MAX(sst), $
               CHARSIZE=2.2, VOID_INDEX=void_index, $
               TITLE='SST [K]', $
               FIGURE_TITLE="ERA-Interim Sea Surface Temperature"
    MAP_CONTINENTS, /CONTINENTS, /HIRES, $
        COLOR=cgcolor('Black'), GLINETHICK=2.2
    MAP_GRID, COLOR=cgcolor('Black'), MLINETHICK=2.2

    end_save, save_as
    cs_eps2png, save_as

END


;--------------------------------------------------------------------
PRO PLOT_SZA2D, sza2d, lat, lon, title, filename
;--------------------------------------------------------------------

    basen = FSC_Base_Filename(filename)
    filepwd = !SAVE_DIR + basen + '_sza2D'
    IF(is_file(filepwd+'.png')) THEN return
    save_as = filepwd + '.eps'
    start_save, save_as, size='A4', /LANDSCAPE
    limit = [-90., -180., 90., 180.]

    MAP_IMAGE, sza2d, lat, lon, LIMIT=limit, $
               CTABLE=33, /FLIP_COLOURS, $
               /BOX_AXES, /MAGNIFY, /GRID, $
               MINI=0., MAXI=180., CHARSIZE=2.2, $
               TITLE='SZA [deg]', $
               FIGURE_TITLE=title
    MAP_CONTINENTS, /CONTINENTS, /HIRES, $
        COLOR=cgcolor('Black'), GLINETHICK=2.2
    MAP_GRID, COLOR=cgcolor('Black'), MLINETHICK=2.2

    end_save, save_as
    cs_eps2png, save_as

END


;--------------------------------------------------------------------
PRO PLOT_HISTOS_1D, FINAL=final,  HIST_INFO=histo, OFILE=fil, $
                    CONSTANT_CER=creff
;--------------------------------------------------------------------

    !P.MULTI = [0,2,2]

    IF KEYWORD_SET(creff) THEN addstr = '_fixed_reffs' $
        ELSE addstr = ''

    basen = FSC_Base_Filename(fil)
    obase = !SAVE_DIR + basen
    ofil = obase + '_tmpHISTOS1D'+addstr

    IF (is_file(ofil+'.png')) THEN RETURN

    IF (fil.EndsWith('.nc') EQ 1) THEN BEGIN
        datutc = GET_DATE_UTC(basen)
    ENDIF ELSE BEGIN
        datutc = ' for '+STRMID(basen, STRLEN(basen)-6, 6)
    ENDELSE

    ; start plotting
    save_as = ofil + '.eps'
    start_save, save_as, size=[45,30]
    cs = 2.1

    ; -- final.HIST1D_COT: CCI binsizes ---
    CREATE_1DHIST, RESULT=final.HIST1D_CTP, VARNAME='ctp', $
        VARSTRING='H1D_CTP', CHARSIZE=cs, XTITLE=datutc, $
        YMAX=50, LEGEND_POSITION='tr'

    CREATE_1DHIST, RESULT=final.HIST1D_CWP, VARNAME='cwp', $
        VARSTRING='H1D_CWP', CHARSIZE=cs, XTITLE=datutc, $
        YMAX=50

    CREATE_1DHIST, RESULT=final.HIST1D_CER, VARNAME='ref', $
        VARSTRING='H1D_CER', CHARSIZE=cs, XTITLE=datutc, $
        YMAX=50, LEGEND_POSITION='tr'

    CREATE_1DHIST, RESULT=final.HIST1D_COT, VARNAME='cot', $
        VARSTRING='H1D_COT', CHARSIZE=cs, XTITLE=datutc, $
        YMAX=50

    ; end plotting
    end_save, save_as
    cs_eps2png, save_as

    !P.MULTI = 0

END


;--------------------------------------------------------------------
PRO PLOT_INTER_HISTOS, INTER=inter, VARNAME=var, HIST_INFO=histo, $
                       OFILE=fil, CONSTANT_CER=creff
;--------------------------------------------------------------------

    !P.MULTI = [0,2,2]

    IF KEYWORD_SET(creff) THEN addstr = '_fixed_reffs' $
        ELSE addstr = ''

    basen = FSC_Base_Filename(fil)
    obase = !SAVE_DIR + basen
    sname = SIZE(inter, /SNAME)
    cph_dim = histo.phase_dim

    CASE var of
        'cot' : BEGIN
            maxvalue = 100.
            bin_dim = histo.cot_bin1d_dim
            lim_bin = histo.cot2d
            cci_str = 'cot'
            ymax = 30
            legpos = "tl" ;top-left
            END

        'cer' : BEGIN
            maxvalue = 80.
            bin_dim = histo.cer_bin1d_dim
            lim_bin = histo.cer2d
            cci_str = 'ref'
            ymax = 60
            legpos = "tr" ;top-right
            END
    ENDCASE


    CASE sname of
        'TEMP_ARRAYS' : BEGIN
            ofil = obase + '_'+var+'2Dtmp'+addstr
            IF (var EQ 'cot') THEN BEGIN 
                aliq = inter.COT_LIQ 
                aice = inter.COT_ICE 
            ENDIF ELSE IF (var EQ 'cer') THEN BEGIN 
                aliq = inter.CER_LIQ 
                aice = inter.CER_ICE 
            ENDIF ELSE BEGIN
                PRINT, 'VARNAME not yet defined here.'
                RETURN 
            ENDELSE
            as = ' (2D - upper most clouds; CFC==1) '
            varstring = 'temps'
            END
        ELSE : BEGIN
            PRINT, 'SNAME has an illegal value.'
            RETURN 
            END
    ENDCASE


    IF(is_file(ofil+'.png')) THEN RETURN

    datutc = GET_DATE_UTC(basen)

    ; start plotting
    save_as = ofil + '.eps'
    start_save, save_as, size=[45,30]

    ; get total COT and set CFC
    all  = aliq + aice
    dims = SIZE(aliq, /DIM)
    acfc = FLTARR(dims[0],dims[1])
    acfc[*,*] = 1.

    ; VARNAME GT maxvalue set to maxvalue
    i1=WHERE( aliq GT maxvalue, ni1)
    IF (ni1 GT 0) THEN aliq[i1] = maxvalue 
    i2=WHERE( aice GT maxvalue, ni2)
    IF (ni2 GT 0) THEN aice[i2] =  maxvalue
    i3=WHERE( all GT maxvalue, ni3)
    IF (ni3 GT 0) THEN all[i3] = maxvalue

    ; VARNAME EQ 0. set to fillvalue
    i1=WHERE( aliq EQ 0.,ni1)
    IF (ni1 GT 0) THEN aliq[i1] = -999.
    i2=WHERE( aice EQ 0.,ni2)
    IF (ni2 GT 0) THEN aice[i2] = -999.
    i3=WHERE( all EQ 0.,ni3)
    IF (ni3 GT 0) THEN all[i3] = -999.

    cs = 2.1

    ; -- inter.HIST1D: equal binsizes ---
    cgHistoplot, aliq, binsize=1, /FILL, POLYCOLOR='red', $
        mininput=0, maxinput=maxvalue, charsize=cs, $
        xtitle=varstring+'.'+STRUPCASE(var)+'_LIQ'+as, $
        histdata=cghist_liq

    cgHistoplot, aice, binsize=1, /FILL, POLYCOLOR='royal blue', $
        mininput=0, maxinput=maxvalue, charsize=cs, $
        xtitle=varstring+'.'+STRUPCASE(var)+'_ICE'+as, $
        histdata=cghist_ice

    cgHistoplot, all, binsize=1, /FILL, POLYCOLOR='black', $
        mininput=0, maxinput=maxvalue, charsize=cs, $
        xtitle=varstring+'.'+STRUPCASE(var)+'_TOTAL'+as, $
        histdata=cghist_liq
    
    ; -- inter.HIST1D: cloud_cci binsizes ---
    res = SUMUP_HIST1D( bin_dim=bin_dim, lim_bin=lim_bin, $
                        cph_dim=cph_dim, cfc_tmp=acfc, $
                        liq_tmp=aliq,    ice_tmp=aice )

    CREATE_1DHIST, RESULT=res, VARNAME=cci_str, YMAX=ymax, $
        VARSTRING=varstring, CHARSIZE=cs, XTITLE=datutc, $
        LEGEND_POSITION=legpos

    ; end plotting
    end_save, save_as
    cs_eps2png, save_as

    !P.MULTI = 0

END


;--------------------------------------------------------------------
PRO PLOT_REFF_T_DEPENDENCY, T, RTT, ZRAD, ZRAD2
;--------------------------------------------------------------------

    filepwd = !SAVE_DIR + 'Reff_ec-earth_ver2.png'
    IF(is_file(filepwd+'.png')) THEN return
    save_as = filepwd + '.eps'
    start_save, save_as, size='A4', /LANDSCAPE

    PLOT, (T-RTT), ZRAD, COLOR=0, $
        XRANGE=[-80,40], YRANGE=[0,100], $
        CHARSIZE=2.5, CHARTHICK=2.5, $
        TITLE='Reff ver 2 unlimited', $
        XTITLE='T(degC)', YTITLE='Reff(microns)'

    PLOT, (T-RTT), ZRAD2,  COLOR=0, $
        XRANGE=[-80,40], YRANGE=[0,80], $
        CHARSIZE=2.5, CHARTHICK=2.5, $
        TITLE='Reff ver 2', $
        XTITLE='T(degC)', YTITLE='Reff(microns)'

    end_save, save_as
    cs_eps2png, save_as

END


;--------------------------------------------------------------------
PRO PLOT_SOLAR_VARS, tmp, grd, fil, void
;--------------------------------------------------------------------

    !P.MULTI = [0,2,3]

    base = FSC_Base_Filename(fil)
    filepwd = !SAVE_DIR + base + '_daytime'
    IF(is_file(filepwd+'.png')) THEN return
    save_as = filepwd + '.eps'
    start_save, save_as, size='A3', /LANDSCAPE

    cs = 2.0
    nlev = 6
    limit = [-90., -180., 90., 180.]
    
    MAP_IMAGE, tmp.lwp_bin, grd.lat2d, grd.lon2d, $
        /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=cs, $
        FORMAT=('(f3.1)'), N_LEV=nlev, $
        MINI=0., MAXI=1., VOID_INDEX=void, /RAINBOW, $
        LIMIT=limit, TITLE='lwp_bin [kg/m^2]'

    MAP_IMAGE, tmp.iwp_bin, grd.lat2d, grd.lon2d, $
        /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=cs, $
        FORMAT=('(f3.1)'), N_LEV=nlev, $
        MINI=0., MAXI=1., VOID_INDEX=void, /RAINBOW, $
        LIMIT=limit, TITLE='iwp_bin [kg/m^2]'

    MAP_IMAGE, tmp.cer_liq, grd.lat2d, grd.lon2d, $
        /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=cs, $
        MINI=MIN(tmp.cer_liq), MAXI=MAX(tmp.cer_liq), $
        VOID_INDEX=void, /RAINBOW, $
        N_LEV=nlev, LIMIT=limit, TITLE='cer_liq [microns]'

    MAP_IMAGE, tmp.cer_ice, grd.lat2d, grd.lon2d, $
        /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=cs, $
        MINI=MIN(tmp.cer_ice), MAXI=MAX(tmp.cer_ice), $
        VOID_INDEX=void, /RAINBOW, $
        N_LEV=nlev, LIMIT=limit, TITLE='cer_ice [microns]'

    MAP_IMAGE, tmp.cot_liq_bin, grd.lat2d, grd.lon2d, $
        /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=cs, $
        MINI=0., MAXI=100., VOID_INDEX=void, /RAINBOW, $
        N_LEV=nlev, LIMIT=limit, TITLE='cot_liq_bin '

    MAP_IMAGE, tmp.cot_ice_bin, grd.lat2d, grd.lon2d, $
        /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=cs, $
        MINI=0., MAXI=100., VOID_INDEX=void, /RAINBOW, $
        N_LEV=nlev, LIMIT=limit, TITLE='cot_ice_bin'

    end_save, save_as
    cs_eps2png, save_as

    !P.MULTI = 0
END


;--------------------------------------------------------------------
PRO CREATE_1DHIST, RESULT=res, VARNAME=vn, VARSTRING=vs, $
                   CHARSIZE=cs, XTITLE=xtitle, YMAX=ymax, $
                   LEGEND_POSITION=lp
;--------------------------------------------------------------------
    IF NOT KEYWORD_SET(ymax) THEN ymax = 40
    IF NOT KEYWORD_SET(lp) THEN lp='tl'

    bild_all = TOTAL(res, 4)
    bild_liq = reform(res[*,*,*,0])
    bild_ice = reform(res[*,*,*,1])

    bild = get_1d_rel_hist_from_1d_hist( bild_all, $
        'hist1d_'+vn, algo='era-i', $;limit=limit, $
        land=land, sea=sea, arctic=arctic, antarctic=antarctic,$ 
        xtickname=xtickname, ytitle = ytitle, hist_name=data_name, $
        found=found1)
    bild1 = get_1d_rel_hist_from_1d_hist( bild_liq, $
        'hist1d_'+vn+'_liq', algo='era-i', $;limit=limit, $
        land=land, sea=sea, arctic=arctic, antarctic=antarctic,$ 
        xtickname=xtickname, ytitle = ytitle, hist_name=data_name, $
        found=found1)
    bild2 = get_1d_rel_hist_from_1d_hist( bild_ice, $
        'hist1d_'+vn+'_ice', algo='era-i', $;limit=limit, $
        land=land, sea=sea, arctic=arctic, antarctic=antarctic,$ 
        xtickname=xtickname, ytitle = ytitle, hist_name=data_name, $
        found=found1)
    plot,[0,0],[1,1],yr=[0,ymax],xr=[0,n_elements(bild)-1],$
        xticks=n_elements(xtickname)-1,xtickname=xtickname, $ 
        xtitle=data_name+xtitle,ytitle=ytitle,xminor=2, $
        charsize=cs, col=cgcolor('black')

    lsty = 0
    thick = 4
    oplot,bild, psym=-1, col=cgcolor('Black'), THICK=thick
    oplot,bild1,psym=-2, col=cgcolor('Red'), THICK=thick
    oplot,bild2,psym=-4, col=cgcolor('royal blue'), THICK=thick

    ;vs='cot_lay_inc' OR vs='temps'
    allstr  = vs+'.TOTAL'
    aliqstr = vs+'.LIQ'
    aicestr = vs+'.ICE'

    legend, [allstr,aliqstr,aicestr], thick=REPLICATE(thick,3), $
        spos=lp, charsize=cs, color=[cgcolor("Black"),$
        cgcolor("Red"),cgcolor("royal blue")]

    ;PRINT, '** MINMAX(bild): ', allstr+'/'+aliqstr+'/'+aicestr
    ;PRINT, MINMAX(bild), MINMAX(bild1), MINMAX(bild2)

END

