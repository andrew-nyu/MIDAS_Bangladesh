clear all;
close all; 

load outputArrays
load midasLocations.mat

coastalMatrixIDs = [1 3 4 7 9 12 16 19 22 23 27 31 40 46 49 50 55 56 63];

bumpMin = 0.07;
bumpMax = 0.12;
distMin = 0.3;
distMax = 0.7;
points = 60;
qLevel = 0.99;
minWidth = 1;
headLength = 3;
transp = 0.4;

credit  = [];
flood = [];
temp1 = RCP26.migrationArray;
for indexI = 1:size(temp1,3)
    temp1(:,:,indexI) = (temp1(:,:,indexI) - temp1(:,:,indexI)') / sum(RCP26.popMatrixLocation(indexI,:));
    credit(end+1) =  table2array(RCP26.input{indexI}(9,2));
    flood(end+1) =  table2array(RCP26.input{indexI}(68,2));
end

temp2 = RCP45.migrationArray;
for indexI = 1:size(temp2,3)
    temp2(:,:,indexI) = (temp2(:,:,indexI) - temp2(:,:,indexI)') / sum(RCP45.popMatrixLocation(indexI,:));
    credit(end+1) =  table2array(RCP45.input{indexI}(9,2));
    flood(end+1) =  table2array(RCP45.input{indexI}(68,2));
end

temp3 = RCP85.migrationArray;
for indexI = 1:size(temp3,3)
    temp3(:,:,indexI) = (temp3(:,:,indexI) - temp3(:,:,indexI)') / sum(RCP85.popMatrixLocation(indexI,:));
    credit(end+1) =  table2array(RCP85.input{indexI}(9,2));
    flood(end+1) =  table2array(RCP85.input{indexI}(68,2));
end

temp = cat(3,temp1,temp2, temp3);

ttestMat = zeros(64);
for indexI = 1:64
    for indexJ = 1:64
        ttestMat(indexI, indexJ) = ttest(reshape(temp(indexI,indexJ,:),size(temp,3),1),0, 'alpha',0.001);
    end
end

tempHi= temp(:,:,credit > 0.6);
ttestMatHi = zeros(64);
for indexI = 1:64
    for indexJ = 1:64
        ttestMatHi(indexI, indexJ) = ttest(reshape(tempHi(indexI,indexJ,:),size(tempHi,3),1),0, 'alpha',0.001);
    end
end

tempLow = temp(:,:,credit < 0.3);
ttestMatLow = zeros(64);
for indexI = 1:64
    for indexJ = 1:64
        ttestMatLow(indexI, indexJ) = ttest(reshape(tempLow(indexI,indexJ,:),size(tempLow,3),1),0, 'alpha',0.001);
    end
end
    
a = mean(tempLow,3);
b = mean(tempHi,3);
a(a < quantile(a(:),.998)) = 0;
b(b < quantile(b(:),.998)) = 0;

%%%

tempHiFlood = temp(:,:,flood > 1);
ttestMatHiF = zeros(64);
for indexI = 1:64
    for indexJ = 1:64
        ttestMatHiF(indexI, indexJ) = ttest(reshape(tempHiFlood(indexI,indexJ,:),size(tempHiFlood,3),1),0, 'alpha',0.001);
    end
end

tempLowFlood = temp(:,:,flood < 0.5);
ttestMatLowF = zeros(64);
for indexI = 1:64
    for indexJ = 1:64
        ttestMatLowF(indexI, indexJ) = ttest(reshape(tempLowFlood(indexI,indexJ,:),size(tempLowFlood,3),1),0, 'alpha',0.001);
    end
end
  


a = mean(tempLow,3);
b = mean(tempHi,3);
g = b - a;
a(a < quantile(a(:),qLevel)) = 0;
b(b < quantile(b(:),qLevel)) = 0;
g(g < quantile(g(:),qLevel)) = 0;

c = mean(tempLowFlood,3);
d = mean(tempHiFlood,3);
f = d - c;
c(c < quantile(c(:),qLevel)) = 0;
d(d < quantile(d(:),qLevel)) = 0;
f(f < quantile(f(:),qLevel)) = 0;

e = mean(temp,3);
e(e < quantile(e(:),qLevel)) = 0;

%%%

% close all;
% figure; imagesc(e);
% figure; subplot(1,2,1); imagesc(a); subplot(1,2,2); imagesc(b); title('credit');
% figure; subplot(1,2,1); imagesc(c); subplot(1,2,2); imagesc(d); title('flood');
% 

%%%%%
    
worldMap = shaperead('world_countries_2017.shp');
worldMap = worldMap([72 74 86 95]);
banDist = shaperead('ipums_district_level.shp');
banCoast = banDist(coastalMatrixIDs);

redBlue = ones(101,3);
redBlue(1:50,2) = 0.02:0.02:1;
redBlue(1:50,3) = 0.02:0.02:1;
redBlue(52:101,1) = 1:-0.02:0.02;
redBlue(52:101,2) = 1:-0.02:0.02;

close all;

ax1 = figure;

tempMean = mean(temp,3);
tempList =  sum(tempMean)' - sum(tempMean,2);

temp2_ = num2cell(tempList');
[banDist.temp2] = temp2_{:};
temp2Colors = makesymbolspec('Polygon', {'temp2', [-.1 .1], 'FaceColor', redBlue});
mapshow(worldMap,'EdgeColor',[0.7 0.7 0.7], 'FaceColor',[0.8 0.8 0.8]);

hold on;
mapshow(banDist, 'DisplayType', 'polygon', ...
   'SymbolSpec', temp2Colors);
mapshow(banCoast,'DisplayType','polygon','LineWidth',3,'FaceAlpha',0,'EdgeColor',[0 0.5 0.5]);
caxis([-.1 .1]); 
axis([88 93 20 27]);
colormap(ax1, redBlue)
ylabel('Latitude (Degrees)');
xlabel('Longitude (Degrees)');

h = colorbar;
set(get(h,'label'),'string',{'Relative change in district population'; '(as fraction of total Bangladesh population)'},'FontSize',14)
% for indexI = 1:64
%     text(banDist(indexI).Longitude, banDist(indexI).Latitude,banDist(indexI).ADMIN_NAME);
% end
dhaka = plot(90.4125, 23.8103,'o','MarkerSize',10, 'MarkerEdgeColor','k','LineWidth',2,'MarkerFaceColor','w');
dhaka_name = text(90.5125, 23.8253,'Dhaka','FontSize',12,'FontWeight','bold');

[i,j,v] = find(e);
lonI = [banDist(i).Longitude]';
latI = [banDist(i).Latitude]';

lonJ = [banDist(j).Longitude]';
latJ = [banDist(j).Latitude]';
hold on;
for indexI = 1:length(i)
    
    dist = distMin + (distMax-distMin) * rand();
    bump = bumpMin + (bumpMax-bumpMin) * rand();
    latOrig = latI(indexI);
    latDest = latJ(indexI);
    lonOrig = lonI(indexI);
    lonDest = lonJ(indexI);
    slope = (latDest - latOrig) / (lonDest - lonOrig);
    origin = [lonOrig latOrig];
    %shift it to origin
    latDest = latDest - latOrig;
    lonDest = lonDest - lonOrig;
    %rotate it flat
    theta = atand(slope);
    rotMat = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    latLonRot = [lonDest latDest] * rotMat;
    
    %verify that lat is now 0 or close to it
    midLon = dist * latLonRot(1);
    midLat = dist * latLonRot(2);
    
    %actual midLat will be our bump
    midLat = bump * latLonRot(1);
    
    spacing = latLonRot(1) / points;
    
    lonList = 0:spacing:latLonRot(1);
    latList = spline([0 midLon latLonRot(1)], [0 midLat 0], lonList);
    
    %reverse rotate it
    rotMat = [cosd(-theta) -sind(-theta); sind(-theta) cosd(-theta)];
    latLonRot = [lonList' latList'] * rotMat;
    
    %reverse shift
    latLonRot(:,1) = latLonRot(:,1) + lonOrig;
    latLonRot(:,2) = latLonRot(:,2) + latOrig;

    arcX = latLonRot(:,1);
    arcY = latLonRot(:,2);
%     slope = (latJ(indexI) - latI(indexI)) / (lonJ(indexI) - lonI(indexI));
%     midX = lonI(indexI) + dist * (lonJ(indexI) - lonI(indexI));
%     midY = latI(indexI) + dist * (latJ(indexI) - latI(indexI));
%     length = sqrt((latJ(indexI) - latI(indexI))^2 + (lonJ(indexI) - lonI(indexI))^2);
%     delX = - bump * length * slope;
%     delY = - delX / slope;
%     spacing = (lonJ(indexI) - lonI(indexI))/points;
%     arcY = interp1([lonI(indexI) midX + delX lonJ(indexI)], [latI(indexI) midY + delY latJ(indexI)], lonI(indexI):spacing:lonJ(indexI),'makima');
%     arcX = lonI(indexI):spacing:lonJ(indexI);
    h = plot(arcX, arcY);
    set(h, 'Color', [0 0 0 transp],'LineWidth',v(indexI)/min(v)*minWidth);
    h = arrow('Start',[arcX(end-1) arcY(end-1)],'Stop',[arcX(end) arcY(end)],'Width',v(indexI)/min(v)*minWidth,'Length',v(indexI)/min(v)*headLength);
    set(h,'EdgeAlpha',transp,'FaceAlpha',transp);
end
set(gcf,'Position',[20 -20 800 1000]);
set(gca,'FontSize',14);
title({'Average net-migration, 2010-2100 (as fraction of population)'; ['(average over all simulations, showing ' num2str(length(i)) ' largest flows)' ]});

% 
% d = plot(91.7832, 22.3569,'o','MarkerSize',10);
% set(d,'MarkerEdgeColor','k','LineWidth',2,'MarkerFaceColor','w');
% e = text(91.8832, 22.3719,'Chittagong','FontSize',12,'FontWeight','bold')
% 
% d = plot(88.6042, 24.3745,'o','MarkerSize',10);
% set(d,'MarkerEdgeColor','k','LineWidth',2,'MarkerFaceColor','w');
% e = text(88.7042, 24.3895,'Rajshahi','FontSize',12,'FontWeight','bold')
% 
% d = plot(89.5403, 22.8456,'o','MarkerSize',10);
% set(d,'MarkerEdgeColor','k','LineWidth',2,'MarkerFaceColor','w');
% e = text(89.6403, 22.8606,'Khulna','FontSize',12,'FontWeight','bold')
%%%%%%%%%%%%%%%%%



tempMat = {temp1, temp2, temp3};

nameList = {'RCP2.6','RCP4.5','RCP8.5'};
letterList = {'A','B','C'};


for indexX = 1:3
    ax1 = figure; %subplot(1,3,indexX)
    
    %subplot('Position',[0.025 + (indexX-1)*0.32 0.025 0.3 0.9])
    current = tempMat{indexX};
    
    e = mean(current,3);
e(e < quantile(e(:),qLevel)) = 0;

tempMean = mean(current,3);
tempList =  sum(tempMean)' - sum(tempMean,2);

temp2_ = num2cell(tempList');
[banDist.temp2] = temp2_{:};
temp2Colors = makesymbolspec('Polygon', {'temp2', [-.1 .1], 'FaceColor', redBlue});
mapshow(worldMap,'EdgeColor',[0.7 0.7 0.7], 'FaceColor',[0.8 0.8 0.8]);

hold on;
mapshow(banDist, 'DisplayType', 'polygon', ...
   'SymbolSpec', temp2Colors);
mapshow(banCoast,'DisplayType','polygon','LineWidth',3,'FaceAlpha',0,'EdgeColor',[0 0.5 0.5]);
text(88.5,20.5,letterList{indexX},'FontSize', 18);
caxis([-.1 .1]); 
axis([88 93 20 27]);
colormap(ax1, redBlue)
colorbar
ylabel('Latitude (Degrees)');
xlabel('Longitude (Degrees)');

h = colorbar;
set(get(h,'label'),'string',{'Relative change in district population'; '(as fraction of total Bangladesh population)'},'FontSize',14)
% for indexI = 1:64
%     text(banDist(indexI).Longitude, banDist(indexI).Latitude,banDist(indexI).ADMIN_NAME);
% end
dhaka = plot(90.4125, 23.8103,'o','MarkerSize',10, 'MarkerEdgeColor','k','LineWidth',2,'MarkerFaceColor','w');
dhaka_name = text(90.5125, 23.8253,'Dhaka','FontSize',12,'FontWeight','bold');


[i,j,v] = find(e);
lonI = [banDist(i).Longitude]';
latI = [banDist(i).Latitude]';

lonJ = [banDist(j).Longitude]';
latJ = [banDist(j).Latitude]';
hold on;
for indexI = 1:length(i)
    
    dist = distMin + (distMax-distMin) * rand();
    bump = bumpMin + (bumpMax-bumpMin) * rand();
    latOrig = latI(indexI);
    latDest = latJ(indexI);
    lonOrig = lonI(indexI);
    lonDest = lonJ(indexI);
    slope = (latDest - latOrig) / (lonDest - lonOrig);
    origin = [lonOrig latOrig];
    %shift it to origin
    latDest = latDest - latOrig;
    lonDest = lonDest - lonOrig;
    %rotate it flat
    theta = atand(slope);
    rotMat = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    latLonRot = [lonDest latDest] * rotMat;
    
    %verify that lat is now 0 or close to it
    midLon = dist * latLonRot(1);
    midLat = dist * latLonRot(2);
    
    %actual midLat will be our bump
    midLat = bump * latLonRot(1);
    
    spacing = latLonRot(1) / points;
    
    lonList = 0:spacing:latLonRot(1);
    latList = spline([0 midLon latLonRot(1)], [0 midLat 0], lonList);
    
    %reverse rotate it
    rotMat = [cosd(-theta) -sind(-theta); sind(-theta) cosd(-theta)];
    latLonRot = [lonList' latList'] * rotMat;
    
    %reverse shift
    latLonRot(:,1) = latLonRot(:,1) + lonOrig;
    latLonRot(:,2) = latLonRot(:,2) + latOrig;

    arcX = latLonRot(:,1);
    arcY = latLonRot(:,2);
%     slope = (latJ(indexI) - latI(indexI)) / (lonJ(indexI) - lonI(indexI));
%     midX = lonI(indexI) + dist * (lonJ(indexI) - lonI(indexI));
%     midY = latI(indexI) + dist * (latJ(indexI) - latI(indexI));
%     length = sqrt((latJ(indexI) - latI(indexI))^2 + (lonJ(indexI) - lonI(indexI))^2);
%     delX = - bump * length * slope;
%     delY = - delX / slope;
%     spacing = (lonJ(indexI) - lonI(indexI))/points;
%     arcY = interp1([lonI(indexI) midX + delX lonJ(indexI)], [latI(indexI) midY + delY latJ(indexI)], lonI(indexI):spacing:lonJ(indexI),'makima');
%     arcX = lonI(indexI):spacing:lonJ(indexI);
    h = plot(arcX, arcY);
    set(h, 'Color', [0 0 0 transp],'LineWidth',v(indexI)/min(v)*minWidth);
    h = arrow('Start',[arcX(end-1) arcY(end-1)],'Stop',[arcX(end) arcY(end)],'Width',v(indexI)/min(v)*minWidth,'Length',v(indexI)/min(v)*headLength);
    set(h,'EdgeAlpha',transp,'FaceAlpha',transp);
end
set(gcf,'Position',[20 -20 800 1000]);
set(gca,'FontSize',14);
%title({'Average net-migration, 2010-2100 (as fraction of population)'; [nameList{indexX} ', showing ' num2str(length(i)) ' largest flows)' ]});

end


%%%%%%%%%%%%%%%%%

ax1 = figure;

%subplot('Position',[0.02 0.05 0.46 0.9]);
tempMean = mean(tempLow,3);
tempList =  sum(tempMean)' - sum(tempMean,2);

temp2_ = num2cell(tempList');
[banDist.temp2] = temp2_{:};
temp2Colors = makesymbolspec('Polygon', {'temp2', [-.1 .1], 'FaceColor', redBlue});
mapshow(worldMap,'EdgeColor',[0.7 0.7 0.7], 'FaceColor',[0.8 0.8 0.8]);

hold on;
mapshow(banDist, 'DisplayType', 'polygon', ...
   'SymbolSpec', temp2Colors);
hold on;
mapshow(banCoast,'DisplayType','polygon','LineWidth',3,'FaceAlpha',0,'EdgeColor',[0 0.5 0.5]);
caxis([-.1 .1]); 
axis([88 93 20 27]);
colormap(ax1, redBlue)
colorbar
ylabel('Latitude (Degrees)');
xlabel('Longitude (Degrees)');

h = colorbar;
set(get(h,'label'),'string',{'Relative change in district population'; '(as fraction of total Bangladesh population)'},'FontSize',14)
% for indexI = 1:64
%     text(banDist(indexI).Longitude, banDist(indexI).Latitude,banDist(indexI).ADMIN_NAME);
% end
dhaka = plot(90.4125, 23.8103,'o','MarkerSize',10, 'MarkerEdgeColor','k','LineWidth',2,'MarkerFaceColor','w');
dhaka_name = text(90.5125, 23.8253,'Dhaka','FontSize',12,'FontWeight','bold');

hold on;
[i,j,v] = find(a);
lonI = [banDist(i).Longitude]';
latI = [banDist(i).Latitude]';

lonJ = [banDist(j).Longitude]';
latJ = [banDist(j).Latitude]';

hold on;
for indexI = 1:length(i)
    
    dist = distMin + (distMax-distMin) * rand();
    bump = bumpMin + (bumpMax-bumpMin) * rand();
    latOrig = latI(indexI);
    latDest = latJ(indexI);
    lonOrig = lonI(indexI);
    lonDest = lonJ(indexI);
    slope = (latDest - latOrig) / (lonDest - lonOrig);
    origin = [lonOrig latOrig];
    %shift it to origin
    latDest = latDest - latOrig;
    lonDest = lonDest - lonOrig;
    %rotate it flat
    theta = atand(slope);
    rotMat = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    latLonRot = [lonDest latDest] * rotMat;
    
    %verify that lat is now 0 or close to it
    midLon = dist * latLonRot(1);
    midLat = dist * latLonRot(2);
    
    %actual midLat will be our bump
    midLat = bump * latLonRot(1);
    
    spacing = latLonRot(1) / points;
    
    lonList = 0:spacing:latLonRot(1);
    latList = spline([0 midLon latLonRot(1)], [0 midLat 0], lonList);
    
    %reverse rotate it
    rotMat = [cosd(-theta) -sind(-theta); sind(-theta) cosd(-theta)];
    latLonRot = [lonList' latList'] * rotMat;
    
    %reverse shift
    latLonRot(:,1) = latLonRot(:,1) + lonOrig;
    latLonRot(:,2) = latLonRot(:,2) + latOrig;

    arcX = latLonRot(:,1);
    arcY = latLonRot(:,2);
%     slope = (latJ(indexI) - latI(indexI)) / (lonJ(indexI) - lonI(indexI));
%     midX = lonI(indexI) + dist * (lonJ(indexI) - lonI(indexI));
%     midY = latI(indexI) + dist * (latJ(indexI) - latI(indexI));
%     length = sqrt((latJ(indexI) - latI(indexI))^2 + (lonJ(indexI) - lonI(indexI))^2);
%     delX = - bump * length * slope;
%     delY = - delX / slope;
%     spacing = (lonJ(indexI) - lonI(indexI))/points;
%     arcY = interp1([lonI(indexI) midX + delX lonJ(indexI)], [latI(indexI) midY + delY latJ(indexI)], lonI(indexI):spacing:lonJ(indexI),'makima');
%     arcX = lonI(indexI):spacing:lonJ(indexI);
    h = plot(arcX, arcY);
    set(h, 'Color', [0 0 0 transp],'LineWidth',v(indexI)/min(v)*minWidth);
    h = arrow('Start',[arcX(end-1) arcY(end-1)],'Stop',[arcX(end) arcY(end)],'Width',v(indexI)/min(v)*minWidth,'Length',v(indexI)/min(v)*headLength);
    set(h,'EdgeAlpha',transp,'FaceAlpha',transp);
end
title('Credit access < 0.3 * Utility layer investment');
text(88.5,20.5,'A','FontSize', 18);
set(gca,'FontSize',14);
set(gcf,'Position',[20 -20 800 1000]);

ax1 = figure;

tempMean = mean(tempHi,3);
tempList =  sum(tempMean)' - sum(tempMean,2);

temp2_ = num2cell(tempList');
[banDist.temp2] = temp2_{:};
temp2Colors = makesymbolspec('Polygon', {'temp2', [-.1 .1], 'FaceColor', redBlue});
mapshow(worldMap,'EdgeColor',[0.7 0.7 0.7], 'FaceColor',[0.8 0.8 0.8]);

hold on;
mapshow(banDist, 'DisplayType', 'polygon', ...
   'SymbolSpec', temp2Colors);
mapshow(banCoast,'DisplayType','polygon','LineWidth',3,'FaceAlpha',0,'EdgeColor',[0 0.5 0.5]);
caxis([-.1 .1]); 
axis([88 93 20 27]);
colormap(ax1, redBlue)
colorbar
ylabel('Latitude (Degrees)');
xlabel('Longitude (Degrees)');

h = colorbar;
set(get(h,'label'),'string',{'Relative change in district population'; '(as fraction of total Bangladesh population)'},'FontSize',14)
% for indexI = 1:64
%     text(banDist(indexI).Longitude, banDist(indexI).Latitude,banDist(indexI).ADMIN_NAME);
% end
dhaka = plot(90.4125, 23.8103,'o','MarkerSize',10, 'MarkerEdgeColor','k','LineWidth',2,'MarkerFaceColor','w');
dhaka_name = text(90.5125, 23.8253,'Dhaka','FontSize',12,'FontWeight','bold');

[i,j,v] = find(b);
lonI = [banDist(i).Longitude]';
latI = [banDist(i).Latitude]';

lonJ = [banDist(j).Longitude]';
latJ = [banDist(j).Latitude]';

hold on;
for indexI = 1:length(i)
    
    dist = distMin + (distMax-distMin) * rand();
    bump = bumpMin + (bumpMax-bumpMin) * rand();
    latOrig = latI(indexI);
    latDest = latJ(indexI);
    lonOrig = lonI(indexI);
    lonDest = lonJ(indexI);
    slope = (latDest - latOrig) / (lonDest - lonOrig);
    origin = [lonOrig latOrig];
    %shift it to origin
    latDest = latDest - latOrig;
    lonDest = lonDest - lonOrig;
    %rotate it flat
    theta = atand(slope);
    rotMat = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    latLonRot = [lonDest latDest] * rotMat;
    
    %verify that lat is now 0 or close to it
    midLon = dist * latLonRot(1);
    midLat = dist * latLonRot(2);
    
    %actual midLat will be our bump
    midLat = bump * latLonRot(1);
    
    spacing = latLonRot(1) / points;
    
    lonList = 0:spacing:latLonRot(1);
    latList = spline([0 midLon latLonRot(1)], [0 midLat 0], lonList);
    
    %reverse rotate it
    rotMat = [cosd(-theta) -sind(-theta); sind(-theta) cosd(-theta)];
    latLonRot = [lonList' latList'] * rotMat;
    
    %reverse shift
    latLonRot(:,1) = latLonRot(:,1) + lonOrig;
    latLonRot(:,2) = latLonRot(:,2) + latOrig;

    arcX = latLonRot(:,1);
    arcY = latLonRot(:,2);
%     slope = (latJ(indexI) - latI(indexI)) / (lonJ(indexI) - lonI(indexI));
%     midX = lonI(indexI) + dist * (lonJ(indexI) - lonI(indexI));
%     midY = latI(indexI) + dist * (latJ(indexI) - latI(indexI));
%     length = sqrt((latJ(indexI) - latI(indexI))^2 + (lonJ(indexI) - lonI(indexI))^2);
%     delX = - bump * length * slope;
%     delY = - delX / slope;
%     spacing = (lonJ(indexI) - lonI(indexI))/points;
%     arcY = interp1([lonI(indexI) midX + delX lonJ(indexI)], [latI(indexI) midY + delY latJ(indexI)], lonI(indexI):spacing:lonJ(indexI),'makima');
%     arcX = lonI(indexI):spacing:lonJ(indexI);
    h = plot(arcX, arcY);
    set(h, 'Color', [0 0 0 transp],'LineWidth',v(indexI)/min(v)*minWidth);
    h = arrow('Start',[arcX(end-1) arcY(end-1)],'Stop',[arcX(end) arcY(end)],'Width',v(indexI)/min(v)*minWidth,'Length',v(indexI)/min(v)*headLength);
    set(h,'EdgeAlpha',transp,'FaceAlpha',transp);
end
title('Credit access >= 0.6 * Utility layer investment');
text(88.5,20.5,'B','FontSize', 18);
%suptitle({'Average net-migration, 2010-2100 (as fraction of population)'; ['(showing ' num2str(length(i)) ' largest flows)' ]});
set(gcf,'Position',[20 -20 800 1000]);
set(gca,'FontSize',14);

%%%%%%%%%%%%%%%%
ax1 = figure; %subplot('Position',[0.54 0.05 0.46 0.9]);

tempMean1 = mean(tempLow,3);
tempList1 =  sum(tempMean1)' - sum(tempMean1,2);

tempMean2 = mean(tempHi,3);
tempList2 =  sum(tempMean2)' - sum(tempMean2,2);

tempList = tempList2 - tempList1;


temp2_ = num2cell(tempList');
[banDist.temp2] = temp2_{:};
temp2Colors = makesymbolspec('Polygon', {'temp2', [-.007 .007], 'FaceColor', redBlue});
mapshow(worldMap,'EdgeColor',[0.7 0.7 0.7], 'FaceColor',[0.8 0.8 0.8]);

hold on;
mapshow(banDist, 'DisplayType', 'polygon', ...
   'SymbolSpec', temp2Colors);
mapshow(banCoast,'DisplayType','polygon','LineWidth',3,'FaceAlpha',0,'EdgeColor',[0 0.5 0.5]);
caxis([-.007 .007]); 
axis([88 93 20 27]);
colormap(ax1, redBlue)
colorbar
ylabel('Latitude (Degrees)');
xlabel('Longitude (Degrees)');

h = colorbar;
set(get(h,'label'),'string',{'Relative change in district population'; '(as fraction of total Bangladesh population)'},'FontSize',14)
% for indexI = 1:64
%     text(banDist(indexI).Longitude, banDist(indexI).Latitude,banDist(indexI).ADMIN_NAME);
% end
dhaka = plot(90.4125, 23.8103,'o','MarkerSize',10, 'MarkerEdgeColor','k','LineWidth',2,'MarkerFaceColor','w');
dhaka_name = text(90.5125, 23.8253,'Dhaka','FontSize',12,'FontWeight','bold');

% hold on;
% [i,j,v] = find(f);
% lonI = [banDist(i).Longitude]';
% latI = [banDist(i).Latitude]';
% 
% lonJ = [banDist(j).Longitude]';
% latJ = [banDist(j).Latitude]';
% 
% hold on;
% for indexI = 1:length(i)
%     
%     dist = distMin + (distMax-distMin) * rand();
%     bump = bumpMin + (bumpMax-bumpMin) * rand();
%     latOrig = latI(indexI);
%     latDest = latJ(indexI);
%     lonOrig = lonI(indexI);
%     lonDest = lonJ(indexI);
%     slope = (latDest - latOrig) / (lonDest - lonOrig);
%     origin = [lonOrig latOrig];
%     shift it to origin
%     latDest = latDest - latOrig;
%     lonDest = lonDest - lonOrig;
%     rotate it flat
%     theta = atand(slope);
%     rotMat = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
%     latLonRot = [lonDest latDest] * rotMat;
%     
%     verify that lat is now 0 or close to it
%     midLon = dist * latLonRot(1);
%     midLat = dist * latLonRot(2);
%     
%     actual midLat will be our bump
%     midLat = bump * latLonRot(1);
%     
%     spacing = latLonRot(1) / points;
%     
%     lonList = 0:spacing:latLonRot(1);
%     latList = spline([0 midLon latLonRot(1)], [0 midLat 0], lonList);
%     
%     reverse rotate it
%     rotMat = [cosd(-theta) -sind(-theta); sind(-theta) cosd(-theta)];
%     latLonRot = [lonList' latList'] * rotMat;
%     
%     reverse shift
%     latLonRot(:,1) = latLonRot(:,1) + lonOrig;
%     latLonRot(:,2) = latLonRot(:,2) + latOrig;
% 
%     arcX = latLonRot(:,1);
%     arcY = latLonRot(:,2);
%     slope = (latJ(indexI) - latI(indexI)) / (lonJ(indexI) - lonI(indexI));
%     midX = lonI(indexI) + dist * (lonJ(indexI) - lonI(indexI));
%     midY = latI(indexI) + dist * (latJ(indexI) - latI(indexI));
%     length = sqrt((latJ(indexI) - latI(indexI))^2 + (lonJ(indexI) - lonI(indexI))^2);
%     delX = - bump * length * slope;
%     delY = - delX / slope;
%     spacing = (lonJ(indexI) - lonI(indexI))/points;
%     arcY = interp1([lonI(indexI) midX + delX lonJ(indexI)], [latI(indexI) midY + delY latJ(indexI)], lonI(indexI):spacing:lonJ(indexI),'makima');
%     arcX = lonI(indexI):spacing:lonJ(indexI);
%     h = plot(arcX, arcY);
%     set(h, 'Color', [0 0 0 transp],'LineWidth',v(indexI)/min(v)*minWidth);
%     h = arrow('Start',[arcX(end-1) arcY(end-1)],'Stop',[arcX(end) arcY(end)],'Width',v(indexI)/min(v)*minWidth,'Length',v(indexI)/min(v)*headLength);
%     set(h,'EdgeAlpha',transp,'FaceAlpha',transp);
% end
title('Difference: B - A');
text(88.5,20.5,'C','FontSize', 18);
set(gca,'FontSize',14);
set(gcf,'Position',[20 -20 800 1000]);



%%%%%%%%%%%%%%%%%%
ax1 = figure;

%subplot('Position',[0.02 0.05 0.46 0.9]);
tempMean = mean(tempLowFlood,3);
tempList =  sum(tempMean)' - sum(tempMean,2);

temp2_ = num2cell(tempList');
[banDist.temp2] = temp2_{:};
temp2Colors = makesymbolspec('Polygon', {'temp2', [-.1 .1], 'FaceColor', redBlue});
mapshow(worldMap,'EdgeColor',[0.7 0.7 0.7], 'FaceColor',[0.8 0.8 0.8]);

hold on;
mapshow(banDist, 'DisplayType', 'polygon', ...
   'SymbolSpec', temp2Colors);
mapshow(banCoast,'DisplayType','polygon','LineWidth',3,'FaceAlpha',0,'EdgeColor',[0 0.5 0.5]);
caxis([-.1 .1]); 
axis([88 93 20 27]);
colormap(ax1, redBlue)
colorbar
ylabel('Latitude (Degrees)');
xlabel('Longitude (Degrees)');

h = colorbar;
set(get(h,'label'),'string',{'Relative change in district population'; '(as fraction of total Bangladesh population)'},'FontSize',14)
% for indexI = 1:64
%     text(banDist(indexI).Longitude, banDist(indexI).Latitude,banDist(indexI).ADMIN_NAME);
% end
dhaka = plot(90.4125, 23.8103,'o','MarkerSize',10, 'MarkerEdgeColor','k','LineWidth',2,'MarkerFaceColor','w');
dhaka_name = text(90.5125, 23.8253,'Dhaka','FontSize',12,'FontWeight','bold');

[i,j,v] = find(c);
lonI = [banDist(i).Longitude]';
latI = [banDist(i).Latitude]';

lonJ = [banDist(j).Longitude]';
latJ = [banDist(j).Latitude]';
set(gca,'FontSize',14);
set(gcf,'Position',[20 -20 800 1000]);

hold on;
for indexI = 1:length(i)
    
    dist = distMin + (distMax-distMin) * rand();
    bump = bumpMin + (bumpMax-bumpMin) * rand();
    latOrig = latI(indexI);
    latDest = latJ(indexI);
    lonOrig = lonI(indexI);
    lonDest = lonJ(indexI);
    slope = (latDest - latOrig) / (lonDest - lonOrig);
    origin = [lonOrig latOrig];
    %shift it to origin
    latDest = latDest - latOrig;
    lonDest = lonDest - lonOrig;
    %rotate it flat
    theta = atand(slope);
    rotMat = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    latLonRot = [lonDest latDest] * rotMat;
    
    %verify that lat is now 0 or close to it
    midLon = dist * latLonRot(1);
    midLat = dist * latLonRot(2);
    
    %actual midLat will be our bump
    midLat = bump * latLonRot(1);
    
    spacing = latLonRot(1) / points;
    
    lonList = 0:spacing:latLonRot(1);
    latList = spline([0 midLon latLonRot(1)], [0 midLat 0], lonList);
    
    %reverse rotate it
    rotMat = [cosd(-theta) -sind(-theta); sind(-theta) cosd(-theta)];
    latLonRot = [lonList' latList'] * rotMat;
    
    %reverse shift
    latLonRot(:,1) = latLonRot(:,1) + lonOrig;
    latLonRot(:,2) = latLonRot(:,2) + latOrig;

    arcX = latLonRot(:,1);
    arcY = latLonRot(:,2);
%     slope = (latJ(indexI) - latI(indexI)) / (lonJ(indexI) - lonI(indexI));
%     midX = lonI(indexI) + dist * (lonJ(indexI) - lonI(indexI));
%     midY = latI(indexI) + dist * (latJ(indexI) - latI(indexI));
%     length = sqrt((latJ(indexI) - latI(indexI))^2 + (lonJ(indexI) - lonI(indexI))^2);
%     delX = - bump * length * slope;
%     delY = - delX / slope;
%     spacing = (lonJ(indexI) - lonI(indexI))/points;
%     arcY = interp1([lonI(indexI) midX + delX lonJ(indexI)], [latI(indexI) midY + delY latJ(indexI)], lonI(indexI):spacing:lonJ(indexI),'makima');
%     arcX = lonI(indexI):spacing:lonJ(indexI);
    h = plot(arcX, arcY);
    set(h, 'Color', [0 0 0 transp],'LineWidth',v(indexI)/min(v)*minWidth);
    h = arrow('Start',[arcX(end-1) arcY(end-1)],'Stop',[arcX(end) arcY(end)],'Width',v(indexI)/min(v)*minWidth,'Length',v(indexI)/min(v)*headLength);
    set(h,'EdgeAlpha',transp,'FaceAlpha',transp);
end
title('Normal flooding < 0.5 * Expected depth');

ax1 = figure; %subplot('Position',[0.54 0.05 0.46 0.9]);

tempMean = mean(tempHiFlood,3);
tempList =  sum(tempMean)' - sum(tempMean,2);

temp2_ = num2cell(tempList');
[banDist.temp2] = temp2_{:};
temp2Colors = makesymbolspec('Polygon', {'temp2', [-.1 .1], 'FaceColor', redBlue});
mapshow(worldMap,'EdgeColor',[0.7 0.7 0.7], 'FaceColor',[0.8 0.8 0.8]);

hold on;
mapshow(banDist, 'DisplayType', 'polygon', ...
   'SymbolSpec', temp2Colors);
mapshow(banCoast,'DisplayType','polygon','LineWidth',3,'FaceAlpha',0,'EdgeColor',[0 0.5 0.5]);
caxis([-.1 .1]); 
axis([88 93 20 27]);
colormap(ax1, redBlue)
colorbar
ylabel('Latitude (Degrees)');
xlabel('Longitude (Degrees)');

h = colorbar;
set(get(h,'label'),'string',{'Relative change in district population'; '(as fraction of total Bangladesh population)'},'FontSize',14)
% for indexI = 1:64
%     text(banDist(indexI).Longitude, banDist(indexI).Latitude,banDist(indexI).ADMIN_NAME);
% end
dhaka = plot(90.4125, 23.8103,'o','MarkerSize',10, 'MarkerEdgeColor','k','LineWidth',2,'MarkerFaceColor','w');
dhaka_name = text(90.5125, 23.8253,'Dhaka','FontSize',12,'FontWeight','bold');

[i,j,v] = find(d);
lonI = [banDist(i).Longitude]';
latI = [banDist(i).Latitude]';

lonJ = [banDist(j).Longitude]';
latJ = [banDist(j).Latitude]';

hold on;
for indexI = 1:length(i)
    
    dist = distMin + (distMax-distMin) * rand();
    bump = bumpMin + (bumpMax-bumpMin) * rand();
    latOrig = latI(indexI);
    latDest = latJ(indexI);
    lonOrig = lonI(indexI);
    lonDest = lonJ(indexI);
    slope = (latDest - latOrig) / (lonDest - lonOrig);
    origin = [lonOrig latOrig];
    %shift it to origin
    latDest = latDest - latOrig;
    lonDest = lonDest - lonOrig;
    %rotate it flat
    theta = atand(slope);
    rotMat = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    latLonRot = [lonDest latDest] * rotMat;
    
    %verify that lat is now 0 or close to it
    midLon = dist * latLonRot(1);
    midLat = dist * latLonRot(2);
    
    %actual midLat will be our bump
    midLat = bump * latLonRot(1);
    
    spacing = latLonRot(1) / points;
    
    lonList = 0:spacing:latLonRot(1);
    latList = spline([0 midLon latLonRot(1)], [0 midLat 0], lonList);
    
    %reverse rotate it
    rotMat = [cosd(-theta) -sind(-theta); sind(-theta) cosd(-theta)];
    latLonRot = [lonList' latList'] * rotMat;
    
    %reverse shift
    latLonRot(:,1) = latLonRot(:,1) + lonOrig;
    latLonRot(:,2) = latLonRot(:,2) + latOrig;

    arcX = latLonRot(:,1);
    arcY = latLonRot(:,2);
%     slope = (latJ(indexI) - latI(indexI)) / (lonJ(indexI) - lonI(indexI));
%     midX = lonI(indexI) + dist * (lonJ(indexI) - lonI(indexI));
%     midY = latI(indexI) + dist * (latJ(indexI) - latI(indexI));
%     length = sqrt((latJ(indexI) - latI(indexI))^2 + (lonJ(indexI) - lonI(indexI))^2);
%     delX = - bump * length * slope;
%     delY = - delX / slope;
%     spacing = (lonJ(indexI) - lonI(indexI))/points;
%     arcY = interp1([lonI(indexI) midX + delX lonJ(indexI)], [latI(indexI) midY + delY latJ(indexI)], lonI(indexI):spacing:lonJ(indexI),'makima');
%     arcX = lonI(indexI):spacing:lonJ(indexI);
    h = plot(arcX, arcY);
    set(h, 'Color', [0 0 0 transp],'LineWidth',v(indexI)/min(v)*minWidth);
    h = arrow('Start',[arcX(end-1) arcY(end-1)],'Stop',[arcX(end) arcY(end)],'Width',v(indexI)/min(v)*minWidth,'Length',v(indexI)/min(v)*headLength);
    set(h,'EdgeAlpha',transp,'FaceAlpha',transp);
end
title('Normal flooding >= Expected depth');
text(88.5,20.5,'B','FontSize', 18);
%suptitle({'Average net-migration, 2010-2100 (as fraction of population)'; ['(showing ' num2str(length(i)) ' largest flows)' ]});
set(gca,'FontSize',14);
set(gcf,'Position',[20 -20 800 1000]);

%%%%

ax1 = figure; %subplot('Position',[0.54 0.05 0.46 0.9]);

tempMean1 = mean(tempLowFlood,3);
tempList1 =  sum(tempMean1)' - sum(tempMean1,2);

tempMean2 = mean(tempHiFlood,3);
tempList2 =  sum(tempMean2)' - sum(tempMean2,2);

tempList = tempList2 - tempList1;


temp2_ = num2cell(tempList');
[banDist.temp2] = temp2_{:};
temp2Colors = makesymbolspec('Polygon', {'temp2', [-.003 .003], 'FaceColor', redBlue});
mapshow(worldMap,'EdgeColor',[0.7 0.7 0.7], 'FaceColor',[0.8 0.8 0.8]);

hold on;
mapshow(banDist, 'DisplayType', 'polygon', ...
   'SymbolSpec', temp2Colors);
mapshow(banCoast,'DisplayType','polygon','LineWidth',3,'FaceAlpha',0,'EdgeColor',[0 0.5 0.5]);
caxis([-.003 .003]); 
axis([88 93 20 27]);
colormap(ax1, redBlue)
colorbar
ylabel('Latitude (Degrees)');
xlabel('Longitude (Degrees)');

h = colorbar;
set(get(h,'label'),'string',{'Relative change in district population'; '(as fraction of total Bangladesh population)'},'FontSize',14)
% for indexI = 1:64
%     text(banDist(indexI).Longitude, banDist(indexI).Latitude,banDist(indexI).ADMIN_NAME);
% end
dhaka = plot(90.4125, 23.8103,'o','MarkerSize',10, 'MarkerEdgeColor','k','LineWidth',2,'MarkerFaceColor','w');
dhaka_name = text(90.5125, 23.8253,'Dhaka','FontSize',12,'FontWeight','bold');

% hold on;
% [i,j,v] = find(f);
% lonI = [banDist(i).Longitude]';
% latI = [banDist(i).Latitude]';
% 
% lonJ = [banDist(j).Longitude]';
% latJ = [banDist(j).Latitude]';
% 
% hold on;
% for indexI = 1:length(i)
%     
%     dist = distMin + (distMax-distMin) * rand();
%     bump = bumpMin + (bumpMax-bumpMin) * rand();
%     latOrig = latI(indexI);
%     latDest = latJ(indexI);
%     lonOrig = lonI(indexI);
%     lonDest = lonJ(indexI);
%     slope = (latDest - latOrig) / (lonDest - lonOrig);
%     origin = [lonOrig latOrig];
%     shift it to origin
%     latDest = latDest - latOrig;
%     lonDest = lonDest - lonOrig;
%     rotate it flat
%     theta = atand(slope);
%     rotMat = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
%     latLonRot = [lonDest latDest] * rotMat;
%     
%     verify that lat is now 0 or close to it
%     midLon = dist * latLonRot(1);
%     midLat = dist * latLonRot(2);
%     
%     actual midLat will be our bump
%     midLat = bump * latLonRot(1);
%     
%     spacing = latLonRot(1) / points;
%     
%     lonList = 0:spacing:latLonRot(1);
%     latList = spline([0 midLon latLonRot(1)], [0 midLat 0], lonList);
%     
%     reverse rotate it
%     rotMat = [cosd(-theta) -sind(-theta); sind(-theta) cosd(-theta)];
%     latLonRot = [lonList' latList'] * rotMat;
%     
%     reverse shift
%     latLonRot(:,1) = latLonRot(:,1) + lonOrig;
%     latLonRot(:,2) = latLonRot(:,2) + latOrig;
% 
%     arcX = latLonRot(:,1);
%     arcY = latLonRot(:,2);
%     slope = (latJ(indexI) - latI(indexI)) / (lonJ(indexI) - lonI(indexI));
%     midX = lonI(indexI) + dist * (lonJ(indexI) - lonI(indexI));
%     midY = latI(indexI) + dist * (latJ(indexI) - latI(indexI));
%     length = sqrt((latJ(indexI) - latI(indexI))^2 + (lonJ(indexI) - lonI(indexI))^2);
%     delX = - bump * length * slope;
%     delY = - delX / slope;
%     spacing = (lonJ(indexI) - lonI(indexI))/points;
%     arcY = interp1([lonI(indexI) midX + delX lonJ(indexI)], [latI(indexI) midY + delY latJ(indexI)], lonI(indexI):spacing:lonJ(indexI),'makima');
%     arcX = lonI(indexI):spacing:lonJ(indexI);
%     h = plot(arcX, arcY);
%     set(h, 'Color', [0 0 0 transp],'LineWidth',v(indexI)/min(v)*minWidth);
%     h = arrow('Start',[arcX(end-1) arcY(end-1)],'Stop',[arcX(end) arcY(end)],'Width',v(indexI)/min(v)*minWidth,'Length',v(indexI)/min(v)*headLength);
%     set(h,'EdgeAlpha',transp,'FaceAlpha',transp);
% end
title('Difference: B - A');
text(88.5,20.5,'C','FontSize', 18);
set(gca,'FontSize',14);
set(gcf,'Position',[20 -20 800 1000]);

%%%%

ax1 = figure; %subplot('Position',[0.54 0.05 0.46 0.9]);

tempMean = mean(tempLowFlood,3);
tempList =  sum(tempMean)' - sum(tempMean,2);

temp2_ = num2cell(tempList');
[banDist.temp2] = temp2_{:};
temp2Colors = makesymbolspec('Polygon', {'temp2', [-.1 .1], 'FaceColor', redBlue});
mapshow(worldMap,'EdgeColor',[0.7 0.7 0.7], 'FaceColor',[0.8 0.8 0.8]);

hold on;
mapshow(banDist, 'DisplayType', 'polygon', ...
   'SymbolSpec', temp2Colors);
mapshow(banCoast,'DisplayType','polygon','LineWidth',3,'FaceAlpha',0,'EdgeColor',[0 0.5 0.5]);
caxis([-.1 .1]); 
axis([88 93 20 27]);
colormap(ax1, redBlue)
colorbar
ylabel('Latitude (Degrees)');
xlabel('Longitude (Degrees)');

h = colorbar;
set(get(h,'label'),'string',{'Relative change in district population'; '(as fraction of total Bangladesh population)'},'FontSize',14)
% for indexI = 1:64
%     text(banDist(indexI).Longitude, banDist(indexI).Latitude,banDist(indexI).ADMIN_NAME);
% end
dhaka = plot(90.4125, 23.8103,'o','MarkerSize',10, 'MarkerEdgeColor','k','LineWidth',2,'MarkerFaceColor','w');
dhaka_name = text(90.5125, 23.8253,'Dhaka','FontSize',12,'FontWeight','bold');

[i,j,v] = find(c);
lonI = [banDist(i).Longitude]';
latI = [banDist(i).Latitude]';

lonJ = [banDist(j).Longitude]';
latJ = [banDist(j).Latitude]';

hold on;
for indexI = 1:length(i)
    
    dist = distMin + (distMax-distMin) * rand();
    bump = bumpMin + (bumpMax-bumpMin) * rand();
    latOrig = latI(indexI);
    latDest = latJ(indexI);
    lonOrig = lonI(indexI);
    lonDest = lonJ(indexI);
    slope = (latDest - latOrig) / (lonDest - lonOrig);
    origin = [lonOrig latOrig];
    %shift it to origin
    latDest = latDest - latOrig;
    lonDest = lonDest - lonOrig;
    %rotate it flat
    theta = atand(slope);
    rotMat = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    latLonRot = [lonDest latDest] * rotMat;
    
    %verify that lat is now 0 or close to it
    midLon = dist * latLonRot(1);
    midLat = dist * latLonRot(2);
    
    %actual midLat will be our bump
    midLat = bump * latLonRot(1);
    
    spacing = latLonRot(1) / points;
    
    lonList = 0:spacing:latLonRot(1);
    latList = spline([0 midLon latLonRot(1)], [0 midLat 0], lonList);
    
    %reverse rotate it
    rotMat = [cosd(-theta) -sind(-theta); sind(-theta) cosd(-theta)];
    latLonRot = [lonList' latList'] * rotMat;
    
    %reverse shift
    latLonRot(:,1) = latLonRot(:,1) + lonOrig;
    latLonRot(:,2) = latLonRot(:,2) + latOrig;

    arcX = latLonRot(:,1);
    arcY = latLonRot(:,2);
%     slope = (latJ(indexI) - latI(indexI)) / (lonJ(indexI) - lonI(indexI));
%     midX = lonI(indexI) + dist * (lonJ(indexI) - lonI(indexI));
%     midY = latI(indexI) + dist * (latJ(indexI) - latI(indexI));
%     length = sqrt((latJ(indexI) - latI(indexI))^2 + (lonJ(indexI) - lonI(indexI))^2);
%     delX = - bump * length * slope;
%     delY = - delX / slope;
%     spacing = (lonJ(indexI) - lonI(indexI))/points;
%     arcY = interp1([lonI(indexI) midX + delX lonJ(indexI)], [latI(indexI) midY + delY latJ(indexI)], lonI(indexI):spacing:lonJ(indexI),'makima');
%     arcX = lonI(indexI):spacing:lonJ(indexI);
    h = plot(arcX, arcY);
    set(h, 'Color', [0 0 0 transp],'LineWidth',v(indexI)/min(v)*minWidth);
    h = arrow('Start',[arcX(end-1) arcY(end-1)],'Stop',[arcX(end) arcY(end)],'Width',v(indexI)/min(v)*minWidth,'Length',v(indexI)/min(v)*headLength);
    set(h,'EdgeAlpha',transp,'FaceAlpha',transp);
end
title('Normal flooding < Expected depth');
text(88.5,20.5,'A','FontSize', 18);

%suptitle({'Average net-migration, 2010-2100 (as fraction of population)'; ['(showing ' num2str(length(i)) ' largest flows)' ]});
set(gca,'FontSize',14);
set(gcf,'Position',[20 -20 800 1000]);