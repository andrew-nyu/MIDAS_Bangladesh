clear all;
close all; 

load outputArrays
load midasLocations.mat

scenario = 0;

inputVarNames = strrep(table2array(RCP26.input{1}(:,1)),'.','_');
outputVarNames1 = {'RCP45';'RCP85';'Wealth';'Gini';'Last10YearAvMig_Scaled'; 'trapped50'; 'trapped100';' coastIn50'; 'coastIn100'; 'coastOut50'; 'coastOut100'; 'coastInOut50'; 'coastInOut100'; 'coastNet50'; 'coastNet100'};
outputVarNames2 = strcat('inOut_',erasePunctuation(strrep(midasLocations.source_ADMIN_NAME,' ','')));
outputVarNames3 = strcat('gini_',erasePunctuation(strrep(midasLocations.source_ADMIN_NAME,' ','')));
outputVarNames4 = strcat('trapped_',erasePunctuation(strrep(midasLocations.source_ADMIN_NAME,' ','')));

allVarNames = [outputVarNames1; outputVarNames2; outputVarNames3; outputVarNames4; inputVarNames];

allVarNames = strrep(allVarNames,'Parameters','Params');
allVarNames = strrep(allVarNames,'networkParam','nParam');
allVarNames = strrep(allVarNames,'modelParam','mParam');
allVarNames = strrep(allVarNames,'agentParam','aParam');
allVarNames = strrep(allVarNames,'uninformed','ui');
allVarNames = strrep(allVarNames,'informed','i');
allVarNames = strrep(allVarNames,'xpected','xp');

