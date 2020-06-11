function [results] = StiffnessFromManualPull(x,qpd,dispslope,fc,dirpath,...
    dirpath_fig)
% Uses manual pull data to approximate nuclear stiffness.
% Jessica Williams, April 8, 2020

% Convert strain gauge arbitrary units to nanometers.
strain2nm = 1415;

% Derive trap stiffness and use to convert to force (from Mack, ...,
% Mochrie, RSI (2012).
R = 0.6e-6; % bead radius
eta = 1.45e-3; % sucrose solution viscosity
beta = 6*pi*eta*R; % friction coefficient of a sphere in an infinite liquid
k = fc*(2*pi*beta); % optical trap stiffness

ext = (x - qpd/dispslope*strain2nm)*1e-9; % in meters
F = k*qpd/dispslope*strain2nm*1e-9; % in Newtons
extension = -ext*1e9;    % nm
force = -F*1e12;         % pN

% Zero x-position and QPD signal.
extension = extension - extension(1);
force = force - force(1);

% Fit slope and save results as .txt file.
[a b rsqr resid] = OLS(extension,force);
fun = @(x) a*x+b;
[h p kstat] = lillietest(resid);

fid = fopen(fullfile(dirpath,'ManualPullStiffnessFit.txt'),'a');
results = [abs(a) rsqr h p];
fprintf(fid,'%f\t%f\t%d\t%f\n',abs(a),rsqr,h,p);

% Plot points with fitted slope.
figure(1); clf; hold on;
scatter(extension,force,20,'filled','k')
plot(extension,fun(extension),'r','linewidth',2);
xlabel('Extension (nm)','fontsize',25);
ylabel('Force (pN)','fontsize',25);
title(['Slope = ' num2str(abs(a)) ' pN/nm'],'fontsize',25);
set(gca,'fontsize',20,'box','off');
print('-dpng',fullfile(dirpath_fig,['ManualPullStiffnessFit']));

end
