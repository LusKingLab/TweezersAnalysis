function  [piezoPos2 qpdVolts2 xoffset yoffset] = AdjustEquilibriumPosition(piezoPos,qpdVolts,xoffset,yoffset)

% save offset and ask user if they want to use old value or make new value

if nargin == 2
    % find offset
    col = linspace(1,10,length(piezoPos{1,:}));
    scatter(piezoPos{1,:},qpdVolts{1,:},20,col,'filled')
    xlabel('Piezo position (nm)','fontsize',16);
    ylabel('QPD voltage (volts)','fontsize',16);
    legend('Dark blue = first points, yellow = last points, red = equilibrium position',...
        'Location','best')
    set(gca,'fontsize',14);
    title('Use cursor to select equilibrium point')
    [xoffset yoffset] = ginput(1);
end
 
piezoPos2 = {}; qpdVolts2 = {};
numData = length(piezoPos);
for i = 1:numData
    piezoPos2{i} = piezoPos{i} - xoffset;
    qpdVolts2{i} = qpdVolts{i} - yoffset;
end
    


