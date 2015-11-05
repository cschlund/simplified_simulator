
PRO PLOT_SZA2D, sza2d, lat, lon, title, filename

    theSize = Get_Screen_Size()
    WINDOW, 0, XSIZE=theSize[0], YSIZE=theSize[1]

    MAP_IMAGE, sza2d, lat, lon, $
        CTABLE=33, /FLIP_COLOR, $
        /BOX_AXES, /MAGNIFY, /GRID, $
        MINI=0., MAXI=180., CHARSIZE=3., $
        TITLE=title

    WRITE_PNG, filename, TVRD(/TRUE)
    PRINT, 'File written to ', filename

END


PRO PLOT_COT_HISTOS, cot_lay_liq, cot_lay_ice, histo, path, grd

    aliq = TOTAL(cot_lay_liq,3)
    aice = TOTAL(cot_lay_ice,3)
    dims = SIZE(aliq, /DIM)
    acfc = FLTARR(dims[0],dims[1])
    acfc[*,*] = 1.

    i1=WHERE( aliq GT 100.,ni1)
    IF (ni1 GT 0) THEN aliq[i1] = 100.
    i2=WHERE( aice GT 100.,ni2)
    IF (ni2 GT 0) THEN aice[i2] = 100.

    i1=WHERE( aliq EQ 0.,ni1)
    IF (ni1 GT 0) THEN aliq[i1] = -999.
    i2=WHERE( aice EQ 0.,ni2)
    IF (ni2 GT 0) THEN aice[i2] = -999.

    ; -- hist1d_cot
    res = SUMUP_HIST1D( bin_dim=histo.cot_bin1d_dim, $
                        cph_dim=histo.phase_dim, $
                        lim_bin=histo.cot2d, $
                        liq_tmp=aliq, $
                        ice_tmp=aice, $
                        cfc_tmp=acfc )

    bild_all = total(res, 4)
    bild_liq = reform(res[*,*,*,0])
    bild_ice = reform(res[*,*,*,1])

    !P.Background = cgColor('white')
    !P.Color = cgColor('black')
    !P.MULTI = [0,2,2]
    theSize = Get_Screen_Size()
    WINDOW, 1, XSIZE=theSize[0], YSIZE=theSize[1]
    cs = 2.5
    black = cgcolor('black')

    MAP_IMAGE, aliq, grd.lat2d, grd.lon2d, $
        /RAINBOW, /BOX_AXES, /MAGNIFY, /GRID, $
        MINI=0., MAXI=100., CHARSIZE=cs, $
        TITLE='cot_lay_inc.LIQ', n_lev=5

    MAP_IMAGE, aice, grd.lat2d, grd.lon2d, $
        /RAINBOW, /BOX_AXES, /MAGNIFY, /GRID, $
        MINI=0., MAXI=100., CHARSIZE=cs, $
        TITLE='cot_lay_inc.ICE', n_lev=5

    ;cgHistoplot, aliq, binsize=1, /FILL, POLYCOLOR='red', $
    ;    mininput=0, maxinput=100., charsize=cs, $
    ;    xtitle='cot_lay_inc.liq', histdata=cghist_liq
    ;cgHistoplot, aice, binsize=1, /FILL, POLYCOLOR='royal blue', $
    ;    mininput=0, maxinput=100., charsize=cs, $
    ;    xtitle='cot_lay_inc.ice', histdata=cghist_ice
    
    hist_liq = HISTOGRAM(aliq, binsize=1, min=0., max=100.)
    bins_liq = FINDGEN(N_ELEMENTS(hist_liq))+MIN(aliq[WHERE(aliq NE -999.)])
    hist_ice = HISTOGRAM(aice, binsize=1, min=0., max=100.)
    bins_ice = FINDGEN(N_ELEMENTS(hist_ice))+MIN(aice[WHERE(aice NE -999.)])
    
    cgPlot, bins_liq, hist_liq, psym=1, color='red', $
        charsize=cs, ytickformat = '(I)', yrange=[0, 20000], $
        xtitle='Bin Number', ytitle='Density per Bin'
    cgPlot, bins_ice, hist_ice, psym=2, color='royal blue', $
        charsize=cs, /overplot
    xyouts, 90, 17000, 'BINSIZE=1', color=cgcolor('Black'), chars=cs
    xyouts, 6, 17000, 'cot_lay_liq', color=cgcolor('Red'), chars=cs
    xyouts, 6, 14000, 'cot_lay_ice', color=cgcolor('royal blue'), chars=cs
    
    
    bild1 = get_1d_rel_hist_from_1d_hist( bild_liq, $
        'hist1d_cot_liq', algo='era-i', limit=limit, $
        land=land, sea=sea, arctic=arctic, antarctic=antarctic,$ 
        xtickname=xtickname, ytitle = ytitle, hist_name=data_name, $
        found=found1)
    bild2 = get_1d_rel_hist_from_1d_hist( bild_ice, $
        'hist1d_cot_ice', algo='era-i', limit=limit, $
        land=land, sea=sea, arctic=arctic, antarctic=antarctic,$ 
        xtickname=xtickname, ytitle = ytitle, hist_name=data_name, $
        found=found1)
    plot,[0,0],[1,1],yr=[0,40],xr=[0,n_elements(bild1)-1],$
        xticks=n_elements(xtickname)-1,xtickname=xtickname, $ 
        xtitle=data_name,ytitle=ytitle,xminor=2, charsize=cs, $
        col=cgcolor('black')

    oplot,bild1,thick=thick,psym=-8,col=cgcolor('Red')
    oplot,bild2,thick=thick,psym=-8,col=cgcolor('royal blue')
    xyouts, .3, 35, 'cot_lay_liq', color=cgcolor('Red'), chars=cs
    xyouts, .3, 30, 'cot_lay_ice', color=cgcolor('royal blue'), chars=cs

    ofil = path + 'cot_lay_inc.png'
    WRITE_PNG, ofil, TVRD(/TRUE)
    PRINT, 'File written to ', ofil
    !P.MULTI = 0

