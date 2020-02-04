function plot_a_weight(callmode)
% This function plots the a weighted frequency response

setpath;
current = AppConversion;
cd(MEASURES_SWEEP_PATH);

if strcmpi(callmode,'main')
    [file,path] = uigetfile('*.wav','Select a wav file to load');
    audio = strcat(path,file);
    
elseif strcmpi(callmode,'plotfig')
    file = evalin('base','IR_file');
    path = evalin('base','IR_path');
    audio = strcat(path,file);
end

if not (file == 0) 
    [x,fs] = audioread(audio);
    checkIR = audioinfo(audio);
    details = checkIR.Comment;
    nums = regexp(details,'\d*','Match');
    f1 = str2num(nums{1});
    f2 = str2num(nums{2});
    
    n = max(size(x));
    n = 2*2^nextpow2(n);

    fx = fft(x,n);
    assignin('base','fx',fx);
    longfreq = ceil(n/2);
    freq = (0 : longfreq) * fs / n;

    % A weighting equation
    freq2 = freq.^2;
    % coefficients
    c1 = 12194.217^2;
    c2 = 20.598997^2;
    c3 = 107.65265^2;
    c4 = 737.86223^2;
    % numerator and denominator
    num = c1*(freq2.^2);
    den = (freq2+c2) .* sqrt((freq2+c3).*(freq2+c4)) .* (freq2+c1);
    freq_a = 1.2589*num./den;

    figure;

    for i = 1:size(x,2)

       fx_mag = abs(fx(1:(ceil(n/2) + 1), i));
       fx_A = fx_mag(:).*freq_a(:);

       % The frequency range of the graph goes bare low. Will be fine when I
       % make it into a proper function where the limits are applied etc
       db_a = mag2db(fx_A);
       db_test = mag2db(freq_a);
       semilogx(freq, db_a);
       grid;

       if (size(x,2) == 1)
          title('A-weighted Frequency Response');
       elseif (i == 1)
          title('A-weighted RTF Left Channel');
       else
          title('A-weighted RTF Right Channel');
       end

       xlabel('Frequency, Hz');
       ylabel('Amplitude, dB'); 
       xlim([f1 f2+(0.1*f2)]);
    end
   
else
    fprintf('Operation cancelled.\n');
    return
end

cd(current);

end