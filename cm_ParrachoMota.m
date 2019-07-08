function [lat_visible,lng_visible,elevation_visible,visgrid,d,angles,lfs,az,Gtx] = cm_ParrachoMota(lat_map,lng_map,elevation_map,lat,lng,elev,rxAltura,txAltura,fc,Method,SAMPLES,R)
convTorad=pi/180;
[d,angles,az]=CoorDistance(lat_map.*(convTorad),lng_map.*(convTorad),elevation_map+rxAltura,lat.*(convTorad),lng.*(convTorad),elev+txAltura);

[visgrid,~] = viewshed(elevation_map,R,lat,lng,txAltura,rxAltura);

Gtx=getGtxAntennasPM(az,angles,"Omni");

visgrid=logical(visgrid);
lat_visible=lat_map;
lng_visible=lng_map;
elevation_visible=elevation_map;

lat_visible(~visgrid)=Inf;
lng_visible(~visgrid)=Inf;
elevation_visible(~visgrid)=Inf;
dAll=d;
d(~visgrid)=Inf;
lfs=NaN(size(d));
switch Method
    case 'Free Space'
        lfs(visgrid)=PL_free(fc,dAll(visgrid),10.^(Gtx(visgrid)./10),1);
    case 'Hata'
        lfs(visgrid)=PL_Hata(fc,dAll(visgrid),elev+txAltura,elevation_map(visgrid)+rxAltura);
    case 'IEEE802'
        lfs(visgrid)=PL_IEEE80216d(fc,dAll(visgrid),'A',elev+txAltura,elevation_map(visgrid)+rxAltura,'Okumura');
end
end

