clear all
close all

path='/home/rafael/Documents/eeg_data/doutorado_cleison';
data='A01E.set';

% data_val='esquerda_30_imag.set';

EEG = pop_loadset('filename', data ,'filepath',path);

%% Filtering [8 12] Hz
EEG = pop_eegfilt( EEG, 8, 0, [], [0]);
EEG = pop_eegfilt( EEG, 0, 12, [], [0]);


%% Epoch extraction
% Stop:
X1 = pop_epoch( EEG, {  '768'  }, [1  3], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
X1 = X1.data;
X1_mean = mean(X1,3);
% X1 = X1 - aux(:,ones(size(X1,1),1));

% Move:
X2 = pop_epoch( EEG, {  '783'  }, [1  3], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
X2 = X2.data;
X2_mean = mean(X2,3);
% X2 = X2 - aux(:,ones(size(X2,1),1));

%% Scatter plot

plot(X1(8,:),X1(12,:), 'r*', X2(8,:),X2(12,:), 'b*')
axis([-1 1 -1 1]);
legend('Classe 1', 'Classe 2');
xlabel('C3')
ylabel('C4')
set(gcf,'color','w');
grid on;

%% Covariance matrices computation
C1 = cov(X1_mean');
C1 = C1 / trace(C1);

C2 = cov(X2_mean');
C2 = C2 / trace(C2);

for i=1:size(X1,3)
    C1_epoch(:,:,i) = cov(X1(:,:,i)');
    C2_epoch(:,:,i) = cov(X1(:,:,i)');
end

C1_mean = mean(C1_epoch,3);
C2_mean = mean(C2_epoch,3);





