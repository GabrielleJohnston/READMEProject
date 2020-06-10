function ft_wins_hann = HarmonicFilt(z, zfs, num_peaks, m, unsmooth_faxis)
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
end