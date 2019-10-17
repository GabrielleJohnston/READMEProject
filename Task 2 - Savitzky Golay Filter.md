# Task 2 - Savitzky Golay Filter

Matlab code: 

Main:
`task2sg.m`

Functions:
`savitzkyGolayFilter.m`
`getmag.m`

## Properties of the smooth

* Savitzky-Golay algorithm performs data smoothing based on local least-squares polynomial approximation
* Acts as a low-pass filter, attenuating higher frequencies
* **Less** effective at reducing noise vs other smoothing algorithms
* **More** effective at preserving peaks and high frequency signal data vs other smoothing algorithms
* At lower frequencies (compard to the cutoff frequency), the impulse response of the filter is completely flat
* The polynomial order must be less than or equal to the window length
  * The filter will perform better when the polynomial order is **much** smaller than the window length
  * The window length, also known as the frame length, or window size, is the number of points used for the approximation at once, and must be smaller than the total number of points
* The normalised frequency, or frequency ratio, `fc_ratio = fc/fs`, where `fc` is the cutoff frequency and `fs` is the sampling frequency, is related to the order and window length
  * `fc_ratio = (order + 1)/(3.2*M - 4.6); M = (framelen - 1)/2`
  * This relation is most accurate when the window length is greater or equal to 50

## Smoothing results
The magnitude spectrum of the signals smoothed with cutoff frequencies of 10 kHz and 20 kHz are shown below. The window length, which is discussed further below, is 127.
![](https://github.com/GabrielleJohnston/READMEProject/blob/SG_Gabby/sg_magnitude_spectrum_10-20kHz_127.png)

### Time taken to plot smoothed curve versus unsmoothed curve
At 10 kHz cutoff frequency:
![](https://github.com/GabrielleJohnston/READMEProject/blob/SG_Gabby/timetakenvswindowlength_sg_10kHz_N20_withnosmooth.png)

At 20 kHz cutoff frequency:
![](https://github.com/GabrielleJohnston/READMEProject/blob/SG_Gabby/timetakenvswindowlength_sg_20kHz_N20_withnosmooth.png)

It can thus be seen that although variable, the time taken to plot the smoothed curve is less than the time taken to plot the unsmoothed curve until the window length is increased past approximately 325. The reduction in time is unfortunately very minimal.

### Effects of changing window length

The relation between the normalised frequency, the order, and the window length was rearranged to give:
`order = round(fc_ratio*(3.2*M - 4.6)) - 1`

For a given frequency cutoff value, the window length was varied and the results observed. 

#### Time
The graph below shows the average time taken to plot the graph vs window length for three different runs of the program, demonstrating that with the exception of outliers, the length of the window does not non-neglibly affect the time taken to plot the graph.
![](https://github.com/GabrielleJohnston/READMEProject/blob/SG_Gabby/timetakenvswindowlength_sg_20kHz_N20_comb.png)

#### Magnitude difference
In the graph below for a 10 kHz cutoff frequency, a window length of 227 appeared to yield the highest performance, followed by the window length of 127. In this case high performance is judged based on sharpness of the envelope of the curve when attenuation begins and the value of attenuation of the envelope, where sharper envelopes and lower values are considered "higher performance".

![](https://github.com/GabrielleJohnston/READMEProject/blob/SG_Gabby/differenceinmagnitude_sg_10kHz.png)

In the graph below for a 20 kHz cutoff frequency, the window length of 127 followed by the window length of 227 appeared to yield the highest performance.


![](https://github.com/GabrielleJohnston/READMEProject/blob/SG_Gabby/differenceinmagnitude_sg_20kHz.png)

## Sources

https://www.ece.rutgers.edu/~orfanidi/intro2sp/orfanidis-i2sp.pdf

https://c.mql5.com/forextsd/forum/147/sgfilter.pdf

https://uk.mathworks.com/help/signal/ref/sgolayfilt.html
