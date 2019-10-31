function new_signal = bark_space(signal, no_bands, start_freq_indx, end_freq_indx, idealNoPoints, band_spacing)
% BARK_SPACE downsamples the signal in accordance with the bark scale
new_signal = signal(start_freq_indx:band_spacing(1):(band_spacing(1)*idealNoPoints(1)));
for n = 2:no_bands
    new_signal_temp = signal((end_freq_indx(n - 1)):band_spacing(n):(band_spacing(n)*idealNoPoints(n) + end_freq_indx(n - 1) - 1));
    new_signal_temp2 = horzcat(new_signal, new_signal_temp);
    new_signal = new_signal_temp2;
end
end

