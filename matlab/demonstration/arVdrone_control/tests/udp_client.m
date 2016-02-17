U = udp('127.0.0.1', 5005);

fopen(U);
% 
% while(1)
fwrite(U, 'x');

% end