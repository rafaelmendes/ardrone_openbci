function [H, w] = DTFT(h,N)
    %Número de pontos da DTFT
    H=fftshift(fft(h,N)); %Calcula a transformada rápida de Fourier
    %Hdb=20*log10(abs(H)); %Calcula magnitude da FFT em db
    %%
    %Cria vetor com a frequência de -pi até pi para o plot da DTFT
    N=fix(N);
    w = (2*pi/N) * (0:(N-1))';
    mid = ceil(N/2) + 1;
    w(mid:N) = w(mid:N) - 2*pi;
    w = fftshift(w);
    %H=H(1:N/2); %descarta metade dos pontos da FFT (Simetria)
end