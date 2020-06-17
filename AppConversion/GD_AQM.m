%% June 17 2020, Marcella Iswanto mai1817@ic.ac.uk
% For each frequency, there is a linear relationship between group delay
% and perceived annoyance a.k.a GD AQM rating.
% This function loops through the input frequency array, and for each
% corresponding GD calculates a GD metric rating.
% The final GD metric rating is the mean of all ratings.
% The functions are calculated using linear regression, linear least
% squares.

% The input GD must already bark smoothed. See rgeobark_short.m

% clear all, clc

function metric = GD_AQM(GDin, GDf)

%Measured gd
% gd = load('measuredGroupDelay');
% gd_in_f = gd.freq_bark; %input frequency data
% gd_in = gd.group_delay_bark_left ; %input group delay data
gd_in = GDin;
gd_in_f = GDf;

% Upper and lower tolerances corresponding to 10/10, 0/10 cost respectively
upper = 80;
lower = 0;

% Loading the Blauert curve: threshold of audibility w.r.t group delay
% (msec) in the human hearing range.
blauert = load('Blauert');
blauert_freq = blauert.xnew;
blauert_gd = blauert.ynew;

% Linear regression
% Looping through input GD values for various frequencies
% Calculating their GD AQM rating

y = [0 4 10]; % Known costs array
n = length(y); % number of points used for linear regression

% Input GD values are rounded
gd_in_f_round = round(gd_in_f);

% Finding the indices of common elements to gd_in_f_round and blauert_freq
pos=arrayfun(@(x) find(blauert_freq==x,1),gd_in_f_round,'UniformOutput',false);

% pos is a cell array.
% ind is the array version of pos.
% Elements point to indices in blauert_freq for which
% gd_in_f == blauert_freq
ind = cell2mat(pos);
% newF = blauert_freq(pos2); % ignore

% Some elements in the input GD frequency array are not in the blauert
% array. These are lost in converting cell to array above.
% Finding those elements:
not_in_blauert =setdiff(gd_in_f_round,blauert_freq);
% Deleting them from the input GD frequency, and their corresponding GD
[~,in_both]=ismember(gd_in_f_round, not_in_blauert);
gd_in_f_round = gd_in_f_round(in_both==0); %stripped input frequency data
gd_in = gd_in(in_both==0); %stripped input gd data

% Initializing the metric array, memory pre-allocation
gd_metric_array = zeros(1,length(gd_in));

for i = 1:length(gd_in)
    x = [lower blauert_gd(ind(i)) upper]; % Group delay values
    format long
    % Calculating the coefficient using linear least squares
    a = (n*(sum(x.*y)) - sum(x)*sum(y))/(n*(sum(x.^2)) - (sum(x)^2));
    b = ((sum(x.^2))*(sum(y)) - sum(x.*y)*(sum(x)))/(n*(sum(x.^2)) - (sum(x)^2));
    % Calculating the GD AQM rating using input GD data
    gd_metric_array(i) = a*gd_in(i)+b;
end

% The final rating cost is the mean of all ratings costs.
metric = 10-mean(gd_metric_array);

string = strcat('The GD AQM for the inputted signal is: ',num2str(metric),'/10')
end