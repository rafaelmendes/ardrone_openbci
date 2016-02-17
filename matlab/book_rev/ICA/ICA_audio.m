clear all

audio_mix_path = '/home/rafael/Documents/bci_openbci_master/codes/matlab/book_rev/ICA/dataset/flac_data/audio_mix.flac';
audio_homem_path = '/home/rafael/Documents/bci_openbci_master/codes/matlab/book_rev/ICA/dataset/flac_data/audio_homem.flac';
audio_mulher_path = '/home/rafael/Documents/bci_openbci_master/codes/matlab/book_rev/ICA/dataset/flac_data/audio_mulher.flac';

[audio_mix1] = audioread(audio_mix_path);
[audio_homem] = audioread(audio_homem_path);
[audio_mulher,Fs] = audioread(audio_mulher_path);

audio_homem(end:size(audio_mulher,1),1) = 0;

% noise = wgn(size(audio_mulher,1),1);

audio_mix2 = audio_homem + audio_mulher*1.5;

audio_mix = [audio_mix1 audio_mix2];

% sound(audio_mix2, Fs);

[ICA_signal, A, W] = fastica(audio_mix');

sound(ICA_signal(1,:), Fs);
pause(2);
sound(ICA_signal(2,:), Fs);


%% Plots
close all

figure;
plot(audio_homem, 'Linewidth', 3)
hold on
plot(audio_mulher, 'Linewidth', 3)
grid on
legend('Audio Homem', 'Audio Mulher')
xlabel('Tempo')
ylabel('Amplitude')
set(gcf,'color','w');

figure;
plot(audio_mix2, 'g','Linewidth', 3)
grid on
legend('Mix')
xlabel('Tempo')
ylabel('Amplitude')
set(gcf,'color','w');

figure;
plot(audio_homem,'Linewidth', 1)
hold on
plot(ICA_signal(1,:),'Linewidth', 1)
grid on
legend('Audio Homem', 'Homem ICA')
xlabel('Tempo')
ylabel('Amplitude')
set(gcf,'color','w');

figure;
hold on
plot(audio_mulher,'Linewidth', 1)
plot(ICA_signal(2,:),'Linewidth', 1)
grid on
legend('Audio Mulher', 'Mulher ICA')
xlabel('Tempo')
ylabel('Amplitude')
set(gcf,'color','w');






