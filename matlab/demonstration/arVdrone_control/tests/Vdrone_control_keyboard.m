vdrone_cmdlist; % loads the cmd list


while(1)
    [status,cmdout] = system(take_off);
    
    pause(5);
    
    [status,cmdout] = system(land);

end

