function smoothed = Trig_Smooth(ydata, odd_width)
half_width=(odd_width/2)-0.5;
length_ydata=length(ydata);
for PositionInFilter = 1:round(odd_width/2)
    filter(PositionInFilter)=PositionInFilter;
end;
for PositionInFilter = (round(odd_width/2)+1):odd_width
    filter(PositionInFilter)=(odd_width-PositionInFilter)+1;
end;

for PositionInData = 1:length_ydata
if PositionInData-half_width>=1
    lower_width = half_width;
else
    lower_width = PositionInData-1;
end;
if PositionInData+half_width<=length_ydata
    upper_width = half_width;
else
    upper_width = length(ydata)-PositionInData;
end;    
total=0;
divide=0;
    for PositionInWidth = -lower_width:upper_width
        total = total+ filter(PositionInWidth+lower_width+1)*ydata(PositionInData+PositionInWidth);
        divide=divide+filter(PositionInWidth+lower_width+1);
    end;
    
    smoothed(PositionInData)=total/(divide);
    lower_width
    upper_width
    total
    filter
    smoothed(PositionInData)
<<<<<<< HEAD
end;
=======
end;

























% 
% 
% 
% 
% 
% 
% function smoothed = Trig_Smooth(data, odd_width)
% [x y] = data; %Take in both x and y coordinates, all tho might not need x set
% half_width = odd_width/2 - 0.5; %How many points to move left and right
%     for j = 1:(length(x))%Go through each point in input data
%         if half_width+1<=j %if counter is at the start then set the lower boundary s.t it doesnt go into negative indexes
%             lower_width = -half_width;
%         else
%             lower_width = -(j-1);
%         end;
%         if half_width+j<=(length(x))%if counter is at the end then set the upper boundary s.t it doesnt go into negative indexes
%             upper_width = half_width;
%         else
%             upper_width = (half_width+j)-odd_width;
% 
%         for i = (lower_width:upper_width)%At each data point, go left and right from that point and put those values into filter[]
%             x(i+j) = filter(half_width+1+i);
%         end;
% 
%         for k = (1:half_width+1)%Sum the first half of the points in filter[], also multiply by their weighting
%             total=filter(k)*k;
%         end;
%         for m = (half_width+2:odd_width)%Sum the first half of the points in filter[], also multiply by their weighting
%             total=filter(k)*(odd_width-(m-1));
%         end;
%         smoothed(j)=total/((upperwidth-lowerwidth)+1);%out put smoothed[], where each value the average summed points
%     end;
% end;
>>>>>>> 96fd618f1aa8bf65b1ebc063ec7d6669b65487d0
