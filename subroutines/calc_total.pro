
FUNCTION CALC_TOTAL, res, array1, array2, fill_value

    idx = WHERE(array1 NE fill_value AND array2 NE fill_value, cnt)
    IF(cnt GT 0) THEN res[idx] = array1[idx] + array2[idx]

    idx0 = WHERE(res EQ 0., cnt0)
    IF(cnt0 GT 0) THEN res[idx0] = fill_value

    RETURN, res

END