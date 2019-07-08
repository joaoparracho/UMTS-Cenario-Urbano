clear 
close all

SAMPLES = 512;
NUM_ANTENAS = 4;
SENSIBILIDADE = -112.7;
MINIUM_COVER_PERC = 0.7;
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

%% ======================HIGHEST/LOWE POINT and RrefComputation===================================== %%

max_elev=max(elevation_map(:));
min_elev=min(elevation_map(:));
[coorXMax ,coorYMax]=find(elevation_map==max_elev);
[coorXMin ,coorYMin]=find(elevation_map==min_elev);
[dminmax,~] = CoorDistance(lat_map(coorXMax ,coorYMax).*(convTorad),lng_map(coorXMax ,coorYMax).*(convTorad),elevation_map(coorXMax ,coorYMax),lat_map(coorXMin ,coorYMin).*(convTorad),lng_map(coorXMin ,coorYMin).*(convTorad),elevation_map(coorXMin ,coorYMin));
Rref = georefpostings([min(lat_map(:)),max(lat_map(:))],[min(lng_map(:)),max(lng_map(:))],[SAMPLES,SAMPLES],'ColumnsStartFrom','north');

%% ==========================CHANNAEL CAPACITY================================ %%

areaTotalkm2 = getArea(lat_map(1,1).*(convTorad),lng_map(1 ,1).*(convTorad),elevation_map(1 ,1).*(convTorad),[lat_map(1,SAMPLES).*(convTorad),lat_map(SAMPLES,1).*(convTorad)],[lng_map(1,SAMPLES).*(convTorad),lng_map(SAMPLES,1).*(convTorad)],[elevation_map(1,SAMPLES).*(convTorad),elevation_map(SAMPLES,1).*(convTorad)])/1e6;
[nCelulas,trafTotal,D,R,aCelula] = getNumChannels(20e3,0.8,0.3,0.03,0.10,areaTotalkm2,N);
[nCelulas,eficUt,x,y] = getHexCellind(nCelulas,SAMPLES,trafTotal);

%% ============================CHANNEL PROPAGATION============================= %%

antennas = ["omni" ,"06", "duo886", "14","duo4868"];

PrxT=NaN(SAMPLES,SAMPLES);
SIaux=zeros(SAMPLES,SAMPLES);
visgridALl = logical(zeros(SAMPLES,SAMPLES));

visgridAL2 = logical(zeros(SAMPLES,SAMPLES));

prcCvrAnt1=zeros(1,nCelulas);

%%
tic
prcCvr=0;
numAntenas=1;
visgridBuff = logical(zeros(SAMPLES,SAMPLES));
salto=50;
for i=1:salto:SAMPLES
    for j=1:salto:SAMPLES
        numAntenas=numAntenas+1;
        [visgrid(:,:,numAntenas),~] = viewshed(elevation_map,Rref,lat_map(i,j),lng_map(i,j),txAltura,rxAltura);
        prcCvrAnt1(i,j) = size(find(visgrid(:,:,numAntenas)==1),1)/(SAMPLES^2);
        prcBuff(numAntenas)=prcCvrAnt1(i,j);
    end
end
toc
%%
first=0;
indx=1:ceil(512/salto);
visgridaux=visgrid;
prcBuffOrder=sort(prcBuff,'descend');
n=2;
while (prcCvr<MINIUM_COVER_PERC)
    sobr=1;
    if(first==0)
        numAntenas=1;
        prcCvr=prcBuffOrder(1);
        [x(numAntenas),y(numAntenas)] = find(prcCvrAnt1==prcCvr);
        visgridAL2=visgrid(:,:,ceil(x(numAntenas)/salto) + (ceil(y(numAntenas)/salto)-1)*ceil(512/salto));
        first=1;
    else
        while(sobr>0.8)
           [x(numAntenas),y(numAntenas)] = find(prcCvrAnt1==prcBuffOrder(n));
            visgridBuff=visgrid(:,:,ceil(x(numAntenas)/salto) + (ceil(y(numAntenas)/salto)-1)*ceil(512/salto));
            sobr = size(find(visgridBuff & visgridAL2)==1 ,1) / size(find(visgridBuff)==1,1);
            n=n+1;
        end
        visgridAL2=visgridAL2 | visgridBuff;
        prcCvr = size(find(visgridAL2==1),1)/(SAMPLES^2);
    end
    numAntenas=1+numAntenas;
