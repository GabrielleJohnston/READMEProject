%% Load in data
[data, fs] = audioread('IR19061314201696-1.wav');
info = audioinfo('IR19061314201696-1.wav');
NoSamples = info.TotalSamples;
fc = 20000; % cutoff frequency

%% Filter and display data 
framelen = 29; % window size
[data_sgf, order_sgf] = savitzkyGolayFilter(data, fs, fc, framelen);
[freq_sgf, mag_sgf] = getmag(data_sgf, fs, NoSamples);
figure (1)
semilogx(freq_sgf, mag_sgf)
xlim([10 40000])
grid on
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')

%% Compare magnitudes with original magnitudes:
framelen1 = 27;
framelen2 = 127;
framelen3 = 227;
framelen4 = 327;
[freq, mag] = getmag(data, fs, NoSamples);

[data_sgf1, order_sgf1] = savitzkyGolayFilter(data, fs, fc, framelen1);
[freq_sgf1, mag_sgf1] = getmag(data_sgf1, fs, NoSamples);

[data_sgf2, order_sgf2] = savitzkyGolayFilter(data, fs, fc, framelen2);
[freq_sgf2, mag_sgf2] = getmag(data_sgf2, fs, NoSamples);

[data_sgf3, order_sgf3] = savitzkyGolayFilter(data, fs, fc, framelen3);
[freq_sgf3, mag_sgf3] = getmag(data_sgf3, fs, NoSamples);

[data_sgf4, order_sgf4] = savitzkyGolayFilter(data, fs, fc, framelen4);
[freq_sgf4, mag_sgf4] = getmag(data_sgf4, fs, NoSamples);

attenuation1 = mag_sgf1 - mag;
attenuation2 = mag_sgf2 - mag;
attenuation3 = mag_sgf3 - mag;
attenuation4 = mag_sgf4 - mag;

figure (2)
semilogx(freq_sgf1, attenuation1, 'r')
hold on
semilogx(freq_sgf2, attenuation2, 'g')
hold on
semilogx(freq_sgf3, attenuation3, 'b')
hold on
semilogx(freq_sgf4, attenuation4, 'k')
xlim([10 99999])
grid on
xlabel('Frequency (Hz)')
ylabel('Difference between smoothed and original magnitudes (dB)')

%% Time elapsed to plot vs window size 
framelen_range = 27:2:407; % range of window size
% max displayed window for fc = 10000 is 731
% max displayed window for fc = 20000 is 407?

N = 20; % number of times to average time taken over 
elapsedTimeAvg = zeros(length(framelen_range), 1);
order = zeros(length(framelen_range), 1);
for i = 1:length(framelen_range)
    elapsedTime = zeros(N, 1);
    [data_sgf, order(i)] = savitzkyGolayFilter(data, fs, fc, framelen_range(i)); 
    [freq_sgf, mag_sgf] = getmag(data_sgf, fs, NoSamples);
    for n = 1:N
        tic;
        semilogx(freq_sgf, mag_sgf)
        xlim([10 40000])
        grid on
        elapsedTime(n) = toc;
    end
    elapsedTimeAvg(i) = mean(elapsedTime);
end

elapsedTimeNoSmooth = zeros(N, 1);

[freq, mag] = getmag(data, fs, NoSamples);
for n = 1:N
    tic;
    semilogx(freq, mag)
    xlim([10 40000])
    grid on
    elapsedTimeNoSmooth(n) = toc;
end
elapsedTimeNoSmoothAverage(1:length(framelen_range)) = mean(elapsedTimeNoSmooth);

figure(3)
plot(framelen_range, elapsedTimeAvg, 'b')
hold on
plot(framelen_range, elapsedTimeNoSmoothAverage, 'k')
xlabel('Window length')
ylabel('Time taken to display plot (s)')
