;-----------------------------------------------------------------------------
PRO SCALE_COT_CWP, data, grd
;-----------------------------------------------------------------------------

    maxcot = 100.
    scale_liq = FLTARR(grd.XDIM,grd.YDIM) & scale_liq[*,*] = 1.
    scale_ice = FLTARR(grd.XDIM,grd.YDIM) & scale_ice[*,*] = 1.

    liq = WHERE( data.COT_LIQ GT maxcot, nliq )
    ice = WHERE( data.COT_ICE GT maxcot, nice )

    IF ( nliq GT 0 ) THEN BEGIN
        scale_liq[liq]   = maxcot / data.COT_LIQ[liq]
        data.LWP[liq]     = data.LWP[liq] * scale_liq[liq]
        data.COT_LIQ[liq] = data.COT_LIQ[liq] * scale_liq[liq]
    ENDIF

    IF ( nice GT 0 ) THEN BEGIN
        scale_ice[ice]   = maxcot / data.COT_ICE[ice]
        data.IWP[ice]     = data.IWP[ice] * scale_ice[ice]
        data.COT_ICE[ice] = data.COT_ICE[ice] * scale_ice[ice]
    ENDIF

END


;-----------------------------------------------------------------------------
PRO SOLAR_VARS, data, sza, grd, FLAG=flag, FILE=fil, MAP=map, SCOPS=type
;-----------------------------------------------------------------------------

    night = WHERE( sza GE 80., nnight, COMPLEMENT=day, NCOMPLEMENT=nday)

    IF ( nnight GT 0 ) THEN BEGIN

        data.LWP[night] = 0.
        data.IWP[night] = 0.
        data.COT_LIQ[night] = 0.
        data.COT_ICE[night] = 0.
        data.CER_LIQ[night] = 0.
        data.CER_ICE[night] = 0.

    ENDIF

    IF KEYWORD_SET(map) AND KEYWORD_SET(fil) AND KEYWORD_SET(flag) THEN $ 
        PLOT_SOLAR_VARS, DATA=data, GRID=grd, FLAG=flag, $
                         FILE=fil, VOID=night, SCOPS=type

END


;-----------------------------------------------------------------------------
FUNCTION GET_DATE_UTC, basename
;-----------------------------------------------------------------------------
    splt = STRSPLIT(basename, /EXTRACT, '_')
    time = STRSPLIT(splt[4],/EXTRACT,'+')
    hour = FIX(time[0])
    yyyy = FIX(STRMID(splt[3],0,4))
    mm = FIX(STRMID(splt[3],4,2))
    dd = FIX(STRMID(splt[3],6,2))
    date_utc = ' for '+splt[3]+' UTC '+splt[4]
    RETURN, date_utc
END


;-----------------------------------------------------------------------------
PRO SPLIT_ERA_FILENAME, FILE=file, BASE=basename, DIR=dir, EXT=ext, $
    YEAR=year, MONTH=month, DAY=day, HOUR=hour, UTC=utc
;-----------------------------------------------------------------------------
    basename = FSC_Base_Filename(file, DIR=dir, EXT=ext)
    splt = STRSPLIT(basename, /EXTRACT, '_')
    time = STRSPLIT(splt[4],/EXTRACT,'+')
    hour = time[0]
    year = STRMID(splt[3],0,4)
    month = STRMID(splt[3],4,2)
    day = STRMID(splt[3],6,2)
    utc = splt[4]
END


;------------------------------------------------------------------------------
FUNCTION SUMUP_HIST1D, bin_dim=bin1d_dim, cph_dim=phase_dim, lim_bin=bbins, $
                       var_tmp=var, liq_tmp=liq, ice_tmp=ice, cfc_tmp=cfc, $
                       cph_tmp=phase
