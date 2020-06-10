function plotdist(callmode)


% if (nargin < 3)
% 	f2 = 22000;  %end frequency 
% end
% if (nargin < 2)
% 	f1 = 10;  %start frequency
% end

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
    fprintf('File successfully loaded.\n');
    
    checkIR = audioinfo(audio);
    details = checkIR.Comment;
    nums = regexp(details,'\d*','Match');
    f1 = str2num(nums{1});
    f2 = str2num(nums{2});
    
    figure;
    for j = 1:size(x,2)
        n = max(size(x));
        time = (0 : n-1) / fs;

        [rg,max_index]=max(x(:,j));
        T=time(max_index);      %impulse response time
        
        subplot(size(x,2),1,j);

        for i=1:9
        deltatn(i)=T*(log(i)/log(f2/f1));       %theoretical formula
        k(i) = T-deltatn(i);                
        end

        k(2)=k(2)-0.01799;       %adjustments for time
        k(3)=k(3)-0.014305;
        k(4)=k(4)-0.0102;

       for i=1:9
       idx(i)=1+round(((length(time)-1)/time(length(time))*k(i))); %index of tn
       end


       harm2=x(idx(2)-300:idx(2)+1000,j);    %isolates the 2nd harmonic

       harm3=x(idx(3)-300:idx(3)+1000,j);        %isolates  the 3rd harmonic

       harm4=x(idx(4)-200:idx(4)+1500,j);        %isolates the 4th harmonic

       fundamental=x(idx(1)-500:n,j);    %fundamental

       noise=x(1:idx(1)-500,j);   %total harmonic distortion
        
        %f=2.205*10^4;
        f=f2;
        
        
        fd=fft(fundamental);
        freq=(0:length(fundamental)-1)*fs/length(fundamental); %frequnecy axis
        adb=20*log10(abs((fd)));  %amplitude in dB
        index1=1+round(((length(freq)-1)/freq(length(freq))*f));
        freq=freq(1:index1);
        adb=adb(1:index1);
        semilogx(freq,adb);
        hold on;

        dist2=fft(harm2);
        freq2=(0:length(harm2)-1)*fs/length(harm2);
        adb2=20*log10(abs((dist2)));
        index2=1+round(((length(freq2)-1)/freq2(length(freq2))*f));
        freq2=freq2(1:index2);
        adb2=adb2(1:index2);
        freq2=freq2./2;
        semilogx(freq2,adb2);
        hold on;

        dist3=fft(harm3);
        freq3=(0:length(harm3)-1)*fs/length(harm3);
        adb3=20*log10(abs((dist3)));
        index3=1+round(((length(freq3)-1)/freq3(length(freq3))*f));
        freq3=freq3(1:index3);
        adb3=adb3(1:index3);
        freq3=freq3./3;
        semilogx(freq3,adb3);
        hold on;

        dist4=fft(harm4);
        freq4=(0:length(harm4)-1)*fs/length(harm4);
        adb4=20*log10(abs((dist4)));
        index4=1+round(((length(freq4)-1)/freq4(length(freq4))*f));
        freq4=freq4(1:index4);
        adb4=adb4(1:index4);
        freq4=freq4./4;
        semilogx(freq4,adb4);
        hold on
        
        
        dist_noise=fft(noise);
        freq_noise=(0:length(noise)-1)*fs/length(noise);
        adb_noise=20*log10(abs((dist_noise)));
        index_n=1+round(((length(freq_noise)-1)/freq_noise(length(freq_noise))*(f/4)));
        freq_noise=freq_noise(1:index_n);
        adb_noise=adb_noise(1:index_n);
        semilogx(freq_noise,adb_noise);
        hold on
        
     
        fd=fd(1:1000);
        dist2=dist2(1:1000);
        dist3=dist3(1:1000);
        dist4=dist4(1:1000);
        thd=sqrt(dist2.^2+dist3.^2+dist4.^2);
        thd=thd./fd;
        thd=20.*log(abs(thd));
        freq_thd=(0:length(thd)-1)*fs/length(thd);
        ind=1+round(((length(freq_thd)-1)/freq_thd(length(freq_thd))*f));
        freq_thd=freq_thd(1:ind);
        freq_thd=freq_thd./4;
        thd=thd(1:ind);
        semilogx(freq_thd,thd);
       
        
        
       if (size(x,2) == 1)
        title(['Distortion data for file ',file]);
       elseif (j == 1)
       title(['Left channel distortion data for ', file]);
       else
       title(['Right channel distortion data for ', file]);
       end
       xlabel("Frequency (Hz)");
       ylabel("Amplitude (dB)");
       legend(["fundamental","2nd harmonic","3rd harmonic","4th harmonic","THD+noise","THD"], 'Location','southwest');
       axis([10 10^5 -100 80]);   
    end
    
else
   fprintf('Operation cancelled.\n');
    
end

cd(current);

end