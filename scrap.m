

x = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15];
y = [1 2 3 3 3 2 2 2 1 2 3 2 4 6 3];
data = [x y];
odd_width = 3;
figure (1);
subplot(2,1,1)
plot(x,y);
smoothed = (@Trig_Smooth)
subplot(2,1,2)
plot(x,smoothed);