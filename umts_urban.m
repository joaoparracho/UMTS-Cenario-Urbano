clear 
close all

SAMPLES = 512;
NUM_ANTENAS = 5;
load(['backup_Lisboa_' num2str(SAMPLES)]);
% Coord1 = [38.8950392,-9.3264467];
% Coord2 = [38.7224502,-9.1289357];

% The maximum transmitting power of UMTS user equipment is 250 mW
Ptx=50; %dbm
Grx=1;
txAltura=25;
rxAltura=1;
fc=2.1e9;
Re=earthRadius('meters');
radius=Re;
convTorad=pi/180;
lambda=3e8/fc;

%% ==========================MEMORY ALLOCATION======================================= %%
lat_visible=zeros(SAMPLES,SAMPLES,NUM_ANTENAS);
lng_visible=zeros(SAMPLES,SAMPLES,NUM_ANTENAS);
elevation_visible=zeros(SAMPLES,SAMPLES,NUM_ANTENAS);
visgrid=zeros(SAMPLES,SAMPLES,NUM_ANTENAS);
d=zeros(SAMPLES,SAMPLES,NUM_ANTENAS);
lfs=zeros(SAMPLES,SAMPLES,NUM_ANTENAS);
vrtangles=zeros(SAMPLES,SAMPLES,NUM_ANTENAS);
hrzAngle=zeros(SAMPLES,SAMPLES,NUM_ANTENAS);
Gtx=zeros(SAMPLES,SAMPLES,NUM_ANTENAS);
Prx=zeros(SAMPLES,SAMPLES,NUM_ANTENAS);
%% ================================================================== %%

max_elev=max(elevation_map(:));
min_elev=min(elevation_map(:));
[coorXMax ,coorYMax]=find(elevation_map==max_elev);
[coorXMin ,coorYMin]=find(elevation_map==min_elev);
[dminmax,~] = CoorDistance(lat_map(coorXMax ,coorYMax).*(convTorad),lng_map(coorXMax ,coorYMax).*(convTorad),elevation_map(coorXMax ,coorYMax),lat_map(coorXMin ,coorYMin).*(convTorad),lng_map(coorXMin ,coorYMin).*(convTorad),elevation_map(coorXMin ,coorYMin));

R = georefpostings([min(lat_map(:)),max(lat_map(:))],[min(lng_map(:)),max(lng_map(:))],[SAMPLES,SAMPLES],'ColumnsStartFrom','north');

% passo=floor(512/(sqrt(NUM_ANTENAS)));
% aux=1:floor(sqrt(NUM_ANTENAS));
% x=(reshape(ones(floor(sqrt(NUM_ANTENAS)),1)*aux ,[],1)').*passo;
% x(x==0) = sqrt(NUM_ANTENAS)*passo;
% x=floor(x);

x=[65,385,128,249,249];
y=[129,129,385,333,117];
antennas = ["omni" ,"06", "duo886", "14","duo4868"];
visgridALl = logical(zeros(SAMPLES,SAMPLES));
for i = 1:NUM_ANTENAS
    [lat_visible(:,:,i),lng_visible(:,:,i),elevation_visible(:,:,i),visgrid(:,:,i),d(:,:,i),vrtangles(:,:,i),lfs(:,:,i),hrzAngle(:,:,i)]=cm_ParrachoMota(lat_map,lng_map,elevation_map,lat_map(x(i),y(i)),lng_map(x(i),y(i)),elevation_map(x(i),y(i)),rxAltura,txAltura,fc,'Hata',SAMPLES,R);
    Gtx(:,:,i)=getGtxAntennasPM(hrzAngle(:,:,i),vrtangles(:,:,i),antennas(i));
    Prx(:,:,i)=Ptx+Gtx(:,:,i)+Grx-lfs(:,:,i);
    visgridALl = visgridALl | visgrid(:,:,i);
end
visgrid=logical(visgrid);
prcCvr = size(find(visgridALl==1),1)/(SAMPLES^2);
%% ================================================================== %%
disp('Displaying Data');
fprintf("Highest point:\n\t Latitude (º)=%.3f \n\t Longitude (º)=%.3f \n\t Elevation (m)=%.3f \n",lng_map(coorXMax,coorYMax), lat_map(coorXMax,coorYMax),max_elev)
fprintf("Lower point:\n\t Latitude (º)=%.3f \n\t Longitude (º)=%.3f \n\t Elevation (m)=%.3f \n",lng_map(coorXMin ,coorYMin), lat_map(coorXMin ,coorYMin),min_elev)
fprintf("Distance between the highest and lower point=%.3f meters\n",dminmax)

axis tight
surf(lng_map(1,:), lat_map(:,1), elevation_map,Prx(:,:,1), 'LineStyle' , ':');
colorbar

% PrxT = Prx(:,:,1);
PrxT=NaN(SAMPLES,SAMPLES);
figure
title('hata');
hold on
% meshc(lng_map(1,:), lat_map(:,1), Prx(:,:,1));j
for i = 1:NUM_ANTENAS 
    meshc(lng_map(1,:), lat_map(:,1), Prx(:,:,i));
    PrAux=Prx(:,:,i);
    PrxT(visgrid(:,:,i))= PrAux(visgrid(:,:,i));
end
colormap(parula(5))
figure
surf(lng_map(1,:), lat_map(:,1), elevation_map,PrxT, 'LineStyle' , ':')

%% ================================================================== %%

AA_func(max(lat_map(:)),min(lat_map(:)),min(lng_map(:)),max(lng_map(:)),PrxT,'urbanData')
