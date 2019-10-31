function new_signal = erb_space(signal, no_bands, samplesPerBand, band_spacing, sample_indx)
%ERB_SPACE Space the signal so that there are the same number of samples in
%each ERB
new_signal = signal(1:band_spacing(1):(band_spacing(1)*samplesPerBand));
for n = 2:no_bands
    new_signal_temp = signal((sample_indx(n - 1)):band_spacing(n):(band_spacing(n)*samplesPerBand + sample_indx(n - 1) - 1));
    new_signal_temp2 = horzcat(new_signal, new_signal_temp);
    new_signal = new_signal_temp2;
end
end