% inputTable = [];
% for indexI = 1:length(Baseline.input)
%     inputTable = [inputTable; (table2array(Baseline.input{indexI}(:,2)))'];
% end
% 
% outputTable = [scenario * ones(length(Baseline.input),1) (Baseline.wealth)' (Baseline.gini)' mean(Baseline.sumMigrationPath(:,end-39:end),2) Baseline.inOutRatio Baseline.giniLocation];
% 
% allVarTable = array2table([outputTable inputTable],'VariableNames', allVarNames);

scenario = 1;

inputTable = [];
for indexI = 1:length(RCP26.input)
    inputTable = [inputTable; (table2array(RCP26.input{indexI}(:,2)))'];
end

trapped50 = reshape(mean(RCP26.trappedByTime(:,184:204,:),1:2),length(RCP26.input),1);
trapped100 = reshape(mean(RCP26.trappedByTime(:,384:404,:),1:2),length(RCP26.input),1);
coastIn50 = reshape(mean(RCP26.coastalInMigsPerPopByTime(:,184:204),2),length(RCP26.input),1);
coastIn100 = reshape(mean(RCP26.coastalInMigsPerPopByTime(:,384:404),2),length(RCP26.input),1);
coastOut50 = reshape(mean(RCP26.coastalOutMigsPerPopByTime(:,184:204),2),length(RCP26.input),1);
coastOut100 = reshape(mean(RCP26.coastalOutMigsPerPopByTime(:,384:404),2),length(RCP26.input),1);

coastInOut50 = coastIn50 ./ coastOut50;
coastInOut100 = coastIn100 ./ coastOut100;
coastNet50 = coastIn50 - coastOut50;
coastNet100 = coastIn100 - coastOut100;

tempTrapped = reshape(mean(RCP26.trappedByTime(:,384:404,:),2),[size(RCP26.trappedByTime,1) size(RCP26.trappedByTime,3)])';
outputTable = [0 * ones(length(RCP26.input),1) 0 * ones(length(RCP26.input),1) (RCP26.wealth) (RCP26.gini) mean(RCP26.sumMigrationPath(:,end-39:end),2) trapped50 trapped100 coastIn50 coastIn100 coastOut50 coastOut100 coastInOut50 coastInOut100 coastNet50 coastNet100 (RCP26.inOutRatio) (RCP26.giniLocation) tempTrapped];

allVarTable = array2table([outputTable inputTable],'VariableNames', allVarNames);

% allVarTable = vertcat(allVarTable, array2table([outputTable inputTable],'VariableNames', allVarNames));

scenario = 2;

inputTable = [];
for indexI = 1:length(RCP45.input)
    inputTable = [inputTable; (table2array(RCP45.input{indexI}(:,2)))'];
end

trapped50 = reshape(mean(RCP45.trappedByTime(:,184:204,:),1:2),length(RCP45.input),1);
trapped100 = reshape(mean(RCP45.trappedByTime(:,384:404,:),1:2),length(RCP45.input),1);
coastIn50 = reshape(mean(RCP45.coastalInMigsPerPopByTime(:,184:204),2),length(RCP45.input),1);
coastIn100 = reshape(mean(RCP45.coastalInMigsPerPopByTime(:,384:404),2),length(RCP45.input),1);
coastOut50 = reshape(mean(RCP45.coastalOutMigsPerPopByTime(:,184:204),2),length(RCP45.input),1);
coastOut100 = reshape(mean(RCP45.coastalOutMigsPerPopByTime(:,384:404),2),length(RCP45.input),1);

coastInOut50 = coastIn50 ./ coastOut50;
coastInOut100 = coastIn100 ./ coastOut100;
coastNet50 = coastIn50 - coastOut50;
coastNet100 = coastIn100 - coastOut100;

tempTrapped = reshape(mean(RCP45.trappedByTime(:,384:404,:),2),[size(RCP45.trappedByTime,1) size(RCP45.trappedByTime,3)])';

outputTable = [1 * ones(length(RCP45.input),1) 0 * ones(length(RCP45.input),1) (RCP45.wealth) (RCP45.gini) mean(RCP45.sumMigrationPath(:,end-39:end),2) trapped50 trapped100 coastIn50 coastIn100 coastOut50 coastOut100 coastInOut50 coastInOut100 coastNet50 coastNet100 RCP45.inOutRatio RCP45.giniLocation tempTrapped];

allVarTable = vertcat(allVarTable, array2table([outputTable inputTable],'VariableNames', allVarNames));

scenario = 3;

inputTable = [];
for indexI = 1:length(RCP85.input)
    inputTable = [inputTable; (table2array(RCP85.input{indexI}(:,2)))'];
end

trapped50 = reshape(mean(RCP85.trappedByTime(:,184:204,:),1:2),length(RCP85.input),1);
trapped100 = reshape(mean(RCP85.trappedByTime(:,384:404,:),1:2),length(RCP85.input),1);

coastIn50 = reshape(mean(RCP85.coastalInMigsPerPopByTime(:,184:204),2),length(RCP85.input),1);
coastIn100 = reshape(mean(RCP85.coastalInMigsPerPopByTime(:,384:404),2),length(RCP85.input),1);
coastOut50 = reshape(mean(RCP85.coastalOutMigsPerPopByTime(:,184:204),2),length(RCP85.input),1);
coastOut100 = reshape(mean(RCP85.coastalOutMigsPerPopByTime(:,384:404),2),length(RCP85.input),1);

coastInOut50 = coastIn50 ./ coastOut50;
coastInOut100 = coastIn100 ./ coastOut100;

coastNet50 = coastIn50 - coastOut50;
coastNet100 = coastIn100 - coastOut100;

tempTrapped = reshape(mean(RCP85.trappedByTime(:,384:404,:),2),[size(RCP85.trappedByTime,1) size(RCP85.trappedByTime,3)])';

outputTable = [0 * ones(length(RCP85.input),1) 1 * ones(length(RCP85.input),1) (RCP85.wealth) (RCP85.gini) mean(RCP85.sumMigrationPath(:,end-39:end),2) trapped50 trapped100 coastIn50 coastIn100 coastOut50 coastOut100 coastInOut50 coastInOut100 coastNet50 coastNet100 RCP85.inOutRatio RCP85.giniLocation tempTrapped];

allVarTable = vertcat(allVarTable, array2table([outputTable inputTable],'VariableNames', allVarNames));

inputVariables = contains(allVarTable.Properties.VariableNames,'Param');
[b,i,j] = unique(allVarTable(:,inputVariables),'rows');

allVarTable = horzcat(allVarTable,table(j,'VariableNames',{'Calibration'}));


%writetable(allVarTable,'allVarTable.xls','FileType','spreadsheet');


lengthVarList = length(allVarTable.Properties.VariableNames);
varSet = [1 2 lengthVarList-68:lengthVarList-1];
variableList = allVarTable.Properties.VariableNames(varSet);
variableList = strrep(variableList,'_','');


%clean up variableList as labels
variableList = strrep(variableList,'aParams','(agent) ');
variableList = strrep(variableList,'nParams','(network) ');
variableList = strrep(variableList,'mParams','(model) ');

% paroptions = statset('UseParallel',true);
% RF_Wealth = TreeBagger(1000,allVarTable(:,varSet),allVarTable{:,'Wealth'},'OOBPrediction','on','OOBPredictorImportance','on','Method','regression','Options',paroptions);
% h = figure;
% [oobError,sortIndex] = sort(RF_Wealth.OOBPermutedPredictorDeltaError');
% barh(oobError);
% title(['Wealth' num2str(mean(RF_Wealth.oobError))]);
% set(gca,'YTick',1:length(varSet),'YTickLabel',variableList(sortIndex));
% set(gcf,'Position',[100 100 1300 400]);
% 
% paroptions = statset('UseParallel',true);
% RF_Migs = TreeBagger(1000,allVarTable(:,varSet),allVarTable{:,'Last10YearAvMig_Scaled'},'OOBPrediction','on','OOBPredictorImportance','on','Method','regression','Options',paroptions);
% h = figure;
% [oobError,sortIndex] = sort(RF_Migs.OOBPermutedPredictorDeltaError');
% barh(oobError);
% title(['Mig Rate' num2str(mean(RF_Migs.oobError))]);
% set(gca,'YTick',1:length(varSet),'YTickLabel',variableList(sortIndex));
% set(gcf,'Position',[100 100 1300 400]);
% 
% paroptions = statset('UseParallel',true);
% RF_Gini = TreeBagger(1000,allVarTable(:,varSet),allVarTable{:,'Gini'},'OOBPrediction','on','OOBPredictorImportance','on','Method','regression','Options',paroptions);
% h = figure;
% [oobError,sortIndex] = sort(RF_Gini.OOBPermutedPredictorDeltaError');
% barh(oobError);
% title(['Gini ' num2str(mean(RF_Gini.oobError))]);
% set(gca,'YTick',1:length(varSet),'YTickLabel',variableList(sortIndex));
% set(gcf,'Position',[100 100 1300 400]);
% 
% h = figure;
% subplot(1,2,1)
% paroptions = statset('UseParallel',true);
% RF_Gini = TreeBagger(1000,allVarTable(:,varSet),allVarTable{:,'trapped50'},'OOBPrediction','on','OOBPredictorImportance','on','Method','regression','Options',paroptions);
% [oobError,sortIndex] = sort(RF_Gini.OOBPermutedPredictorDeltaError');
% barh(oobError);
% title(['Trapped populations - 2050 ']);
% set(gca,'YTick',1:length(varSet),'YTickLabel',variableList(sortIndex));
% set(gca,'YLim',[length(variableList)-9.5 length(variableList)+.5], 'FontSize',12);
% set(gcf,'Position',[100 100 1300 400]);
% 
% subplot(1,2,2)
% paroptions = statset('UseParallel',true);
% RF_Gini = TreeBagger(1000,allVarTable(:,varSet),allVarTable{:,'trapped100'},'OOBPrediction','on','OOBPredictorImportance','on','Method','regression','Options',paroptions);
% [oobError,sortIndex] = sort(RF_Gini.OOBPermutedPredictorDeltaError');
% barh(oobError);
% title(['Trapped populations - 2100 ']);
% set(gca,'YTick',1:length(varSet),'YTickLabel',variableList(sortIndex));
% set(gca,'YLim',[length(variableList)-9.5 length(variableList)+.5], 'FontSize',12);
% set(gcf,'Position',[100 100 1300 400]);
% 
% 
% h = figure;
% subplot(1,2,1)
% paroptions = statset('UseParallel',true);
% RF_Gini = TreeBagger(1000,allVarTable(:,varSet),allVarTable{:,'coastIn50'},'OOBPrediction','on','OOBPredictorImportance','on','Method','regression','Options',paroptions);
% [oobError,sortIndex] = sort(RF_Gini.OOBPermutedPredictorDeltaError');
% barh(oobError);
% title(['Coastal In-migration - 2050 ']);
% set(gca,'YTick',1:length(varSet),'YTickLabel',variableList(sortIndex));
% set(gca,'YLim',[length(variableList)-9.5 length(variableList)+.5], 'FontSize',12);
% set(gcf,'Position',[100 100 1300 400]);
% 
% subplot(1,2,2)
% paroptions = statset('UseParallel',true);
% RF_Gini = TreeBagger(1000,allVarTable(:,varSet),allVarTable{:,'coastIn100'},'OOBPrediction','on','OOBPredictorImportance','on','Method','regression','Options',paroptions);
% [oobError,sortIndex] = sort(RF_Gini.OOBPermutedPredictorDeltaError');
% barh(oobError);
% title(['Coastal In-migration - 2100 ']);
% set(gca,'YTick',1:length(varSet),'YTickLabel',variableList(sortIndex));
% set(gca,'YLim',[length(variableList)-9.5 length(variableList)+.5], 'FontSize',12);
% set(gcf,'Position',[100 100 1300 400]);
% 
% h = figure;
% subplot(1,2,1)
% paroptions = statset('UseParallel',true);
% RF_Gini = TreeBagger(1000,allVarTable(:,varSet),allVarTable{:,'coastOut50'},'OOBPrediction','on','OOBPredictorImportance','on','Method','regression','Options',paroptions);
% [oobError,sortIndex] = sort(RF_Gini.OOBPermutedPredictorDeltaError');
% barh(oobError);
% title(['Coastal Out-migration - 2050 ' ]);
% set(gca,'YTick',1:length(varSet),'YTickLabel',variableList(sortIndex));
% set(gca,'YLim',[length(variableList)-9.5 length(variableList)+.5], 'FontSize',12);
% set(gcf,'Position',[100 100 1300 400]);
% 
% subplot(1,2,2)
% paroptions = statset('UseParallel',true);
% RF_Gini = TreeBagger(1000,allVarTable(:,varSet),allVarTable{:,'coastOut100'},'OOBPrediction','on','OOBPredictorImportance','on','Method','regression','Options',paroptions);
% [oobError,sortIndex] = sort(RF_Gini.OOBPermutedPredictorDeltaError');
% barh(oobError);
% title(['Coastal Out-migration - 2100 ' ]);
% set(gca,'YTick',1:length(varSet),'YTickLabel',variableList(sortIndex));
% set(gca,'YLim',[length(variableList)-9.5 length(variableList)+.5], 'FontSize',12);
% set(gcf,'Position',[100 100 1300 400]);


% h = figure;
% subplot(1,2,1)
% paroptions = statset('UseParallel',true);
% RF_Gini = TreeBagger(1000,allVarTable(:,varSet),allVarTable{:,'coastInOut50'},'OOBPrediction','on','OOBPredictorImportance','on','Method','regression','Options',paroptions);
% [oobError,sortIndex] = sort(RF_Gini.OOBPermutedPredictorDeltaError');
% barh(oobError);
% title(['Coastal In-Out Ratio - 2050 ' num2str(mean(RF_Gini.oobError))]);
% set(gca,'YTick',1:length(varSet),'YTickLabel',variableList(sortIndex));
% set(gcf,'Position',[100 100 1300 400]);
% 
% subplot(1,2,2)
% paroptions = statset('UseParallel',true);
% RF_Gini = TreeBagger(1000,allVarTable(:,varSet),allVarTable{:,'coastInOut100'},'OOBPrediction','on','OOBPredictorImportance','on','Method','regression','Options',paroptions);
% [oobError,sortIndex] = sort(RF_Gini.OOBPermutedPredictorDeltaError');
% barh(oobError);
% title(['Coastal In-Out Ratio - 2100 ' num2str(mean(RF_Gini.oobError))]);
% set(gca,'YTick',1:length(varSet),'YTickLabel',variableList(sortIndex));
% set(gcf,'Position',[100 100 1300 400]);
% 
% h = figure;
% subplot(1,2,1)
% paroptions = statset('UseParallel',true);
% RF_Gini = TreeBagger(1000,allVarTable(:,varSet),allVarTable{:,'coastNet50'},'OOBPrediction','on','OOBPredictorImportance','on','Method','regression','Options',paroptions);
% [oobError,sortIndex] = sort(RF_Gini.OOBPermutedPredictorDeltaError');
% barh(oobError);
% title(['Coastal Net Migration - 2050 ' num2str(mean(RF_Gini.oobError))]);
% set(gca,'YTick',1:length(varSet),'YTickLabel',variableList(sortIndex));
% set(gcf,'Position',[100 100 1300 400]);
% 
% subplot(1,2,2)
% paroptions = statset('UseParallel',true);
% RF_Gini = TreeBagger(1000,allVarTable(:,varSet),allVarTable{:,'coastNet100'},'OOBPrediction','on','OOBPredictorImportance','on','Method','regression','Options',paroptions);
% [oobError,sortIndex] = sort(RF_Gini.OOBPermutedPredictorDeltaError');
% barh(oobError);
% title(['Coastal Net Migration - 2100 ' num2str(mean(RF_Gini.oobError))]);
% set(gca,'YTick',1:length(varSet),'YTickLabel',variableList(sortIndex));
% set(gcf,'Position',[100 100 1300 400]);

%%%%%
close all;

aList = [];
bList = [];
cList = [];
dList = [];

trappedList = 144:207;
inOutList = 16:79;
for indexI = 1:64
    
 [a,b] = corrcoef(table2array(allVarTable(:,inOutList(indexI))), table2array(allVarTable(:,trappedList(indexI))));
 aList(indexI) = a(2);
 bList(indexI) = b(2);
 cList(indexI) = mean(table2array(allVarTable(:,inOutList(indexI))));
 dList(indexI)= mean(table2array(allVarTable(:,trappedList(indexI))));
 
end 

% aList(1:15) = [];
% bList(1:15) = [];
% cList(1:15) = [];
% dList(1:15) = [];
  

coastalMatrixIDs = [1 3 4 7 9 12 16 19 22 23 27 31 40 46 49 50 55 56 63];
allDists = zeros(64,1);
allDists(coastalMatrixIDs) = 1;

inOutData = table2array(allVarTable(:,inOutList));
trappedData = table2array(allVarTable(:,trappedList));

inOutCoast = inOutData(:,boolean(allDists));
inOutNotCoast = inOutData(:,~boolean(allDists));

trappedCoast = trappedData(:,boolean(allDists));
trappedNotCoast = trappedData(:,~boolean(allDists));

allDistData = zeros(size(inOutData));
allDistData(:,allDists == 1) = 1;

close all;
figure
subplot(1,2,2)
scatter(inOutCoast(:), trappedCoast(:), [],[1 0 0 ],'.','MarkerEdgeAlpha',0.1,'MarkerFaceAlpha',0.1);
hold on;
%[b,d,s] = glmfit(inOutCoast(:), trappedCoast(:));
[b,~,d,~,s] = regress(trappedCoast(:), [ones(size(inOutCoast(:))) inOutCoast(:)] );
%plot([.9 1.1],b(1) + b(2)*[.9 1.1],'k');
set(gca,'XLim',[.9 1.1],'YLim',[0 0.018],'FontSize',12);
xlabel('District In-out Ratio');
ylabel('Fraction of agents trapped in district');
%text(.92, 0.017, {['y = ' num2str(b(1)) ' + ' num2str(b(2)) 'x']; ['R^2 = ' num2str(s(1))]});
%text(1.07, 0.001, 'B','FontSize',18);
legend('Coastal Zone Districts','OLS Best Fit Line');
subplot(1,2,1)
scatter(inOutNotCoast(:), trappedNotCoast(:), [],[0 0 1 ],'.','MarkerEdgeAlpha',0.1,'MarkerFaceAlpha',0.1);
hold on;
scatter(inOutData(:,13), trappedData(:,13), [],[0 1 0 ],'.','MarkerEdgeAlpha',0.1,'MarkerFaceAlpha',0.1);
hold on;
%[b,d,s] = glmfit(inOutNotCoast(:), trappedNotCoast(:));
[b,~,d,~,s] = regress(trappedNotCoast(:), [ones(size(inOutNotCoast(:))) inOutNotCoast(:)] );
%plot([.9 1.1],b(1) + b(2)*[.9 1.1],'k');
set(gca,'XLim',[.9 1.1],'YLim',[0 0.018],'FontSize',12);
xlabel('District In-out Ratio');
ylabel('Fraction of agents trapped in district');
%text(.92, 0.017, {['y = ' num2str(b(1)) ' + ' num2str(b(2)) 'x']; ['R^2 = ' num2str(s(1))]});
%text(1.07, 0.001, 'A','FontSize',18);
legend('Interior Districts','Dhaka','OLS Best Fit Line');
%scatter(mean(inOutCoast(:)), mean(trappedCoast(:)),'o','MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 1 1]);
%scatter(mean(inOutNotCoast(:)), mean(trappedNotCoast(:)),'v','MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[1 1 1]);
%legend('Coastal Zone Districts','Interior Districts','Dhaka','Coastal Zone Mean','Interior Districts Mean');


% figure;
% plot(cList(allDists == 1),aList(allDists == 1),'x');
% hold on;
% plot(cList(allDists == 0),aList(allDists == 0),'o');
% 
% set(gca,'FontSize',12);
% xlabel('District In-out Ratio','FontSize',14);
% ylabel('Correlation with Fraction of Trapped Agents','FontSize',14);
% legend('Coastal Zone Districts','Interior Districts');
% 
% 
% figure;
% plot(cList(allDists == 1),dList(allDists == 1),'x');
% hold on;
% plot(cList(allDists == 0),dList(allDists == 0),'o');
% 
% set(gca,'FontSize',12);
% xlabel('District In-out Ratio','FontSize',14);
% ylabel('Fraction of Trapped Agents','FontSize',14);
% legend('Coastal Zone Districts','Interior Districts');
% 
% banDist = shaperead('ipums_district_level.shp');
% 
% redBlue = ones(101,3);
% redBlue(1:50,2) = 0.02:0.02:1;
% redBlue(1:50,3) = 0.02:0.02:1;
% redBlue(52:101,1) = 1:-0.02:0.02;
% redBlue(52:101,2) = 1:-0.02:0.02;
% 
% 
% % figure;
% % subplot(1,4,1)
% % plot(allVarTable.mParams_creditMultiplier,allVarTable.Wealth,'o');
% % ylabel('Wealth');
% % xlabel('Credit access');
% % 
% % subplot(1,4,2)
% % plot(allVarTable.mParams_creditMultiplier,allVarTable.Last10YearAvMig_Scaled,'o');
% % ylabel('Migrations');
% % xlabel('Credit access');
% % 
% % subplot(1,4,3)
% % plot(allVarTable.mParams_creditMultiplier,allVarTable.trapped100,'o')
% % ylabel('Trapped - overall');
% % xlabel('Credit access');
% % 
% % subplot(1,4,4)
% % plot(allVarTable.mParams_creditMultiplier,allVarTable.trapped_Dhaka,'o');
% % ylabel('Trapped - Dhaka');
% % xlabel('Credit access');
% 
% ax1 = figure;
% 
% temp2_ = num2cell(aList');
% [banDist.temp2] = temp2_{:};
% temp2Colors = makesymbolspec('Polygon', {'temp2', [-.4 .4], 'FaceColor', redBlue});
% mapshow(banDist, 'DisplayType', 'polygon', ...
%    'SymbolSpec', temp2Colors);
% caxis([-.4 .4]); 
% colormap(ax1, redBlue)
% colorbar
% for indexI = 1:64
%     text(banDist(indexI).Longitude, banDist(indexI).Latitude,banDist(indexI).ADMIN_NAME);
% end
