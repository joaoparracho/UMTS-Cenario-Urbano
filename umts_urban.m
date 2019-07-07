clear 
close all

SAMPLES = 512;
NUM_ANTENAS = 4;
SENSIBILIDADE = -112.7;
load(['backup_Lisboa_' num2str(SAMPLES)]);
% Coord1 = [38.8950392,-9.3264467];
% Coord2 = [38.7224502,-9.1289357];
N=1;
Ptx=21; %dbm
Grx=1;
txAltura=30;
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
%% ================================================================== %%

areaTotalkm2 = getArea(lat_map(1,1).*(convTorad),lng_map(1 ,1).*(convTorad),elevation_map(1 ,1).*(convTorad),[lat_map(1,SAMPLES).*(convTorad),lat_map(SAMPLES,1).*(convTorad)],[lng_map(1,SAMPLES).*(convTorad),lng_map(SAMPLES,1).*(convTorad)],[elevation_map(1,SAMPLES).*(convTorad),elevation_map(SAMPLES,1).*(convTorad)])/1e6;
[nCanais,trafTotal,eficUt,D,R]=getNumChannels(100e3,0.6,0.2,0.03,0.02,areaTotalkm2,N);

passo=floor(512/(sqrt(nCanais)));
aux=1:floor(sqrt(nCanais));

x=(reshape(ones(floor(sqrt(nCanais)),1)*aux ,[],1)').*passo;
x(x==0) = sqrt(nCanais)*passo;
x=floor(x);

y=repmat(aux,1,max(aux)).*passo;

indHext=find(mod(y./passo,2)==0);
x(indHext)=x(indHext)-passo./2;
%% ================================================================== %%

antennas = ["omni" ,"06", "duo886", "14","duo4868"];

PrxT=NaN(SAMPLES,SAMPLES);
visgridALl = logical(zeros(SAMPLES,SAMPLES));
for i = 1:nCanais
    [lat_visible(:,:,i),lng_visible(:,:,i),elevation_visible(:,:,i),visgrid(:,:,i),d(:,:,i),vrtangles(:,:,i),lfs(:,:,i),hrzAngle(:,:,i)]=cm_ParrachoMota(lat_map,lng_map,elevation_map,lat_map(x(i),y(i)),lng_map(x(i),y(i)),elevation_map(x(i),y(i)),rxAltura,txAltura,fc,'Hata',SAMPLES,R);
    %Gtx(:,:,i)=getGtxAntennasPM(hrzAngle(:,:,i),vrtangles(:,:,i),antennas(i));
    Gtx(:,:,i)=getGtxAntennasPM(hrzAngle(:,:,i),vrtangles(:,:,i),"omni");
    PrxBuff=Ptx+Gtx(:,:,i)+Grx-lfs(:,:,i);
    PrxBuff(PrxBuff<SENSIBILIDADE)=NaN;
    Prx(:,:,i)=PrxBuff;
    visgridALl = visgridALl | visgrid(:,:,i); 
end
visgrid=logical(visgrid);
[PrxT,bestServer]=max(Prx,[],3);
bestServer(~visgridALl)=NaN;
prcCvr = size(find(visgridALl==1),1)/(SAMPLES^2);
%% ================================================================== %%
disp('Displaying Data');
fprintf("Highest point:\n\t Latitude (º)=%.3f \n\t Longitude (º)=%.3f \n\t Elevation (m)=%.3f \n",lng_map(coorXMax,coorYMax), lat_map(coorXMax,coorYMax),max_elev)
fprintf("Lower point:\n\t Latitude (º)=%.3f \n\t Longitude (º)=%.3f \n\t Elevation (m)=%.3f \n",lng_map(coorXMin ,coorYMin), lat_map(coorXMin ,coorYMin),min_elev)
fprintf("Distance between the highest and lower point=%.3f meters\n",dminmax)
fprintf("Cell Radius=%.3f meters\n",R)
fprintf("Cell Distance (D)=%.3f meters\n",D)
fprintf("Number of Cells =%.3f meters\n",nCanais)

axis tight
surf(lng_map(1,:), lat_map(:,1), elevation_map,Prx(:,:,1), 'LineStyle' , ':');
colorbar

figure
title('hata');
meshc(lng_map(1,:), lat_map(:,1), Prx(:,:,i));
colormap(parula(5))

figure
surf(lng_map(1,:), lat_map(:,1), elevation_map,PrxT, 'LineStyle' , ':')

%% ================================================================== %%

AA_func(max(lat_map(:)),min(lat_map(:)),min(lng_map(:)),max(lng_map(:)),PrxT,'urbanData')
