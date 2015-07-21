
;RANGE_YY=['1979','1980','1981','1982','1983','1984','1985','1986','1987','1988','1989','1990',$
;          '1991','1992','1993','1994','1995','1996','1997','1998','1999','2000','2001',$
;          '2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012']
;RANGE_YY=['1988','1989','1990',$
;          '1991','1992','1993','1994','1995','1996','1997','1998','1999','2000','2001',$
;          '2002','2003','2004','2005','2006','2007','2008']
;RANGE_YY=['1988','1989','1990',$
;          '1991','1992','1993','1994','1995','1996','1997','1998','1999']

RANGE_YY=['1983'];
;RANGE_YY=['2002','2003']
;RANGE_YY=['2004','2005'];,'2006','2007','2008']

;RANGE_YY=['2008']
;RANGE_YY=['1988','1989','1990','1991','1992']

;RANGE_MM=['01','02','03','04','05','06','07','08','09','10','11','12']
;RANGE_MM=['01','02','03','04']
RANGE_MM=['01']

nyy=n_elements(RANGE_YY)
;ndays=n_elements(RANGE_days)
nmonths=n_elements(RANGE_MM)

ctp_limits_final1d=[ 1.0,90.0, 180.0, 245.0, 310.0, 375.0, 440.0, 500.0, 560.0, 620.0, 680.0, 740.0, 800.0, 950., 1100.0]
ctp_limits_final2d=fltarr(2,n_elements(ctp_limits_final1d)-1)

for gu=0,n_elements(ctp_limits_final2d[0,*])-1 do begin
  ctp_limits_final2d[0,gu]=ctp_limits_final1d[gu]
  ctp_limits_final2d[1,gu]=ctp_limits_final1d[gu+1]
endfor


dim_ctp=n_elements(ctp_limits_final1d)-1

era_path='/cmsaf/cmsaf-cld1/mstengel/ERA_Interim/ERA_simulator/MARS_data/ERA_simulator/'


for ii1=0,nyy-1 do begin
for jj1=0,nmonths-1 do begin


year=RANGE_YY[ii1]
month=RANGE_MM[jj1]

counti=0


;ff=findfile(era_path+year+month+'/'+'*'+year+month+'*8_12*plev')
ff=findfile(era_path+year+month+'/'+'*'+year+month+'*plev')
;if(year eq '1983') then ff=findfile(era_path+year+month+'/ERA_Interim_fc_1983'+month+'??_??+??')
help, ff

if(n_elements(ff) gt 1) then begin

for fidx=0,n_elements(ff)-1,1 do begin
  file0=ff[fidx]
  file1=file0+'.nc'
  if(is_file(file0) and (not is_file(file1))) then begin
    print,'converting: '+file0
    spawn,'cdo -f nc copy '+file0+' '+file1
  endif
  if(is_file(file1)) then begin
    print,'processing '+file1
    fileID = ncdf_open(file1)
    varID=ncdf_varid(fileID,'lev') & ncdf_varget,fileID,varID,plevel ;pressure level [Pa]
    varID=ncdf_varid(fileID,'lon') & ncdf_varget,fileID,varID,lon ;pressure level [Pa]
    varID=ncdf_varid(fileID,'lat') & ncdf_varget,fileID,varID,lat ;pressure level [Pa]
    varID=ncdf_varid(fileID,'var246') & ncdf_varget,fileID,varID,lwc ;clwc	kg kg**-1
    varID=ncdf_varid(fileID,'var247') & ncdf_varget,fileID,varID,iwc ;ciwc	kg kg**-1
    varID=ncdf_varid(fileID,'var248') & ncdf_varget,fileID,varID,cc ;cloud cover
    varID=ncdf_varid(fileID,'var129') & ncdf_varget,fileID,varID,geop ;cloud cover
    varID=ncdf_varid(fileID,'var130') & ncdf_varget,fileID,varID,temp ;cloud cover
    ncdf_close,(fileID)


