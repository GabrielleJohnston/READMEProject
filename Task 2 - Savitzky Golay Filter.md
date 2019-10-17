---
tags: [Uni/Third year project]
title: Task 2 - Savitzky Golay Filter
created: '2019-10-17T16:05:56.967Z'
modified: '2019-10-17T17:22:28.606Z'
---

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

### Effects of changing window length

The relation between the normalised frequency, the order, and the window length was rearranged to give:
`order = round(fc_ratio*(3.2*M - 4.6)) - 1`

For a given frequency cutoff value, the window length was varied and the results observed. 

#### Time
The graph below shows the average time taken to plot the graph vs window length for three different runs of the program, demonstrating that with the exception of outliers, the length of the window does not non-neglibly affect the time taken to plot the graph.
![](@attachment/third_year_project/timetakenvswindowlength_sg_20kHz_N20_comb.png)

#### Magnitude difference
In the graph below for a 10 kHz cutoff frequency, a window length of 227 appeared to yield the highest performance, followed by the window length of 127. In this case high performance is judged based on sharpness of the envelope of the curve when attenuation begins and the value of attenuation of the envelope, where sharper envelopes and lower values are considered "higher performance".

![](@attachment/third_year_project/differenceinmagnitude_sg_10kHz.png)

In the graph below for a 20 kHz cutoff frequency, the window length of 127 followed by the window length of 227 appeared to yield the highest performance.


![](@attachment/third_year_project/differenceinmagnitude_sg_20kHz.png)