;------------------------------------------------------------------------------
; -- NOTE --
; simulator -> 0=ice,    1=liquid
; cc4cl     -> 0=liquid, 1=ice
;------------------------------------------------------------------------------

    IF KEYWORD_SET(liq) AND KEYWORD_SET(ice)  $
        AND ~KEYWORD_SET(phase) THEN BEGIN 

        dims = SIZE(liq, /DIM)

    ENDIF ELSE IF KEYWORD_SET(var) $
        AND KEYWORD_SET(phase) THEN BEGIN

        dims = SIZE(var, /DIM)

    ENDIF

    ; counts [lon,lat]
    cnts = LONARR(dims[0],dims[1])
    cnts[*,*] = 0l 

    ; hist1d [lon,lat,bins,phase] = [720,361,15,2]
    vmean = LONARR(dims[0],dims[1],bin1d_dim,phase_dim) 
    vmean[*,*,*,*] = 0l

    ; last bin
    gu_last = bin1d_dim-1

    FOR gu=0, gu_last DO BEGIN 

        ; consider also last bin-border via GE & LE
        IF ( gu EQ gu_last ) THEN BEGIN

            IF KEYWORD_SET(liq) AND KEYWORD_SET(ice) $
                AND ~KEYWORD_SET(phase) THEN BEGIN

                wohi_ice = WHERE( ice GE bbins[0,gu] AND $ 
                                  ice LE bbins[1,gu] AND $
                                  cfc GT 0. , nwohi_ice )

                wohi_liq = WHERE( liq GE bbins[0,gu] AND $ 
                                  liq LE bbins[1,gu] AND $
                                  cfc GT 0. , nwohi_liq )


            ENDIF ELSE IF KEYWORD_SET(var) AND KEYWORD_SET(phase) THEN BEGIN

                wohi_ice = WHERE( var GE bbins[0,gu] AND $ 
                                  var LE bbins[1,gu] AND $
                                  cfc EQ 1. AND phase EQ 0., $
                                  nwohi_ice )

                wohi_liq = WHERE( var GE bbins[0,gu] AND $ 
                                  var LE bbins[1,gu] AND $
                                  cfc EQ 1. AND phase EQ 1., $
                                  nwohi_liq )

            ENDIF

        ; between GE & LT
        ENDIF ELSE BEGIN

            IF KEYWORD_SET(liq) AND KEYWORD_SET(ice) $
                AND ~KEYWORD_SET(phase) THEN BEGIN

                wohi_ice = WHERE( ice GE bbins[0,gu] AND $ 
                                  ice LT bbins[1,gu] AND $
                                  ice GT 0. AND $
                                  cfc GT 0. , nwohi_ice )

                wohi_liq = WHERE( liq GE bbins[0,gu] AND $ 
                                  liq LT bbins[1,gu] AND $
                                  liq GT 0. AND $
                                  cfc GT 0. , nwohi_liq )


            ENDIF ELSE IF KEYWORD_SET(var) AND KEYWORD_SET(phase) THEN BEGIN
                
                wohi_ice = WHERE( var GE bbins[0,gu] AND $ 
                                  var LT bbins[1,gu] AND $
                                  var GT 0. AND $
                                  cfc EQ 1. AND phase EQ 0., $
                                  nwohi_ice )

                wohi_liq = WHERE( var GE bbins[0,gu] AND $ 
                                  var LT bbins[1,gu] AND $
                                  var GT 0. AND $
                                  cfc EQ 1. AND phase EQ 1., $
                                  nwohi_liq )

            ENDIF

        ENDELSE


        IF ( nwohi_ice GT 0 ) THEN BEGIN
            cnts[wohi_ice] = 1l
            vmean[*,*,gu,1] = vmean[*,*,gu,1] + cnts
            cnts[*,*] = 0l 
        ENDIF


        IF ( nwohi_liq GT 0 ) THEN BEGIN
            cnts[wohi_liq] = 1l
            vmean[*,*,gu,0] = vmean[*,*,gu,0] + cnts
            cnts[*,*] = 0l 
        ENDIF


    ENDFOR

    RETURN, vmean

