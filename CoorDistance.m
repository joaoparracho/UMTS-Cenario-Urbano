function [d,angles,az] = CoorDistance(lat,lng,alt,lat2,lng2,alt2)

d=sqrt((alt-alt2).^2 + (2.*asin(sqrt(sin((lat-lat2)./2).^2 + cos(lat).*cos(lat2).*sin((lng-lng2)./2).^2)).* 6371000).^2);

angles=asin((alt-alt2)./d).*180/pi;
angles(isnan(angles)==1)=0;

az = atan2(sin(lng2-lng).*cos(lat2) , cos(lat).*sin(lat2)-sin(lat).*cos(lat2).*cos(lng2-lng)).*180/pi;
az(az<0)=360+az(az<0);
end