dpres=plevel[1:n_elements(plevel)-1]-plevel[0:n_elements(plevel)-2]


    if(counti eq 0) then begin
     xdim=n_elements(lwc[*,0,0])
     ydim=n_elements(lwc[0,*,0])
     zdim=n_elements(lwc[0,0,*])
     lon2d=fltarr(xdim,ydim)
     lat2d=fltarr(xdim,ydim)
     for loi=0,xdim-1 do lon2d[loi,*]=lon[loi]
     for lai=0,ydim-1 do lat2d[*,lai]=lat[lai]
     ctp_tmp=fltarr(xdim,ydim)
     cth_tmp=fltarr(xdim,ydim)
     ctt_tmp=fltarr(xdim,ydim)
     ctp_tmp_cot=fltarr(xdim,ydim)
     cth_tmp_cot=fltarr(xdim,ydim)
     ctt_tmp_cot=fltarr(xdim,ydim)
     lwp_lay_tmp=fltarr(xdim,ydim)
     iwp_lay_tmp=fltarr(xdim,ydim)
     lwp_tmp=fltarr(xdim,ydim)
     iwp_tmp=fltarr(xdim,ydim)
     lwp_tmp_cot=fltarr(xdim,ydim)
     iwp_tmp_cot=fltarr(xdim,ydim)
     cph_tmp=fltarr(xdim,ydim)
     cph_tmp_cot=fltarr(xdim,ydim)
  
     cfc_tmp=fltarr(xdim,ydim)
     cfc_tmp_cot=fltarr(xdim,ydim)

     cfc_mean=fltarr(xdim,ydim)
     cfc_mean[*,*]=0.
     cfc_mean_cot=fltarr(xdim,ydim)
     cfc_mean_cot[*,*]=0.     
     ctt_mean=fltarr(xdim,ydim)
     ctt_mean[*,*]=0.
     cth_mean=fltarr(xdim,ydim)
     cth_mean[*,*]=0.
     ctp_mean=fltarr(xdim,ydim)
     ctp_mean[*,*]=0.
     lwp_mean=fltarr(xdim,ydim)
     lwp_mean[*,*]=0.
     iwp_mean=fltarr(xdim,ydim)
     iwp_mean[*,*]=0.
     ctt_mean_cot=fltarr(xdim,ydim)
     ctt_mean_cot[*,*]=0.
     cth_mean_cot=fltarr(xdim,ydim)
     cth_mean_cot[*,*]=0.
     ctp_mean_cot=fltarr(xdim,ydim)
     ctp_mean_cot[*,*]=0.
     lwp_mean_cot=fltarr(xdim,ydim)
     lwp_mean_cot[*,*]=0.
     iwp_mean_cot=fltarr(xdim,ydim)
     iwp_mean_cot[*,*]=0.
     cph_mean=fltarr(xdim,ydim)
     cph_mean[*,*]=0.
     cph_mean_cot=fltarr(xdim,ydim)
     cph_mean_cot[*,*]=0.

     ctp_hist=lonarr(xdim,ydim,dim_ctp)
     ctp_hist[*,*,*]=0l
     ctp_hist_cot=lonarr(xdim,ydim,dim_ctp)
     ctp_hist_cot[*,*,*]=0l

     lwp_lay=fltarr(xdim,ydim,zdim-1)
     iwp_lay=fltarr(xdim,ydim,zdim-1)
     lcot_lay=fltarr(xdim,ydim,zdim-1)
     icot_lay=fltarr(xdim,ydim,zdim-1)

     numb=lonarr(xdim,ydim)
     numb[*,*]=0
     numb_tmp=intarr(xdim,ydim)
     numb_cot=lonarr(xdim,ydim)
     numb_cot[*,*]=0
     numb_raw=0l
     
     found=0
    endif 
    counti++
    ctp_tmp[*,*]=-999.
    cth_tmp[*,*]=-999.
    ctt_tmp[*,*]=-999.
    ctp_tmp_cot[*,*]=-999.
    cth_tmp_cot[*,*]=-999.
    ctt_tmp_cot[*,*]=-999.
    lwp_lay_tmp[*,*]=-999.
    iwp_lay_tmp[*,*]=-999.
    lwp_tmp[*,*]=0.
    iwp_tmp[*,*]=0.
    lwp_tmp_cot[*,*]=0.
    iwp_tmp_cot[*,*]=0.
    cph_tmp[*,*]=-999.
    cph_tmp_cot[*,*]=-999.
    cfc_tmp[*,*]=0.
    cfc_tmp_cot[*,*]=0.