end
disp('Hey');
%%
for i = 1:numAntenas
    [lat_visible(:,:,i),lng_visible(:,:,i),elevation_visible(:,:,i),visgrid(:,:,i),d(:,:,i),vrtangles(:,:,i),lfs(:,:,i),hrzAngle(:,:,i),Gtx(:,:,i)]=cm_ParrachoMota(lat_map,lng_map,elevation_map,lat_map(x(i),y(i)),lng_map(x(i),y(i)),elevation_map(x(i),y(i)),rxAltura,txAltura,fc,'Free Space',SAMPLES,Rref);
    PrxBuff=Ptx+Gtx(:,:,i)+Grx-lfs(:,:,i);
    PrxBuff(PrxBuff<SENSIBILIDADE)=NaN;
    Prx(:,:,i)=PrxBuff;
    visgridALl = visgridALl | visgrid(:,:,i);
    
    prcCvrAnt(i) = size(find(visgrid(:,:,i)==1),1)/(SAMPLES^2);
    
    paux=10.^(Prx(:,:,i)./10);
    paux(find(isnan(paux))) = 0;
    SIaux = SIaux + paux;
end
visgrid=logical(visgrid);
[PrxT,bestServer]=max(Prx,[],3);
bestServer(~visgridALl)=NaN;

paux=10.^(PrxT./10);
for i = 1:numAntenas
    indSI=find(bestServer==i);
    SIaux(indSI) = SIaux(indSI) - paux(indSI);
end

SI = 10.*log10(paux./SIaux);
prcCvr = size(find(visgridALl==1),1)/(SAMPLES^2);

if (prcCvr<MINIUM_COVER_PERC)
     disp('Low Coverage - We are going insert more antennas');  
else
    disp('Acceptable Coverage'); 
end

%% ==========================GRAPHS================================= %%

disp('Displaying Data');
fprintf("Highest point:\n\t Latitude (º)= %.3f \n\t Longitude (º)=%.3f \n\t Elevation (m)=%.3f \n",lng_map(coorXMax,coorYMax), lat_map(coorXMax,coorYMax),max_elev)
fprintf("Lower point:\n\t Latitude (º)= %.3f \n\t Longitude (º)=%.3f \n\t Elevation (m)=%.3f \n",lng_map(coorXMin ,coorYMin), lat_map(coorXMin ,coorYMin),min_elev)
fprintf("Distance between the highest and lower point= %.3f meters\n",dminmax)
fprintf("Cell Radius = %.3f meters\n",R)
fprintf("Cell Distance (D)= %.3f km\n",D)
fprintf("Number of Cells = %.3f km\n",nCelulas)
fprintf("Area per Cell = %.3f km2\n",aCelula)

axis tight
surf(lng_map(1,:), lat_map(:,1), elevation_map,Prx(:,:,1), 'LineStyle' , ':');
colorbar

figure
meshc(lng_map(1,:), lat_map(:,1), Prx(:,:,i));
title('Model Hata')
colormap(parula(5))

figure
surf(lng_map(1,:), lat_map(:,1), elevation_map,PrxT(:,:,1), 'LineStyle' , ':');
title(['Pot�ncia (dBm) recebida no movel - Percentagem de cobertura=',num2str(prcCvr*100),' % - Num Antenas=',num2str(nCelulas)])

figure
surf(lng_map(1,:), lat_map(:,1), elevation_map,SI, 'LineStyle' , ':');
title(['Signal Interference ratio (dBm) - Num Antenas=',num2str(nCelulas)])
%% =======================KML===================================== %%

AA_func(max(lat_map(:)),min(lat_map(:)),min(lng_map(:)),max(lng_map(:)),PrxT,'urbanData')
AB_func(max(lat_map(:)),min(lat_map(:)),min(lng_map(:)),max(lng_map(:)),SI,'SI')
