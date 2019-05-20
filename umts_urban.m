clear all
close all

SAMPLES = 512;
load(['backup_' num2str(SAMPLES)]);

% The maximum transmitting power of UMTS user equipment is 250 mW
Ptx=10*log(10);
Gtx=20;Grx=10;
txAltura=60;
rxAltura=10;
fc=2.1e9;
x=165;y=148;
Re = earthRadius('meters');
radius=Re;
convTorad=pi/180;
lambda=3e8/fc;

[d,angles]=CoorDistance(lat_map.*(convTorad),lng_map.*(convTorad),elevation_map+rxAltura,lat_map(x,y).*(convTorad),lng_map(x,y).*(convTorad),elevation_map(x,y)+txAltura);
radiusD=d.*sin(angles.*convTorad);
radiusD(radiusD<=radius)=1;radiusD(radiusD>radius)=0;
radiusD=logical(radiusD);

%% ================================================================== %%
max_elev=max(elevation_map(:));
min_elev=min(elevation_map(:));
[coorXMax ,coorYMax]=find(elevation_map==max_elev);
[coorXMin ,coorYMin]=find(elevation_map==min_elev);
[dminmax,~] = CoorDistance(lat_map(coorXMax ,coorYMax).*(convTorad),lng_map(coorXMax ,coorYMax).*(convTorad),elevation_map(coorXMax ,coorYMax),lat_map(coorXMin ,coorYMin).*(convTorad),lng_map(coorXMin ,coorYMin).*(convTorad),elevation_map(coorXMin ,coorYMin));

%% ================================================================== %%
R = georefpostings([min(lat_map(:)),max(lat_map(:))],[min(lng_map(:)),max(lng_map(:))],[SAMPLES,SAMPLES],'ColumnsStartFrom','north');
tic
[visgrid,~] = viewshed_nova(elevation_map,R,lat_map(x,y),lng_map(x,y),txAltura,rxAltura);
toc

%% ================================================================== %%
disp('Displaying Data');
fprintf("Highest point:\n\t Latitude (º)=%.3f \n\t Longitude (º)=%.3f \n\t Elevation (m)=%.3f \n",lng_map(coorXMax,coorYMax), lat_map(coorXMax,coorYMax),max_elev)
fprintf("Lower point:\n\t Latitude (º)=%.3f \n\t Longitude (º)=%.3f \n\t Elevation (m)=%.3f \n",lng_map(coorXMin ,coorYMin), lat_map(coorXMin ,coorYMin),min_elev)
fprintf("Distance between the highest and lower point=%.3f meters\n",dminmax)

%figure('Name','Elevation');
meshc(lng_map(1,:), lat_map(:,1), elevation_map);
hold on
title('Elevation profile from Serra de Aire e Candeeiros');
xlabel('Longitude (º)');
ylabel('Latitude (º)');
zlabel('Elevation (m)');

%% ================================================================== %%
visgrid=logical(visgrid) & radiusD;

lat_visible=lat_map;
lng_visible=lng_map;
elevation_visible=elevation_map;

lat_visible(~visgrid)=Inf;
lng_visible(~visgrid)=Inf;
elevation_visible(~visgrid)=Inf;
dAll=d;
d(~visgrid)=Inf;

lfs=NaN(size(d));
lfs(visgrid)=PL_free(fc,dAll(visgrid),Gtx,Grx);
%lfs(~visgrid)=PL_Hata(fc,dAll(~visgrid),elevation_map(x,y),elevation_map(~visgrid));
hata=PL_Hata(fc,dAll,elevation_map(x,y),elevation_map);
ieee802=PL_IEEE80216d(fc,dAll,'A',elevation_map(x,y),elevation_map,'Okumura');
free=PL_free(fc,dAll,Gtx,Grx);

Prx=Ptx+Gtx+Grx-lfs;
Prx(~radiusD)=Inf;

%% ================================================================== %%
%plot3(lng_map(radiusD),lat_map(radiusD),elevation_map(radiusD),'r.','markersize',0.1,'DisplayName','InsideRadius');
plot3(lng_visible,lat_visible,elevation_visible,'g.','markersize',5,'DisplayName','Visible');
plot3(lng_map(x,y),lat_map(x,y),elevation_map(x,y),'b.','markersize',50,'DisplayName','Tx')
%plot3([lng_map(coorXMin ,coorYMin),lng_map(coorXMax ,coorYMax)],[lat_map(coorXMin ,coorYMin),lat_map(coorXMax ,coorYMax)],[elevation_map(coorXMin ,coorYMin),elevation_map(coorXMax ,coorYMax)],'k')

figure
title('hata');
meshc(lng_map(1,:), lat_map(:,1), Prx);
colormap(parula(5))
figure
meshc(lng_map(1,:), lat_map(:,1), angles);

%% ================================================================== %%
AA_func(max(lat_map(:)),min(lat_map(:)),min(lng_map(:)),max(lng_map(:)),Prx,'urbanData')

% tx = txsite('Name','MathWorks', ...
%     'Latitude',lat_map(165,148), ...
%     'Longitude',lng_map(165,148), ...
%     'Antenna',design(dipole,fc), ...
%     'AntennaHeight',10, ...        % Units: meters
%     'TransmitterFrequency',fc, ... % Units: Hz
%     'TransmitterPower',0.01);        % Units: Watts
% viewer.Basemap = "openstreetmap";
% siteviewer;
% show(tx)
% coverage(tx,'freespace', ...
%     'SignalStrengths',-90)