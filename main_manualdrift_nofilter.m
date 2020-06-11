%% (1) Optical tweezers analysis code
% Last update 20200309 - Jessica Williams

% Run this section first, then proceed through each section in order.
% Figures made in each section will be saved in separate 'Figures' folder.
% Final corrected, converted force vs. extension data (for each
% oscillation) will be saved to 'Fit.txt' file.

clear all;
close all;
clc;
dirpath = fileparts(pwd);

% Name of .mat file to save analysis data.
dataFileName = '20200304_nucleus_7_1';

% If you have already run this data set and done the 'point-picking', you
% can set 'doManualAdjust' to FALSE; otherwise leave as TRUE to do
% point-picking and proceed.
doManualAdjust = true;
% If 'false', proceed to section 4.

%% (2) Use 'manual pull' data to find equilibrium position.

% This section uses the 'manual pull' data--when the bead was manually
% attached to the nucleus, watching for deflection in the QPD--to set the
% equilibrium position/starting x-position for the oscillations. 

% (1) Select 'Manual_***_001.txt' file; if multiple files, pick one that
% clearly shows the transition between bead free in optical trap and bead
% beginning to be pushed out of trap by nucleus. At this transition point,
% the QPD signal will begin to drop linearly as the nucleus pushes the bead
% out of the trap. 
% (2) The QPD signal data is plotted as a scatter plot, with the first data
% plotted as dark blue and the last data plotted as yellow. This allows you
% to see where you stopped the piezo stage (the point at which you zeroed
% the piezo stage to start the first oscillation).
% (3) Use the cursor to select the point at which the bead attaches to the
% nucleus and begins to be pushed out of the optical trap and the piezo
% stage's final resting position.

% -------------------------------------------------------------------------

if doManualAdjust
    % Load and parse manual pulls.
    [piezoPos qpdVolts fname numData dirpath filename] = ...
        LoadParseData(dirpath);

    % Find equilibrium offset.
    [piezoPos2 qpdVolts2 xoffset yoffset] = ...
        AdjustEquilibriumPosition(piezoPos,qpdVolts);

    % Save data and figures.
    SaveData(piezoPos2,qpdVolts2,dirpath,filename,'Corrected');
    dlmwrite(fullfile(dirpath,'EquilibriumOffset.txt'),[xoffset yoffset]);
    hold on
    scatter(xoffset,yoffset,50,'MarkerFaceColor','r')
    dirpath_str = string(dirpath);
    dirpath_fig = char(plus(dirpath_str,'Figures/'));
    mkdir(dirpath_fig)
    print('-dpng',fullfile(dirpath_fig,...
        ['EquilibriumOffset']));
end

%% (3) Plot raw, uncorrected oscillation data.

% This section plots all of the raw, uncorrected oscillation tracings 
% together for comparison.

% (1) Select all oscillation files ('***_001.txt', '***_002.txt', etc.) to 
% plot together.

% -------------------------------------------------------------------------

if doManualAdjust
    % Load frequency data.
    [freq sampling_f freqName] = LoadFileIndex(dirpath);

    % Load oscillation data.
    [piezoPos qpdVolts fname numData dirpath filename] = ...
        LoadParseData(dirpath);
    [piezoPos2 qpdVolts2] = AdjustEquilibriumPosition(piezoPos,...
        qpdVolts,xoffset,yoffset);
    
    % Plot raw/uncorrected oscillations together.
    h = PlotRawData(piezoPos2,qpdVolts2,1);
    PlotLegend(filename,'southwest');
    title('Raw Oscillations Uncorrected')
    print('-dpng',fullfile(dirpath_fig,...
        ['Raw_Oscillations_Uncorrected_Comparison']));
end

%% (4) Manually correct oscillations for piezo stage drift.

% This section plots the oscillation data and asks you to manually do the 
% following: 
% (1) Use the cursor to select the range (left-most point and right-most 
% point) of oscillations to analyze from the piezo stage tracing, 
% (2) Use the cursor to select the span (left-most point and right-most 
% point) of each individual oscillation (note: oscillations faster than 0.5 
% Hz cannot be seen on the tracing, so just pick two point approximately 
% where they should have occurred),
% (3) Use the cursor to adjust the span of each oscillation to maximize 
% overlap of oscillation tracing. Hit 'Enter' when satisfied with overlap
% to move onto next oscillation.

% -------------------------------------------------------------------------

if doManualAdjust
    % Parse drift data.
    driftInfo = ParseDriftManual(dirpath,dirpath_fig);

    % Manually adjust drift in oscillations.
    adjustPos = AdjustDriftOscillations(piezoPos2,qpdVolts2,driftInfo,...
        filename,dirpath,dirpath_fig);
    save([dirpath dataFileName '.mat'])
