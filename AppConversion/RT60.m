function RT60(callmode)

setpath;
current = AppConversion;
cd(MEASURES_SWEEP_PATH);

if strcmpi(callmode,'main')
    [file,path] = uigetfile('*.wav','Select a wav file to load');
    audio = strcat(path,file);
    
elseif strcmpi(callmode,'plotfig')
    file = evalin('base','IR_file');
    path = evalin('base','IR_path');
    audio = strcat(path,file);
end

if not (file == 0) 
    [x,fs] = audioread(audio);

    % Y1 
    subplot(8,2,1)
    y1 = bandpass(x,[44 88],4400); 
    start_index1 = min(find(y1>1e-4)); 
    y1 = y1(start_index1:end,:);  
    y1_a = abs(y1);
    time_1 = (0:length(y1)-1)/fs; 
    plot(time_1, y1);
    grid;

                if (size(x,2) == 1)
                    title('Impulse Response for 44Hz - 88Hz band');
                elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                    title('Impulse Response for 44Hz - 88Hz band Left Channel');
                else
                    title('Impulse Response for 44Hz - 88Hz band Right Channel');
                end
    figure;
    %subplot(8,2,2)
    EDC1 = 10*log10(flipud(cumsum(flipud(y1.^2)))); % impulse response is stored in one dimension, thus do not have to add size of vector in cumsum 
    EDC1 = EDC1 - max(EDC1); % max(EDC) is a constant value that normalises the graph to 0dB 
    plot(time_1,EDC1); 
    ylim([-80 10])
    xlim([0 4])
    grid;
                if (size(x,2) == 1)
                    title('Schroeder Integral for 44Hz - 88Hz band');
                elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                    title('Schroeder Integral for 44Hz - 88Hz band Left Channel');
                else
                    title('Schroeder Integral for 44Hz - 88Hz band Right Channel');
                end


            index_y1_1 = min(find(EDC1<0)) %find the indices for where y1 = 0 
            index_y1_2 = min(find(EDC1<-10)) 
            time_x11 = time_1(index_y1_1) 
            time_x12 = time_1(index_y1_2)
            m1 = -10./(time_x12-time_x11) 
            time_t60_Y1 = -60./m1       


                % Compile the indices from the Schroeder Integral to get time

                index_y1_zerodb = min(find(EDC1<0)); %find the indices for where y1 = 0 
                index_y1_fivedb = min(find(EDC1<-5));
                index_y1_tendb = min(find(EDC1<-10));
                index_y1_twentyfivedb = min(find(EDC1<-25));
                index_y1_thirtyfivedb = min(find(EDC1<-35));

                % EDT

                time_x1_zerodb = time_1(index_y1_zerodb);
                time_x1_tendb = time_1(index_y1_tendb);

                slope_y1_EDT = -10./(time_x1_tendb - time_x1_zerodb);
                time_y1_EDT = -60./slope_y1_EDT  

                % T20

                time_x1_T20_fivedb = time_1(index_y1_fivedb);
                time_x1_T20_twentyfivedb = time_1(index_y1_twentyfivedb);

                slope_y1_T20 = -20./(time_x1_T20_twentyfivedb - time_x1_T20_fivedb);
                time_y1_T20 = -60./slope_y1_T20

                % T30 

                time_x1_T30_fivedb = time_1(index_y1_fivedb);
                time_x1_T30_thirtyfivedb = time_1(index_y1_thirtyfivedb);

                slope_y1_T30 = -20./(time_x1_T30_thirtyfivedb - time_x1_T30_fivedb);
                time_y1_T30 = -60./slope_y1_T30
    
    % Y2
    subplot(8,2,3)
    y2 = bandpass(x, [88 177], 4400); 
    start_index2 = min(find(y2>1e-4)); 
    y2 = y2(start_index2:end,:); 
    y2_a = abs(y2);
    time_2 = (0:length(y2)-1)/fs;
    plot(time_2, y2);
    grid;
                if (size(x,2) == 1)
                    title('Impulse Response for 88Hz - 177Hz band');
                elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                    title('Impulse Response for 88Hz - 177Hz band Left Channel');
                else
                    title('Impulse Response for 88Hz - 177Hz band Right Channel');
                end

    subplot(8,2,4)
    EDC2 = 10*log10(flipud(cumsum(flipud(y2.^2)))); 
    EDC2 = EDC2 - max(EDC2); 
    plot(time_2, EDC2);
    ylim([-80 10])
    xlim([0 4])
    grid;
                if (size(x,2) == 1)
                    title('Schroeder Integral for 88Hz - 177Hz band');
                elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                    title('Schroeder Integral for 88Hz - 177Hz band Left Channel');
                else
                    title('Schroeder Integral for 88Hz - 177Hz band Right Channel');
                end 

                % Compile the indices from the Schroeder Integral to get time

                index_y2_zerodb = min(find(EDC2<0)); %find the indices for where y1 = 0 
                index_y2_fivedb = min(find(EDC2<-5));
                index_y2_tendb = min(find(EDC2<-10));
                index_y2_twentyfivedb = min(find(EDC2<-25));
                index_y2_thirtyfivedb = min(find(EDC2<-35));

                % EDT

                time_x2_zerodb = time_1(index_y2_zerodb);
                time_x2_tendb = time_1(index_y2_tendb);

                slope_y2_EDT = -10./(time_x2_tendb - time_x2_zerodb);
                time_y2_EDT = -60./slope_y2_EDT  

                % T20

                time_x2_T20_fivedb = time_1(index_y2_fivedb);
                time_x2_T20_twentyfivedb = time_1(index_y2_twentyfivedb);

                slope_y2_T20 = -20./(time_x2_T20_twentyfivedb - time_x2_T20_fivedb);
                time_y2_T20 = -60./slope_y2_T20

                % T30 

                time_x2_T30_fivedb = time_1(index_y2_fivedb);
                time_x2_T30_thirtyfivedb = time_1(index_y2_thirtyfivedb);

                slope_y2_T30 = -20./(time_x2_T30_thirtyfivedb - time_x2_T30_fivedb);
                time_y2_T30 = -60./slope_y2_T30

    % Y3 
    subplot(8,2,5)
    y3 = bandpass(x, [177 355], 4400); 
    start_index3 = min(find(y3>1e-4)); 
    y3 = y3(start_index3:end,:); 
    y3_a = abs(y3);
    time_3 = (0:length(y3)-1)/fs; 
    plot(time_3, y3); 
    grid;
               if (size(x,2) == 1)
                  title('Impulse Response for 177Hz - 355Hz band');
               elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                  title('Impulse Response for 177Hz - 355Hz band Left Channel');
               else
                  title('Impulse Response for 177Hz - 355Hz band Right Channel');
               end 

    subplot(8,2,6) 
    EDC3 = 10*log(flipud(cumsum(flipud(y3.^2))));
    EDC3 = EDC3 - max(EDC3);
    plot(time_3, EDC3);
    ylim([-80 10])
    xlim([0 4])
    grid;
               if (size(x,2) == 1)
                  title('Schroeder Integral for 177Hz - 355Hz band');
               elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                  title('Schroeder Integral for 177Hz - 355Hz band Left Channel');
               else
                  title('Schroeder Integral for 177Hz - 355Hz band Right Channel');
               end 

                % Compile the indices from the Schroeder Integral to get time

                index_y3_zerodb = min(find(EDC3<0)); %find the indices for where y1 = 0 
                index_y3_fivedb = min(find(EDC3<-5));
                index_y3_tendb = min(find(EDC3<-10));
                index_y3_twentyfivedb = min(find(EDC3<-25));
                index_y3_thirtyfivedb = min(find(EDC3<-35));

                % EDT

                time_x3_zerodb = time_1(index_y3_zerodb);
                time_x3_tendb = time_1(index_y3_tendb);

                slope_y3_EDT = -10./(time_x3_tendb - time_x3_zerodb);
                time_y3_EDT = -60./slope_y3_EDT  

                % T20

                time_x3_T20_fivedb = time_1(index_y3_fivedb);
                time_x3_T20_twentyfivedb = time_1(index_y3_twentyfivedb);

                slope_y3_T20 = -20./(time_x3_T20_twentyfivedb - time_x3_T20_fivedb);
                time_y3_T20 = -60./slope_y3_T20

                % T30 

                time_x3_T30_fivedb = time_1(index_y3_fivedb);
                time_x3_T30_thirtyfivedb = time_1(index_y3_thirtyfivedb);

                slope_y3_T30 = -20./(time_x3_T30_thirtyfivedb - time_x3_T30_fivedb);
                time_y3_T30 = -60./slope_y3_T30
              
    % Y4 
    subplot(8,2,7)
    y4 = bandpass(x, [355 710], 4400);
    start_index4 = min(find(y4>1e-4)); 
    y4 = y4(start_index4:end,:); 
    y4_a = abs(y4); 
    time_4 = (0:length(y4)-1)/fs; 
    plot(time_4, y4); 
    grid;
                if (size(x,2) == 1)
                    title('Impulse Response for 355Hz - 710Hz band');
                elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                    title('Impulse Response for 355Hz - 710Hz band Left Channel');
                else
                    title('Impulse Response for 355Hz - 710Hz band Right Channel');
                end 


    subplot(8,2,8)
    EDC4 = 10*log(flipud(cumsum(flipud(y4.^2))));
    EDC4 = EDC4 - max(EDC4); 
    plot(time_4, EDC4);
    ylim([-80 10])
    xlim([0 4])
    grid;
                if (size(x,2) == 1)
                    title('Schroeder Integral for 355Hz - 710Hz band');
                elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                    title('ISchroeder Integral for 355Hz - 710Hz band Left Channel');
                else
                    title('Schroeder Integral for 355Hz - 710Hz band Right Channel');
                end 

                % Compile the indices from the Schroeder Integral to get time

                index_y4_zerodb = min(find(EDC4<0)); %find the indices for where y1 = 0 
                index_y4_fivedb = min(find(EDC4<-5));
                index_y4_tendb = min(find(EDC4<-10));
                index_y4_twentyfivedb = min(find(EDC4<-25));
                index_y4_thirtyfivedb = min(find(EDC4<-35));

                % EDT

                time_x4_zerodb = time_1(index_y4_zerodb);
                time_x4_tendb = time_1(index_y4_tendb);

                slope_y4_EDT = -10./(time_x4_tendb - time_x4_zerodb);
                time_y4_EDT = -60./slope_y4_EDT  

                % T20

                time_x4_T20_fivedb = time_1(index_y4_fivedb);
                time_x4_T20_twentyfivedb = time_1(index_y4_twentyfivedb);

                slope_y4_T20 = -20./(time_x4_T20_twentyfivedb - time_x4_T20_fivedb);
                time_y4_T20 = -60./slope_y4_T20

                % T30 

                time_x4_T30_fivedb = time_1(index_y4_fivedb);
                time_x4_T30_thirtyfivedb = time_1(index_y4_thirtyfivedb);

                slope_y4_T30 = -20./(time_x4_T30_thirtyfivedb - time_x4_T30_fivedb);
                time_y4_T30 = -60./slope_y4_T30

    % Y5 
    subplot(8,2,9)
    y5 = bandpass(x, [710 1420], 4400);
    start_index5 = min(find(y5>1e-4)); 
    y5 = y5(start_index5:end,:);
    y5_a = abs(y5);
    time_5 = (0:length(y5)-1)/fs; 
    plot(time_5, y5);
    grid;
               if (size(x,2) == 1)
                  title('Impulse Response for 710Hz - 1420Hz band');
               elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                  title('Impulse Response for 710Hz - 1420Hz band Left Channel');
               else
                  title('Impulse Response for 710Hz - 1420Hz band Right Channel');
               end 

    subplot(8,2,10)
    EDC5 = 10*log(flipud(cumsum(flipud(y5.^2))));
    EDC5 = EDC5 - max(EDC5);
    plot(time_5, EDC5);
    ylim([-80 10])
    xlim([0 4])
    grid;
               if (size(x,2) == 1)
                  title('Schroeder Integral for 710Hz - 1420Hz band');
               elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                  title('Schroeder Integral for 710Hz - 1420Hz band Left Channel');
               else
                  title('Schroeder Integral for 710Hz - 1420Hz band Right Channel');
               end

                % Compile the indices from the Schroeder Integral to get time

                index_y5_zerodb = min(find(EDC5<0)); %find the indices for where y1 = 0 
                index_y5_fivedb = min(find(EDC5<-5));
                index_y5_tendb = min(find(EDC5<-10));
                index_y5_twentyfivedb = min(find(EDC5<-25));
                index_y5_thirtyfivedb = min(find(EDC5<-35));

                % EDT

                time_x5_zerodb = time_1(index_y5_zerodb);
                time_x5_tendb = time_1(index_y5_tendb);

                slope_y5_EDT = -10./(time_x5_tendb - time_x5_zerodb);
                time_y5_EDT = -60./slope_y5_EDT  

                % T20

                time_x5_T20_fivedb = time_1(index_y5_fivedb);
                time_x5_T20_twentyfivedb = time_1(index_y5_twentyfivedb);

                slope_y5_T20 = -20./(time_x5_T20_twentyfivedb - time_x5_T20_fivedb);
                time_y5_T20 = -60./slope_y5_T20

                % T30 

                time_x5_T30_fivedb = time_1(index_y5_fivedb);
                time_x5_T30_thirtyfivedb = time_1(index_y5_thirtyfivedb);

                slope_y5_T30 = -20./(time_x5_T30_thirtyfivedb - time_x5_T30_fivedb);
                time_y5_T30 = -60./slope_y5_T30

    % Y6 
    subplot(8,2,11)
    y6 = bandpass(x, [1420 2840], 4400);
    start_index6 = min(find(y6>1e-4)); 
    y6 = y6(start_index6:end,:);
    y6_a = abs(y6);
    time_6 = (0:length(y6)-1)/fs;
    plot(time_6,y6); 
    grid;
               if (size(x,2) == 1)
                  title('Impulse Response for 1420Hz - 2840Hz band');
               elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                  title('Impulse Response for 1420Hz - 2840Hz band Left Channel');
               else
                  title('Impulse Response for 1420Hz - 2840Hz band Right Channel');
               end

    subplot(8,2,12)
    EDC6 = 10*log(flipud(cumsum(flipud(y6.^2)))); 
    EDC6 = EDC6 - max(EDC6); 
    plot(time_6, EDC6); 
    ylim([-80 10])
    xlim([0 4])
    grid;
               if (size(x,2) == 1)
                  title('Schroeder Integral for 1420Hz - 2840Hz band');
               elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                  title('Schroeder Integral for 1420Hz - 2840Hz band Left Channel');
               else
                  title('Schroeder Integral for 1420Hz - 2840Hz band Right Channel');
               end

                % Compile the indices from the Schroeder Integral to get time

                index_y6_zerodb = min(find(EDC6<0)); %find the indices for where y1 = 0 
                index_y6_fivedb = min(find(EDC6<-5));
                index_y6_tendb = min(find(EDC6<-10));
                index_y6_twentyfivedb = min(find(EDC6<-25));
                index_y6_thirtyfivedb = min(find(EDC6<-35));

                % EDT

                time_x6_zerodb = time_1(index_y6_zerodb);
                time_x6_tendb = time_1(index_y6_tendb);

                slope_y6_EDT = -10./(time_x6_tendb - time_x6_zerodb);
                time_y6_EDT = -60./slope_y6_EDT  

                % T20

                time_x6_T20_fivedb = time_1(index_y6_fivedb);
                time_x6_T20_twentyfivedb = time_1(index_y6_twentyfivedb);

                slope_y6_T20 = -20./(time_x6_T20_twentyfivedb - time_x6_T20_fivedb);
                time_y6_T20 = -60./slope_y6_T20

                % T30 

                time_x6_T30_fivedb = time_1(index_y6_fivedb);
                time_x6_T30_thirtyfivedb = time_1(index_y6_thirtyfivedb);

                slope_y6_T30 = -20./(time_x6_T30_thirtyfivedb - time_x6_T30_fivedb);
                time_y6_T30 = -60./slope_y6_T30

    % Y7 
    subplot(8,2,13)
    y7 = bandpass(x, [2840 5680], 24000); 
    start_index7 = min(find(y7>1e-4)); 
    y7 = y7(start_index7:end,:);
    y7_a = abs(y7);
    time_7 = (0:length(y7)-1)/fs;
    plot(time_7, y7); 
    grid;
               if (size(x,2) == 1)
                  title('Impulse Response for 2840Hz - 5680Hz band');
               elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                  title('Impulse Response for 2840Hz - 5680Hz band Left Channel');
               else
                  title('Impulse Response for 2840Hz - 5680Hz band Right Channel');
               end

    subplot(8,2,14)
    EDC7 = 10*log(flipud(cumsum(flipud(y7.^2))));
    EDC7 = EDC7 - max(EDC7);
    plot(time_7, EDC7);
    ylim([-80 10])
    xlim([0 4])
    grid;
               if (size(x,2) == 1)
                  title('Schroeder Integral for 2840Hz - 5680Hz band');
               elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                  title('Schroeder Integral for 2840Hz - 5680Hz band Left Channel');
               else
                  title('Schroeder Integral for 2840Hz - 5680Hz band Right Channel');
               end

                % Compile the indices from the Schroeder Integral to get time

                index_y7_zerodb = min(find(EDC7<0)); %find the indices for where y1 = 0 
                index_y7_fivedb = min(find(EDC7<-5));
                index_y7_tendb = min(find(EDC7<-10));
                index_y7_twentyfivedb = min(find(EDC7<-25));
                index_y7_thirtyfivedb = min(find(EDC7<-35));

                % EDT

                time_x7_zerodb = time_1(index_y7_zerodb);
                time_x7_tendb = time_1(index_y7_tendb);

                slope_y7_EDT = -10./(time_x7_tendb - time_x7_zerodb);
                time_y7_EDT = -60./slope_y7_EDT  

                % T20

                time_x7_T20_fivedb = time_1(index_y7_fivedb);
                time_x7_T20_twentyfivedb = time_1(index_y7_twentyfivedb);

                slope_y7_T20 = -20./(time_x7_T20_twentyfivedb - time_x7_T20_fivedb);
                time_y7_T20 = -60./slope_y7_T20

                % T30 

                time_x7_T30_fivedb = time_1(index_y7_fivedb);
                time_x7_T30_thirtyfivedb = time_1(index_y7_thirtyfivedb);

                slope_y7_T30 = -20./(time_x7_T30_thirtyfivedb - time_x7_T30_fivedb);
                time_y7_T30 = -60./slope_y7_T30

    % Y8
    subplot(8,2,15)
    y8 = bandpass(x, [5680 11360], 24000);
    start_index8 = min(find(y8>1e-4)); 
    y8 = y8(start_index8:end,:);
    y8_a = abs(y8);
    time_8 = (0:length(y8)-1)/fs; 
    plot(time_8, y8);
    grid;
               if (size(x,2) == 1)
                  title('Impulse Response for 5680Hz - 11360Hz band');
               elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                  title('Impulse Response for 5680Hz - 11360Hz band Left Channel');
               else
                  title('Impulse Response for 5680Hz - 11360Hz band Right Channel');
               end 

    subplot(8,2,16) 
    EDC8 = 10*log(flipud(cumsum(flipud(y8.^2))));
    EDC8 = EDC8 - max(EDC8); 
    plot(time_8, EDC8);
    ylim([-80 10])
    xlim([0 4])
    grid;
               if (size(x,2) == 1)
                  title('Schroeder Integral for 5680Hz - 11360Hz band');
               elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                  title('Schroeder Integral for 5680Hz - 11360Hz band Left Channel');
               else
                  title('Schroeder Integral for 5680Hz - 11360Hz band Right Channel'); 
               end 

                % Compile the indices from the Schroeder Integral to get time

                index_y8_zerodb = min(find(EDC8<0)); %find the indices for where y1 = 0 
                index_y8_fivedb = min(find(EDC8<-5));
                index_y8_tendb = min(find(EDC8<-10));
                index_y8_twentyfivedb = min(find(EDC8<-25));
                index_y8_thirtyfivedb = min(find(EDC8<-35));

                % EDT

                time_x8_zerodb = time_1(index_y8_zerodb);
                time_x8_tendb = time_1(index_y8_tendb);

                slope_y8_EDT = -10./(time_x8_tendb - time_x8_zerodb);
                time_y8_EDT = -60./slope_y8_EDT  

                % T20

                time_x8_T20_fivedb = time_1(index_y8_fivedb);
                time_x8_T20_twentyfivedb = time_1(index_y8_twentyfivedb);

                slope_y8_T20 = -20./(time_x8_T20_twentyfivedb - time_x8_T20_fivedb);
                time_y8_T20 = -60./slope_y8_T20

                % T30 

                time_x8_T30_fivedb = time_1(index_y8_fivedb);
                time_x8_T30_thirtyfivedb = time_1(index_y8_thirtyfivedb);

                slope_y8_T30 = -20./(time_x8_T30_thirtyfivedb - time_x8_T30_fivedb);
                time_y8_T30 = -60./slope_y8_T30

    % Graphing of Times for different Octave Bands 
    % Channel still need to be added

    figure(5);
    hold on 
                        % Filtered Signal Bands (in Hz)
                        
                        Filter = [63 125 250 500 1000 2000 4000 8000];

                        % EDT Plot for All Filtered Signals

                        EDT = [time_y1_EDT time_y2_EDT time_y3_EDT time_y4_EDT time_y5_EDT time_y6_EDT time_y7_EDT time_y8_EDT];

                        plot(Filter, EDT, 'o-');

                        % T20 Plot for All filtered Signals

                        T20 = [time_y1_T20 time_y2_T20 time_y3_T20 time_y4_T20 time_y5_T20 time_y6_T20 time_y7_T20 time_y8_T20];

                        plot(Filter, T20, '+-');


                        % T30 Plot for All filtered Signals

                        T30 = [time_y1_T30 time_y2_T30 time_y3_T30 time_y4_T30 time_y5_T30 time_y6_T30 time_y7_T30 time_y8_T30];

                        plot(Filter, T30, '*-');

                        grid on
                        grid minor 

                          if (size(x,2) == 1)
                              title('RT60');
                           elseif (i == 1)      %outermost loop is for left channel, then right channel if stereo - IS THIS WRONG?
                              title('RT60 Left Channel');
                           else
                              title('RT60 Right Channel');
                          end 


else
    fprintf('Operation cancelled.\n');
    return
end

cd(current);

end
