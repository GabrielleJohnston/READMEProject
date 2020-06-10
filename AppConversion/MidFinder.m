function midpoints= MidFinder(p,n)
    n=n+1;
    df1=p(1)-p(2);
    df2=p(2)-p(3);
    id1=1/df1;
    id2=1/df2;
    D=id2-id1;


    for i =(3:n-1)
        df=p(i-1)-p(i);
        idf=1/df;
        p(i+1)=p(i)-(1/(D+idf));
    end

    for i = 1:(length(p)-1)
        midpoints(i+1)=p(i+1)+((p(i)-p(i+1))/2);
    end

    peak0=p(1)+(1/(id1-D));
    midpoints(1)=p(1)+((peak0-p(1))/2);
end