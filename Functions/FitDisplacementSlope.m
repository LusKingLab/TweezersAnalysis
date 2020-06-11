function dispslope = FitDisplacementSlope(dirpath,dirpath_fig)


[filename dirpath] = uigetfile(fullfile(dirpath,'*.txt'),'Select a file');
[tmp fname] = fileparts(filename);
data = dlmread(fullfile(dirpath,filename));

x = data(:,5); % strain gauge position
% y = data(:,4); 
qpd = data(:,3); % qpd x deflection
qpdz = data(:,2); % qpd z deflection
qpdy = data(:,4); % qpd y deflection

% low pass filter strain gauge data
fNorm = .05;                                
[b,a] = butter(10, fNorm, 'low');                                                           
x = filtfilt(b, a, x);                                                           
qpd = filtfilt(b, a, qpd);
qpdz = filtfilt(b, a, qpdz);
qpdy = filtfilt(b, a, qpdy);

time = 0:length(x)-1;

% plot qpd x deflection vs. strain gauge position.
figure(1); clf; hold on
subplot(3,1,1)
col = linspace(1,10,length(x));
scatter(x,qpd,10,col)
legend('Dark blue = first points, yellow = last points','Location','best')
xlabel('Strain gauge position (a.u.)')
ylabel('QPD voltage - X (volts)')

subplot(3,1,2)
scatter(x,qpdz,10,col)
xlabel('Strain gauge position (a.u.)')
ylabel('QPD voltage - Z (volts)')

subplot(3,1,3)
scatter(x,qpdy,10,col)
xlabel('Strain gauge position (a.u.)')
ylabel('QPD voltage - Y (volts)')
print('-dpng',fullfile(dirpath_fig,strcat(fname,'_QPDvsStrainGauge.png')));
hold off

figure(2); clf; hold on
col = linspace(1,10,length(x));
scatter(x,qpd,10,col)
legend('Dark blue = first points, yellow = last points','Location','best')
title('Use cursor to pick two points of QPD deflection slope')
xlabel('Strain gauge position (a.u.)')
ylabel('QPD voltage - X (volts)')

[x2 y2] = ginput(2);

range = find(x > min(x2) & x < max(x2)); 

x = x(range);
qpd = qpd(range);

f = fittype('a*x+b');
[c gof] = fit(x,qpd,f,'startpoint',[-1 0]);

plot(x,c(x),'r','LineWidth',2);
title(['Displacement Slope = ' num2str(abs(c.a))]);
xlabel('Strain gauge position (a.u.)');
ylabel('QPD voltage (volts)');
print('-dpng',fullfile(dirpath_fig,strcat(fname,'_Fit.png')));

dispslope = abs(c.a);