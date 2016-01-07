
; C. Schlundt, 2016-01-07
PRO CS_EPS2PNG, epsfile
    filbase = FSC_Base_Filename( epsfile, Directory=dir, Extension=ext )
    pngfile = dir + filbase + '.png'
    SPAWN, 'convert -density 300 ' + epsfile + $
           ' -resize 25% -flatten ' + pngfile
    PRINT, '** Image converted to: ' + pngfile
    SPAWN, 'rm -f ' + epsfile
    PRINT, '** Image removed: ', epsfile
END

