clc; 
% clear all;
% close all; 

% cd /arquivos/software/BCILAB
% startup

mrks = {'769', '770'};

TrainAccuracy = zeros(9,1);
TestAccuracy = zeros(9,1);

for j=1:9
    % load the data set (BCI2000 format)
    filenameset = ['/arquivos/Documents/eeg_data/doutorado_cleison/data_set/A0' num2str(j) 'T.set'];
    filenamesev = ['/arquivos/Documents/eeg_data/doutorado_cleison/data_set/A0' num2str(j) 'E.set'];
    
    traindata = io_loadset(filenameset);

    % define the approach (here: Common Spatial Patterns without any customization)
    % myapproach = 'SpecCSP'
%     myapproach = {'CSP' 'SignalProcessing',{'EpochExtraction',[0.5 2.5],'FIRFilter',[6 8 30 32]}, ...
%         'FeatureExtraction',{'PatternPairs', 3}, ...
%         'MachineLearning',{'Learner','qda'}};
    myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[0.5 2.5],'IIRFilter',[6 8 30 32]}};
    
%     myapproach = {'SpecCSP' 'SignalProcessing',{'IIRFilter',[6 8 30 32], ...
%         'EpochExtraction',{'TimeWindow',[0.5 2.5],'EventTypes',mrks}}, ...
%         'FeatureExtraction',{'PatternPairs',10}};
    
    % Event markers
    

    % Define approach

    % learn a predictive model
    [trainloss,lastmodel,laststats] = bci_train('Data',traindata,'Approach',myapproach);

    % visualize results
    % bci_visualize(lastmodel)

    %%

    % Applying a model to a new dataset
    testset = io_loadset(filenamesev);
    [predictions,testloss,teststats,targets] = bci_predict(lastmodel,testset);
    
    TrainAccuracy(j) = 100 - trainloss*100;
    TestAccuracy(j) = 100 - testloss*100;
end

clc

TestAccuracy

results_path = '/home/rafael/Documents/eeg_data/doutorado_cleison/results/specCSP_results_IIR.txt';

result_file = fopen(results_path,'w');

fprintf(result_file,'%6s\n','Accuracy (%)');
fprintf(result_file,'%6.2f\n',TestAccuracy);

fclose(result_file);
% Print Results
% disp(['training classification rate: ' num2str(100 - trainloss*100,3) '%']);
% disp(['test classification rate: ' num2str(100 - testloss*100,3) '%']);
% disp(['  predicted classes: ',num2str(round(predictions{2}*predictions{3})')]);
% disp(['  true classes     : ',num2str(round(targets)')]);