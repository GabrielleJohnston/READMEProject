%% Loading in data
[dataL, fs] = audioread('Ashdown MAG 410 T Deep B5 Left A 230 200 320.wav');
[dataR, fs] = audioread('Ashdown MAG 410 T Deep B5 Right A 230 200 320.wav');
NoSamples = length(dataL);
dataL = dataL(:, 1);
dataR = dataR(:, 1);

T = 1/fs; %sampling period
t = (0:NoSamples-1)*T; %time vector
freq = fs*(0:NoSamples-1)/NoSamples;

%% Freq domain IF
transL = fft(dataL);
transR = fft(dataR);

[MP_inv_abvL, AP_inv_abvL] = inverseFilterv2(transL);
signal_equalised_MP_onlyL = transL.*MP_inv_abvL;
signal_equalisedL = signal_equalised_MP_onlyL.*AP_inv_abvL;

[MP_inv_abvR, AP_inv_abvR] = inverseFilterv2(transR);
signal_equalised_MP_onlyR = transR.*MP_inv_abvR;
signal_equalisedR = signal_equalised_MP_onlyR.*AP_inv_abvR;

signal_equalised_MP_onlyL_t = real(ifft(signal_equalised_MP_onlyL));
signal_equalisedL_t = real(ifft(signal_equalisedL));

signal_equalised_MP_onlyR_t = real(ifft(signal_equalised_MP_onlyR));
signal_equalisedR_t = real(ifft(signal_equalisedR));

%% Calculating IF
Ninv = 2048;
reg = 0.3;
[invL, flag, error] = inverseFilterTime(dataL, Ninv, reg, 0.000001, 10000, 15500, 20000, fs);
resL = filter(invL, 1, dataL);
trans_resL= fft(resL);

%% Calculating IF
Ninv = 2048;
reg = 0.3;
[invR, flag, error] = inverseFilterTime(dataR, Ninv, reg, 0.000001, 10000, 15500, 20000, fs);
resR = filter(invR, 1, dataR);
trans_resR= fft(resR);

%% plotting
figure;
semilogx(freq, 20*log10(abs(trans_resL)))
hold on
semilogx(freq, 20*log10(abs(fft(dataL))))
figure;
semilogx(freq, 20*log10(abs(trans_resR)))
hold on
semilogx(freq, 20*log10(abs(fft(dataR))))

%% Changing coef...
Niir = 512;
Diir = 0;
[hL, ~] = impz(invL, 1);
[biirL, aiirL] = prony(hL, Niir, Diir);
newresL = filter(biirL, aiirL, dataL);
figure;
trans_newresL = fft(newresL);
semilogx(freq, 20*log10(abs(trans_newresL)))

[hR, ~] = impz(invR, 1);
[biirR, aiirR] = prony(hR, Niir, Diir);
newresR = filter(biirR, aiirR, dataR);
trans_newresR = fft(newresR);
figure;
semilogx(freq, 20*log10(abs(trans_newresR)))

%% Warped FIR 
lambda = barkwarp(fs); 
h_warpedL = warpImpulseResponse(hL, lambda);
Niir = 512;
[bw1L, ~] = prony(h_warpedL, Niir, 0);
yL = warpedFIR(dataL, h_warpedL, lambda);
y1L = warpedFIR(dataL, bw1L, lambda);
figure;
semilogx(freq, 20*log10(abs(trans_resL)))
hold on
semilogx(freq, 20*log10(abs(fft(yL))))

figure;
semilogx(freq, 20*log10(abs(trans_newresL)))
hold on
semilogx(freq, 20*log10(abs(fft(y1L))))

h_warpedR = warpImpulseResponse(hR, lambda);
[bw1R, ~] = prony(h_warpedR, Niir, 0);
yR = warpedFIR(dataR, h_warpedR, lambda);
y1R = warpedFIR(dataR, bw1R, lambda);
figure;
semilogx(freq, 20*log10(abs(trans_resR)))
hold on
semilogx(freq, 20*log10(abs(fft(yR))))

figure;
semilogx(freq, 20*log10(abs(trans_newresR)))
hold on
semilogx(freq, 20*log10(abs(fft(y1R))))