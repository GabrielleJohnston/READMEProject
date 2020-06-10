function [ left, right ] = givelocationwav( elein, angin )
%[ left, right ] = givelocationwav( elein, angin )
%
%This function takes in elevation (elein) and azimuth (angin) angle 
%of the location of soucre of sound, and match them with the respective 
%spatial impulse response in the folder 'LocationIR'.
%Function Returns the location of the left and right channel spatial
%impulse responses.
elein = str2double(elein);
angin = str2double(angin);

if angin == 360.0
    angin = 0;
end

if elein == -0
    elein = 0;
end

if elein >= -45.0 && elein <=45.0
    eleout = elein;
    angout = angin;
elseif elein == 60.0
    eleout = 60.0;
    angout = round(angin/30)*30;
elseif elein == 75.0
    eleout = 75.0;
    angout = round(angin/60)*60;
elseif elein == 90.0
    eleout = 90.0;
    angout = 0;
end

if angout == 360.0
    angout = 0
end


setpath;
file_left = sprintf('space_left_ele%.f_ang%.f.wav',eleout,angout);
left = strcat(LOCATION_PATH,file_left);
file_right = sprintf('space_right_ele%.f_ang%.f.wav',eleout,angout);
right = strcat(LOCATION_PATH,file_right);

% string = "Heyyyyy"
end

