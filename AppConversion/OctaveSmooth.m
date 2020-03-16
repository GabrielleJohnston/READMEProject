function [filt_sig, fcenter] = OctaveSmooth(amp, f, base)
    if base == 2
        fcenter  = 10^3 * (2 .^ ([-18:16]/3));
        fd = 2^(1/6);
    else
        fcenter = 10.^(0.1.*[12:46]);
        fd = 10^0.05;
    end
    fupper = fcenter * fd;
    flower = fcenter / fd;
    filt_sig = zeros(length(fcenter), 1);
    for i=1:length(fcenter)
        filt_sig(i) =  10*log10(sum(10.^(0.1*amp(find(f >= flower(i) & f <= fupper(i)))))/length(find(f >= flower(i) & f <= fupper(i)))); % logarithmic mean
    end
end