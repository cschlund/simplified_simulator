
PRO ICE_REFF_T, T, ZRAD, ZRAD2

    T = FINDGEN(350-200+1)+200.
    ZT = FLTARR(SIZE(T, /DIM))
    ZRAD = ZT 
    RTICE = 250.
    RTT = 273.16
    ZRefDe = 0.64952

    FOR i = 0, 49 DO BEGIN
        ZT(i) = T(i) - RTT
    ENDFOR
    FOR i = 50, N_ELEMENTS(ZT)-1 DO BEGIN
        ZT(i) = RTICE - RTT
    ENDFOR

    ZRAD = 326.3 + ZT*( 12.42 + ZT*(0.197 + ZT*0.0012) )
    ZRAD = ZRAD * ZRefDe
    ZRAD2 = ZRAD;
    wo1 = WHERE(ZRAD2 GT 60, nwo1)
    wo2 = WHERE(ZRAD2 LT 30, nwo2)
    ZRAD2[wo1] = 60.
    ZRAD2[wo2] = 30.

    PLOT_REFF_T_DEPENDENCY, T, RTT, ZRAD, ZRAD2

END
