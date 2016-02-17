% [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;


for j=1:9
    filenamegdf = ['/arquivos/Documents/eeg_data/doutorado_cleison/A0' num2str(j) 'E.gdf'];
    filenameset = ['/arquivos/Documents/eeg_data/doutorado_cleison/data_set/A0' num2str(j) 'E.set'];
    
    path_labelsE = ['/arquivos/Documents/eeg_data/doutorado_cleison/true_labels/A0' num2str(j) 'E.mat'];
    path_labelsEcsv = ['/arquivos/Documents/eeg_data/doutorado_cleison/true_labels/A0' num2str(j) 'E.csv'];
    

    EEG = pop_biosig(filenamegdf, 'channels',[1:22]);
    
    pop_expevents(EEG, path_labelsEcsv, 'seconds');
    
    labels = csvread(path_labelsEcsv,1);

    aux = load(path_labelsE);
    
    epoch_index = find(labels == 783);
    
    true_labels = aux.classlabel;
    
    true_labels(true_labels == 1) = 769;
    true_labels(true_labels == 2) = 770;
    true_labels(true_labels == 3) = 771;
    true_labels(true_labels == 4) = 772;
    
    labels(epoch_index) = true_labels;
    
    dlmwrite(path_labelsEcsv,labels(:,[1 2 3]),'	');
%     labels = [header; labels];
    
%     csvwrite(path_labelsEcsv,labels, header);
        

%     EEG = pop_saveset( EEG, 'filename', filenameset);

end

%% Altera os headers dos arquivos gerados para

% header =  number	type	latency	duration	ureven;
clc 
for j=1:9
    filenameset = ['/arquivos/Documents/eeg_data/doutorado_cleison/data_set/A0' num2str(j) 'E.set'];
    
    path_labelsEcsv = ['/arquivos/Documents/eeg_data/doutorado_cleison/true_labels/A0' num2str(j) 'E.csv'];
    
    EEG = pop_loadset(filenameset);
    
    EEG = pop_importevent( EEG, 'append','no','event',path_labelsEcsv,'fields',{'number' 'type' 'latency' 'duration' 'ureven'},'skipline',1,'timeunit',1,'align',0);

    EEG = pop_saveset( EEG, 'filename', filenameset);


end