end

% If you have already done the oscillation selection ('point-picking'), 
% 'doManualAdjust' should be set to FALSE, and it will simply load files.
if ~doManualAdjust
    [dataFileName dataFilePath] = uigetfile(fullfile(pwd,'*.mat'),...
        'Select a file','MultiSelect','off');
    load([dataFilePath dataFileName])
end

% Save data.
SaveData(adjustPos,qpdVolts2,dirpath,filename,'Corrected');

% Plot drift-corrected raw oscillations together.
h = PlotRawData(adjustPos,qpdVolts2,1);
PlotLegend(filename,'southwest');
title('Raw Oscillations Drift-Corrected')
saveIndex = FindNextFileIndex(dirpath,...
    'Raw_Oscillations_Drift-Corrected_','png');
print('-dpng',fullfile(dirpath_fig,['Raw_Oscillations_Drift-Corrected_' ...
    num2str(saveIndex)]));
close all

%% (Extra) Ignore drift.
% If no drift data is present, can ignore drift protocol.

% Adjust positions based on mean position.
adjustPos = IgnoreDrift(piezoPos2,qpdVolts2);
save([dirpath dataFileName '.mat'])

% Save data.
SaveData(adjustPos,qpdVolts2,dirpath,filename,'Corrected');

% Plot drift-ignored raw oscillations together.
h = PlotRawData(adjustPos,qpdVolts2,1);
PlotLegend(filename,'southwest');
title('Raw Oscillations Drift-Corrected')
saveIndex = FindNextFileIndex(dirpath,...
    'Raw_Oscillations_Drift-Corrected_','png');
print('-dpng',fullfile(dirpath_fig,['Raw_Oscillations_Drift-Corrected_' ...
    num2str(saveIndex)]));
close all

%% (5a) Calibration parameters for optical tweezers (part a): 
% displacement slope

% Run this section to find the calibration parameter - the displacement
% slope of the bead in the optical trap. Note: you only have to do this
% once per experimental set.

% Script will open up folder window.
% (1) Choose '***StuckBead.txt_BeadScan_001.txt' file.
% (2) Use cursor to pick two points on plot to fit displacement slope. 
% (3) Displacement slope will be fit and displayed on plot and saved in
% Workspace as 'dispslope'.
% (4) Run this script for each bead scan and take the mean to use in
% Section 3.

% -------------------------------------------------------------------------

% Manually find the displacement slope.
dispslope = FitDisplacementSlope(dirpath,dirpath_fig);

%% (5b) Calibration parameters for optical tweezers (part b)
% Power spectrum

% Run this section to find the calibration parameter - the power spectrum 
% of the free bead in the trap.

% Script will open up folder window.
% (1) Choose '***PowerSpectrum_001.txt' file.

% -------------------------------------------------------------------------

[psfile pspath] = uigetfile(fullfile(dirpath,'*.txt'),...
    'Select a power spectrum files','MultiSelect','on');
data = dlmread(fullfile(pspath,psfile));
sampling_f = 40000;
nblock = 100;
Lfit_start = 30;
Lfit_end = 10000;
[fc fcerror] = PowerSpectrumSingle(data,pspath,dirpath_fig,sampling_f,...
    nblock,Lfit_start,Lfit_end);

%% (5c) Calibration parameters for optical tweezers (part c)
% If multiple values for dispslope and/or fc exist, it is reasonable to do
% the following:

% (1) Take the mean of all dispslope values and reassign dispslope as mean.
% Note: use the same dispslope for all experiments from the same run/day.
dispslope = 12;

% (2) Use the largest value of fc and reassign fc. Note: must use
% individual fc values for each bead/nucleus pair.
fc = 2254;

%% (6) Convert oscillation data to physical units and plot.

% This section converts the oscillation data from QPD voltage to
% force-units (pN) and from strain gauge units to distance in nm. It then
% plots:
% (1) the corrected, converted oscillations together,
% (2) each individual oscillation with its slope (stiffness),
% (3) stiffness vs. oscillation frequency as scatter plot, and
% (4) stiffness vs. oscillation frequency in order of execution.

% -------------------------------------------------------------------------

% Convert strain gauge arbitrary units to nanometers.
strain2nm = 1415;