crit_str='0.01'
cc_crit=float(crit_str)
cwc_crit=1.0E-07 & crit_str='lwc_crit_'+strtrim(cwc_crit,1)
cot_crit=1.0 & crit_str='cot_crit_'+strtrim(cot_crit,1)
cot_crit=0.3 & crit_str='cot_crit_'+strtrim(cot_crit,1)
cot_crit=1.0 & cot_crit0=0.01 & crit_str='cot_crit_'+strtrim(cot_crit,1)


    for z=zdim-2,0,-1 do begin

      lwc_lay=lwc[*,*,z]*0.5+lwc[*,*,z+1]*0.5
      iwc_lay=iwc[*,*,z]*0.5+iwc[*,*,z+1]*0.5

; http://en.wikipedia.org/wiki/Liquid_water_path#cite_note-2
      lwp_lay[*,*,z]=lwc_lay*dpres[z]/9.81
      iwp_lay[*,*,z]=iwc_lay*dpres[z]/9.81


;IWP = (COT (1/0.84))/0.065
;cot_ice=(IWP*0.065)^0.84
ro_water=1000 ; kg/m3
ro_ice=930;kg/m3
reff_water=10.*1.0E-6
reff_ice=20.*1.0E-6
;LWP=2./3.*cot*reff*ro
;cot=lwp*3./(2.*reff*ro)

      lcot_lay[*,*,z]=lwp_lay[*,*,z]*3./(2.*reff_water*ro_water)
      ;icot_lay[*,*,z]=iwp_lay[*,*,z]*3./(2.*reff_ice*ro_ice)
      iwp_tmp=reform(iwp_lay[*,*,z])
      icot_tmp=iwp_tmp*0.
      wo_iwp=where(iwp_tmp gt 0.,n_wo_iwp)
      if(n_wo_iwp gt 0) then icot_tmp[wo_iwp]=(iwp_tmp[wo_iwp]*1000*0.065)^(0.84)
      icot_lay[*,*,z]=icot_tmp

    endfor



;stop
cl_lay_num=0.
cl_lay_cot_num=0.
    for z=zdim-2,1,-1 do begin
 ;     wo=where(cc[*,*,z] gt cc_crit,nwo)
      ;wo=where((lwc[*,*,z]+(0 > iwc[*,*,z])) gt cwc_crit,nwo)
      ;wo=where(lwc[*,*,z] gt cwc_crit,nwo)
      ;wo_cot=where((lcot_lay+icot_lay)[*,*,z] gt cot_crit,nwo)
      wo_cot0=where(total((lcot_lay+icot_lay)[*,*,0:z],3) gt cot_crit0,nwo_cot0)
      wo_cot=where(total((lcot_lay+icot_lay)[*,*,0:z],3) gt cot_crit,nwo_cot)
