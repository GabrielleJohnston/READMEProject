% Calculated the True Octave smooth of a signal
% Input: amp (signal), f (frequency)
% frequency range: 15.8 Hz - 31,623 Hz
function [filt_sig,fcenter] = trueOctave(amp, f)

    fcenter = (10.^(0.3*[4:15]));
    fd = 2^0.5;
    fupper = fcenter * fd;
    flower = fcenter / fd;
    filt_sig = zeros(length(fcenter), 1);
    for i=1:length(fcenter)
        filt_sig(i) =  10*log10(sum(10.^(0.1*amp(find(f >= flower(i) & f <= fupper(i)))))/length(find(f >= flower(i) & f <= fupper(i)))); % logarithmic mean
    end

end

