function [] = PlotPiezoMovement(adjustPos);
% Plot piezo stage x movement

for i = 1:size(piezoPos,2)
    x = piezoPos{i};
    t = 0:length(x)-1;
    plot(t,x)
    [x1 y1] = ginput(1);
    
    hold on
    f = 1/t(end);
    a = -50*sin(2*pi*f*t) + y1;
    plot(t,a,'Color','k','LineWidth',2)
    [x2 y2] = ginput(1);
    
    hold off
    pause
end

end

