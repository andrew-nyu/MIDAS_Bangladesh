clear all;
load midasLocations.mat;
load ipums_district_level.mat;

load migrationCounts_2002_2011;
interDistrictMovesMat(isnan(interDistrictMovesMat)) = 0;

aveMigsPerson = sum(sum(mean(interDistrictMovesMat,3))) / sum(mean(popMat,2));

absMinWealth = Inf;
minWealthGini = 0;
flags = [];
incomePoints = [41:44 201:204 401:404];
coastalMatrixIDs = [1 3 4 7 9 12 16 19 22 23 27 31 40 46 49 50 55 56 63];




cd('RCP26\Outputs')

fileList = dir('RCP*');
flags = [];
averageNumberSources = zeros(length(fileList),1);
averageQuantile = averageNumberSources;
gini = averageNumberSources;
wealth = gini;
migrationArray = zeros(64,64,length(fileList));
wealthLocation = zeros(length(fileList),64);
giniLocation = wealthLocation;
inOutRatio = wealthLocation;
netInAverage = wealthLocation;
inputSet = cell(length(fileList),1);
sumMigrationPath = zeros(length(fileList),404); 
netInAverage = wealthLocation; 
popMatrixLocation = wealthLocation;
popByTimeSet = zeros(64,404,length(fileList)); 
trappedByTimeSet = popByTimeSet;
nonAgOccByTimeSet = popByTimeSet;
agOccByTimeSet = popByTimeSet;
incomeDivByTimeSet = popByTimeSet; 
aveIncomeByTimeSet = popByTimeSet;
aveAgIncomeByTimeSet = popByTimeSet;
aveNonAgIncomeByTimeSet = popByTimeSet; 
fullAgIncomeByTimeSet = cell(64,12,length(fileList));
fullNonAgIncomeByTimeSet = cell(64,12,length(fileList));
coastalInMigsPerPopByTimeSet = sumMigrationPath;
coastalOutMigsPerPopByTimeSet = sumMigrationPath;

