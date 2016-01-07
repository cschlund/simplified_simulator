
PRO PLOT_SZA2D, sza2d, lat, lon, title, filename

    filepwd = !SAVE_DIR + filename
    save_as = filepwd + '.eps'
    start_save, save_as, size='A4', /LANDSCAPE
    limit = [-90., -180., 90., 180.]

    MAP_IMAGE, sza2d, lat, lon, LIMIT=limit, $
               CTABLE=33, /FLIP_COLOURS, $
               /BOX_AXES, /MAGNIFY, /GRID, $
               MINI=0., MAXI=180., CHARSIZE=3., $
               TITLE=title
    MAP_CONTINENTS, /CONTINENTS, /HIRES, $
        COLOR=cgcolor('Black'), GLINETHICK=2.2
    MAP_GRID, COLOR=cgcolor('Black'), MLINETHICK=2.2

    end_save, save_as
    cs_eps2png, save_as

END


PRO PLOT_COT_HISTOS, cot_lay_inc, histo, means, fil, grd,$
                     temps=temps, fixed_reffs=creff

    !P.MULTI = [0,2,2]

    IF KEYWORD_SET(creff) THEN addstr = '_fixed_reffs' $
        ELSE addstr = ''

    base = FSC_Base_Filename(fil)

    IF KEYWORD_SET(temps) THEN BEGIN 
        ofil = !SAVE_DIR + base + '_cot_lay_inc_2'+addstr
    ENDIF ELSE BEGIN
        ofil = !SAVE_DIR + base + '_cot_lay_inc'+addstr
    ENDELSE

    save_as = ofil + '.eps'
    start_save, save_as, size=[45,30]

    splt = STRSPLIT(base, /EXTRACT, '_')
    time = STRSPLIT(splt[4],/EXTRACT,'+')
    hour = FIX(time[0])
    yyyy = FIX(STRMID(splt[3],0,4))
    mm = FIX(STRMID(splt[3],4,2))
    dd = FIX(STRMID(splt[3],6,2))
    datutc = ' for '+splt[3]+' UTC '+splt[4]

    aliq = TOTAL(cot_lay_inc.LIQ,3)
    aice = TOTAL(cot_lay_inc.ICE,3)
    all  = aliq + aice
    dims = SIZE(aliq, /DIM)
    acfc = FLTARR(dims[0],dims[1])
    acfc[*,*] = 1.

    i1=WHERE( aliq GT 100.,ni1)
    IF (ni1 GT 0) THEN aliq[i1] = 100.
    i2=WHERE( aice GT 100.,ni2)
    IF (ni2 GT 0) THEN aice[i2] = 100.
    i3=WHERE( all GT 100.,ni3)
    IF (ni3 GT 0) THEN all[i3] = 100.

    i1=WHERE( aliq EQ 0.,ni1)
    IF (ni1 GT 0) THEN aliq[i1] = -999.
    i2=WHERE( aice EQ 0.,ni2)
    IF (ni2 GT 0) THEN aice[i2] = -999.
    i3=WHERE( all EQ 0.,ni3)
    IF (ni3 GT 0) THEN all[i3] = -999.


    ;  COT_LIQ   FLOAT   Array[720, 361]
    ;  COT_ICE   FLOAT   Array[720, 361]
    IF KEYWORD_SET(temps) THEN BEGIN 
        aliq2 = temps.COT_LIQ
        aice2 = temps.COT_ICE
        all2  = aliq2 + aice2
        dims2 = SIZE(aliq2, /DIM)
        acfc2 = FLTARR(dims2[0],dims2[1])
        acfc2[*,*] = 1.

        i1=WHERE( aliq2 GT 100.,ni1)
        IF (ni1 GT 0) THEN aliq2[i1] = 100.
        i2=WHERE( aice2 GT 100.,ni2)
        IF (ni2 GT 0) THEN aice2[i2] = 100.
        i3=WHERE( all2 GT 100.,ni3)
        IF (ni3 GT 0) THEN all2[i3] = 100.

        i1=WHERE( aliq2 EQ 0.,ni1)
        IF (ni1 GT 0) THEN aliq2[i1] = -999.
        i2=WHERE( aice2 EQ 0.,ni2)
        IF (ni2 GT 0) THEN aice2[i2] = -999.
        i3=WHERE( all2 EQ 0.,ni3)
        IF (ni3 GT 0) THEN all2[i3] = -999.
    ENDIF


    cs = 2.1
    limit = [-90., -180., 90., 180.]

    cgHistoplot, aliq, binsize=1, /FILL, POLYCOLOR='red', $
        mininput=0, maxinput=100., charsize=cs, $
        xtitle='cot_lay_inc.LIQ'+datutc, histdata=cghist_liq
    cgHistoplot, aice, binsize=1, /FILL, POLYCOLOR='royal blue', $
        mininput=0, maxinput=100., charsize=cs, $
        xtitle='cot_lay_inc.ICE'+datutc, histdata=cghist_ice
    
    
    ; -- hist1d_cot for temps.COT_LIQ + temps.COT_ICE
    IF KEYWORD_SET(temps) THEN BEGIN 
        res = SUMUP_HIST1D( bin_dim=histo.cot_bin1d_dim, $
                            cph_dim=histo.phase_dim, $
                            lim_bin=histo.cot2d, $
                            liq_tmp=aliq2, $
                            ice_tmp=aice2, $
                            cfc_tmp=acfc2 )
    ; -- hist1d_cot for cot_lay_inc.LIQ + .ICE
    ENDIF ELSE BEGIN
        res = SUMUP_HIST1D( bin_dim=histo.cot_bin1d_dim, $
                            cph_dim=histo.phase_dim, $
                            lim_bin=histo.cot2d, $
                            liq_tmp=aliq, $
                            ice_tmp=aice, $
                            cfc_tmp=acfc )
    ENDELSE

    bild_all = TOTAL(res, 4)
    bild_liq = reform(res[*,*,*,0])
    bild_ice = reform(res[*,*,*,1])

    bild = get_1d_rel_hist_from_1d_hist( bild_all, $
        'hist1d_cot', algo='era-i', $;limit=limit, $
        land=land, sea=sea, arctic=arctic, antarctic=antarctic,$ 
        xtickname=xtickname, ytitle = ytitle, hist_name=data_name, $
        found=found1)
    bild1 = get_1d_rel_hist_from_1d_hist( bild_liq, $
        'hist1d_cot_liq', algo='era-i', $;limit=limit, $
        land=land, sea=sea, arctic=arctic, antarctic=antarctic,$ 
        xtickname=xtickname, ytitle = ytitle, hist_name=data_name, $
        found=found1)
    bild2 = get_1d_rel_hist_from_1d_hist( bild_ice, $
        'hist1d_cot_ice', algo='era-i', $;limit=limit, $
        land=land, sea=sea, arctic=arctic, antarctic=antarctic,$ 
        xtickname=xtickname, ytitle = ytitle, hist_name=data_name, $
        found=found1)
    plot,[0,0],[1,1],yr=[0,40],xr=[0,n_elements(bild)-1],$
        xticks=n_elements(xtickname)-1,xtickname=xtickname, $ 
        xtitle=data_name+datutc,ytitle=ytitle,xminor=2, charsize=cs, $
        col=cgcolor('black')

    lsty = 0
    oplot,bild, psym=-1, col=cgcolor('Black'), THICK=3
    oplot,bild1,psym=-2, col=cgcolor('Red'), THICK=3
    oplot,bild2,psym=-4, col=cgcolor('royal blue'), THICK=3

    IF KEYWORD_SET(temps) THEN BEGIN 
        allstr  = 'temps.COT_ALL'
        aliqstr = 'temps.COT_LIQ'
        aicestr = 'temps.COT_ICE'
    ENDIF ELSE BEGIN
        allstr  = 'cot_lay_inc.ALL'
        aliqstr = 'cot_lay_inc.LIQ'
        aicestr = 'cot_lay_inc.ICE'
    ENDELSE

    xyouts, .3, 25, allstr,  color=cgcolor('Black'), chars=cs
    xyouts, .3, 35, aliqstr, color=cgcolor('Red'), chars=cs
    xyouts, .3, 30, aicestr, color=cgcolor('royal blue'), chars=cs

    PRINT, '** MINMAX(bild): ', allstr+'/'+aliqstr+'/'+aicestr
    PRINT, MINMAX(bild), MINMAX(bild1), MINMAX(bild2)


    ; -- means.HIST1D_COT
    bild_all = TOTAL(means.HIST1D_COT, 4)
    bild_liq = REFORM(means.HIST1D_COT[*,*,*,0])
    bild_ice = REFORM(means.HIST1D_COT[*,*,*,1])

    bild = get_1d_rel_hist_from_1d_hist( bild_all, $
        'hist1d_cot', algo='era-i', $;limit=limit, $
        land=land, sea=sea, arctic=arctic, antarctic=antarctic,$ 
        xtickname=xtickname, ytitle = ytitle, hist_name=data_name, $
        found=found1)
    bild1 = get_1d_rel_hist_from_1d_hist( bild_liq, $
        'hist1d_cot_liq', algo='era-i', $;limit=limit, $
        land=land, sea=sea, arctic=arctic, antarctic=antarctic,$ 
        xtickname=xtickname, ytitle = ytitle, hist_name=data_name, $
        found=found1)
    bild2 = get_1d_rel_hist_from_1d_hist( bild_ice, $
        'hist1d_cot_ice', algo='era-i', $;limit=limit, $
        land=land, sea=sea, arctic=arctic, antarctic=antarctic,$ 
        xtickname=xtickname, ytitle = ytitle, hist_name=data_name, $
        found=found1)
    plot,[0,0],[1,1],yr=[0,40],xr=[0,n_elements(bild)-1],$
        xticks=n_elements(xtickname)-1,xtickname=xtickname, $ 
        xtitle=data_name,ytitle=ytitle,xminor=2, charsize=cs, $
        col=cgcolor('black')

    oplot,bild, psym=-1,col=cgcolor('Black'), THICK=3
    oplot,bild1,psym=-2,col=cgcolor('Red'), THICK=3
    oplot,bild2,psym=-4,col=cgcolor('royal blue'), THICK=3
    xyouts, .3, 25, 'hist1d_cot: liq + ice', color=cgcolor('Black'), chars=cs
    xyouts, .3, 35, 'hist1d_cot: liq', color=cgcolor('Red'), chars=cs
    xyouts, .3, 30, 'hist1d_cot: ice', color=cgcolor('royal blue'), chars=cs

    PRINT, '** MINMAX(bild): hist1d_cot(all,liq,ice)'
    PRINT, MINMAX(bild), MINMAX(bild1), MINMAX(bild2)

    end_save, save_as
    cs_eps2png, save_as

    !P.MULTI = 0
