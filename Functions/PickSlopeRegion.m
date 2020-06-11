function [x,qpd] = PickSlopeRegion(piezoPos,qpdVolts,dirpath_fig)
% Pick region to approximate slope.
% Jessica Williams, April 8, 2020

x = piezoPos{1,:}; % piezo x-position 
qpd = qpdVolts{1,:}; % qpd x deflection

% Plot qpd x deflection vs. piezo x-position.
figure(1); clf; hold on
col = linspace(1,10,length(x));
scatter(x,qpd,20,col,'filled')
legend('Dark blue = first points, yellow = last points','Location','best')
title('Use cursor to pick left and right points of slope')
xlabel('Piezo position (nm)')
ylabel('QPD voltage - X (volts)')
set(gca,'fontsize',14,'box','off')

[x2 y2] = ginput(2);

range = find(x > min(x2) & x < max(x2)); 

% New x and qpd values within range.
x = x(range);
qpd = qpd(range);

% Plot new qpd x deflection vs. piezo x-position.
figure(2); clf; hold on
col = linspace(1,10,length(x));
scatter(x,qpd,20,col,'filled')
legend('Dark blue = first points, yellow = last points','Location','best')
xlabel('Piezo position (nm)')
ylabel('QPD voltage - X (volts)')
set(gca,'fontsize',14,'box','off')
print('-dpng',fullfile(dirpath_fig,['ManualPullSlopeRegion']));

end