parfor indexI = 1:length(fileList)
    try
    currentFile = load(fileList(indexI).name);
     fprintf(['RCP26 File ' num2str(indexI) ' of ' num2str(length(fileList)) '\n'])
   
     output = currentFile.output;
     input = currentFile.input;
    portfolioSet = reshape([output.agentSummary.currentPortfolio{:}],height(output.agentSummary),length(output.agentSummary.currentPortfolio{1}));
    %note the prereqs... only count the highest layer of a source
    portfolioSet = [sum(portfolioSet(:,1:4),2) ...
        sum(portfolioSet(:,5:8),2) ...
        sum(portfolioSet(:,9:12),2) ...
        sum(portfolioSet(:,13:16),2) ...
        sum(portfolioSet(:,17:20),2) ...
        sum(portfolioSet(:,21:24),2) ...
        sum(portfolioSet(:,25:28),2) ...
        sum(portfolioSet(:,29:32),2) ...
        sum(portfolioSet(:,33:36),2) ...
        sum(portfolioSet(:,37:40),2) ...
        sum(portfolioSet(:,41:44),2) ...
        sum(portfolioSet(:,45:48),2) ...
        sum(portfolioSet(:,49:52),2)];
    averageNumberSources(indexI) = mean(sum(portfolioSet > 0,2));
    averageQuantile(indexI) = mean(sum(portfolioSet,2) ./ sum(portfolioSet > 0,2));
    %gini(indexI) = calcGini(output.agentSummary.wealth(output.agentSummary.TOD < 0) - min(output.agentSummary.wealth(output.agentSummary.TOD < 0)));
    gini(indexI) = calcGini(output.agentSummary.wealth(output.agentSummary.TOD < 0) - minWealthGini);
    temp = output.agentSummary.wealth(output.agentSummary.TOD < 0);
    temp2 = output.agentSummary.location(output.agentSummary.TOD < 0);
    temp2(isnan(temp)) = [];
    temp(isnan(temp)) = [];
    wealth(indexI) = mean(temp);
    temp3  = zeros(1,64);
    temp4 = temp3;
    for indexJ = 1:max(temp2)
        temp3( midasLocations.matrixID(midasLocations.cityID == indexJ)) = mean(temp(temp2 ==indexJ));
        temp4( midasLocations.matrixID(midasLocations.cityID == indexJ)) = calcGini(temp(temp2 == indexJ) - minWealthGini);
        
    end
    migrationArray(:,:,indexI) = output.migrationMatrix;
    wealthLocation(indexI,:) = temp3;
    giniLocation(indexI,:) = temp4;    
    inOutRatio(indexI,:) = sum(output.migrationMatrix) ./ sum(output.migrationMatrix,2)';
    netInAverage(indexI,:) = (sum(output.migrationMatrix) - sum(output.migrationMatrix,2)') / 51 ;
    inputSet{indexI} = input;
    %estimate number of living agents
    agentBD = zeros(height(output.agentSummary),2);
    for indexA = 1:height(output.agentSummary)
        agentBD(indexA,1) = output.agentSummary.moveHistory{indexA}(1,1);
        agentBD(indexA,2) = output.agentSummary.TOD(indexA);
    end
    
    agentBD(agentBD == -9999) = 9999;
    numAgents = zeros(size(output.migrations));
    for indexT = 1:length(numAgents)
        numAgents(indexT) = sum(agentBD(:,1) <= indexT & agentBD(:,2) > indexT);
    end
    
    tempMigs = output.migrations(end-403:end)' ./numAgents(end-403:end)';
    sumMigrationPath(indexI,:) = tempMigs;
    
    temp = min([output.agentSummary.wealth]);
    %if(temp < absMinWealth)
    %    absMinWealth = temp;
    %end
    
    aveMigsDataPeriod = mean(tempMigs(1:44)) * 4 / input.parameterValues(2);
    sumMigrationPath(indexI,:) = sumMigrationPath(indexI,:) / aveMigsDataPeriod * aveMigsPerson;
        netInAverage(indexI,:) = netInAverage(indexI,:) * sum(mean(popMat,2)) / mean(numAgents(end-204:end));

    temp = output.agentSummary.location(output.agentSummary.TOD < 0);
    temp2 = temp;
    for indexL = 1:length(midasLocations)
        temp2(temp == midasLocations.cityID(indexL)) = midasLocations.matrixID(indexL);
end
popMatrixLocation(indexI,:) = hist(temp2,1:64);

    %%construct time paths of agent population and income by source
    temp = output.portfolioHistory;
    popByTime = zeros(size(temp));
    aveIncomeByTime = zeros(size(temp));
    aveAgIncomeByTime = zeros(size(temp));
    aveNonAgIncomeByTime = zeros(size(temp));
    incomeDivByTime = zeros(size(temp));
    agOccByTime = zeros(size(temp));
    nonAgOccByTime = zeros(size(temp));
    %ag occupation by time
    %non ag occupation by time
    fullAgIncomeByTime = cell(size(temp));
    fullNonAgIncomeByTime = fullAgIncomeByTime;
    for indexA = 1:size(temp,1)
        for indexB = 1:size(temp,2)
            tempPop = temp{indexA,indexB};
            popByTime(indexA, indexB) = length(tempPop);
            tempIncome = zeros(length(tempPop),1);
            tempAgIncome = zeros(length(tempPop),1);
            tempNonAgIncome = zeros(length(tempPop),1);
            tempDiv = zeros(length(tempPop),1);
            tempAgOcc = zeros(length(tempPop),1);
            tempNonAgOcc = zeros(length(tempPop),1);
            tempUtilHist2 = output.utilityHistory(indexA,:,indexB);
            for indexC = 1:length(tempPop)
                tempPort = temp{indexA,indexB}{indexC};
                tempDiv(indexC) = sum(sum(reshape(tempPort,4,13)) > 0);
                tempAgOcc(indexC) = any(tempPort(13:end));
                tempNonAgOcc(indexC) = any(tempPort(1:12));

                
                tempN = tempPort .* tempUtilHist2;
                tempIncome(indexC) = sum(tempN);
                tempNonAgIncome(indexC) = sum(tempN(1:12));
                tempAgIncome(indexC) = sum(tempN(13:end));
                
               
            end
            agOccByTime(indexA, indexB) = sum(tempAgOcc);
            nonAgOccByTime(indexA, indexB) = sum(tempNonAgOcc);
            incomeDivByTime(indexA, indexB) = mean(tempDiv);
            aveIncomeByTime(indexA, indexB) = mean(tempIncome);
            aveAgIncomeByTime(indexA, indexB) = mean(tempAgIncome);
            aveNonAgIncomeByTime(indexA, indexB) = mean(tempNonAgIncome);
            fullAgIncomeByTime{indexA, indexB} = tempAgIncome;
            fullNonAgIncomeByTime{indexA, indexB} = tempNonAgIncome;
        end
    end
    
    %%path of all agent locations
    fracTrappedByTime = zeros(size(temp));
    agentLocsByTime = zeros(size(output.trappedHistory));
    for indexF = 1:length(output.agentSummary.moveHistory)
       currentMoves = output.agentSummary.moveHistory{indexF};
       currentTOD = output.agentSummary.TOD(indexF);
       timesPlace = [];
       if(size(currentMoves,1) > 0)
           %agent has lived
           timesPlace = currentMoves(:,[1 1:2]);
       end
       if(timesPlace(1,1) == 0)
           timesPlace(1,1) = 1;
       end
       if(size(timesPlace,1) > 1)
          %agent has moved
          timesPlace(1:end-1,2) = timesPlace(2:end,2);          
       end
       if(currentTOD > 0)
           timesPlace(end,2) = currentTOD;
       else
           timesPlace(end,2) = size(temp,2);
       end
       
       for indexM = 1:size(timesPlace,1)
          agentLocsByTime(indexF,timesPlace(indexM,1):timesPlace(indexM,2)) = timesPlace(indexM,3);
       end
        
    end
    for indexFT = 1:size(temp,2)
        totalPop = hist(agentLocsByTime(:,indexFT),0:64);
        trappedPop = hist(agentLocsByTime(output.trappedHistory(:,indexFT) == 1, indexFT),0:64);
        fracTrappedByTime(:,indexFT) = trappedPop(2:end) / sum(totalPop(2:end));
    end
    
    %%%estimate migrations INTO the coastal zone from outside
    %i.e., transitions where the agent was previously in a coastal
    %district, then was
    for indexCZ = 1:length(coastalMatrixIDs)
       agentLocsByTime(agentLocsByTime == coastalMatrixIDs(indexCZ)) = 100; 
    end
    agentLocsByTime(and(agentLocsByTime > 0,agentLocsByTime < 100)) = -100;
    agentLocsByTime(:,2:end) = agentLocsByTime(:,2:end) - agentLocsByTime(:,1:end-1);
    coastalInMigs = sum(agentLocsByTime == 200) ./ sum(popByTime);
    coastalOutMigs = sum(agentLocsByTime == -200) ./ sum(popByTime);
    coastalInMigsPerPopByTimeSet(indexI,:) = coastalInMigs(end-403:end);
    coastalOutMigsPerPopByTimeSet(indexI,:) = coastalOutMigs(end-403:end);
    
    trappedByTimeSet(:,:,indexI) = fracTrappedByTime(:,end-403:end);
    popByTimeSet(:,:,indexI) = popByTime(:,end-403:end);
    agOccByTimeSet(:,:,indexI) = agOccByTime(:,end-403:end);
    nonAgOccByTimeSet(:,:,indexI) = nonAgOccByTime(:,end-403:end);
    incomeDivByTimeSet(:,:,indexI) = incomeDivByTime(:,end-403:end);
    aveIncomeByTimeSet(:,:,indexI) = aveIncomeByTime(:,end-403:end);
    aveAgIncomeByTimeSet(:,:,indexI) = aveAgIncomeByTime(:,end-403:end);
    aveNonAgIncomeByTimeSet(:,:,indexI) = aveNonAgIncomeByTime(:,end-403:end);
    fullAgIncomeByTimeSet(:,:,indexI) = fullAgIncomeByTime(:,end-404 + incomePoints);
    fullNonAgIncomeByTimeSet(:,:,indexI) = fullNonAgIncomeByTime(:,end-404 + incomePoints);
    
    catch
        flags = [flags indexI];
    end
end
RCP26.averageNumberSources = averageNumberSources;
RCP26.averageQuantile = averageQuantile;
RCP26.gini = gini;
RCP26.wealth = wealth;
RCP26.migrationArray = migrationArray;
RCP26.wealthLocation = wealthLocation;
RCP26.giniLocation = giniLocation;
RCP26.inOutRatio = inOutRatio;
RCP26.netInAverage = netInAverage;
RCP26.input = inputSet;
RCP26.sumMigrationPath = sumMigrationPath;
RCP26.netInAverage = netInAverage;
RCP26.popMatrixLocation = popMatrixLocation;
RCP26.popByTime = popByTimeSet; 
RCP26.trappedByTime = trappedByTimeSet;
RCP26.agOccByTime = agOccByTimeSet;
RCP26.nonAgOccByTime = nonAgOccByTimeSet;
RCP26.incomeDivByTime = incomeDivByTimeSet;
RCP26.aveIncomeByTime = aveIncomeByTimeSet;
RCP26.aveAgIncomeByTime = aveAgIncomeByTimeSet;
RCP26.aveNonAgIncomeByTime = aveNonAgIncomeByTimeSet; 
RCP26.fullNonAgIncomeByTime = fullNonAgIncomeByTimeSet; 
RCP26.fullAgIncomeByTime = fullAgIncomeByTimeSet; 
RCP26.coastalInMigsPerPopByTime = coastalInMigsPerPopByTimeSet;
RCP26.coastalOutMigsPerPopByTime = coastalOutMigsPerPopByTimeSet;

RCP26.averageNumberSources(flags) = [];
RCP26.averageQuantile(flags) = [];
RCP26.gini(flags) = [];
RCP26.inOutRatio(flags,:) = [];
RCP26.netInAverage(flags,:) = [];
RCP26.wealth(flags) = [];
RCP26.wealthLocation(flags,:) = [];
RCP26.giniLocation(flags,:) = [];
RCP26.migrationArray(:,:,flags) = [];
RCP26.input(flags) = [];
RCP26.sumMigrationPath(flags,:) = [];
RCP26.popMatrixLocation(flags,:) = [];
RCP26.popByTime = popByTimeSet; 
RCP26.trappedByTime(:,:,flags) = [];
RCP26.agOccByTime(:,:,flags) = [];
RCP26.nonAgOccByTime(:,:,flags) = [];
RCP26.incomeDivByTime(:,:,flags) = [];
RCP26.aveIncomeByTime(:,:,flags) = [];
RCP26.aveAgIncomeByTime(:,:,flags) = [];
RCP26.aveNonAgIncomeByTime(:,:,flags) = [];
RCP26.fullNonAgIncomeByTime(:,:,flags) = [];
RCP26.fullAgIncomeByTime(:,:,flags) = [];
RCP26.coastalInMigsPerPopByTime(flags,:) = [];
RCP26.coastalOutMigsPerPopByTime(flags,:) = [];



cd ..
cd ..

cd('RCP45\Outputs')

fileList = dir('RCP*');
flags = [];
averageNumberSources = zeros(length(fileList),1);
averageQuantile = averageNumberSources;
gini = averageNumberSources;
wealth = gini;
migrationArray = zeros(64,64,length(fileList));
wealthLocation = zeros(length(fileList),64);
giniLocation = wealthLocation;
inOutRatio = wealthLocation;
netInAverage = wealthLocation;
inputSet = cell(length(fileList),1);
sumMigrationPath = zeros(length(fileList),404); 
netInAverage = wealthLocation; 
popMatrixLocation = wealthLocation;
popByTimeSet = zeros(64,404,length(fileList)); 
trappedByTimeSet = popByTimeSet;
nonAgOccByTimeSet = popByTimeSet;
agOccByTimeSet = popByTimeSet;
incomeDivByTimeSet = popByTimeSet; 
aveIncomeByTimeSet = popByTimeSet; 
aveAgIncomeByTimeSet = popByTimeSet;
aveNonAgIncomeByTimeSet = popByTimeSet; 
fullAgIncomeByTimeSet = cell(64,12,length(fileList));
fullNonAgIncomeByTimeSet = cell(64,12,length(fileList));
coastalInMigsPerPopByTimeSet = sumMigrationPath;
coastalOutMigsPerPopByTimeSet = sumMigrationPath;

parfor indexI = 1:length(fileList)
    try
    currentFile = load(fileList(indexI).name);
     fprintf(['RCP45 File ' num2str(indexI) ' of ' num2str(length(fileList)) '\n'])
   
     output = currentFile.output;
     input = currentFile.input;
    portfolioSet = reshape([output.agentSummary.currentPortfolio{:}],height(output.agentSummary),length(output.agentSummary.currentPortfolio{1}));
    %note the prereqs... only count the highest layer of a source
    portfolioSet = [sum(portfolioSet(:,1:4),2) ...
        sum(portfolioSet(:,5:8),2) ...
        sum(portfolioSet(:,9:12),2) ...
        sum(portfolioSet(:,13:16),2) ...
        sum(portfolioSet(:,17:20),2) ...
        sum(portfolioSet(:,21:24),2) ...
        sum(portfolioSet(:,25:28),2) ...
        sum(portfolioSet(:,29:32),2) ...
        sum(portfolioSet(:,33:36),2) ...
        sum(portfolioSet(:,37:40),2) ...
        sum(portfolioSet(:,41:44),2) ...
        sum(portfolioSet(:,45:48),2) ...
        sum(portfolioSet(:,49:52),2)];
    averageNumberSources(indexI) = mean(sum(portfolioSet > 0,2));
    averageQuantile(indexI) = mean(sum(portfolioSet,2) ./ sum(portfolioSet > 0,2));
    %gini(indexI) = calcGini(output.agentSummary.wealth(output.agentSummary.TOD < 0) - min(output.agentSummary.wealth(output.agentSummary.TOD < 0)));
    gini(indexI) = calcGini(output.agentSummary.wealth(output.agentSummary.TOD < 0) - minWealthGini);
    temp = output.agentSummary.wealth(output.agentSummary.TOD < 0);
    temp2 = output.agentSummary.location(output.agentSummary.TOD < 0);
    temp2(isnan(temp)) = [];
    temp(isnan(temp)) = [];
    wealth(indexI) = mean(temp);
    temp3  = zeros(1,64);
    temp4 = temp3;
    for indexJ = 1:max(temp2)
        temp3( midasLocations.matrixID(midasLocations.cityID == indexJ)) = mean(temp(temp2 ==indexJ));
        temp4( midasLocations.matrixID(midasLocations.cityID == indexJ)) = calcGini(temp(temp2 == indexJ) - minWealthGini);
        
    end
    migrationArray(:,:,indexI) = output.migrationMatrix;
    wealthLocation(indexI,:) = temp3;
    giniLocation(indexI,:) = temp4;    
    inOutRatio(indexI,:) = sum(output.migrationMatrix) ./ sum(output.migrationMatrix,2)';
    netInAverage(indexI,:) = (sum(output.migrationMatrix) - sum(output.migrationMatrix,2)') / 51 ;
    inputSet{indexI} = input;
    %estimate number of living agents
    agentBD = zeros(height(output.agentSummary),2);
    for indexA = 1:height(output.agentSummary)
        agentBD(indexA,1) = output.agentSummary.moveHistory{indexA}(1,1);
        agentBD(indexA,2) = output.agentSummary.TOD(indexA);
    end
    
    agentBD(agentBD == -9999) = 9999;
    numAgents = zeros(size(output.migrations));
    for indexT = 1:length(numAgents)
        numAgents(indexT) = sum(agentBD(:,1) <= indexT & agentBD(:,2) > indexT);
    end
    
    tempMigs = output.migrations(end-403:end)' ./numAgents(end-403:end)';
    sumMigrationPath(indexI,:) = tempMigs;
    
    temp = min([output.agentSummary.wealth]);
    %if(temp < absMinWealth)
    %    absMinWealth = temp;
    %end
    
    aveMigsDataPeriod = mean(tempMigs(1:44)) * 4 / input.parameterValues(2);
    sumMigrationPath(indexI,:) = sumMigrationPath(indexI,:) / aveMigsDataPeriod * aveMigsPerson;
        netInAverage(indexI,:) = netInAverage(indexI,:) * sum(mean(popMat,2)) / mean(numAgents(end-204:end));

    temp = output.agentSummary.location(output.agentSummary.TOD < 0);
    temp2 = temp;
    for indexL = 1:length(midasLocations)
        temp2(temp == midasLocations.cityID(indexL)) = midasLocations.matrixID(indexL);
end
popMatrixLocation(indexI,:) = hist(temp2,1:64);

    %%construct time paths of agent population and income by source
    temp = output.portfolioHistory;
    popByTime = zeros(size(temp));
    aveIncomeByTime = zeros(size(temp));
    aveAgIncomeByTime = zeros(size(temp));
    aveNonAgIncomeByTime = zeros(size(temp));
    incomeDivByTime = zeros(size(temp));
    agOccByTime = zeros(size(temp));
    nonAgOccByTime = zeros(size(temp));
    %ag occupation by time
    %non ag occupation by time
    fullAgIncomeByTime = cell(size(temp));
    fullNonAgIncomeByTime = fullAgIncomeByTime;
    for indexA = 1:size(temp,1)
        for indexB = 1:size(temp,2)
            tempPop = temp{indexA,indexB};
            popByTime(indexA, indexB) = length(tempPop);
            tempIncome = zeros(length(tempPop),1);
            tempAgIncome = zeros(length(tempPop),1);
            tempNonAgIncome = zeros(length(tempPop),1);
            tempDiv = zeros(length(tempPop),1);
            tempAgOcc = zeros(length(tempPop),1);
            tempNonAgOcc = zeros(length(tempPop),1);
            tempUtilHist2 = output.utilityHistory(indexA,:,indexB);
            for indexC = 1:length(tempPop)
                tempPort = temp{indexA,indexB}{indexC};
                tempDiv(indexC) = sum(sum(reshape(tempPort,4,13)) > 0);
                tempAgOcc(indexC) = any(tempPort(13:end));
                tempNonAgOcc(indexC) = any(tempPort(1:12));

                
                tempN = tempPort .* tempUtilHist2;
                tempIncome(indexC) = sum(tempN);
                tempNonAgIncome(indexC) = sum(tempN(1:12));
                tempAgIncome(indexC) = sum(tempN(13:end));
                
               
            end
            agOccByTime(indexA, indexB) = sum(tempAgOcc);
            nonAgOccByTime(indexA, indexB) = sum(tempNonAgOcc);
            incomeDivByTime(indexA, indexB) = mean(tempDiv);
            aveIncomeByTime(indexA, indexB) = mean(tempIncome);
            aveAgIncomeByTime(indexA, indexB) = mean(tempAgIncome);
            aveNonAgIncomeByTime(indexA, indexB) = mean(tempNonAgIncome);
            fullAgIncomeByTime{indexA, indexB} = tempAgIncome;
            fullNonAgIncomeByTime{indexA, indexB} = tempNonAgIncome;
        end
    end
        %%path of all agent locations
    fracTrappedByTime = zeros(size(temp));
    agentLocsByTime = zeros(size(output.trappedHistory));
    for indexF = 1:length(output.agentSummary.moveHistory)
       currentMoves = output.agentSummary.moveHistory{indexF};
       currentTOD = output.agentSummary.TOD(indexF);
       timesPlace = [];
       if(size(currentMoves,1) > 0)
           %agent has lived
           timesPlace = currentMoves(:,[1 1:2]);
       end
       if(timesPlace(1,1) == 0)
           timesPlace(1,1) = 1;
       end
       if(size(timesPlace,1) > 1)
          %agent has moved
          timesPlace(1:end-1,2) = timesPlace(2:end,2);          
       end
       if(currentTOD > 0)
           timesPlace(end,2) = currentTOD;
       else
           timesPlace(end,2) = size(temp,2);
       end
       
       for indexM = 1:size(timesPlace,1)
          agentLocsByTime(indexF,timesPlace(indexM,1):timesPlace(indexM,2)) = timesPlace(indexM,3);
       end
        
    end
    for indexFT = 1:size(temp,2)
        totalPop = hist(agentLocsByTime(:,indexFT),0:64);
        trappedPop = hist(agentLocsByTime(output.trappedHistory(:,indexFT) == 1, indexFT),0:64);
        fracTrappedByTime(:,indexFT) = trappedPop(2:end) / sum(totalPop(2:end));
    end
    
        %%%estimate migrations INTO the coastal zone from outside
    %i.e., transitions where the agent was previously in a coastal
    %district, then was
    for indexCZ = 1:length(coastalMatrixIDs)
       agentLocsByTime(agentLocsByTime == coastalMatrixIDs(indexCZ)) = 100; 
    end
    agentLocsByTime(and(agentLocsByTime > 0,agentLocsByTime < 100)) = -100;
    agentLocsByTime(:,2:end) = agentLocsByTime(:,2:end) - agentLocsByTime(:,1:end-1);
    coastalInMigs = sum(agentLocsByTime == 200) ./ sum(popByTime);
    coastalOutMigs = sum(agentLocsByTime == -200) ./ sum(popByTime);
    coastalInMigsPerPopByTimeSet(indexI,:) = coastalInMigs(end-403:end);
    coastalOutMigsPerPopByTimeSet(indexI,:) = coastalOutMigs(end-403:end);
    
    trappedByTimeSet(:,:,indexI) = fracTrappedByTime(:,end-403:end);

    popByTimeSet(:,:,indexI) = popByTime(:,end-403:end);
    agOccByTimeSet(:,:,indexI) = agOccByTime(:,end-403:end);
    nonAgOccByTimeSet(:,:,indexI) = nonAgOccByTime(:,end-403:end);
    incomeDivByTimeSet(:,:,indexI) = incomeDivByTime(:,end-403:end);
    aveIncomeByTimeSet(:,:,indexI) = aveIncomeByTime(:,end-403:end);
    aveAgIncomeByTimeSet(:,:,indexI) = aveAgIncomeByTime(:,end-403:end);
    aveNonAgIncomeByTimeSet(:,:,indexI) = aveNonAgIncomeByTime(:,end-403:end);
    fullAgIncomeByTimeSet(:,:,indexI) = fullAgIncomeByTime(:,end-404 + incomePoints);
    fullNonAgIncomeByTimeSet(:,:,indexI) = fullNonAgIncomeByTime(:,end-404 + incomePoints);
    
    catch
        flags = [flags indexI];
    end
end

RCP45.averageNumberSources = averageNumberSources;
RCP45.averageQuantile = averageQuantile;
RCP45.gini = gini;
RCP45.wealth = wealth;
RCP45.migrationArray = migrationArray;
RCP45.wealthLocation = wealthLocation;
RCP45.giniLocation = giniLocation;
RCP45.inOutRatio = inOutRatio;
RCP45.netInAverage = netInAverage;
RCP45.input = inputSet;
RCP45.sumMigrationPath = sumMigrationPath;
RCP45.netInAverage = netInAverage;
RCP45.popMatrixLocation = popMatrixLocation;
RCP45.popByTime = popByTimeSet; 
RCP45.trappedByTime = trappedByTimeSet;
RCP45.agOccByTime = agOccByTimeSet;
RCP45.nonAgOccByTime = nonAgOccByTimeSet;
RCP45.incomeDivByTime = incomeDivByTimeSet;
RCP45.aveIncomeByTime = aveIncomeByTimeSet;
RCP45.aveAgIncomeByTime = aveAgIncomeByTimeSet;
RCP45.aveNonAgIncomeByTime = aveNonAgIncomeByTimeSet; 
RCP45.fullNonAgIncomeByTime = fullNonAgIncomeByTimeSet; 
RCP45.fullAgIncomeByTime = fullAgIncomeByTimeSet; 
RCP45.coastalInMigsPerPopByTime = coastalInMigsPerPopByTimeSet;
RCP45.coastalOutMigsPerPopByTime = coastalOutMigsPerPopByTimeSet;

RCP45.averageNumberSources(flags) = [];
RCP45.averageQuantile(flags) = [];
RCP45.gini(flags) = [];
RCP45.inOutRatio(flags,:) = [];
RCP45.netInAverage(flags,:) = [];
RCP45.wealth(flags) = [];
RCP45.wealthLocation(flags,:) = [];
RCP45.giniLocation(flags,:) = [];
RCP45.migrationArray(:,:,flags) = [];
RCP45.input(flags) = [];
RCP45.sumMigrationPath(flags,:) = [];
RCP45.popMatrixLocation(flags,:) = [];
RCP45.popByTime = popByTimeSet; 
RCP45.trappedByTime(:,:,flags) = [];
RCP45.agOccByTime(:,:,flags) = [];
RCP45.nonAgOccByTime(:,:,flags) = [];
RCP45.incomeDivByTime(:,:,flags) = [];
RCP45.aveIncomeByTime(:,:,flags) = [];
RCP45.aveAgIncomeByTime(:,:,flags) = [];
RCP45.aveNonAgIncomeByTime(:,:,flags) = [];
RCP45.fullNonAgIncomeByTime(:,:,flags) = [];
RCP45.fullAgIncomeByTime(:,:,flags) = [];
RCP45.coastalInMigsPerPopByTime(flags,:) = [];
RCP45.coastalOutMigsPerPopByTime(flags,:) = [];


cd ..
cd ..

cd('RCP85\Outputs')

fileList = dir('RCP*');

flags = [];averageNumberSources = zeros(length(fileList),1);
averageQuantile = averageNumberSources;
gini = averageNumberSources;
wealth = gini;
migrationArray = zeros(64,64,length(fileList));
wealthLocation = zeros(length(fileList),64);
giniLocation = wealthLocation;
inOutRatio = wealthLocation;
netInAverage = wealthLocation;
inputSet = cell(length(fileList),1);
sumMigrationPath = zeros(length(fileList),404); 
netInAverage = wealthLocation; 
popMatrixLocation = wealthLocation;
popByTimeSet = zeros(64,404,length(fileList)); 
trappedByTimeSet = popByTimeSet;
nonAgOccByTimeSet = popByTimeSet;
agOccByTimeSet = popByTimeSet;
incomeDivByTimeSet = popByTimeSet; 
aveIncomeByTimeSet = popByTimeSet; 
aveAgIncomeByTimeSet = popByTimeSet;
aveNonAgIncomeByTimeSet = popByTimeSet; 
fullAgIncomeByTimeSet = cell(64,12,length(fileList));
fullNonAgIncomeByTimeSet = cell(64,12,length(fileList));
coastalInMigsPerPopByTimeSet = sumMigrationPath;
coastalOutMigsPerPopByTimeSet = sumMigrationPath;

parfor indexI = 1:length(fileList)
    try
    currentFile = load(fileList(indexI).name);
     fprintf(['RCP85 File ' num2str(indexI) ' of ' num2str(length(fileList)) '\n'])
   
     output = currentFile.output;
     input = currentFile.input;
    portfolioSet = reshape([output.agentSummary.currentPortfolio{:}],height(output.agentSummary),length(output.agentSummary.currentPortfolio{1}));
    %note the prereqs... only count the highest layer of a source
    portfolioSet = [sum(portfolioSet(:,1:4),2) ...
        sum(portfolioSet(:,5:8),2) ...
        sum(portfolioSet(:,9:12),2) ...
        sum(portfolioSet(:,13:16),2) ...
        sum(portfolioSet(:,17:20),2) ...
        sum(portfolioSet(:,21:24),2) ...
        sum(portfolioSet(:,25:28),2) ...
        sum(portfolioSet(:,29:32),2) ...
        sum(portfolioSet(:,33:36),2) ...
        sum(portfolioSet(:,37:40),2) ...
        sum(portfolioSet(:,41:44),2) ...
        sum(portfolioSet(:,45:48),2) ...
        sum(portfolioSet(:,49:52),2)];
    averageNumberSources(indexI) = mean(sum(portfolioSet > 0,2));
    averageQuantile(indexI) = mean(sum(portfolioSet,2) ./ sum(portfolioSet > 0,2));
    %gini(indexI) = calcGini(output.agentSummary.wealth(output.agentSummary.TOD < 0) - min(output.agentSummary.wealth(output.agentSummary.TOD < 0)));
    gini(indexI) = calcGini(output.agentSummary.wealth(output.agentSummary.TOD < 0) - minWealthGini);
    temp = output.agentSummary.wealth(output.agentSummary.TOD < 0);
    temp2 = output.agentSummary.location(output.agentSummary.TOD < 0);
    temp2(isnan(temp)) = [];
    temp(isnan(temp)) = [];
    wealth(indexI) = mean(temp);
    temp3  = zeros(1,64);
    temp4 = temp3;
    for indexJ = 1:max(temp2)
        temp3( midasLocations.matrixID(midasLocations.cityID == indexJ)) = mean(temp(temp2 ==indexJ));
        temp4( midasLocations.matrixID(midasLocations.cityID == indexJ)) = calcGini(temp(temp2 == indexJ) - minWealthGini);
        
    end
    migrationArray(:,:,indexI) = output.migrationMatrix;
    wealthLocation(indexI,:) = temp3;
    giniLocation(indexI,:) = temp4;    
    inOutRatio(indexI,:) = sum(output.migrationMatrix) ./ sum(output.migrationMatrix,2)';
    netInAverage(indexI,:) = (sum(output.migrationMatrix) - sum(output.migrationMatrix,2)') / 51 ;
    inputSet{indexI} = input;
    %estimate number of living agents
    agentBD = zeros(height(output.agentSummary),2);
    for indexA = 1:height(output.agentSummary)
        agentBD(indexA,1) = output.agentSummary.moveHistory{indexA}(1,1);
        agentBD(indexA,2) = output.agentSummary.TOD(indexA);
    end
    
    agentBD(agentBD == -9999) = 9999;
    numAgents = zeros(size(output.migrations));
    for indexT = 1:length(numAgents)
        numAgents(indexT) = sum(agentBD(:,1) <= indexT & agentBD(:,2) > indexT);
    end
    
    tempMigs = output.migrations(end-403:end)' ./numAgents(end-403:end)';
    sumMigrationPath(indexI,:) = tempMigs;
    
    temp = min([output.agentSummary.wealth]);
    %if(temp < absMinWealth)
    %    absMinWealth = temp;
    %end
    
    aveMigsDataPeriod = mean(tempMigs(1:44)) * 4 / input.parameterValues(2);
    sumMigrationPath(indexI,:) = sumMigrationPath(indexI,:) / aveMigsDataPeriod * aveMigsPerson;
        netInAverage(indexI,:) = netInAverage(indexI,:) * sum(mean(popMat,2)) / mean(numAgents(end-204:end));

    temp = output.agentSummary.location(output.agentSummary.TOD < 0);
    temp2 = temp;
    for indexL = 1:length(midasLocations)
        temp2(temp == midasLocations.cityID(indexL)) = midasLocations.matrixID(indexL);
end
popMatrixLocation(indexI,:) = hist(temp2,1:64);

    %%construct time paths of agent population and income by source
    temp = output.portfolioHistory;
    popByTime = zeros(size(temp));
    aveIncomeByTime = zeros(size(temp));
    aveAgIncomeByTime = zeros(size(temp));
    aveNonAgIncomeByTime = zeros(size(temp));
    incomeDivByTime = zeros(size(temp));
    agOccByTime = zeros(size(temp));
    nonAgOccByTime = zeros(size(temp));
    %ag occupation by time
    %non ag occupation by time
    fullAgIncomeByTime = cell(size(temp));
    fullNonAgIncomeByTime = fullAgIncomeByTime;
    for indexA = 1:size(temp,1)
        for indexB = 1:size(temp,2)
            tempPop = temp{indexA,indexB};
            popByTime(indexA, indexB) = length(tempPop);
            tempIncome = zeros(length(tempPop),1);
            tempAgIncome = zeros(length(tempPop),1);
            tempNonAgIncome = zeros(length(tempPop),1);
            tempDiv = zeros(length(tempPop),1);
            tempAgOcc = zeros(length(tempPop),1);
            tempNonAgOcc = zeros(length(tempPop),1);
            tempUtilHist2 = output.utilityHistory(indexA,:,indexB);
            for indexC = 1:length(tempPop)
                tempPort = temp{indexA,indexB}{indexC};
                tempDiv(indexC) = sum(sum(reshape(tempPort,4,13)) > 0);
                tempAgOcc(indexC) = any(tempPort(13:end));
                tempNonAgOcc(indexC) = any(tempPort(1:12));

                
                tempN = tempPort .* tempUtilHist2;
                tempIncome(indexC) = sum(tempN);
                tempNonAgIncome(indexC) = sum(tempN(1:12));
                tempAgIncome(indexC) = sum(tempN(13:end));
                
               
            end
            agOccByTime(indexA, indexB) = sum(tempAgOcc);
            nonAgOccByTime(indexA, indexB) = sum(tempNonAgOcc);
            incomeDivByTime(indexA, indexB) = mean(tempDiv);
            aveIncomeByTime(indexA, indexB) = mean(tempIncome);
            aveAgIncomeByTime(indexA, indexB) = mean(tempAgIncome);
            aveNonAgIncomeByTime(indexA, indexB) = mean(tempNonAgIncome);
            fullAgIncomeByTime{indexA, indexB} = tempAgIncome;
            fullNonAgIncomeByTime{indexA, indexB} = tempNonAgIncome;
        end
    end
        %%path of all agent locations
    fracTrappedByTime = zeros(size(temp));
    agentLocsByTime = zeros(size(output.trappedHistory));
    for indexF = 1:length(output.agentSummary.moveHistory)
       currentMoves = output.agentSummary.moveHistory{indexF};
       currentTOD = output.agentSummary.TOD(indexF);
       timesPlace = [];
       if(size(currentMoves,1) > 0)
           %agent has lived
           timesPlace = currentMoves(:,[1 1:2]);
       end
       if(timesPlace(1,1) == 0)
           timesPlace(1,1) = 1;
       end
       if(size(timesPlace,1) > 1)
          %agent has moved
          timesPlace(1:end-1,2) = timesPlace(2:end,2);          
       end
       if(currentTOD > 0)
           timesPlace(end,2) = currentTOD;
       else
           timesPlace(end,2) = size(temp,2);
       end
       
       for indexM = 1:size(timesPlace,1)
          agentLocsByTime(indexF,timesPlace(indexM,1):timesPlace(indexM,2)) = timesPlace(indexM,3);
       end
        
    end
    for indexFT = 1:size(temp,2)
        totalPop = hist(agentLocsByTime(:,indexFT),0:64);
        trappedPop = hist(agentLocsByTime(output.trappedHistory(:,indexFT) == 1, indexFT),0:64);
        fracTrappedByTime(:,indexFT) = trappedPop(2:end) / sum(totalPop(2:end));
    end
    
        %%%estimate migrations INTO the coastal zone from outside
    %i.e., transitions where the agent was previously in a coastal
    %district, then was
    for indexCZ = 1:length(coastalMatrixIDs)
       agentLocsByTime(agentLocsByTime == coastalMatrixIDs(indexCZ)) = 100; 
    end
    agentLocsByTime(and(agentLocsByTime > 0,agentLocsByTime < 100)) = -100;
    agentLocsByTime(:,2:end) = agentLocsByTime(:,2:end) - agentLocsByTime(:,1:end-1);
    coastalInMigs = sum(agentLocsByTime == 200) ./ sum(popByTime);
    coastalOutMigs = sum(agentLocsByTime == -200) ./ sum(popByTime);
    coastalInMigsPerPopByTimeSet(indexI,:) = coastalInMigs(end-403:end);
    coastalOutMigsPerPopByTimeSet(indexI,:) = coastalOutMigs(end-403:end);
    
    trappedByTimeSet(:,:,indexI) = fracTrappedByTime(:,end-403:end);

    popByTimeSet(:,:,indexI) = popByTime(:,end-403:end);
    agOccByTimeSet(:,:,indexI) = agOccByTime(:,end-403:end);
    nonAgOccByTimeSet(:,:,indexI) = nonAgOccByTime(:,end-403:end);
    incomeDivByTimeSet(:,:,indexI) = incomeDivByTime(:,end-403:end);
    aveIncomeByTimeSet(:,:,indexI) = aveIncomeByTime(:,end-403:end);
    aveAgIncomeByTimeSet(:,:,indexI) = aveAgIncomeByTime(:,end-403:end);
    aveNonAgIncomeByTimeSet(:,:,indexI) = aveNonAgIncomeByTime(:,end-403:end);
    fullAgIncomeByTimeSet(:,:,indexI) = fullAgIncomeByTime(:,end-404 + incomePoints);
    fullNonAgIncomeByTimeSet(:,:,indexI) = fullNonAgIncomeByTime(:,end-404 + incomePoints);
    
    catch
        flags = [flags indexI];
    end
end
RCP85.averageNumberSources = averageNumberSources;
RCP85.averageQuantile = averageQuantile;
RCP85.gini = gini;
RCP85.wealth = wealth;
RCP85.migrationArray = migrationArray;
RCP85.wealthLocation = wealthLocation;
RCP85.giniLocation = giniLocation;
RCP85.inOutRatio = inOutRatio;
RCP85.netInAverage = netInAverage;
RCP85.input = inputSet;
RCP85.sumMigrationPath = sumMigrationPath;
RCP85.netInAverage = netInAverage;
RCP85.popMatrixLocation = popMatrixLocation;
RCP85.popByTime = popByTimeSet; 
RCP85.trappedByTime = trappedByTimeSet;
RCP85.agOccByTime = agOccByTimeSet;
RCP85.nonAgOccByTime = nonAgOccByTimeSet;
RCP85.incomeDivByTime = incomeDivByTimeSet;
RCP85.aveIncomeByTime = aveIncomeByTimeSet;
RCP85.aveAgIncomeByTime = aveAgIncomeByTimeSet;
RCP85.aveNonAgIncomeByTime = aveNonAgIncomeByTimeSet; 
RCP85.fullNonAgIncomeByTime = fullNonAgIncomeByTimeSet; 
RCP85.fullAgIncomeByTime = fullAgIncomeByTimeSet; 
RCP85.coastalInMigsPerPopByTime = coastalInMigsPerPopByTimeSet;
RCP85.coastalOutMigsPerPopByTime = coastalOutMigsPerPopByTimeSet;


RCP85.averageNumberSources(flags) = [];
RCP85.averageQuantile(flags) = [];
RCP85.gini(flags) = [];
RCP85.inOutRatio(flags,:) = [];
RCP85.netInAverage(flags,:) = [];
RCP85.wealth(flags) = [];
RCP85.wealthLocation(flags,:) = [];
RCP85.giniLocation(flags,:) = [];
RCP85.migrationArray(:,:,flags) = [];
RCP85.input(flags) = [];
RCP85.sumMigrationPath(flags,:) = [];
RCP85.popMatrixLocation(flags,:) = [];
RCP85.popByTime = popByTimeSet; 
RCP85.trappedByTime(:,:,flags) = [];
RCP85.agOccByTime(:,:,flags) = [];
RCP85.nonAgOccByTime(:,:,flags) = [];
RCP85.incomeDivByTime(:,:,flags) = [];
RCP85.aveIncomeByTime(:,:,flags) = [];
RCP85.aveAgIncomeByTime(:,:,flags) = [];
RCP85.aveNonAgIncomeByTime(:,:,flags) = [];
RCP85.fullNonAgIncomeByTime(:,:,flags) = [];
RCP85.fullAgIncomeByTime(:,:,flags) = [];
RCP85.coastalInMigsPerPopByTime(flags,:) = [];
RCP85.coastalOutMigsPerPopByTime(flags,:) = [];



cd ..
cd ..

RCP26.sumMigrationPath = RCP26.sumMigrationPath * 10000;
RCP45.sumMigrationPath = RCP45.sumMigrationPath * 10000;
RCP85.sumMigrationPath = RCP85.sumMigrationPath * 10000;


save outputArrays RCP* -v7.3;


