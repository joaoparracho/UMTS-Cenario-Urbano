function [Gtx] = getGtxAntennasPM(az,ele,type)
load('Antenas.mat');
switch type
    case 'Allgon792085004'
        Ga = reshape(Allgon792085004.Ga,360,181)'; 
    case 'Allgon792085006'
        Ga = reshape(Allgon792085006.Ga,360,181)';
    case 'Allgon792085010'
        Ga = reshape(Allgon792085010.Ga,360,181)';
    case 'Allgon792085014'
        Ga = reshape(Allgon792085014.Ga,360,181)';
    case 'DUO4606000850'
        Ga = reshape(DUO4606000850.Ga,360,181)';
    case 'DUO4786500850'
        Ga = reshape(DUO4786500850.Ga,360,181)';
    case 'DUO4867000850'
        Ga = reshape(DUO4867000850.Ga,360,181)';
    case 'DUO4868600850'
        Ga = reshape(DUO4868600850.Ga,360,181)';
    case 'DUO8606000850'
        Ga = reshape(DUO8606000850.Ga,360,181)';
    case 'DUO8786500850'
        Ga = reshape(DUO8786500850.Ga,360,181)';
    case 'DUO8867000850'
        Ga = reshape(DUO8867000850.Ga,360,181)';
    case 'Omni'
        Ga = zeros(360,181);
end
 
xVert = round(ele);
xVert(xVert<0) = abs(xVert(xVert<0) - 90);
yHor = round(az);
yHor(yHor==360)=0;
Gtx = Ga(xVert + 1 + yHor.*181);
end

