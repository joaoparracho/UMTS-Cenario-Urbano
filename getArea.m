function [A] = getArea(lat,lng,alt,lat2,lng2,alt2)
d=sqrt((alt-alt2).^2 + (2.*asin(sqrt(sin((lat-lat2)./2).^2 + cos(lat).*cos(lat2).*sin((lng-lng2)./2).^2)).* 6371000).^2);
A=d(1)*d(2);
end