;print,nwo,nwo_cot
      if(nwo_cot0 gt 0 or nwo_cot gt 0) then begin
        geop_tmp=reform(geop[*,*,z])/9.81
        temp_tmp=reform(temp[*,*,z])
        lwp_lay_tmp=reform(lwp_lay[*,*,z])
        iwp_lay_tmp=reform(iwp_lay[*,*,z])
      endif
      if(nwo_cot0 gt 0) then begin
        ctp_tmp[wo_cot0]=plevel[z]/100.
        cth_tmp[wo_cot0]=geop_tmp[wo_cot0]
        ctt_tmp[wo_cot0]=temp_tmp[wo_cot0]
        cph_tmp[wo_cot0]=(0. > (lwp_lay_tmp[wo_cot0]/(lwp_lay_tmp[wo_cot0]+iwp_lay_tmp[wo_cot0])) < 1.0)
        if(z lt zdim-2) then begin
          lwp_tmp[wo_cot0]=(total(lwp_lay[*,*,z:*],3))[wo_cot0]
          iwp_tmp[wo_cot0]=(total(iwp_lay[*,*,z:*],3))[wo_cot0]
          cfc_tmp[wo_cot0]=(max(cc[*,*,z:*],dimension=3))[wo_cot0]
       endif else begin
          lwp_tmp[wo_cot0]=(lwp_lay[*,*,z])[wo_cot0]
          iwp_tmp[wo_cot0]=(iwp_lay[*,*,z])[wo_cot0]
          cfc_tmp[wo_cot0]=(cc[*,*,z])[wo_cot0]
       endelse 
      endif
      if(nwo_cot gt 0) then begin
        ctp_tmp_cot[wo_cot]=plevel[z]/100.
        cth_tmp_cot[wo_cot]=geop_tmp[wo_cot]
        ctt_tmp_cot[wo_cot]=temp_tmp[wo_cot]
        cph_tmp_cot[wo_cot]=(0. > (lwp_lay_tmp[wo_cot]/(lwp_lay_tmp[wo_cot]+iwp_lay_tmp[wo_cot])) < 1.0)
        if(z lt zdim-2) then begin
          lwp_tmp_cot[wo_cot]=(total(lwp_lay[*,*,z:*],3))[wo_cot]
          iwp_tmp_cot[wo_cot]=(total(iwp_lay[*,*,z:*],3))[wo_cot]
          cfc_tmp_cot[wo_cot]=(max(cc[*,*,z:*],dimension=3))[wo_cot]
       endif else begin
          lwp_tmp_cot[wo_cot]=(lwp_lay[*,*,z])[wo_cot]
          iwp_tmp_cot[wo_cot]=(iwp_lay[*,*,z])[wo_cot]
          cfc_tmp_cot[wo_cot]=(cc[*,*,z])[wo_cot]
       endelse
      endif

    endfor

print, minmax(iwp_tmp_cot-iwp_tmp)

;lwp_tmp=total(lwp_lay,3)
;iwp_tmp=total(iwp_lay,3)

;stop

    wo_ctp=where(ctp_tmp gt 10.,nwo_ctp)
    ctp_mean[wo_ctp]=ctp_mean[wo_ctp]+ctp_tmp[wo_ctp]
    cth_mean[wo_ctp]=cth_mean[wo_ctp]+cth_tmp[wo_ctp]
    ctt_mean[wo_ctp]=ctt_mean[wo_ctp]+ctt_tmp[wo_ctp]
;    lwp_mean[wo_ctp]=lwp_mean[wo_ctp]+lwp_tmp[wo_ctp]
;    iwp_mean[wo_ctp]=iwp_mean[wo_ctp]+iwp_tmp[wo_ctp]
    lwp_mean=lwp_mean+lwp_tmp
    iwp_mean=iwp_mean+iwp_tmp
    cfc_mean=cfc_mean+cfc_tmp
    cph_mean[wo_ctp]=cph_mean[wo_ctp]+cph_tmp[wo_ctp]
    numb[wo_ctp]=numb[wo_ctp]+1l

    wo_ctp_cot=where(ctp_tmp_cot gt 10.,nwo_ctp_cot)
    ctp_mean_cot[wo_ctp_cot]=ctp_mean_cot[wo_ctp_cot]+ctp_tmp_cot[wo_ctp_cot]
    cth_mean_cot[wo_ctp_cot]=cth_mean_cot[wo_ctp_cot]+cth_tmp_cot[wo_ctp_cot]
    ctt_mean_cot[wo_ctp_cot]=ctt_mean_cot[wo_ctp_cot]+ctt_tmp_cot[wo_ctp_cot]