END


;------------------------------------------------------------------------------
FUNCTION SUMUP_HIST2D, hist, cot, ctp, cfc, cph
;------------------------------------------------------------------------------
; sum up 2d histograms: 
; -- NOTE --
; simulator -> 0=ice,    1=liquid
; cc4cl     -> 0=liquid, 1=ice
;------------------------------------------------------------------------------

    dims = SIZE(cot, /DIM)

    ; counts [lon,lat]
    cnts = LONARR(dims[0],dims[1])
    cnts[*,*] = 0l 

    ; hist2d [lon,lat,cotbins,ctpbins,phase] = [720,361,13,15,2]
    vmean = LONARR(dims[0], dims[1], hist.cot_bin1d_dim, $
                   hist.ctp_bin1d_dim, hist.phase_dim) 
    vmean[*,*,*,*] = 0l

    ; last bins
    ctp_last = hist.ctp_bin1d_dim-1
    cot_last = hist.cot_bin1d_dim-1

    FOR ictp=0, ctp_last DO BEGIN 
        FOR jcot=0, cot_last DO BEGIN

            ; consider also last COT & CTP bin-border via GE & LE
            IF ( jcot EQ cot_last AND ictp EQ ctp_last) THEN BEGIN

                wohi_ice = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LE hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LE hist.ctp2d[1,ictp] AND $
                                  cfc EQ 1. AND cph EQ 0., nwohi_ice )

                wohi_liq = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LE hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LE hist.ctp2d[1,ictp] AND $
                                  cfc EQ 1. AND cph EQ 1., nwohi_liq )


            ; consider also last COT bin-border via GE & LE
            ENDIF ELSE IF ( jcot EQ cot_last ) THEN BEGIN

                wohi_ice = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LE hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LT hist.ctp2d[1,ictp] AND $
                                  cfc EQ 1. AND cph EQ 0., nwohi_ice )

                wohi_liq = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LE hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LT hist.ctp2d[1,ictp] AND $
                                  cfc EQ 1. AND cph EQ 1., nwohi_liq )


            ; consider also last CTP bin-border via GE & LE
            ENDIF ELSE IF ( ictp EQ ctp_last) THEN BEGIN


                wohi_ice = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LT hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LE hist.ctp2d[1,ictp] AND $
                                  cfc EQ 1. AND cph EQ 0., nwohi_ice )

                wohi_liq = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LT hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LE hist.ctp2d[1,ictp] AND $
                                  cfc EQ 1. AND cph EQ 1., nwohi_liq )


            ; between GE & LT
            ENDIF ELSE BEGIN

                wohi_ice = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LT hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LT hist.ctp2d[1,ictp] AND $
                                  cot GT 0. AND ctp GT 0. AND $
                                  cfc EQ 1. AND cph EQ 0., nwohi_ice )

                wohi_liq = WHERE( cot GE hist.cot2d[0,jcot] AND $ 
                                  cot LT hist.cot2d[1,jcot] AND $
                                  ctp GE hist.ctp2d[0,ictp] AND $
                                  ctp LT hist.ctp2d[1,ictp] AND $
                                  cot GT 0. AND ctp GT 0. AND $
                                  cfc EQ 1. AND cph EQ 1., nwohi_liq )

            ENDELSE

            ; hist2d [lon,lat,cotbins,ctpbins,phase] = [720,361,13,15,2]

            IF ( nwohi_ice GT 0 ) THEN BEGIN
                cnts[wohi_ice] = 1l
                vmean[*,*,jcot,ictp,1] = vmean[*,*,jcot,ictp,1] + cnts
                cnts[*,*] = 0l 
            ENDIF

            IF ( nwohi_liq GT 0 ) THEN BEGIN
                cnts[wohi_liq] = 1l
                vmean[*,*,jcot,ictp,0] = vmean[*,*,jcot,ictp,0] + cnts
                cnts[*,*] = 0l 
            ENDIF

        ENDFOR
    ENDFOR

    RETURN, vmean

