function [nCelulas,trafTotal,D,R,aCelula] = getNumChannels(numPop,pPen,Putp,ut,gosD,aTotal,N)
%load('erlangB_table.mat');   

trafTotal = numPop*pPen*Putp*ut;
nCelulas = ErlangB_Circuits(trafTotal,gosD);
aCelula = aTotal/nCelulas; % km2

R = sqrt(2*aCelula/(3*sqrt(3)));
D = sqrt(3*N)*R; % km
end