;    lwp_mean_cot[wo_ctp_cot]=lwp_mean_cot[wo_ctp_cot]+lwp_tmp_cot[wo_ctp_cot]
;    iwp_mean_cot[wo_ctp_cot]=iwp_mean_cot[wo_ctp_cot]+iwp_tmp_cot[wo_ctp_cot]
    lwp_mean_cot=lwp_mean_cot+lwp_tmp_cot
    iwp_mean_cot=iwp_mean_cot+iwp_tmp_cot
    cfc_mean_cot=cfc_mean_cot+cfc_tmp_cot
    cph_mean_cot[wo_ctp_cot]=cph_mean_cot[wo_ctp_cot]+cph_tmp_cot[wo_ctp_cot]
    numb_cot[wo_ctp_cot]=numb_cot[wo_ctp_cot]+1l

numb_raw++

    for gu=0,dim_ctp-1 do begin
      numb_tmp[*,*]=0
      wohi=where(ctp_tmp ge ctp_limits_final2d[0,gu] and ctp_tmp lt ctp_limits_final2d[1,gu],nwohi) 
      if(nwohi gt 0) then numb_tmp[wohi]=1
      ctp_hist[*,*,gu]=ctp_hist[*,*,gu]+numb_tmp
    endfor
    for gu=0,dim_ctp-1 do begin
      numb_tmp[*,*]=0
      wohi=where(ctp_tmp_cot ge ctp_limits_final2d[0,gu] and ctp_tmp_cot lt ctp_limits_final2d[1,gu],nwohi_cot) 
      if(nwohi_cot gt 0) then numb_tmp[wohi]=1
      ctp_hist_cot[*,*,gu]=ctp_hist_cot[*,*,gu]+numb_tmp
    endfor

;view2d,ctp_mean/numb,/cool,/color,min=100,no_data_idx=where(ctp_mean lt 1)
;print, minmax(ctt_tmp)
;print, minmax(ctt_mean/numb)
;print, minmax(numb)
;map_image,ctt_mean/numb,lat2d,lon2d,ctable=33,limit=[-90,-180,90,180],min=200,max=300

  endif
endfor


wo_numi=where(numb gt 0, n_wo_numi)
wo_numi0=where(numb eq 0, n_wo_numi0)
if(n_wo_numi gt 0) then ctp_mean[wo_numi]=ctp_mean[wo_numi]/numb[wo_numi]
if(n_wo_numi gt 0) then cth_mean[wo_numi]=cth_mean[wo_numi]/numb[wo_numi]
if(n_wo_numi gt 0) then ctt_mean[wo_numi]=ctt_mean[wo_numi]/numb[wo_numi]
lwp_mean=lwp_mean/numb_raw
iwp_mean=iwp_mean/numb_raw
cfc_mean=cfc_mean/numb_raw
if(n_wo_numi gt 0) then cph_mean[wo_numi]=cph_mean[wo_numi]/numb[wo_numi]
if(n_wo_numi0 gt 0) then ctp_mean[wo_numi0]=-999.
if(n_wo_numi0 gt 0) then cth_mean[wo_numi0]=-999.
if(n_wo_numi0 gt 0) then ctt_mean[wo_numi0]=-999.
if(n_wo_numi0 gt 0) then lwp_mean[wo_numi0]=-999.
if(n_wo_numi0 gt 0) then iwp_mean[wo_numi0]=-999.
if(n_wo_numi0 gt 0) then cph_mean[wo_numi0]=-999.

