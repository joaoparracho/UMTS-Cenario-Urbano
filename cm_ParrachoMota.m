function [lat_visible,lng_visible,elevation_visible,visgrid,d,angles,lfs,az] = cm_ParrachoMota(lat_map,lng_map,elevation_map,lat,lng,elev,rxAltura,txAltura,fc,Method,SAMPLES)
convTorad=pi/180;
[d,angles,az]=CoorDistance(lat_map.*(convTorad),lng_map.*(convTorad),elevation_map+rxAltura,lat.*(convTorad),lng.*(convTorad),elev+txAltura);

R = georefpostings([min(lat_map(:)),max(lat_map(:))],[min(lng_map(:)),max(lng_map(:))],[SAMPLES,SAMPLES],'ColumnsStartFrom','north');

% count=0;
% coverPerc=zeros(512*512,6)-Inf;
% size512=(512*512);
%tic
% for y= 1:4:512
%     for x= 1:4:512
%         count=count+1;
        [visgrid,~] = viewshed(elevation_map,R,lat,lng,txAltura,rxAltura);
        
%         coverPerc(count,3)= size(find(visgrid==1),1)/(size512);
%         coverPerc(count,4)= size(find(visgrid(1:256,1:256)==1),1)/size512;
%         coverPerc(count,5)= size(find(visgrid(257:512,1:256)==1),1)/size512;
%         coverPerc(count,6)= size(find(visgrid(1:256,257:512)==1),1)/size512;
%         coverPerc(count,7)= size(find(visgrid(257:512,257:512)==1),1)/size512;
%         coverPerc(count,2)=y;
%         coverPerc(count,1)=x;
%     end
% end
%toc
% coverPerc = sortrows(coverPerc,3,'descend');
% save('CoverPerc.mat','coverPerc')
visgrid=logical(visgrid);
% visgrid=logical(visgrid) & radiusD;
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
    case 'Free'
        lfs(visgrid)=PL_free(fc,dAll,Gtx,Grx);
    case 'Hata'
        lfs(visgrid)=PL_Hata(fc,dAll(visgrid),elev,elevation_map(visgrid));
    case 'IEEE802'
        lfs(visgrid)=PL_IEEE80216d(fc,dAll(visgrid),'A',elev,elevation_map(visgrid),'Okumura');
end

end