END


;-----------------------------------------------------------------------------
PRO PLOT_ERA_SST, FILENAME=filename, DATA=sst, $
                  LATITUDE=lat, LONGITUDE=lon, VOID=void_index
;-----------------------------------------------------------------------------
    !EXCEPT=0

    filepwd = !SAVE_DIR + filename

    IF ( is_file(filepwd+'.png') ) THEN RETURN

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


;-----------------------------------------------------------------------------
PRO PLOT_LSM2D, FILENAME=filename, DATA=lsm, $
                LATITUDE=lat, LONGITUDE=lon, TITLE=title
;-----------------------------------------------------------------------------
    !EXCEPT=0

    filepwd = !SAVE_DIR + filename

    IF ( is_file(filepwd+'.png') ) THEN RETURN

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


;-----------------------------------------------------------------------------
PRO PLOT_SZA2D, FILENAME=filename, DATA=sza2d, $
                LATITUDE=lat, LONGITUDE=lon, TITLE=title
;-----------------------------------------------------------------------------
    !EXCEPT=0

    filepwd = !SAVE_DIR + filename + '_sza'

    IF ( is_file(filepwd+'.png') ) THEN RETURN

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


;-----------------------------------------------------------------------------
PRO PLOT_HISTOS_1D, data, filename, flag, scops_type, $
                    CONSTANT_CER=creff, RATIO=ratio
;-----------------------------------------------------------------------------

    !P.MULTI = [0,2,2]

    IF KEYWORD_SET(creff) THEN addstr = '_fixed_reffs' ELSE addstr = ''
    IF (scops_type EQ 1) THEN st = 'random' ELSE st='max/random'

    ststr = STRTRIM(STRING(scops_type),2)
    basen = FSC_Base_Filename(filename)
    obase = !SAVE_DIR + basen + '_' + flag + '_scops' + ststr
    ofil = obase + '_tmpHISTOS1D'+addstr

    IF (is_file(ofil+'.png')) THEN RETURN

    IF (filename.EndsWith('.nc') EQ 1) THEN BEGIN
        datutc = GET_DATE_UTC(basen)
    ENDIF ELSE BEGIN
        datutc = ' for '+STRMID(basen, STRLEN(basen)-6, 6)
    ENDELSE

    ; start plotting
    save_as = ofil + '.eps'
    start_save, save_as, size=[45,30]
    cs = 2.0

    CREATE_1DHIST, RESULT=data.HIST1D_CTP, VARNAME='ctp', $
        VARSTRING='H1D_CTP', CHARSIZE=cs, XTITLE=datutc, $
        YMAX=40, LEGEND_POSITION='top', RATIO=ratio

    CREATE_1DHIST, RESULT=data.HIST1D_CWP, VARNAME='cwp', $
        VARSTRING='H1D_CWP', CHARSIZE=cs, XTITLE=datutc, $
        YMAX=40, RATIO=ratio, LEGEND_POSITION='tr'

    CREATE_1DHIST, RESULT=data.HIST1D_CER, VARNAME='ref', $
        VARSTRING='H1D_CER', CHARSIZE=cs, XTITLE=datutc, $
        YMAX=60, LEGEND_POSITION='tr', RATIO=ratio

    CREATE_1DHIST, RESULT=data.HIST1D_COT, VARNAME='cot', $
        VARSTRING='H1D_COT', CHARSIZE=cs, XTITLE=datutc, $
        YMAX=40, RATIO=ratio

    cgText, 0.52, 0.49, Alignment=0.5, /Normal, 'SCOPS.type='+st, chars=cs

    ; end plotting
    end_save, save_as
    cs_eps2png, save_as

    !P.MULTI = 0

END


;-----------------------------------------------------------------------------
PRO PLOT_INTER_HISTOS, data, varname, histo, filename, flag, scops_type, $
                       CONSTANT_CER=creff, RATIO=ratio
