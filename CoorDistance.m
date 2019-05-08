function [d,angles] = CoorDistance(lat,lng,alt,lat2,lng2,alt2)

d=sqrt((alt-alt2).^2 + (2.*asin(sqrt(sin((lat-lat2)./2).^2 + cos(lat).*cos(lat2).*sin((lng-lng2)./2).^2)).* 6371000).^2);

angles=mod(acos((abs(alt-alt2))./d).*180/pi,360);

angles(isnan(angles)==1)=1;
end

