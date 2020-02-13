clear all
close all
file = 'GBS_Project.wav';
[z,zfs]=audioread(file);
xaxis=transpose([0:1/zfs:(length(z)-1)/zfs]);
unsmooth_faxis =  zfs*(0:length(z)-1)/length(z);
num_peaks = 15;
last_harmonic = 6;  % Choose which harmonic is last to display - rest will be plotted but greyed out with noise

int_maybe_noise = [];
figure; plot(z);hold on;
noise_in_signal=z(1:(3e5));
noise_faxis = zfs*(0:length(noise_in_signal)-1)/length(noise_in_signal);
maybe_noise = 20*log10(abs(fft(noise_in_signal)));
int_maybe_noise = interp1(noise_faxis, maybe_noise, unsmooth_faxis);
[smoothed_maybe_noise, n_axis] = rlogbark(unsmooth_faxis, int_maybe_noise);
int_smoothed_maybe_noise = interp1(n_axis, smoothed_maybe_noise, unsmooth_faxis);
figure(12)
% semilogx(noise_faxis, maybe_noise, 'LineWidth', 2)
% hold on 
semilogx(unsmooth_faxis, int_smoothed_maybe_noise)
xlim([15 20000])
hold off

noise_in_singal_abs=abs(noise_in_signal);
noise=mean(noise_in_singal_abs);
Nplus=z>0;
Nplus=Nplus.*noise;
Nminus=z<0;
Nminus=Nminus.*noise;
z=z-Nplus+Nminus;
figure()
plot(z);
legend("Noise","NoNoise");



ClearSignal=PeakRemover(file,num_peaks);

ThreeP = AutoPeak(file);
m=MidFinder(ThreeP,num_peaks);

m2=round(m(2)*zfs);
mend=round(m(end)*zfs);


%% Create the Hanning windows for each harmonic
m_ind = round(m.*zfs);
for filt_num = [1:1:num_peaks]
   
    hann_temp = hann(m_ind(filt_num) - m_ind(filt_num + 1));
    c = zeros(m_ind(filt_num + 1), 1);
    d = zeros((length(z)-m_ind(filt_num)), 1);
    wins_hann{filt_num} = [c' hann_temp' d']'.*z;
end

%% Filter and FT hanning windows 

i = 1;
while i <= length(wins_hann)
    ft_wins_hann{i} = 20*log10(abs(fft(wins_hann{i})));
    [ft_wins_hann{i}, faxis] = rlogbark(unsmooth_faxis, ft_wins_hann{i});
    ft_wins_hann{i} = interp1(faxis, ft_wins_hann{i}, unsmooth_faxis);
    i = i + 1;
end




%% Plot the harmonics 
figure(3)
subplot(2, 1, 1)
% Plot the FT of the signal - with smoothing
semilogx(faxis, rlogbark(unsmooth_faxis, 20*log10(abs(fft(z)))),'LineWidth',2) ;
hold on
semilogx(unsmooth_faxis, 20*log10(abs(fft(z))));
xlim([15 20000]);
title('Plot of Fourier Transform of Impulse');
xlabel('Frequency (Hz)');
ylabel('Amplutide (dB)');

subplot(2, 1, 2)
for i = 1:9
    semilogx(unsmooth_faxis, ft_wins_hann{i});
    hold on
end
xlim([15 20000]);
%% THD
final_harmonic_thd = 10;


%% THDs calculated using magnitude (dB) - with Christophe method


for freqs = [1:40000]
    freq_ind = round(freqs.*length(z)/zfs);
    for harms = [2:final_harmonic_thd]
        temp = 10^((ft_wins_hann{harms}(freq_ind) - ft_wins_hann{1}(freq_ind))/20)*100;
        distortion_at{freqs}(harms-1) = temp;
    end
end

for freqs = [1:40000]
    thd_mag_at(freqs) = sum(distortion_at{freqs});
end

Chris(1,1)=100;
Chris(1,2)=thd_mag_at(100);

Chris(2,1)=1000;
Chris(2,2)=thd_mag_at(1000);

Chris(3,1)=10000;
Chris(3,2)=thd_mag_at(10000);

Chris(4,1)=find(thd_mag_at(15:20000) == min(thd_mag_at(15:20000)));
Chris(4,2)=thd_mag_at(find(thd_mag_at(15:20000) == min(thd_mag_at(15:20000))));

Chris(5,1)=find(thd_mag_at(15:20000) == max(thd_mag_at(15:20000)));
Chris(5,2)=thd_mag_at(find(thd_mag_at(15:20000) == max(thd_mag_at(15:20000))));

figure;
semilogx(thd_mag_at);
ylabel("THD (%)"); xlabel("Frequency (Hz)");
xlim([15 20000]);