;-----------------------------------------------------------------------------

    !P.MULTI = [0,2,2]

    IF KEYWORD_SET(creff) THEN addstr = '_fixed_reffs' ELSE addstr = ''
    IF KEYWORD_SET(ratio) THEN addstr = addstr + '_ratio'
    IF (scops_type EQ 1) THEN st = 'random' ELSE st='max/random'

    ststr = STRTRIM(STRING(scops_type),2)
    basen = FSC_Base_Filename(filename)
    obase = !SAVE_DIR + basen + '_' + flag + '_scops' + ststr
    sname = SIZE(data, /SNAME)
    cph_dim = histo.PHASE_DIM
    ofil = obase + '_'+varname+'2Dtmp'+addstr

    IF(is_file(ofil+'.png')) THEN RETURN

    astr = ' (2D - upper most clouds; CFC==1) '
    varstring = 'temps'

    ; collect data and hist settings
    GET_ALIQ_AICE, data, sname, varname, aliq, aice

    GET_HIST_DETAILS, histo, varname, maxvalue, minvalue, $
                      bin_dim, lim_bin, cci_str, ymax, legpos, binsize

    datutc = GET_DATE_UTC(basen)

    ; start plotting
    save_as = ofil + '.eps'
    start_save, save_as, size=[45,30]
    cs = 2.0
    lg = 'tr'

    ; get total COT and set CFC
    all  = (aliq>0) + (aice>0) ; consider fill_values
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


    ; -- HIST1D: equal binsizes ---
    cgHistoplot, aliq, binsize=binsize, /FILL, $
        POLYCOLOR='red', mininput=minvalue, maxinput=maxvalue, $
        charsize=cs, histdata=cghist_liq, $
        xtitle=varstring+'.'+STRUPCASE(varname)+'_LIQ'+astr
    legend, ['binsize='+STRTRIM(STRING(binsize,FORMAT='(I)'),2)], $
        thick=4., spos=lg, charsize=cs, color=[cgcolor("red")]

    cgHistoplot, aice, binsize=binsize, /FILL, $
        POLYCOLOR='royal blue', histdata=cghist_ice, $
        mininput=minvalue, maxinput=maxvalue, charsize=cs, $
        xtitle=varstring+'.'+STRUPCASE(varname)+'_ICE'+astr
    legend, ['binsize='+STRTRIM(STRING(binsize,FORMAT='(I)'),2)], $
        thick=4., spos=lg, charsize=cs, color=[cgcolor("royal blue")]

    cgHistoplot, all, binsize=binsize, /FILL, $
        POLYCOLOR='black', histdata=cghist_all, $
        mininput=minvalue, maxinput=maxvalue, charsize=cs, $
        xtitle=varstring+'.'+STRUPCASE(varname)+astr
    legend, ['binsize='+STRTRIM(STRING(binsize,FORMAT='(I)'),2)], $
        thick=4., spos=lg, charsize=cs, color=[cgcolor("black")]
    
    ; -- HIST1D: cloud_cci binsizes ---
    res = SUMUP_HIST1D( bin_dim=bin_dim, lim_bin=lim_bin, $
                        cph_dim=cph_dim, cfc_tmp=acfc, $
                        liq_tmp=aliq,    ice_tmp=aice )

    CREATE_1DHIST, RESULT=res, VARNAME=cci_str, YMAX=ymax, $
        VARSTRING=varstring, CHARSIZE=cs, XTITLE=datutc, $
        LEGEND_POSITION=legpos, RATIO=ratio

    cgText, 0.52, 0.49, Alignment=0.5, /Normal, 'SCOPS.type='+st, chars=cs

    ; end plotting
    end_save, save_as
    cs_eps2png, save_as

    !P.MULTI = 0

END


;-----------------------------------------------------------------------------
PRO PLOT_SOLAR_VARS, DATA=data, GRID=grd, FLAG=flg, FILE=fil, VOID=void,$
                     SCOPS=type
