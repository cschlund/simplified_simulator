
; C. Schlundt, 2016-01-07
PRO CS_EPS2PNG, epsfile
    filbase = FSC_Base_Filename( epsfile, Directory=dir, Extension=ext )
    pngfile = dir + filbase + '.png'
    SPAWN, 'convert -density 300 ' + epsfile + $
           ' -resize 50% -flatten ' + pngfile + ' >/dev/null 2>&1 '
    PRINT, '** Image converted to: ' + pngfile
    SPAWN, 'rm -f ' + epsfile
    PRINT, '** Image removed: ', epsfile
END