wo_numi_cot=where(numb_cot gt 0, n_wo_numi_cot)
wo_numi0_cot=where(numb_cot eq 0, n_wo_numi0_cot)
if(n_wo_numi_cot gt 0) then ctp_mean_cot[wo_numi_cot]=ctp_mean_cot[wo_numi_cot]/numb_cot[wo_numi_cot]
if(n_wo_numi_cot gt 0) then cth_mean_cot[wo_numi_cot]=cth_mean_cot[wo_numi_cot]/numb_cot[wo_numi_cot]
if(n_wo_numi_cot gt 0) then ctt_mean_cot[wo_numi_cot]=ctt_mean_cot[wo_numi_cot]/numb_cot[wo_numi_cot]
if(n_wo_numi_cot gt 0) then cph_mean_cot[wo_numi_cot]=cph_mean_cot[wo_numi_cot]/numb_cot[wo_numi_cot]
lwp_mean_cot=lwp_mean_cot/numb_raw
iwp_mean_cot=iwp_mean_cot/numb_raw
cfc_mean_cot=cfc_mean_cot/numb_raw
if(n_wo_numi0_cot gt 0) then ctp_mean_cot[wo_numi0_cot]=-999.
if(n_wo_numi0_cot gt 0) then cth_mean_cot[wo_numi0_cot]=-999.
if(n_wo_numi0_cot gt 0) then ctt_mean_cot[wo_numi0_cot]=-999.
if(n_wo_numi0_cot gt 0) then cph_mean_cot[wo_numi0_cot]=-999.
if(n_wo_numi0_cot gt 0) then lwp_mean_cot[wo_numi0_cot]=-999.
if(n_wo_numi0_cot gt 0) then iwp_mean_cot[wo_numi0_cot]=-999.

;map_image,ctt_mean,lat2d,lon2d,ctable=33,limit=[-90,-180,90,180],min=200,max=300


path_out='/cmsaf/cmsaf-cld1/mstengel/ERA_Interim/ERA_simulator/MM2/'


fyear=float(year)
fmonth=float(month)
dayi_start=1
dayi_end=daysinmonth(fyear,fmonth)
tbo=dblarr(2,1)
tref=julday(1,1,1970,0,0,0)
tttt=julday(fmonth,dayi_start,fyear,0,0,0)
tttt2=julday(fmonth,dayi_end,fyear,23,59,59)
tbo[0,0]=tttt-tref
tbo[1,0]=tttt2-tref
titi=tttt-tref
erg_plev=ctp_limits_final1d[1:n_elements(ctp_limits_final1d)-1]*0.5+ctp_limits_final1d[0:n_elements(ctp_limits_final1d)-2]*0.5
erg_plev_bnds=ctp_limits_final2d;*100.

;dim_ctp=nctp_new
dim_time=1

file_out='ERA_Interim_MM'+year+month+'_'+crit_str+'_CTP.nc'
clobber=1
print,'creating netcdf file: '+file_out
id = NCDF_CREATE(path_out+file_out, CLOBBER = clobber)      ;Create netCDF output file

NCDF_ATTPUT, id, /GLOBAL, "Source" , "ERA-Interim" ;
NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_START" , ""+year+month ;
NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_RESOLUTION", "P1M"

dim_x_id  = NCDF_DIMDEF(id, 'lon', xdim)                       ;Define y-dimension
dim_y_id  = NCDF_DIMDEF(id, 'lat', ydim)                       ;Define y-dimension
time_id  = NCDF_DIMDEF(id, 'time', dim_time)                       ;Define y-dimension

vid  = NCDF_VARDEF(id, 'lon', [dim_x_id], /FLOAT)     ;Define data variable
vid  = NCDF_VARDEF(id, 'lat', [dim_y_id], /FLOAT)     ;Define data variable
vid  = NCDF_VARDEF(id, 'time', [time_id], /DOUBLE)     ;Define data variable

