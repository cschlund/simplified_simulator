function daysinmonth, year, month

return, julday(month+1, 1, year) - julday(month, 1, year)
end
