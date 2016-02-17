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
X1 = pop_epoch( EEG, {  '768'  }, [3  5], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
X1 = X1.data;

% Move:
X2 = pop_epoch( EEG, {  '783'  }, [3  5], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
X2 = X2.data;
%% Scatter plot
% 
% plot(X1(8,:),X1(12,:), 'r*', X2(8,:),X2(12,:), 'b*')
% axis([-1 1 -1 1]);
% legend('Classe 1', 'Classe 2');
% xlabel('C3')
% ylabel('C4')
% set(gcf,'color','w');
% grid on;

%% Covariance matrices classical computation
C1_epoch = zeros(size(X1,1),size(X1,1),size(X1,3)); % dim = channels x samples x trial
C2_epoch = zeros(size(X1,1),size(X1,1),size(X1,3));

for i=1:size(X1,3)
    C1_epoch(:,:,i) = cov(X1(:,:,i)')/trace(cov(X1(:,:,i)'));
    C2_epoch(:,:,i) = cov(X2(:,:,i)')/trace(cov(X2(:,:,i)'));
end

C1 = mean(C1_epoch,3);
C2 = mean(C2_epoch,3);

%% Transformation Matrix computation
[v, lambda] = eig(C1 + C2);

[v2, lambda2] = eig(C2);

% whiten matrix
Q = lambda^(-1/2) * v';

[V D] = eig(Q * C2 * Q');

% [V D] = eig(C1, C1 + C2);

% W = [v1(:,end) v1(:,end-1) v1(:,end-2) v2(:,end-3) v2(:,end-2) v2(:,1)]';
W = V' * Q;

B = [W(1:3,:) ; W(end-2:end,:)]; % transformation matrix with selected eigv (filters)

%% Applying filter to whole data
Y1 = zeros(size(B,1),size(X1,2),size(X1,3));
Y2 = zeros(size(B,1),size(X1,2),size(X1,3));

for i=1:size(X1,3)
    Y1(:,:,i) = B * X1(:,:,i);
    Y2(:,:,i) = B * X2(:,:,i);
end

%% Feature extraction

feature1 = zeros(size(X1,3),size(B,1));
feature2 = zeros(size(X1,3),size(B,1));

for i=1:size(X1,3) % for all trials
    feature1(i,:) = log10(var(Y1(:,:,i), [], 2))';
    feature2(i,:) = log10(var(Y2(:,:,i), [], 2))';
end

feature = [feature1; feature2];












