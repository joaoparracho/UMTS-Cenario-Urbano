function AA_func(LATITUDE_NORTH,LATITUDE_SOUTH,LONGITUDE_EAST,LONGITUDE_WEST,SIGNAL_COVERAGE_LEVELS,FILE_NAME)
Distance_Latitude = 20e3;
Distance_Longitude = 50e3;
LAT_OFFSET = (Distance_Latitude/2)/111111; % APROXIMATION
LONG_OFFSET = (Distance_Longitude/2)/86670; % APROXIMATION

SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_R = uint8(zeros(length(SIGNAL_COVERAGE_LEVELS(:,1)), length(SIGNAL_COVERAGE_LEVELS(1,:))));
SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_G = uint8(zeros(length(SIGNAL_COVERAGE_LEVELS(:,1)), length(SIGNAL_COVERAGE_LEVELS(1,:))));
SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_B = uint8(zeros(length(SIGNAL_COVERAGE_LEVELS(:,1)), length(SIGNAL_COVERAGE_LEVELS(1,:))));
Signal_levels_and_colors = [1e9     -10     254 000 000
                            -10     -20     255 127 000
                            -20     -30     254 165 000
                            -30     -40     254 206 000
                            -40     -50     255 255 000
                            -50     -60     184 255 000
                            -60     -70     000 255 001
                            -70     -80     000 208 000
                            -80     -90     000 197 194
                            -90     -100    000 148 254
                            -100    -110    080 080 254
                            -110    -120    000 038 255
                            -120    -130    143 063 255
                            -130    -140    196 053 255
                            -140    -150    254 001 252
                            -150    -200    255 193 204];
for LEVEL_index = 1 : length(Signal_levels_and_colors(:,1))
    LEVEL_MAX = Signal_levels_and_colors(LEVEL_index,1);
    LEVEL_MIN = Signal_levels_and_colors(LEVEL_index,2);
    
    SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_R(SIGNAL_COVERAGE_LEVELS<LEVEL_MAX & SIGNAL_COVERAGE_LEVELS>= LEVEL_MIN) = uint8(Signal_levels_and_colors(LEVEL_index,3));
    SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_G(SIGNAL_COVERAGE_LEVELS<LEVEL_MAX & SIGNAL_COVERAGE_LEVELS>= LEVEL_MIN) = uint8(Signal_levels_and_colors(LEVEL_index,4));
    SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_B(SIGNAL_COVERAGE_LEVELS<LEVEL_MAX & SIGNAL_COVERAGE_LEVELS>= LEVEL_MIN) = uint8(Signal_levels_and_colors(LEVEL_index,5));
end
SIGNAL_LEVEL_COVERAGE_MAP_IMAGE(:,:,1) = SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_R;
SIGNAL_LEVEL_COVERAGE_MAP_IMAGE(:,:,2) = SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_G;
SIGNAL_LEVEL_COVERAGE_MAP_IMAGE(:,:,3) = SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_B;

% imwrite(SIGNAL_LEVEL_COVERAGE_MAP_IMAGE,[FILE_NAME '.png']);


TRANSPARENCY_SIGNAL_COVERAGE_LEVELS = ones(size(SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_R));

SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_R_TRANSPARENT = SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_R;
SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_G_TRANSPARENT = SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_G;
SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_B_TRANSPARENT = SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_B;

INDEXES = find(SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_R == 0 & SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_G == 0 & SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_B == 0);

SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_R_TRANSPARENT(INDEXES) = 255;
SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_G_TRANSPARENT(INDEXES) = 255;
SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_B_TRANSPARENT(INDEXES) = 255;
TRANSPARENCY_SIGNAL_COVERAGE_LEVELS(INDEXES) = 0;


SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_TRANSPARENT(:,:,1) = SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_R_TRANSPARENT;
SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_TRANSPARENT(:,:,2) = SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_G_TRANSPARENT;
SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_TRANSPARENT(:,:,3) = SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_B_TRANSPARENT;

imwrite(SIGNAL_LEVEL_COVERAGE_MAP_IMAGE_TRANSPARENT,[FILE_NAME '.png'],'Alpha',TRANSPARENCY_SIGNAL_COVERAGE_LEVELS);


%% ========================================================================
%% Create KML file
%% ========================================================================
fid_write = fopen([FILE_NAME '.kml'],'w');
fprintf(fid_write,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid_write,'<kml xmlns="http://earth.google.com/kml/2.1">\n');
fprintf(fid_write,'  <Folder>\n');
fprintf(fid_write,'   <name>Signal level - %s</name>\n',FILE_NAME);
fprintf(fid_write,'       <GroundOverlay>\n');
fprintf(fid_write,'		<Icon>\n');
fprintf(fid_write,'              <href>%s.png</href>\n',FILE_NAME);
fprintf(fid_write,'		</Icon>\n');
fprintf(fid_write,'            <LatLonBox>\n');
fprintf(fid_write,'               <north>%s</north>\n',num2str(LATITUDE_NORTH));
fprintf(fid_write,'               <south>%s</south>\n',num2str(LATITUDE_SOUTH));
fprintf(fid_write,'               <east>%s</east>\n',num2str(LONGITUDE_EAST));
fprintf(fid_write,'               <west>%s</west>\n',num2str(LONGITUDE_WEST));
fprintf(fid_write,'               <rotation>0.0</rotation>\n');
fprintf(fid_write,'            </LatLonBox>\n');
fprintf(fid_write,'       </GroundOverlay>\n');
fprintf(fid_write,'       <ScreenOverlay>\n');
fprintf(fid_write,'          <name>Color Key</name>\n');
fprintf(fid_write,'            <description>Contour Color Key</description>\n');
fprintf(fid_write,'          <Icon>\n');
fprintf(fid_write,'            <href>z_Legend.jpg</href>\n');
fprintf(fid_write,'          </Icon>\n');
fprintf(fid_write,'          <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>\n');
fprintf(fid_write,'          <screenXY x="0" y="1" xunits="fraction" yunits="fraction"/>\n');
fprintf(fid_write,'          <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>\n');
fprintf(fid_write,'          <size x="0" y="0" xunits="fraction" yunits="fraction"/>\n');
fprintf(fid_write,'       </ScreenOverlay>\n');
fprintf(fid_write,'  </Folder>\n');
fprintf(fid_write,'</kml>\n');

fclose(fid_write);

end

