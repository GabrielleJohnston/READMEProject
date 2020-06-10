function ThreePeaks=AutoPeak(z,zfs)

    NoSamples = length(z);

    [zsort index] = sort(z);

    timelength=(length(z)-1)/zfs;
    t_ax=[0:1/(zfs):timelength];


    %abs value of signal
    zabs=abs(z);

    % slightly smooth
    MA_coef=150;
    MA=ones(1, MA_coef);
    zsmooth=conv(transpose(zabs),MA,'same');

    %remove slight background noise
    znorm=zsmooth/(max(zsmooth));
    zbignorm=znorm*500;
    zbigroundnorm=round(zbignorm);
    for(i=1:length(zbigroundnorm))
        if(zbigroundnorm(i)==0)
            if(i==1)
                Z(i)=zbigroundnorm(i+1);
            elseif(i==(length(zbigroundnorm)))
                Z(i)=zbigroundnorm(i-1);
            else
                Z(i)=(zbigroundnorm(i-1)+zbigroundnorm(i+1))/2;
            end
        else
        Z(i)=zbigroundnorm(i);
        end
    end

    %find first peak
    peak1leftindex=index(end);
    peak1rightindex=index(end);
    b=0;
    while b==0;
        if (Z(peak1leftindex-1)==0)
            b=1;
        else
            peak1leftindex=peak1leftindex-1;
        end 
    end
    b=0;
    while b==0;
        if (Z(peak1rightindex+1)==0)
            b=1;
        else
            peak1rightindex=peak1rightindex+1;
        end 
    end

    %Ignore band with existing peak
    b=0;
    i=0;
    while b==0;
        if ((index(end-i)>=peak1leftindex) && (index(end-i)<=peak1rightindex))
           i=i+1; 
        else
            b=1;
        end
    end
    %Find second peak
    peak2leftindex=index(end-i);
    peak2rightindex=index(end-i);
    b=0;
    while b==0;
        if (Z(peak2leftindex-1)==0)
            b=1;
        else
            peak2leftindex=peak2leftindex-1;
        end 
    end
    b=0;
    while b==0;
        if (Z(peak2rightindex+1)==0)
            b=1;
        else
            peak2rightindex=peak2rightindex+1;
        end 
    end

    %Ignore band with existing peaks
    b=0;
    i=0;
    while b==0;
        if (((index(end-i)>=peak1leftindex) && (index(end-i)<=peak1rightindex) )|| ((index(end-i)>=peak2leftindex) && (index(end-i)<=peak2rightindex)))
           i=i+1; 
        else
            b=1;
        end
    end
    %Find second peaks
    peak3leftindex=index(end-i);
    peak3rightindex=index(end-i);
    b=0;
    while b==0;
        if (Z(peak3leftindex-1)==0)
            b=1;
        else
            peak3leftindex=peak3leftindex-1;
        end 
    end
    b=0;
    while b==0;
        if (Z(peak3rightindex+1)==0)
            b=1;
        else
            peak3rightindex=peak3rightindex+1;
        end 
    end
    % 
    % 
    % 
    % plot(Z);
    % hold on;
    % xline(peak1leftindex,'r');
    % hold on
    % xline(peak1rightindex,'r');
    % hold on;
    % xline(peak2leftindex,'b');
    % hold on
    % xline(peak2rightindex,'b');
    % hold on;
    % xline(peak3leftindex,'g');
    % hold on
    % xline(peak3rightindex,'g');
    % hold on;

    ThreePeaks(1)=index(end);
    b=0;
    i=0;
    while b==0;
        if ((index(end-i)>=peak1leftindex) && (index(end-i)<=peak1rightindex))
           i=i+1; 
        else
            b=1;
        end
    end
    ThreePeaks(2)=index(end-i);
    b=0;
    i=0;
    while b==0;
        if (((index(end-i)>=peak1leftindex) && (index(end-i)<=peak1rightindex) )|| ((index(end-i)>=peak2leftindex) && (index(end-i)<=peak2rightindex)))
           i=i+1; 
        else
            b=1;
        end
    end
    ThreePeaks(3)=index(end-i);

    ThreePeaks=sort(ThreePeaks/zfs,'descend');
end