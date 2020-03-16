function plottime(x,fs)
% plottime(x[,fs,n])
% Plot IR

if (nargin < 2)
	fs = 44100;
end

n = max(size(x));
time = (0 : n-1) / fs;
h = figure;
set(h, 'Color', [1 1 1]);

for i = (1:size(x,2))           %size(x,2) is the number of channels - 2 if stereo
   subplot(size(x,2),1,i);
   plot(time, x(:,i));
   grid;
   if (size(x,2) == 1)
      title('Impulse Response');
   elseif (i == 1)
      title('Left Ear HRIR');
   else
      title('Right Ear HRIR');
   end
     
   xlabel('Time (s)');
   ylabel('Amplitude');
   axis([0 time(length(time)) -1 1]);
   zoom on;
end