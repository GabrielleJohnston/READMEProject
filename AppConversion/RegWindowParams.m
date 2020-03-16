% Script to set the parameters of the regularization window in terms of its low frequency, high frequency, width of the transition band of the high-pass filter, and width of the transition band of the low pass filter
prompt = {'Low frequency of the regularization window' 'High frequency of regularization window' 'Width of the transition band of the high-pass filter' 'Width of the transition band of the low pass filter'};
defans = {'70','20000','20','20'};
answer = inputdlg(prompt, 'Regularization window settings', 1, defans);

if isempty(answer) == 1
   fprintf('Operation cancelled.\n');
   return;
end

lowfreqRegUser = str2double(answer(1));
highfreqRegUser = str2double(answer(2));
lowTB = str2double(answer(3));
highTB = str2double(answer(4));

if (lowfreqRegUser - lowTB) < 0
   fprintf('The low frequency adjustment is too small relative to the transition frequency width');
   return;
end;

if (highfreqRegUser + highTB) > 0.5*fs
   fprintf('The high frequency of regulation is too large compared to the transition frequency width'); %to avoid the phenomena of aliasing
   return;
end;

fprintf('\nThe signal is preequalized from %dHz to %dHz\n', lowfreqRegUser, highfreqRegUser);
fprintf('The widths of the transition LP and HP band filters are, respectively: %dHz and %dHz\n\n', lowTB, highTB);

lowfreqReg = lowfreqRegUser - 0.5*lowTB; % To take into account the transition frequency width
highfreqReg = highfreqRegUser + 0.5*highTB;