END



PRO PLOT_REFF_T_DEPENDENCY, T, RTT, ZRAD, ZRAD2, path

    !P.MULTI = [0,1,2]
    theSize = Get_Screen_Size()
    WINDOW, 3, XSIZE=theSize[0], YSIZE=theSize[1]

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

    ofil = path + 'Reff_ec-earth_ver2.png'
    WRITE_PNG, ofil, TVRD(/TRUE)
    PRINT, 'File written to ', ofil
    !P.MULTI = 0

END


PRO PLOT_SOLAR_COT_CWP, tmp, grd, pwd, fil, void

    !P.MULTI = [0,2,2]

    base = FSC_Base_Filename(fil)
    ofil = pwd + base + '_solar_cot_cwp.png'

    theSize = Get_Screen_Size()
    WINDOW, 4, XSIZE=theSize[0], YSIZE=theSize[1]
    
    MAP_IMAGE, tmp.lwp_bin, grd.lat2d, grd.lon2d, $
        /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=3., $
        MINI=0., MAXI=1., VOID_INDEX=void, /RAINBOW, $
        TITLE='lwp_bin [kg/m^2]'

    MAP_IMAGE, tmp.iwp_bin, grd.lat2d, grd.lon2d, $
        /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=3., $
        MINI=0., MAXI=1., VOID_INDEX=void, /RAINBOW, $
        TITLE='iwp_bin [kg/m^2]'

    MAP_IMAGE, tmp.cot_liq_bin, grd.lat2d, grd.lon2d, $
        /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=3., $
        MINI=0., MAXI=100., VOID_INDEX=void, /RAINBOW, $
        TITLE='cot_liq_bin '

    MAP_IMAGE, tmp.cot_ice_bin, grd.lat2d, grd.lon2d, $
        /BOX_AXES, /MAGNIFY, /GRID, CHARSIZE=3., $
        MINI=0., MAXI=100., VOID_INDEX=void, /RAINBOW, $
        TITLE='cot_ice_bin'

    WRITE_PNG, ofil, TVRD(/TRUE)
    PRINT, 'File written to ', ofil

    !P.MULTI = 0

END
