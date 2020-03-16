function sh2 = plotsphere( ele,ang,mode,sh2 )

%sh2 = plotsphere( ele,ang,mode,sh2)
%
%This function plots the figures showing the location of audio source
%relative to the user's head and facing direction, mainly used in
%getlocation.m
%
% The transparent sphere represents the space around the user's head.
% GREEN arrow points at the user's facing direction. 
% YELLOW spot represents the location of the audio source.
%
% ele = elevation angle of the audio source
%
% ang = azimuth angle of the audio source
%
% mode = 0 when the program is first called in getlocation.m, plot all
%          figures including transparent sphere, green cone and yellow dot
%      = 1 when this function is called again which only moves the location
%          of the yellow dot but not the other figures.
%
% sh2 = the figure representing the yellow dot, needed as input to be
%       deleted if this function is called after the first time, and is
%       returned as output in case this function is called another time.

if mode == 0
     [x,y,z]=sphere(128);
     sh1=surf(x,y,z);
     set(sh1,'EdgeAlpha',0);
     alpha(sh1,.2);
         
     hold on;
    
     t = [0.1,0];
     [y,z,x] = cylinder(t);
     sh3 = surf(x,y,z);
     my_colour = [20 173 23] ./ 255;
     set(sh3,'FaceColor',my_colour,'EdgeAlpha',0);
     alpha(sh3,0.8);
else
     hold on;
     delete(sh2);
end
     [x,y,z]=sphere(128);
     [xs,ys,zs] = sph2cart(deg2rad(ang),deg2rad(ele),1);
     sh2 = surf(0.05*x+xs,0.05*y+ys,0.05*z+zs);
     set(sh2,'FaceColor',[1 1 0],'EdgeAlpha',0);
     
     daspect([1 1 1]);
     rotate3d on;
     grid off;
     axis off;
     hold off;    

end