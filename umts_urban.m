clear 
close all

SAMPLES = 512;
NUM_ANTENAS = 4;
load(['backup_Lisboa_' num2str(SAMPLES)]);
% Coord1 = [38.8950392,-9.3264467];
% Coord2 = [38.7224502,-9.1289357];

% The maximum transmitting power of UMTS user equipment is 250 mW
Ptx=25; %dbm
%Gtx=1;
Grx=1;
txAltura=30;
rxAltura=10;
fc=2.1e9;
Re = earthRadius('meters');
radius=Re;
convTorad=pi/180;
lambda=3e8/fc;

max_elev=max(elevation_map(:));
min_elev=min(elevation_map(:));
[coorXMax ,coorYMax]=find(elevation_map==max_elev);
[coorXMin ,coorYMin]=find(elevation_map==min_elev);
[dminmax,~] = CoorDistance(lat_map(coorXMax ,coorYMax).*(convTorad),lng_map(coorXMax ,coorYMax).*(convTorad),elevation_map(coorXMax ,coorYMax),lat_map(coorXMin ,coorYMin).*(convTorad),lng_map(coorXMin ,coorYMin).*(convTorad),elevation_map(coorXMin ,coorYMin));

% x=coorXMax;x2=231;x3=128;x4=384;
% y=coorYMax;y2=305;y3=384;y4=384;

x=[coorXMax,1,128,384];
y=[coorYMax,1,384,384];

for i = 1:NUM_ANTENAS 
[lat_visible(:,:,i),lng_visible(:,:,i),elevation_visible(:,:,i),visgrid(:,:,i),d(:,:,i),vrtangles(:,:,i),lfs(:,:,i),hrzAngle(:,:,i)] = cm_ParrachoMota(lat_map,lng_map,elevation_map,lat_map(x(i),y(i)),lng_map(x(i),y(i)),elevation_map(x(i),y(i)),rxAltura,txAltura,fc,'Hata',SAMPLES);
Gtx(:,:,i) = getGtxAntennasPM(hrzAngle(:,:,i),vrtangles(:,:,i),'04');
Prx(:,:,i)=Ptx+Gtx(:,:,i)+Grx-lfs(:,:,i);
end

% [lat_visible,lng_visible,elevation_visible,visgrid,d,vrtangles,lfs,hrzAngle] = cm_ParrachoMota(lat_map,lng_map,elevation_map,lat_map(x,y),lng_map(x,y),elevation_map(x,y),rxAltura,txAltura,fc,'Hata',SAMPLES);
% [lat_visible2,lng_visible2,elevation_visible2,visgrid2,d2,vrtangles2,lfs2,hrzAngle2] = cm_ParrachoMota(lat_map,lng_map,elevation_map,lat_map(x2,y2),lng_map(x2,y2),elevation_map(x2,y2),rxAltura,txAltura,fc,'Hata',SAMPLES);
% [lat_visible3,lng_visible3,elevation_visible3,visgrid3,d3,vrtangles3,lfs3,hrzAngle3] = cm_ParrachoMota(lat_map,lng_map,elevation_map,lat_map(x3,y3),lng_map(x3,y3),elevation_map(x3,y3),rxAltura,txAltura,fc,'Hata',SAMPLES);
% [lat_visible4,lng_visible4,elevation_visible4,visgrid4,d4,vrtangles4,lfs4,hrzAngle4] = cm_ParrachoMota(lat_map,lng_map,elevation_map,lat_map(x4,y4),lng_map(x4,y4),elevation_map(x4,y4),rxAltura,txAltura,fc,'Hata',SAMPLES);
% 
% Gtx1 = getGtxAntennasPM(hrzAngle,vrtangles,'04');
% Gtx2 = getGtxAntennasPM(hrzAngle,vrtangles,'10');
% Gtx3 = getGtxAntennasPM(hrzAngle,vrtangles,'06');
% 
% Prx=Ptx+Gtx1+Grx-lfs;
% Prx2=Ptx+Gtx2+Grx-lfs2;
% Prx3=Ptx+Gtx3+Grx-lfs3;
% Prx4=Ptx+Gtx+Grx-lfs4;

%% ================================================================== %%
disp('Displaying Data');
fprintf("Highest point:\n\t Latitude (º)=%.3f \n\t Longitude (º)=%.3f \n\t Elevation (m)=%.3f \n",lng_map(coorXMax,coorYMax), lat_map(coorXMax,coorYMax),max_elev)
fprintf("Lower point:\n\t Latitude (º)=%.3f \n\t Longitude (º)=%.3f \n\t Elevation (m)=%.3f \n",lng_map(coorXMin ,coorYMin), lat_map(coorXMin ,coorYMin),min_elev)
fprintf("Distance between the highest and lower point=%.3f meters\n",dminmax)


axis tight
surf(lng_map(1,:), lat_map(:,1), elevation_map,Prx, 'LineStyle' , ':')
colorbar

% figure
% meshc(lng_map(1,:), lat_map(:,1), elevation_map);
% 
% hold on
% title('Elevation profile from Lisboa');
% xlabel('Longitude (º)');
% ylabel('Latitude (º)');
% zlabel('Elevation (m)');

% plot3(lng_visible,lat_visible,elevation_visible,'g.','markersize',5,'DisplayName','Visible');
% plot3(lng_visible2,lat_visible2,elevation_visible2,'b.','markersize',5,'DisplayName','Visible');
% plot3(lng_visible3,lat_visible3,elevation_visible3,'k.','markersize',5,'DisplayName','Visible');
% plot3(lng_visible4,lat_visible4,elevation_visible4,'m.','markersize',5,'DisplayName','Visible');
% 
% visgridSobr = (visgrid&visgrid2) | (visgrid&visgrid3) | (visgrid&visgrid4) | (visgrid2&visgrid3) | (visgrid2&visgrid4) | (visgrid3&visgrid4);
% visgridAll = visgrid | visgrid2 | visgrid3 | visgrid4;
% plot3(lng_map(visgridSobr),lat_map(visgridSobr),elevation_map(visgridSobr),'r.','markersize',20,'DisplayName','Visible');
% 
% plot3(lng_map(x,y),lat_map(x,y),elevation_map(x,y),'b.','markersize',50,'DisplayName','Tx')
% plot3(lng_map(x2,y2),lat_map(x2,y2),elevation_map(x2,y2),'b.','markersize',50,'DisplayName','Tx2')
% plot3(lng_map(x3,y3),lat_map(x3,y3),elevation_map(x3,y3),'b.','markersize',50,'DisplayName','Tx3')
% plot3(lng_map(x4,y4),lat_map(x4,y4),elevation_map(x4,y4),'b.','markersize',50,'DisplayName','Tx4')


for i = 1:NUM_ANTENAS 
    
end
figure
title('hata');
meshc(lng_map(1,:), lat_map(:,1), Prx);
hold on
meshc(lng_map(1,:), lat_map(:,1), Prx2);
meshc(lng_map(1,:), lat_map(:,1), Prx3);
meshc(lng_map(1,:), lat_map(:,1), Prx4);
colormap(parula(5))

PrxT= Prx;
PrxT(visgrid2)= Prx2(visgrid2);
PrxT(visgrid3)= Prx3(visgrid3);
PrxT(visgrid4)= Prx4(visgrid4);

surf(lng_map(1,:), lat_map(:,1), elevation_map,PrxT, 'LineStyle' , ':')

%% ================================================================== %%

AA_func(max(lat_map(:)),min(lat_map(:)),min(lng_map(:)),max(lng_map(:)),PrxT,'urbanData')
