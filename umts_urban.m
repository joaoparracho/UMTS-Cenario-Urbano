clear 
close all

SAMPLES = 512;
NUM_ANTENAS = 4;
SENSIBILIDADE = -112.7;
MINIUM_COVER_PERC = 0.90;
load(['backup_Lisboa_' num2str(SAMPLES)]);
N=1;
Ptx=21; %dbm
Grx=0;
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
[nCanais,trafTotal,~,~,~] = getNumChannels(20e3,0.8,0.3,0.03,0.10,areaTotalkm2,N);
[nCanais,eficUt,~,~] = getHexCellind(nCanais,SAMPLES,trafTotal);

%% ============================CHANNEL PROPAGATION============================= %%

antennas = ["omni" ,"06", "duo886", "14","duo4868"];

PrxT=NaN(SAMPLES,SAMPLES);
SIaux=zeros(SAMPLES,SAMPLES);
visgridALl = logical(zeros(SAMPLES,SAMPLES));
visgridAL2 = logical(zeros(SAMPLES,SAMPLES));
prcCvrAnt1=zeros(SAMPLES,SAMPLES);

tic
prcCvr=0;
numAntenas=1;
visgridBuff = logical(zeros(SAMPLES,SAMPLES));
salto=50;
for i=1:salto:SAMPLES
    for j=salto:salto:SAMPLES       
        [visgrid(:,:,numAntenas),~] = viewshed(elevation_map,Rref,lat_map(i,j),lng_map(i,j),txAltura,rxAltura);
        prcCvrAnt1(i,j) = size(find(visgrid(:,:,numAntenas)==1),1)/(SAMPLES^2);
        prcBuff(numAntenas)=prcCvrAnt1(i,j);
        numAntenas=numAntenas+1;   
    end
end
toc
%%
% Primeira Antena a ser colocada é a que tem maior percentagem de cobertura
% De seguida é colocada a segunda com maior percentagem de cobertura e uma
% percentagem de sobreposição menor ou igual a 5 %
% Para todas antes, antes de ser calculada a sua percentagem de cobertura
% sao retirados os pontos com pontencias inferiores a da sensibilidade
%
first=0;
prcBuffOrder=sort(prcBuff,'descend');
n=2;
sbrbf=0;
prcCvr=0;
while (prcCvr<MINIUM_COVER_PERC && n<size(prcBuff,2))
    sobr=1;
    if(first==0)
        numAntenas=1;
        prcCvr=prcBuffOrder(1);
        [x(numAntenas),y(numAntenas)] = find(prcCvrAnt1==prcCvr);
        visgridAL2=visgrid(:,:,find(prcBuff==prcCvr)); 
        visgridBuff(:,:,1)=visgridAL2;
        [lat_visible(:,:,numAntenas),lng_visible(:,:,numAntenas),elevation_visible(:,:,numAntenas),visgrid(:,:,numAntenas),d(:,:,numAntenas),vrtangles(:,:,numAntenas),lfs(:,:,numAntenas),hrzAngle(:,:,numAntenas),Gtx(:,:,numAntenas)]=cm_ParrachoMota2(lat_map,lng_map,elevation_map,lat_map(x(numAntenas),y(numAntenas)),lng_map(x(numAntenas),y(numAntenas)),elevation_map(x(numAntenas),y(numAntenas)),rxAltura,txAltura,fc,'Hata',SAMPLES,Rref,visgridBuff(:,:,1),"Omni");
        PrxBuff=Ptx+Gtx(:,:,numAntenas)+Grx-lfs(:,:,numAntenas);
        visgridAL2(PrxBuff<SENSIBILIDADE)=0; 
        first=1;
    else
        while(sobr>0.95)
            sis=size(find(prcCvrAnt1==prcBuffOrder(n)),1);
            if (sis>1)
                [a b]=find(prcCvrAnt1==prcBuffOrder(n));
                for k = 1:size(a,1)
                     sbrbf1=visgrid(:,:,find(prcBuff==prcCvrAnt1(a(k),b(k))));
                     sbrbf(k)=size(find(sbrbf1 & visgridAL2)==1 ,1) / size(find(sbrbf1)==1,1);
                end
                x(numAntenas) = a(find(sbrbf==min(sbrbf)));
                y(numAntenas) = b(find(sbrbf==min(sbrbf)));
                sbrbf=[];
            else
                [x(numAntenas),y(numAntenas)] = find(prcCvrAnt1==prcBuffOrder(n));
            end
            visgridBuff(:,:,numAntenas)=visgrid(:,:,find(prcBuff==prcBuffOrder(n)));
            %Verificar a potencia
            
            [lat_visible(:,:,numAntenas),lng_visible(:,:,numAntenas),elevation_visible(:,:,numAntenas),visgrid(:,:,numAntenas),d(:,:,numAntenas),vrtangles(:,:,numAntenas),lfs(:,:,numAntenas),hrzAngle(:,:,numAntenas),Gtx(:,:,numAntenas)]=cm_ParrachoMota2(lat_map,lng_map,elevation_map,lat_map(x(numAntenas),y(numAntenas)),lng_map(x(numAntenas),y(numAntenas)),elevation_map(x(numAntenas),y(numAntenas)),rxAltura,txAltura,fc,'Hata',SAMPLES,Rref,visgridBuff(:,:,numAntenas),"Omni");
            PrxBuff=Ptx+Gtx(:,:,numAntenas)+Grx-lfs(:,:,numAntenas);
            
            vB=visgridBuff(:,:,numAntenas);
            vB(PrxBuff<SENSIBILIDADE)=0;
            visgridBuff(:,:,numAntenas)=vB;
            
            sobr = size(find(visgridBuff(:,:,numAntenas) & visgridAL2)==1 ,1) / size(find(visgridBuff(:,:,numAntenas))==1,1);
            n=n+1;
            if(n>=size(prcBuff,2))
                break;
            end
        end
        if(n<size(prcBuff,2))
            visgridAL2=visgridAL2 | logical(visgridBuff(:,:,numAntenas));
            prcCvr = size(find(visgridAL2==1),1)/(SAMPLES^2);        
            [lat_visible(:,:,numAntenas),lng_visible(:,:,numAntenas),elevation_visible(:,:,numAntenas),visgrid(:,:,numAntenas),d(:,:,numAntenas),vrtangles(:,:,numAntenas),lfs(:,:,numAntenas),hrzAngle(:,:,numAntenas),Gtx(:,:,numAntenas)]=cm_ParrachoMota2(lat_map,lng_map,elevation_map,lat_map(x(numAntenas),y(numAntenas)),lng_map(x(numAntenas),y(numAntenas)),elevation_map(x(numAntenas),y(numAntenas)),rxAltura,txAltura,fc,'Hata',SAMPLES,Rref,visgridBuff(:,:,numAntenas),"Omni");
        end
    end
    if(n<size(prcBuff,2))
        
        PrxBuff=Ptx+Gtx(:,:,numAntenas)+Grx-lfs(:,:,numAntenas);
        PrxBuff(PrxBuff<SENSIBILIDADE)=NaN;
        Prx(:,:,numAntenas)=PrxBuff;
        %visgridALl = visgridALl | visgrid(:,:,numAntenas);

        prcCvrAnt(numAntenas) = size(find(visgrid(:,:,numAntenas)==1),1)/(SAMPLES^2);

        paux=10.^(Prx(:,:,numAntenas)./10);
        paux(find(isnan(paux))) = 0;
        SIaux = SIaux + paux;

        numAntenas=1+numAntenas;
    end