END



PRO PLOT_REFF_T_DEPENDENCY, T, RTT, ZRAD, ZRAD2

    filepwd = !SAVE_DIR + 'Reff_ec-earth_ver2.png'
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


PRO PLOT_SOLAR_COT_CWP, tmp, grd, fil, void

    !P.MULTI = [0,2,2]

    base = FSC_Base_Filename(fil)
    filepwd = !SAVE_DIR + base + '_solar_cot_cwp'
    save_as = filepwd + '.eps'
    start_save, save_as, size='A3', /LANDSCAPE

    cs = 2.3
    limit = [-90., -180., 90., 180.]
    
    MAP_IMAGE, tmp.lwp_bin, grd.lat2d, grd.lon2d, $
        /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=cs, $
        FORMAT=('(f3.1)'), $
        MINI=0., MAXI=1., VOID_INDEX=void, /RAINBOW, $
        LIMIT=limit, TITLE='lwp_bin [kg/m^2]'

    MAP_IMAGE, tmp.iwp_bin, grd.lat2d, grd.lon2d, $
        /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=cs, $
        FORMAT=('(f3.1)'), $
        MINI=0., MAXI=1., VOID_INDEX=void, /RAINBOW, $
        LIMIT=limit, TITLE='iwp_bin [kg/m^2]'

    MAP_IMAGE, tmp.cot_liq_bin, grd.lat2d, grd.lon2d, $
        /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=cs, $
        MINI=0., MAXI=100., VOID_INDEX=void, /RAINBOW, $
        LIMIT=limit, TITLE='cot_liq_bin '

    MAP_IMAGE, tmp.cot_ice_bin, grd.lat2d, grd.lon2d, $
        /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=cs, $
        MINI=0., MAXI=100., VOID_INDEX=void, /RAINBOW, $
        LIMIT=limit, TITLE='cot_ice_bin'

    end_save, save_as
    cs_eps2png, save_as

    !P.MULTI = 0
END
