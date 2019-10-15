function smoothed = Trig_Smooth(data, odd_width)
[x y] = data; %Take in both x and y coordinates, all tho might not need x set
half_width = odd_width/2 - 0.5; %How many points to move left and right
    for j = 1:(length(x))%Go through each point in input data
        if half_width+1<=j %if counter is at the start then set the lower boundary s.t it doesnt go into negative indexes
            lower_width = -half_width;
        else
            lower_width = -(j-1);
        end;
        if half_width+j<=(length(x))%if counter is at the end then set the upper boundary s.t it doesnt go into negative indexes
            upper_width = half_width;
        else
            upper_width = (half_width+j)-odd_width;

        for i = (lower_width:upper_width)%At each data point, go left and right from that point and put those values into filter[]
            x(i+j) = filter(half_width+1+i);
        end;

        for k = (1:half_width+1)%Sum the first half of the points in filter[], also multiply by their weighting
            total=filter(k)*k;
        end;
        for m = (half_width+2:odd_width)%Sum the first half of the points in filter[], also multiply by their weighting
            total=filter(k)*(odd_width-(m-1));
        end;
        smoothed(j)=total/((upperwidth-lowerwidth)+1);%out put smoothed[], where each value the average summed points
    end;
end;