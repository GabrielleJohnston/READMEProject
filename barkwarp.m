function lambda = barkwarp(fs)
% the /1000 is based on code used in papers, and seems to work better
lambda = 1.0674*sqrt((2/pi)*atan(0.06583*fs/1000))-0.1916; 
end

