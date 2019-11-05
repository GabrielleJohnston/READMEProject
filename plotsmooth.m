%Read wav file, plot in frequency domain

%% Load data
clear all
close all
[z,fs]=audioread('Test.m4a');% fs = sample rate
info = audioinfo('Test.m4a');
NoSamples = info.TotalSamples;
y=z(:,1)+z(:,2);
y(1400000:end)=0;
sound(y,fs);
pause(3);


%% Plot Sound 
figure(1);
subplot(6,1,1);
plot(1:length(y),y);


%% Find FT
Y = fft(y);
freq = fs*(0:NoSamples-1)/NoSamples;


%% Plot Mag
Mag = 20*log10(abs(Y));
subplot(6,1,2);
semilogx(freq ,Mag,'r');

%% Plot fast Smoothed Mag
yfs=fastsmooth(y, 100, 2);
subplot(6,1,3);
plot(1:length(yfs),yfs);
sound(yfs,fs);
pause(3);

norm_yfs=yfs/(max(yfs));
sound(norm_yfs,fs);
pause(3);

%% Plot trig Smoothed Mag
yts=Trig_Smooth(y, 101);
subplot(6,1,4);
plot(1:length(yts),yts);
sound(yts,fs);
pause(3);

norm_yts=yts/(max(yts));
sound(norm_yts,fs);
pause(3);
%% Plot fast Smoothed Sound
% yfS = ifft(YfS);
% subplot(6,1,5);
% plot(1:length(real(yfS)),real(yfS));
% sound(real(yfS),fs);
% pause(10);

%% Plot trig Smoothed Sound
% ytS = ifft(YtS);
% subplot(6,1,6);
% plot(1:length(real(ytS)),real(ytS));
% sound(real(ytS),fs);


% 
% 
% ys = ifft(Ys);
% subplot(5,1,5);
% plot(1:length(y),ys)
% % pause(10);
% % sound(Ys,fs);
% % figure(1);
% % subplot(3,1,1);

%  semilogx(freq ,Mag,'r');
%  title("Original signal");
%  xlabel('frequency(Hz)');
%  ylabel('magnitude(dB)');
%  xlim([10 100000])
%  ylim([-100 50]);
% set(gca, 'XScale', 'log');
% 
% for repeats = 1
%     n=1;
% for w = 1:6:7
%     tic;
%     s = fastsmooth(Mag, w, 2);
%     t_fs_f(repeats,n) = toc;
%     tic;
%     figure(1);
%     semilogx(freq,s,'b');
%     t_fs_p(repeats,n) = toc;
%     close all
%     sum_fs(n) = sum(abs(s-Mag));
%     tic;
%     T = Trig_Smooth(Mag, w);
%     t_ts_f(repeats,n) = toc;
%     tic;
%     figure(1);
%     semilogx(freq,T,'b');
%     t_ts_p(repeats,n) = toc;
%     
%     close all
%     sum_ts(n) = sum(abs(T-Mag));
%     n=n+1;
% end
% end
% mt_fs_f = mean(t_fs_f(1:end,:));
% mt_fs_p = mean(t_fs_p(1:end,:));
% mt_ts_f = mean(t_ts_f(1:end,:));
% mt_ts_p = mean(t_ts_p(1:end,:));
% 
% 
% figure(2);
% plot(1:6:151,mt_fs_f)
% hold on
% plot(1:6:151,mt_fs_p)
% hold on
% plot(1:6:151,mt_ts_f)
% hold on
% plot(1:6:151,mt_ts_p)
% legend("FS: function","FS: plot","TS: function","TS: plot")
% xlabel("Filter width")
% ylabel("Time elapsed (s)")
% title("Time elapsed vs Filter width")
% 
% figure(3);
% plot(1:6:151,sum_fs)
% hold on
% plot(1:6:151,sum_ts)
% legend("SAD: Fs","SAD: Ts")
% xlabel("Filter width")
% ylabel("Sum Absolute Difference")
% title("Sum Absolute Difference vs Filter width")

% set(gca, 'YScale', 'linear');
%=================================================================
%% plot smoothed version
% hold on;
% % tic
% s = fastsmooth(Mag, 1, 2); %a function from Mathwork
% % toc
% % tic
% % figure(2);
% subplot(3,1,2)
% semilogx(freq,s,'b');
% title("fastsmooth filter");
% xlabel('frequency(Hz)');
%  ylabel('magnitude(dB)');
%  xlim([10 100000])
%  ylim([-100 50]);
% % toc
% %% plot smooth (Alex)
% 
% %tic
% T = Trig_Smooth(Mag, 1); %a function from Mathwork
% %toc
% %tic
% %figure(3);
% subplot(3,1,3);
% semilogx(freq,T,'b');
% title("TrigSmooth filter");
% xlabel('frequency(Hz)');
%  ylabel('magnitude(dB)');
%  xlim([10 100000])
%  ylim([-100 50]);
% %toc