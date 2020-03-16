function AvgResponse = AvgSWEEP(responsetot, time, number, silence, fs, preequal)

% Averages "number" sweep measurements of duration "time" followed by silence zones of duration "silence"
% Does so from the vector "responsetot " containing them


% AvgResponse = AvgSWEEP(responsetot, time, number, silence, fs, preequal)

% "fs" is the sampling frequency
% "preequal" specifies if the response was preequalised

fprintf('\nAveraging %d sweeps of duration %gs. Please wait...\n',number,time);

h = waitbar(0,'Averaging');

nbEch = (time*fs)+1;

if (preequal == 1)
   nbEch = 2^nextpow2(nbEch);
end


AvgResponse = zeros(nbEch+silence*fs, size(responsetot,2));

offset = 144+floor(fs/4);

for i = 1:number
   AvgResponse = AvgResponse + responsetot(offset:offset + nbEch + silence*fs - 1, :);
   offset = offset + nbEch + silence*fs;
   waitbar(ceil(i/number));
end

close(h);

AvgResponse = AvgResponse/number;

fprintf('Averaging carried out successfully !\n');

return;