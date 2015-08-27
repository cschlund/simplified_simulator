;+
; NAME: CREATE_DIR
;
; PURPOSE: create directory
;
; CALLING SEQUENCE: result = create_dir(dir)
;
; INPUT:
;   dir : full qualified path
;
; OUTPUT: 0 if function failed, 1 if directory was created
;
; MODIFICATION HISTORY:
;   07 JUL 2015 Initial coding, C. Schlundt
; ----------------------------------------------------------------

FUNCTION CREATE_DIR, dir
    SPAWN, 'mkdir ' + dir
    result = VALID_DIR( dir )
    RETURN, KEYWORD_SET( result )
END
