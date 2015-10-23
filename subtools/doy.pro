function doy, year, month, day

if n_params() eq 0 then begin
	print, "USAGE: print, doy(year, month, day)"
	return, -1
end
return, julday(month, day, year) - julday(1, 0, year)
end
