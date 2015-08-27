;+
; NAME: VALID_DIR
;
; PURPOSE: check if directory exists
;
; CALLING SEQUENCE: result = valid_dir(dir)
;
; INPUT:
;   dir : full qualified path
;
; OUTPUT: returns 1 if valid, 0 if not.
;
; MODIFICATION HISTORY:
;   07 JUL 2015 Initial coding, C. Schlundt
; ----------------------------------------------------------------

FUNCTION VALID_DIR, dir
    ; Go to UNIX and check if directory exists using test command
    ; Open a new shell to avoid aliases
    SPAWN, ['/bin/sh -c "test -d ' + dir + '" && echo 1'], result
    RETURN, KEYWORD_SET( result )
END
