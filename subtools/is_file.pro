function is_file,name,help=help
;-------------------------------------------------------------
;+
; NAME:
;       is_file
; PURPOSE:
;       checks if name is an existing file 
;
; CATEGORY:In/Output, strings
;
; CALLING SEQUENCE:
;
;	isfile=is_file("/full/or/relativ/path")
;
; MODIFICATION HISTORY:
;       Written  R. Preusker, Dez, 2000.
;
; Copyright (C) 1998, Freie Universitaet Berlin
; This software may be used, copied, or redistributed as long
; as it is not sold and this copyright notice is reproduced on
; each copy made.  This routine is provided as is without any
; express or implied warranties whatsoever.
;-

if keyword_set(help) then print_help,"is_file"

errorstatus=0

catch,errorstatus
;stop
if errorstatus ne 0 then return,0 $
else begin
	openr, lun, name, /get_lun
	free_lun, lun
	return, 1
endelse

end