end
numAntenas=numAntenas-1;
%%
visgrid=logical(visgrid);
[PrxT,bestServer]=max(Prx,[],3);
bestServer(~visgridAL2)=NaN;

paux=10.^(PrxT./10);
for i = 1:numAntenas
    indSI=find(bestServer==i);
    SIaux(indSI) = SIaux(indSI) - paux(indSI);
end

SI = 10.*log10(paux./SIaux);


if (prcCvr<MINIUM_COVER_PERC)
     disp('Low Coverage - We are going insert more antennas');  
else
    disp('Acceptable Coverage'); 
end


aCelula = areaTotalkm2/numAntenas;
R = sqrt(2*aCelula/(3*sqrt(3)));
D = sqrt(3*N)*R; % km
%% ==========================GRAPHS================================= %%

disp('Displaying Data');
fprintf("Highest point:\n\t Latitude (Âº)= %.3f \n\t Longitude (Âº)=%.3f \n\t Elevation (m)=%.3f \n",lng_map(coorXMax,coorYMax), lat_map(coorXMax,coorYMax),max_elev)
fprintf("Lower point:\n\t Latitude (Âº)= %.3f \n\t Longitude (Âº)=%.3f \n\t Elevation (m)=%.3f \n",lng_map(coorXMin ,coorYMin), lat_map(coorXMin ,coorYMin),min_elev)
fprintf("Distance between the highest and lower point= %.3f meters\n",dminmax)
fprintf("Cell Radius = %.3f meters\n",R)
fprintf("Cell Distance (D)= %.3f km\n",D)
fprintf("Number of Channels needed = %.3f km\n",nCanais)
fprintf("Area per Cell = %.3f km2\n",aCelula)


figure
surf(lng_map(1,:), lat_map(:,1), elevation_map,PrxT(:,:,1), 'LineStyle' , ':');
title(['Potência (dBm) recebida no movel - Percentagem de cobertura=',num2str(prcCvr*100),' % - Num Antenas=',num2str(numAntenas)])

figure
surf(lng_map(1,:), lat_map(:,1), elevation_map,bestServer, 'LineStyle' , ':');
title(['BestServer - Num Antenas=',num2str(numAntenas)])

figure
surf(lng_map(1,:), lat_map(:,1), elevation_map,SI, 'LineStyle' , ':');
title(['Signal Interference ratio (dBm) - Num Antenas=',num2str(numAntenas)])
%% =======================KML===================================== %%

AA_func(max(lat_map(:)),min(lat_map(:)),min(lng_map(:)),max(lng_map(:)),PrxT,'urbanData')
AB_func(max(lat_map(:)),min(lat_map(:)),min(lng_map(:)),max(lng_map(:)),SI,'SI')