;-----------------------------------------------------------------------------
    !EXCEPT=0

    !P.MULTI = [0,2,3]

    ststr = STRTRIM(STRING(type),2)
    base = FSC_Base_Filename(fil)
    filepwd = !SAVE_DIR + base + '_' + flg + '_scops'+ ststr + '_daytime'

    IF ( is_file(filepwd+'.png') ) THEN RETURN

    save_as = filepwd + '.eps'
    start_save, save_as, size='A4', /LANDSCAPE

    cs = 1.5 & cs_bar = 2 & nlev = 6
    limit = [-90., -180., 90., 180.]
    
    MAP_IMAGE, data.LWP*1000., grd.LAT2D, grd.LON2D, $
        /MAGNIFY, CHARS=cs_bar, FORMAT=('(f8.1)'), N_LEV=nlev, $
        MINI=MIN(data.LWP*1000.), MAXI=MAX(data.LWP*1000.), $
        VOID_INDEX=void, /RAINBOW, LIMIT=limit, TITLE='LWP [g/m2]'
    MAP_GRID, COLOR=cgcolor('Black'), MLINETHICK=2.2, /BOX_AXES, CHARS=cs

    MAP_IMAGE, data.IWP*1000., grd.LAT2D, grd.LON2D, $
        /MAGNIFY, CHARS=cs_bar, FORMAT=('(f8.1)'), N_LEV=nlev, $
        MINI=MIN(data.IWP*1000.), MAXI=MAX(data.IWP*1000.), $
        VOID_INDEX=void, /RAINBOW, LIMIT=limit, TITLE='IWP [g/m2]'
    MAP_GRID, COLOR=cgcolor('Black'), MLINETHICK=2.2, /BOX_AXES, CHARS=cs

    MAP_IMAGE, data.CER_LIQ, grd.LAT2D, grd.LON2D, $
        /MAGNIFY, CHARS=cs_bar, TITLE='CER_LIQ [microns]', $
        MINI=MIN(data.CER_LIQ), MAXI=MAX(data.CER_LIQ), $
        VOID_INDEX=void, /RAINBOW, N_LEV=nlev, LIMIT=limit
    MAP_GRID, COLOR=cgcolor('Black'), MLINETHICK=2.2, /BOX_AXES, CHARS=cs

    MAP_IMAGE, data.CER_ICE, grd.LAT2D, grd.LON2D, $
        /MAGNIFY, CHARS=cs_bar, TITLE='CER_ICE [microns]', $
        MINI=MIN(data.CER_ICE), MAXI=MAX(data.CER_ICE), $
        VOID_INDEX=void, /RAINBOW, N_LEV=nlev, LIMIT=limit
    MAP_GRID, COLOR=cgcolor('Black'), MLINETHICK=2.2, /BOX_AXES, CHARS=cs

    MAP_IMAGE, data.COT_LIQ, grd.LAT2D, grd.LON2D, $
        /MAGNIFY, CHARS=cs_bar, TITLE='COT_LIQ', $
        MINI=0., MAXI=30., $
        ;MINI=MIN(data.COT_LIQ), MAXI=MAX(data.COT_LIQ), $
        VOID_INDEX=void, /RAINBOW, N_LEV=nlev, LIMIT=limit
    MAP_GRID, COLOR=cgcolor('Black'), MLINETHICK=2.2, /BOX_AXES, CHARS=cs

    MAP_IMAGE, data.COT_ICE, grd.LAT2D, grd.LON2D, $
        /MAGNIFY, CHARS=cs_bar, TITLE='COT_ICE', $
        MINI=0., MAXI=60., $
        ;MINI=MIN(data.COT_ICE), MAXI=MAX(data.COT_ICE), $
        VOID_INDEX=void, /RAINBOW, N_LEV=nlev, LIMIT=limit
    MAP_GRID, COLOR=cgcolor('Black'), MLINETHICK=2.2, /BOX_AXES, CHARS=cs

    end_save, save_as
    cs_eps2png, save_as

    !P.MULTI = 0
