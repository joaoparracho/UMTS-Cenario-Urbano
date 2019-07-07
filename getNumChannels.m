function [nCanais,trafTotal,eficUt,D,R] = getNumChannels(numPop,pPen,Putp,ut,gosD,aTotal,N)
load('erlangB_table.mat');   

trafTotal = numPop*pPen*Putp*ut;
nCanais = ErlangB_Circuits(trafTotal,gosD)

eficUt = trafTotal./nCanais

aCelula = aTotal/nCanais % km2

R = sqrt(2*aCelula/(3*sqrt(3)));
D = sqrt(3*N)*R; % km
end

