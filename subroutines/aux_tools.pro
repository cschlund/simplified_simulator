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
PRO SOLAR_VARS, data, sza, grd, FLAG=flag, FILE=fil, MAP=map
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
                         FILE=fil, VOID=night

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
PRO PLOT_HISTOS_1D, FINAL=final,  HIST_INFO=histo, OFILE=fil, $
                    FLAG=flg, CONSTANT_CER=creff
;-----------------------------------------------------------------------------

    !P.MULTI = [0,2,2]

    IF KEYWORD_SET(creff) THEN addstr = '_fixed_reffs' $
        ELSE addstr = ''

    basen = FSC_Base_Filename(fil)
    obase = !SAVE_DIR + basen + '_' + flg
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
    cs = 2.0

    ; -- final.HIST1D_COT: CCI binsizes ---
    CREATE_1DHIST, RESULT=final.HIST1D_CTP, VARNAME='ctp', $
        VARSTRING='H1D_CTP', CHARSIZE=cs, XTITLE=datutc, $
        YMAX=40, LEGEND_POSITION='top'

    CREATE_1DHIST, RESULT=final.HIST1D_CWP, VARNAME='cwp', $
        VARSTRING='H1D_CWP', CHARSIZE=cs, XTITLE=datutc, $
        YMAX=40

    CREATE_1DHIST, RESULT=final.HIST1D_CER, VARNAME='ref', $
        VARSTRING='H1D_CER', CHARSIZE=cs, XTITLE=datutc, $
        YMAX=60, LEGEND_POSITION='tr'

    CREATE_1DHIST, RESULT=final.HIST1D_COT, VARNAME='cot', $
        VARSTRING='H1D_COT', CHARSIZE=cs, XTITLE=datutc, $
        YMAX=40

    ; end plotting
    end_save, save_as
    cs_eps2png, save_as

    !P.MULTI = 0

END


;-----------------------------------------------------------------------------
PRO PLOT_INTER_HISTOS, INTER=inter, VARNAME=var, HIST_INFO=histo, $
                       OFILE=fil, FLAG=flg, CONSTANT_CER=creff
;-----------------------------------------------------------------------------

    !P.MULTI = [0,2,2]

    IF KEYWORD_SET(creff) THEN addstr = '_fixed_reffs' $
        ELSE addstr = ''

    basen = FSC_Base_Filename(fil)
    obase = !SAVE_DIR + basen + '_' + flg
    sname = SIZE(inter, /SNAME)
    cph_dim = histo.PHASE_DIM

    CASE var of
        'ctp' : BEGIN
            maxvalue = 1100.
            bin_dim = histo.CTP_BIN1D_DIM
            lim_bin = histo.CTP2D
            cci_str = 'ctp'
            ymax = 40
            legpos = "tr" ;top-left
            END
        'cwp' : BEGIN
            maxvalue = 10E5
            bin_dim = histo.CWP_BIN1D_DIM
            lim_bin = histo.CWP2D
            cci_str = 'cwp'
            ymax = 40
            legpos = "tl" ;top-left
            END
        'cot' : BEGIN
            maxvalue = 100.
            bin_dim = histo.COT_BIN1D_DIM
            lim_bin = histo.COT2D
            cci_str = 'cot'
            ymax = 40
            legpos = "tl" ;top-left
            END
        'cer' : BEGIN
            maxvalue = 80.
            bin_dim = histo.CER_BIN1D_DIM
            lim_bin = histo.CER2D
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
            ENDIF ELSE IF (var EQ 'cwp') THEN BEGIN 
                aliq = inter.LWP 
                aice = inter.IWP 
            ENDIF ELSE IF (var EQ 'ctp') THEN BEGIN 
                dims = SIZE(inter.CPH, /DIM)
                aliq = FLTARR(dims[0],dims[1]) & aliq[*,*] = -999
                aice = FLTARR(dims[0],dims[1]) & aice[*,*] = -999
                ; cc4cl -> 0=liquid, 1=ice
                liq = WHERE(inter.CPH EQ 1)
                ice = WHERE(inter.CPH EQ 0)
                aliq[liq] = inter.CTP[liq] 
                aice[ice] = inter.CTP[ice]
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


;-----------------------------------------------------------------------------
PRO PLOT_SOLAR_VARS, DATA=data, GRID=grd, FLAG=flg, FILE=fil, VOID=void
;-----------------------------------------------------------------------------
    !EXCEPT=0

    !P.MULTI = [0,2,3]

    base = FSC_Base_Filename(fil)
    filepwd = !SAVE_DIR + base + '_' + flg +'_daytime'

    IF ( is_file(filepwd+'.png') ) THEN RETURN

    save_as = filepwd + '.eps'
    start_save, save_as, size='A3', /LANDSCAPE

    cs = 2 & cs_bar = 3.5 & nlev = 6
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
        MINI=MIN(data.COT_LIQ), MAXI=MAX(data.COT_LIQ), $
        VOID_INDEX=void, /RAINBOW, N_LEV=nlev, LIMIT=limit
    MAP_GRID, COLOR=cgcolor('Black'), MLINETHICK=2.2, /BOX_AXES, CHARS=cs

    MAP_IMAGE, data.COT_ICE, grd.LAT2D, grd.LON2D, $
        /MAGNIFY, CHARS=cs_bar, TITLE='COT_ICE', $
        MINI=MIN(data.COT_ICE), MAXI=MAX(data.COT_ICE), $
        VOID_INDEX=void, /RAINBOW, N_LEV=nlev, LIMIT=limit
    MAP_GRID, COLOR=cgcolor('Black'), MLINETHICK=2.2, /BOX_AXES, CHARS=cs

    end_save, save_as
    cs_eps2png, save_as

    !P.MULTI = 0
END


;-----------------------------------------------------------------------------
PRO CREATE_1DHIST, RESULT=res, VARNAME=vn, VARSTRING=vs, $
                   CHARSIZE=cs, XTITLE=xtitle, YMAX=ymax, $
                   LEGEND_POSITION=lp
;-----------------------------------------------------------------------------
    IF NOT KEYWORD_SET(ymax) THEN ymax = 40
    IF NOT KEYWORD_SET(lp) THEN lp='tl'

    bild_liq = reform(res[*,*,*,0])
    bild_ice = reform(res[*,*,*,1])
    bild_all = ( bild_liq>0 ) + ( bild_ice>0 ) ;consider fill_values!

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

    allstr  = vs+'.TOTAL'
    aliqstr = vs+'.LIQ'
    aicestr = vs+'.ICE'

    legend, [allstr,aliqstr,aicestr], thick=REPLICATE(thick,3), $
        spos=lp, charsize=2.3, color=[cgcolor("Black"),$
        cgcolor("Red"),cgcolor("royal blue")]

END


