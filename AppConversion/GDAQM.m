% Takes in AS group delay and its corresponding frequency data
% Calculates its group delay metric using a picewise function

function GDmetric = GDAQM(f_in, gd_in)

    % Raw Blauert curve data
    blauert = load('Blauert');
    blauert_freq = blauert.xnew;
    blauert_max_gd = blauert.ynew;
    
    %Values to be plotted in the app
    min_idx = find(blauert_freq >= 10,1);
    max_idx = find(blauert_freq >= 22000,1);
    
    blauert_freq_app = blauert_freq(min_idx:max_idx);
    blauert_app = blauert_max_gd(min_idx:max_idx);
    
    % Adjustments so metric is calculated from 20 to 16000Hz only
    % The human ear sensitivity
    
    % Blauert curve
    min_idx = find(blauert_freq > 20,1);
    max_idx = find(blauert_freq > 16000,1);

    new_freq_blauert = blauert_freq(min_idx:max_idx);
    blauert_max_gd = blauert_max_gd(min_idx:max_idx);
   
    %% Getting the frequency axis and measured and smoothed group delay
    % from the Acoustic Suite measurements
    gd_bark = gd_in;
    f_bark = f_in;
    %% Creating upper and lower limits
    N = length(f_bark);
    z = zeros(1,N);
    
    lower = length(find(f_bark<300));
    middle = length(find(f_bark>=300 & f_bark<=1000));
    upper = length(find(f_bark>1000));
    lower_limit = [zeros(1,lower) ones(1, middle) zeros(1, upper)];% lower tolerance
    
    upper_limit = z + 80; % 80ms

    % Area between the upper and lower limit
%     Area_80_0 = trapz(lower_limit, upper_limit);
      Area_80_0 = 1758500;

    % Area between the Blauert curve and lower limit
    Area_Blauert_0 = trapz(new_freq_blauert, blauert_max_gd);
    
    % Area between lower limit and 0ms
%     Area_lower = abs(trapz(f_bark, lower_limit));
      Area_lower = 700;

    % Area between measured and lower limit
    Area_M_0 = trapz(f_bark, gd_bark)-Area_lower;

    %% Use Piecewise linear functions to calculate the metric
    % Values were using simple linear regression between
    % Areas [Area_lower Area_Blauert_0 Area_80_0]
    % and ratings [1 3 7] to correspond to research findings with Likert
    % scale
    
    if Area_M_0 >Area_Blauert_0
        GDmetric = 0.000002318*Area_M_0+2.9238;
    else
        GDmetric = 0.000062172*Area_M_0+0.9565;
    end

    %% Rating conversion, from 1-7 to 1-10
    GDmetric = (9/6)*GDmetric-0.5;
    % Rating reverse to have increasing quality with increasing rating
    GDmetric = 10 - GDmetric;
    
    %% Saving values to base workspace
    assignin('base', 'blauert_app', blauert_app);
    assignin('base','blauert_freq_app',blauert_freq_app);
    
    %% IGNORE
    %Visualization - Plotting the GD AQM function
%     areas = [0 Area_Blauert_0 Area_80_0];
%     ratings=[10 7 0];
% 
%     figure()
%     hold on
%     %From the theoretical hardcoded values
%     plot(areas, ratings, 'DisplayName', 'Theoretical piecewise functions')
%     xline(175370, 'DisplayName', 'Example of a measured Area');
%     %example of a measured Area. The intersect is the rating
% 
%     %From the picewise linear functions
%     plot(func,'-r', 'DisplayName', 'Experimental piecewise functions')
% 
%     ylim([0 10])
%     grid on
%     title('Rating vs Area (AU)')
%     xlabel('Area (AU)')
%     ylabel('Resulting metric (AU)')
%     legend('show')
%     hold off

%     disp(['The group delay metric is out of 10.']);
%     disp(['The maximum is 10/10 for a group delay of 0ms.']);
%     disp(['The minimum is 0/10 for a group delay of 80ms.']);
%     disp(['The Blauert curve corresponds to 7/10.']);
%     disp(['For the given measured data, the group delay metric is ', num2str(gd_metric),'/10.'])
end