% Derive trap stiffness and use to convert to force (from Mack, ...,
% Mochrie, RSI (2012).
R = 0.6e-6; % bead radius
eta = 1.45e-3; % sucrose solution viscosity
beta = 6*pi*eta*R; % friction coefficient of a sphere in an infinite liquid
k = fc*(2*pi*beta); % optical trap stiffness
extension = cell(numData,1);
force = cell(numData,1);
for i = 1:numData
    ext = (adjustPos{i} - qpdVolts2{i}/dispslope*strain2nm)*1e-9; % in meters
    F = k*qpdVolts2{i}/dispslope*strain2nm*1e-9; % in Newtons
    extension{i} = -ext*1e9;    % nm
    force{i} = -F*1e12;         % pN
end

SaveData(extension,force,dirpath,filename,'FvsX_Filtered');

% Plot force vs extension all together
linewidth = 2;
h = PlotForceVsExtension(extension,force,linewidth);
PlotLegend(filename,'southwest');
saveIndex = FindNextFileIndex(dirpath,'FvsX_Oscillations_Comparison_',...
    'png');
print('-dpng',fullfile(dirpath_fig,['FvsX_Oscillations_Comparison_' ...
    num2str(saveIndex)]));
saveas(h,fullfile(dirpath_fig,['FvsX_Oscillations_Comparison_' ...
    num2str(saveIndex) '.fig']));
 
% Plot individual oscillation slopes.
fid = fopen(fullfile(dirpath,'Fit.txt'),'a');
results = [];
for i = 1:numData
    warning off;
    piezo = extension{i};
    qpd = force{i};
    A = max(piezo)-min(piezo);
    steps = round(length(qpd)/4);
    range = 1:length(qpd);
%     range = steps*2:steps*3;
    piezo = piezo(range);
    qpd = qpd(range);
    
    [a b rsqr resid] = OLS(piezo,qpd);
    fun = @(x) a*x+b;
    [h p kstat] = lillietest(resid);
    results = [results; freq(i) abs(a) A rsqr h p];
    
    figure(2); clf; hold on; box on;
    col = linspace(1,10,length(piezo));
    scatter(piezo,qpd,20,col) % Plot as scatter plot with changing colors.
%     plot(piezo,qpd,'k'); % Plot as black line plot.
    plot(piezo,fun(piezo),'r','linewidth',2);
    xlabel('Extension (nm)','fontsize',25);
    ylabel('Force (pN)','fontsize',25);
    title([num2str(freq(i)) ' Hz; slope = ' num2str(abs(a)) ' pN/nm'],...
        'fontsize',25);
    set(gca,'fontsize',20,'box','off');
    fname_u = strrep(fname{i},' ','_');
    print('-dpng',fullfile(dirpath_fig,['Fit_' fname_u]));
    fprintf(fid,'%s\t%f\t%f\t%f\t%d\t%f\n',fname_u,freq(i),abs(a),...
        rsqr,h,p);
end
fclose(fid);

% Plot stiffness vs. oscillation frequency as scatter plot.
figure(3); clf; hold on; box on;
colorSet = varycolor(length(freq));
for i = 1:length(freq)
    scatter(freq(i),results(i,2),120,colorSet(i,:),'filled');
end
xlabel('Frequency (Hz)','fontsize',25);
ylabel('Stiffness (pN/nm)','fontsize',25);
set(gca,'fontsize',20,'xscale','log');
print('-dpng',fullfile(dirpath_fig,'ScatterSlopeVsFrequency'));

% Plot stiffness vs. oscillation frequency in order of execution.
figure(4); clf; hold on; box on;
colorSet = varycolor(length(freq)-1);
for i = 1:length(freq)-1
    plot(freq(i:i+1),results(i:i+1,2),'color',colorSet(i,:),'linewidth',2);
end
xlabel('Frequency (Hz)','fontsize',25);
ylabel('Stiffness  (pN/nm)','fontsize',25);
title('Oscillations in order','fontsize',25);
legend('First = green')
set(gca,'fontsize',20,'xscale','log');
print('-dpng',fullfile(dirpath_fig,'SlopeVsFrequency_inOrder'));

%% (Extra) Derive stiffness from manual pull.
% Can use manual pull data to approximate stiffness (the point at which the
% bead comes into contact with the nucleus and begins to be pushed out of
% the trap).

% Load manual pull data.
[piezoPos,qpdVolts,fname,numData,dirpath,filename] = ...
    LoadParseData(dirpath);

% Pick region within manual pull to approximate slope.
[x,qpd] = PickSlopeRegion(piezoPos,qpdVolts,dirpath_fig);

% Fit points and find slope.
[results] = StiffnessFromManualPull(x,qpd,dispslope,fc,dirpath,...
    dirpath_fig);








