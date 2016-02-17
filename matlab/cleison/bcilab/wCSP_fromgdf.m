clc; 
% clear all;
% close all; 

% cd /arquivos/software/BCILAB
% startup



% load the data set (BCI2000 format)
traindata = pop_biosig('/arquivos/Documents/eeg_data/doutorado_cleison/A01T.gdf', 'channels', [1:22]);

% define the approach (here: Common Spatial Patterns without any customization)
% myapproach = 'SpecCSP'
myapproach = {'CSP' 'SignalProcessing',{'EpochExtraction',[0.5 2.5],'FIRFilter',[6 8 30 32]}};

% Event markers
mrks = {'769', '770'};

% Define approach

% learn a predictive model
[trainloss,lastmodel,laststats] = bci_train('Data',traindata,'Approach',myapproach,'TargetMarkers',mrks);

% visualize results
% bci_visualize(lastmodel)

%%

% Applying a model to a new dataset
testset = pop_biosig('/home/rafael/Documents/eeg_data/doutorado_cleison/A01E.gdf', 'channels', [1:22]);
[predictions,testloss,teststats,targets] = bci_predict(lastmodel,testset);

clc
% Print Results
disp(['training classification rate: ' num2str(100 - trainloss*100,3) '%']);
disp(['test classification rate: ' num2str(100 - testloss*100,3) '%']);
% disp(['  predicted classes: ',num2str(round(predictions{2}*predictions{3})')]);
% disp(['  true classes     : ',num2str(round(targets)')]);