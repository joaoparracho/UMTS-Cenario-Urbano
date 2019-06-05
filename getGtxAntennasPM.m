function [Gtx] = getGtxAntennasPM(az,ele,type)
load('D:\IPL\IPL\3ºano\ComunicacoesMoveis\Scripts\UMTS_Urban\Antenas.mat');
switch type
    case '04'
        Ga = reshape(Allgon792085004.Ga,360,181)'; 
    case '06'
        Ga = reshape(Allgon792085006.Ga,360,181)';
    case '10'
        Ga = reshape(Allgon792085010.Ga,360,181)';
    case '14'
        Ga = reshape(Allgon792085014.Ga,360,181)';
    case 'duo460'
        Ga = reshape(DUO4606000850.Ga,360,181)';
    case 'duo478'
        Ga = reshape(DUO4786500850.Ga,360,181)';
    case 'duo4867'
        Ga = reshape(DUO4867000850.Ga,360,181)';
    case 'duo4868'
        Ga = reshape(DUO4868600850.Ga,360,181)';
    case 'duo860'
        Ga = reshape(DUO8606000850.Ga,360,181)';
    case 'duo786'
        Ga = reshape(DUO8786500850.Ga,360,181)';
    case 'duo886'
        Ga = reshape(DUO8867000850.Ga,360,181)';
    case 'omni'
        Ga = zeros(360,181);
end
 
xVert = round(ele);
xVert(xVert<0) = abs(xVert(xVert<0) - 90);
yHor = round(az);
yHor(yHor==360)=0;
Gtx = Ga(xVert + 1 + yHor.*181);
end

