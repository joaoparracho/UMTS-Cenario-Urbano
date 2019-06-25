function [lat_visible,lng_visible,elevation_visible,visgrid,d,angles,lfs,az] = cm_ParrachoMota(lat_map,lng_map,elevation_map,lat,lng,elev,rxAltura,txAltura,fc,Method,SAMPLES,R)
convTorad=pi/180;
[d,angles,az]=CoorDistance(lat_map.*(convTorad),lng_map.*(convTorad),elevation_map+rxAltura,lat.*(convTorad),lng.*(convTorad),elev+txAltura);

% count=0;
% coverPerc=zeros(512*512,6)-Inf;
% size512=(512*512);
% tic
% for y= 1:64:512
%     for x= 1:64:512
%         count=count+1;
[visgrid,~] = viewshed(elevation_map,R,lat,lng,txAltura,rxAltura);
%         [visgrid,~] = viewshed(elevation_map,R,lat_map(x,y),lng_map(x,y),txAltura,rxAltura);
%         coverPerc(count,3)= size(find(visgrid==1),1)/(size512);
%         coverPerc(count,4)= size(find(visgrid(1:256,1:256)==1),1)/size512;
%         coverPerc(count,5)= size(find(visgrid(257:512,1:256)==1),1)/size512;
%         coverPerc(count,6)= size(find(visgrid(1:256,257:512)==1),1)/size512;
%         coverPerc(count,7)= size(find(visgrid(257:512,257:512)==1),1)/size512;
%         coverPerc(count,2)=y;
%         coverPerc(count,1)=x;
%     end
% end

% [X ~]=find(coverPerc==max(max(coverPerc(:,4))));
% [X(2) ~]=find(coverPerc==max(max(coverPerc(:,5))));
% [X(3) ~]=find(coverPerc==max(max(coverPerc(:,6))));
% [X(4) ~]=find(coverPerc==max(max(coverPerc(:,7))));
% 
% X=coverPerc(X,1)';
% Y=coverPerc(X,2)';
%toc
% coverPerc = sortrows(coverPerc,3,'descend');
% save('CoverPerc.mat','coverPerc')
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
    case 'Free'
        lfs(visgrid)=PL_free(fc,dAll,Gtx,Grx);
    case 'Hata'
        lfs(visgrid)=PL_Hata(fc,dAll(visgrid),elev+txAltura,elevation_map(visgrid)+rxAltura);
    case 'IEEE802'
        lfs(visgrid)=PL_IEEE80216d(fc,dAll(visgrid),'A',elev+txAltura,elevation_map(visgrid)+rxAltura,'Okumura');
end
end

