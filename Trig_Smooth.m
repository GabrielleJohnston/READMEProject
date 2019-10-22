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
end;