vid  = NCDF_VARDEF(id, 'ctp_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)     ;Define data variable
NCDF_ATTPUT, id, 'ctp_ori', '_FillValue', -999.
vid  = NCDF_VARDEF(id, 'cth_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)     ;Define data variable
NCDF_ATTPUT, id, 'cth_ori', '_FillValue', -999.
vid  = NCDF_VARDEF(id, 'ctt_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)     ;Define data variable
NCDF_ATTPUT, id, 'ctt_ori', '_FillValue', -999.

vid  = NCDF_VARDEF(id, 'ctp', [dim_x_id,dim_y_id,time_id], /FLOAT)     ;Define data variable
NCDF_ATTPUT, id, 'ctp', '_FillValue', -999.
vid  = NCDF_VARDEF(id, 'cth', [dim_x_id,dim_y_id,time_id], /FLOAT)     ;Define data variable
NCDF_ATTPUT, id, 'cth', '_FillValue', -999.
vid  = NCDF_VARDEF(id, 'ctt', [dim_x_id,dim_y_id,time_id], /FLOAT)     ;Define data variable
NCDF_ATTPUT, id, 'ctt', '_FillValue', -999.

vid  = NCDF_VARDEF(id, 'cc_total_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)     ;Define data variable
NCDF_ATTPUT, id, 'cc_total_ori', '_FillValue', -999.
vid  = NCDF_VARDEF(id, 'cc_total', [dim_x_id,dim_y_id,time_id], /FLOAT)     ;Define data variable
NCDF_ATTPUT, id, 'cc_total', '_FillValue', -999.

vid  = NCDF_VARDEF(id, 'lwp_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)     ;Define data variable
NCDF_ATTPUT, id, 'lwp_ori', '_FillValue', -999.
vid  = NCDF_VARDEF(id, 'lwp', [dim_x_id,dim_y_id,time_id], /FLOAT)     ;Define data variable
NCDF_ATTPUT, id, 'lwp', '_FillValue', -999.
vid  = NCDF_VARDEF(id, 'iwp_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)     ;Define data variable
NCDF_ATTPUT, id, 'iwp_ori', '_FillValue', -999.
vid  = NCDF_VARDEF(id, 'iwp', [dim_x_id,dim_y_id,time_id], /FLOAT)     ;Define data variable
NCDF_ATTPUT, id, 'iwp', '_FillValue', -999.
vid  = NCDF_VARDEF(id, 'cph_ori', [dim_x_id,dim_y_id,time_id], /FLOAT)     ;Define data variable
NCDF_ATTPUT, id, 'cph_ori', '_FillValue', -999.
vid  = NCDF_VARDEF(id, 'cph', [dim_x_id,dim_y_id,time_id], /FLOAT)     ;Define data variable
NCDF_ATTPUT, id, 'cph', '_FillValue', -999.

vid  = NCDF_VARDEF(id, 'nobs', [dim_x_id,dim_y_id,time_id], /LONG)     ;Define data variable
vid  = NCDF_VARDEF(id, 'nobs_cot', [dim_x_id,dim_y_id,time_id], /LONG)     ;Define data variable

print,'counti',counti

NCDF_CONTROL, id, /ENDEF                              ;Exit define mode

NCDF_VARPUT, id, 'time',titi                        ;Write data to file
;NCDF_VARPUT, id, 'time_bnds',tbo                        ;Write data to file
NCDF_VARPUT, id, 'lon',lon                        ;Write data to file
NCDF_VARPUT, id, 'lat',lat                        ;Write data to file
NCDF_VARPUT, id, 'ctp_ori',ctp_mean                        ;Write data to file
NCDF_VARPUT, id, 'cth_ori',cth_mean                        ;Write data to file
NCDF_VARPUT, id, 'ctt_ori',ctt_mean                        ;Write data to file
NCDF_VARPUT, id, 'ctp',ctp_mean_cot                       ;Write data to file
NCDF_VARPUT, id, 'cth',cth_mean_cot                        ;Write data to file
NCDF_VARPUT, id, 'ctt',ctt_mean_cot                        ;Write data to file
NCDF_VARPUT, id, 'cc_total_ori',cfc_mean ;(numb*1.0)/counti                        ;Write data to file
NCDF_VARPUT, id, 'cc_total',cfc_mean_cot ;(numb_cot*1.0)/counti                        ;Write data to file
NCDF_VARPUT, id, 'lwp_ori',lwp_mean                        ;Write data to file
NCDF_VARPUT, id, 'lwp',lwp_mean_cot                        ;Write data to file
NCDF_VARPUT, id, 'iwp_ori',iwp_mean                        ;Write data to file
NCDF_VARPUT, id, 'iwp',iwp_mean_cot                        ;Write data to file
NCDF_VARPUT, id, 'cph_ori',cph_mean                        ;Write data to file
NCDF_VARPUT, id, 'cph',cph_mean_cot                        ;Write data to file
NCDF_VARPUT, id, 'nobs',numb                        ;Write data to file
NCDF_VARPUT, id, 'nobs_cot',numb_cot                        ;Write data to file

NCDF_CLOSE, id                                        ;Close netCDF output file


file_out='ERA_Interim_MH'+year+month+'_'+crit_str+'_CTP.nc'
clobber=1
print,'creating netcdf file: '+file_out
id = NCDF_CREATE(path_out+file_out, CLOBBER = clobber)      ;Create netCDF output file

NCDF_ATTPUT, id, /GLOBAL, "Source" , "ERA-Interim" ;
NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_START" , ""+year+month ;
NCDF_ATTPUT, id, /GLOBAL, "TIME_COVERAGE_RESOLUTION", "P1M"

dim_tb_id  = NCDF_DIMDEF(id, 'gsize', 2)                       ;Define y-dimension
dim_p_id  = NCDF_DIMDEF(id, 'plev', dim_ctp)                       ;Define y-dimension
dim_x_id  = NCDF_DIMDEF(id, 'lon', xdim)                       ;Define y-dimension
dim_y_id  = NCDF_DIMDEF(id, 'lat', ydim)                       ;Define y-dimension
dim_b_id  = NCDF_DIMDEF(id, 'bnds', 2)                       ;Define y-dimension
time_id  = NCDF_DIMDEF(id, 'time', dim_time)                       ;Define y-dimension

vid  = NCDF_VARDEF(id, 'lon', [dim_x_id], /FLOAT)     ;Define data variable
vid  = NCDF_VARDEF(id, 'lat', [dim_y_id], /FLOAT)     ;Define data variable
vid  = NCDF_VARDEF(id, 'time', [time_id], /DOUBLE)     ;Define data variable

vid  = NCDF_VARDEF(id, 'ctp', [dim_p_id], /FLOAT)     ;Define data variable
vid  = NCDF_VARDEF(id, 'ctp_bnds', [dim_b_id,dim_p_id], /FLOAT)     ;Define data variable
vid  = NCDF_VARDEF(id, 'ctp_hist', [dim_x_id,dim_y_id,dim_p_id,time_id], /LONG)     ;Define data variable
vid  = NCDF_VARDEF(id, 'ctp_hist_cot', [dim_x_id,dim_y_id,dim_p_id,time_id], /LONG)     ;Define data variable

NCDF_CONTROL, id, /ENDEF                              ;Exit define mode

NCDF_VARPUT, id, 'time',titi                        ;Write data to file
;NCDF_VARPUT, id, 'time_bnds',tbo                        ;Write data to file
NCDF_VARPUT, id, 'lon',lon                        ;Write data to file
NCDF_VARPUT, id, 'lat',lat                        ;Write data to file
NCDF_VARPUT, id, 'ctp',erg_plev                        ;Write data to file
NCDF_VARPUT, id, 'ctp_bnds',erg_plev_bnds                        ;Write data to file
NCDF_VARPUT, id, 'ctp_hist',ctp_hist                        ;Write data to file
NCDF_VARPUT, id, 'ctp_hist_cot',ctp_hist_cot                        ;Write data to file

NCDF_CLOSE, id                                        ;Close netCDF output file

endif

endfor
endfor



end