END


;-----------------------------------------------------------------------------
PRO CREATE_1DHIST, RESULT=res, VARNAME=vn, VARSTRING=vs, $
                   CHARSIZE=cs, XTITLE=xtitle, YMAX=ymax, $
                   LEGEND_POSITION=lp, RATIO=ratio
;-----------------------------------------------------------------------------
    IF NOT KEYWORD_SET(ymax) THEN ymax = 40
    IF NOT KEYWORD_SET(lp) THEN lp='tl'
    IF KEYWORD_SET(ratio) THEN ymax = 100

    bild_liq = reform(res[*,*,*,0])
    bild_ice = reform(res[*,*,*,1])
    bild_all = ( bild_liq>0 ) + ( bild_ice>0 ) ;consider fill_values!

    bild = get_1d_rel_hist_from_1d_hist( bild_all, $
        'hist1d_'+vn, algo='era-i',  $
        land=land, sea=sea, arctic=arctic, antarctic=antarctic,$ 
        xtickname=xtickname, ytitle = ytitle, hist_name=data_name, $
        found=found1)

    bild1 = get_1d_rel_hist_from_1d_hist( bild_liq, $
        'hist1d_'+vn+'_liq', algo='era-i', $
        land=land, sea=sea, arctic=arctic, antarctic=antarctic,$ 
        xtickname=xtickname, ytitle = ytitle, hist_name=data_name, $
        found=found1)

    bild2 = get_1d_rel_hist_from_1d_hist( bild_ice, $
        'hist1d_'+vn+'_ice', algo='era-i', $
        land=land, sea=sea, arctic=arctic, antarctic=antarctic,$ 
        xtickname=xtickname, ytitle = ytitle, hist_name=data_name, $
        found=found1)

    IF KEYWORD_SET(ratio) THEN BEGIN
        bild3 = get_1d_rel_hist_from_1d_hist( res, $
            'hist1d_'+vn+'_ratio', algo='era-i', $
            land=land, sea=sea, arctic=arctic, antarctic=antarctic,$ 
            xtickname=xtickname, ytitle = ytitle, hist_name=data_name, $
            found=found1)
    ENDIF

    plot,[0,0],[1,1],yr=[0,ymax],xr=[0,n_elements(bild)-1],$
        xticks=n_elements(xtickname)-1,xtickname=xtickname, $ 
        xtitle=data_name+xtitle,ytitle=ytitle,xminor=2, $
        charsize=cs, col=cgcolor('black')

    lsty = 0
    thick = 4
    oplot,bild, psym=-1, col=cgcolor('Black'), THICK=thick
    oplot,bild1,psym=-2, col=cgcolor('Red'), THICK=thick
    oplot,bild2,psym=-4, col=cgcolor('royal blue'), THICK=thick
    IF KEYWORD_SET(ratio) THEN $
        oplot,bild3,psym=-6, col=cgcolor('forest green'), THICK=thick

    allstr  = vs
    aliqstr = vs+'.LIQ'
    aicestr = vs+'.ICE'
    ratiostr = vs+'.RATIO'
    labels = [allstr,aliqstr,aicestr]
    IF KEYWORD_SET(ratio) THEN labels = [labels, ratiostr]
    colors = [cgcolor("Black"),cgcolor("Red"),cgcolor("royal blue")]
    IF KEYWORD_SET(ratio) THEN colors = [colors, cgcolor("forest green")]
    nlabels = N_ELEMENTS(labels)

    legend, labels, thick=REPLICATE(thick,nlabels), spos=lp, $
            charsize=cs, color=colors

END


