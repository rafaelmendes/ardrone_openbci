% Cria Ho diagonal

function [Hf,faixaFreq] = gera_Ho_diag(varargin)


faixa = varargin{1};
coef = varargin{2};
m = varargin{3};
banda = varargin{4};
incremento = varargin{5};
flag = varargin{6};

% fL = 0;  % freq inferior (min 0Hz)
% fH = 40; % freq superior (max 40Hz)
SubBandL = (.5*m-1)/(banda(2))*faixa(1) + 1;
SubBandH = (.5*m-1)/(banda(2))*faixa(2) + 1;

faixaFreq = [SubBandL:SubBandH SubBandL+.5*m:SubBandH+.5*m];


if nargin == 6
    f = faixa(1):incremento:faixa(2);
    switch flag
        case 'expo'
            hS = exp(coef(1,2)*(f-coef(1,1)).^2) + exp(coef(2,2)*(f-coef(2,1)).^2); % Para os senos
            hC = exp(coef(3,2)*(f-coef(3,1)).^2) + exp(coef(4,2)*(f-coef(4,1)).^2); % Para os cossenos

            Hf = diag([hS';hC']);
        case 'ident'
            Hf = eye(length(faixaFreq));
    end
else
    PA = varargin{7}; 
    
    PA_mean = mean(PA,3);
    
    Hf = diag([PA_mean(14,:)';PA_mean(14,:)']);
    
    Hf = Hf(faixaFreq, faixaFreq);
     
end
end