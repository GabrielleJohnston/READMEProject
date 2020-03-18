function warpedSig = warpImpulseResponse(signal, lambda)
%WARPIMPULSERESPONSE Apply bark warping on impulse response 
%   Do this prior to applying lpc() or prony()
    sigLength = length(signal);
    b = [lambda 1]';
    a = [1 lambda]';
    feed = [1 zeros(1, sigLength)];
    warpedSig = signal(1)*feed;
    for i = 2:sigLength
        temp = filter(b, a, feed);
        feed = temp;
        warpedSigTemp = warpedSig + signal(i)*temp;
        warpedSig = warpedSigTemp;
    end
end