;-----------------------------------------------------------------------------
PRO GET_ALIQ_AICE, data, sname, varname, aliq, aice
;-----------------------------------------------------------------------------

    CASE sname of

        'TEMP_ARRAYS' : BEGIN

            IF (varname EQ 'cot') THEN BEGIN 
                aliq = data.COT_LIQ 
                aice = data.COT_ICE 

            ENDIF ELSE IF (varname EQ 'cer') THEN BEGIN 
                aliq = data.CER_LIQ 
                aice = data.CER_ICE 

            ENDIF ELSE IF (varname EQ 'cwp') THEN BEGIN 
                aliq = data.LWP*1000. ;g/m2
                aice = data.IWP*1000. ;g/m2

            ENDIF ELSE IF (varname EQ 'ctp') THEN BEGIN 
                dims = SIZE(data.CPH, /DIM)
                aliq = FLTARR(dims[0],dims[1]) & aliq[*,*] = -999
                aice = FLTARR(dims[0],dims[1]) & aice[*,*] = -999
                ice = WHERE((data.CTP GT 10.) AND (data.CTH GT 0.)  $
                        AND (data.CPH EQ 0))
                liq = WHERE((data.CTP GT 10.) AND (data.CTH GT 0.)  $
                        AND (data.CPH EQ 1))
                aliq[liq] = data.CTP[liq] 
                aice[ice] = data.CTP[ice]

            ENDIF ELSE IF (varname EQ 'ctt') THEN BEGIN 
                dims = SIZE(data.CPH, /DIM)
                aliq = FLTARR(dims[0],dims[1]) & aliq[*,*] = -999
                aice = FLTARR(dims[0],dims[1]) & aice[*,*] = -999
                ice = WHERE((data.CTP GT 10.) AND (data.CTH GT 0.)  $
                        AND (data.CPH EQ 0))
                liq = WHERE((data.CTP GT 10.) AND (data.CTH GT 0.)  $
                        AND (data.CPH EQ 1))
                aliq[liq] = data.CTT[liq] 
                aice[ice] = data.CTT[ice]

            ENDIF ELSE BEGIN
                PRINT, 'VARNAME not yet defined here.'
                RETURN 

            ENDELSE
            END

        ELSE : BEGIN
            PRINT, 'SNAME has an illegal value. Must be TEMP_ARRAYS!'
            RETURN 
            END

    ENDCASE

END


;-----------------------------------------------------------------------------
PRO GET_HIST_DETAILS, histo, varname, $
                      maxvalue, minvalue, bin_dim, lim_bin, $
                      cci_str, ymax, legpos, binsize
;-----------------------------------------------------------------------------

    CASE varname of
        'ctt' : BEGIN
            maxvalue = 350.
            minvalue = 200.
            bin_dim = histo.CTT_BIN1D_DIM
            lim_bin = histo.CTT2D
            cci_str = 'ctt'
            ymax = 40
            legpos = "tl" 
            binsize = 5
            END
        'ctp' : BEGIN
            maxvalue = 1100.
            minvalue = 1.
            bin_dim = histo.CTP_BIN1D_DIM
            lim_bin = histo.CTP2D
            cci_str = 'ctp'
            ymax = 40
            legpos = "top"
            binsize = 50
            END
        'cwp' : BEGIN
            maxvalue = 2000.
            minvalue = 0.0001
            bin_dim = histo.CWP_BIN1D_DIM
            lim_bin = histo.CWP2D
            cci_str = 'cwp'
            ymax = 40
            legpos = "tl"
            binsize = 50
            END
        'cot' : BEGIN
            maxvalue = 100.
            minvalue = 0.0001
            bin_dim = histo.COT_BIN1D_DIM
            lim_bin = histo.COT2D
            cci_str = 'cot'
            ymax = 40
            legpos = "tl"
            binsize = 1
            END
        'cer' : BEGIN
            maxvalue = 80.
            minvalue = 0.0001
            bin_dim = histo.CER_BIN1D_DIM
            lim_bin = histo.CER2D
            cci_str = 'ref'
            ymax = 60
            legpos = "tr" 
            binsize = 1
            END
    ENDCASE

END
