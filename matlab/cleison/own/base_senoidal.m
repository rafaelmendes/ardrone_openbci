close all
clear all

n = 5; % Número de canais
q = 256; % Número de amostras em uma janela

fs = 256; % Freq de amostragem
delf = fs/q;

fL = 1;
fH = 50;

m = 1 + round((fH - fL) / delf); % Quantidade de componentes de frequência

% Filter specifications
filter_order = 5;                   
filter_cutoff = [2*fL/fs 2*fH/fs];

[b, a] = butter(filter_order,filter_cutoff); 

% Sinal Tempo:
t = linspace(0, q/fs, q);

% Sinal sintético
X = rand(n,q);

% Bins de frequência
f = zeros(1,m);
for i=1:m
    f(i) = fL + (i - 1)*delf;
end

% Base de senos e cossenos.
X0_seno = zeros(n,q);
X0_cos = zeros(n,q);
for i=1:m
    X0_seno(i,:) = sin(2 * pi .* t .* f(i));
    X0_cos(i,:) = cos(2 * pi .* t .* f(i));
end

X0 = [X0_seno; X0_cos];

% Cálculo dos coeficientes:
F = X * X0' * inv(X0 * X0');

X_est = F * X0;

% Aplica filtro aos dados
X_filt=filtfilt(b, a, X')';

plot(t, X_filt(1,:), t, X_est(1,:));
legend('Filtrado', 'Reconstruido')

Y_est = F(1,:);
% Y_est = fft(X_est(1,:),198);

Y_filt=fftshift(fft(X_filt(1,:),2*198));

plot(abs(Y_filt), 'b');
hold on
plot(abs(Y_est), 'r');


%% Análise da influência de cada componente nos canais
X2 = X;
X2(1,:) = X2(1,:) + X0_seno(1,:);

% Cálculo dos coeficientes:
F2 = X2 * X0' * inv(X0 * X0');

figure
plot(F(:,1), '-*b');
hold on
plot(F2(:,1), '-sr', 'LineWidth', 3);

%% Reescrevendo Y_est
F_sin = F(:,1:m); % coef que multiplicam seno a_ij
F_cos = F(:,m+1:end); % coef que multiplicam cosseno b_ij

C = sqrt(F_sin.^2 + F_cos.^2);
theta = atan(F_cos ./ F_sin);

%% Energia dos sinais estimados

P_est = F*F' / 2; % Potencia dos canais a partir da matriz de covariância
P = sum(X_est.^2,2)/q; % Potencia calculada a partir do canais estimados

%% Parametrizacão da matriz de covariância
H0 = eye(2*m); % Define matriz de parametrizacao: diagonal 

step_func = zeros(1,2*m);
step_func(5:10) = 1;
step_func(m+5:m+10) = 1;

% H0 = H0 * step_func;

covX = F * F' / q; % covariância do sinal X estimado
covY = F * H0 * F' / q; % covariância do sinal projetado parametrizada por H0




