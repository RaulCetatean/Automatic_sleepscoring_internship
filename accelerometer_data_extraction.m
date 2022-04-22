tic
clear all; close all; clc
% selecting the .rec file first 
[file,path]=uigetfile('*.rec','Select the .rec file to be analyzed');
FileName = file(1:end-4);
TargetFs = 500;

AnalogFolder = [FileName, '.analog'];
cd(AnalogFolder)
    
accel_x = readTrodesExtractedDataFile([FileName, '.analog_AccelX.dat']);
OriginalFs = accel_x.clockrate;
NdownSamp = OriginalFs / TargetFs;
ag_x = accel_x.fields.data;
g_x = decimate(double(ag_x),NdownSamp,'FIR');
accel_y = readTrodesExtractedDataFile([FileName, '.analog_AccelY.dat']);
ag_y = accel_y.fields.data;
g_y = decimate(double(ag_y),NdownSamp,'FIR');
accel_z = readTrodesExtractedDataFile([FileName, '.analog_AccelZ.dat']);
ag_z = accel_z.fields.data;
g_z = decimate(double(ag_z),NdownSamp,'FIR');
movement_data = [g_x'; g_y'; g_z'];

meeg = abs(zscore(movement_data')');
meeg = sum(meeg, 1);

%% Plot meeg signal and smoothed meeg signal
% the image was saved as 'raw_and_smoothed_meeg_signal.m

sm_meeg = smooth(meeg);

sm_std = std(sm_meeg);
std = std(meeg);

tiledlayout(2,1)
nexttile
plot(diff(meeg))
title('meeg signal')
hold on;
xline(std,'k','LineWidth', 2,'DisplayName','Standard Deviation')

%nexttile
%plot(diff(smooth_meeg))

nexttile
plot(diff(sm_meeg))
title('smoothed meeg signal')
hold on;
xline(sm_std,'k','LineWidth', 2,'DisplayName','Standard Deviation')

%% This part was done to analyze if it is possible to use the LFP signal in order to get the EMG-like signal for automatic sleep scoring
% It didn't really worked as wished so it is not important anymore

% cd(path);
% cd(LFPFolder);

% prompt = {'Enter tetrode number:','Enter channel number:'};
% dlgtitle = 'Channels to analyze';
% dims = [1 35];
% channelsToAnalyze = inputdlg(prompt,dlgtitle,dims);

% tetrodeNum = str2num(channelsToAnalyze{1});
% channelNum = str2num(channelsToAnalyze{2});

% for i = 1:numel(tetrodeNum)
%     lfpToExtract = [LFPFolder,'_','nt',num2str(tetrodeNum(i)),'ch',num2str(channelNum(i)),'.dat'];
%     dataTrodes = readTrodesExtractedDataFile(lfpToExtract);
%     eeg_data{i} = double(dataTrodes.fields.data);
% end

% samplingFrequency = 5;
% smoothWindowEMG = 10;
% matfilename = 'EMGLikeSignalMat';
% sig1 = eeg_data{1};
% sig2 = eeg_data{2};

% maxfreqband = floor(max([500 TargetFs/2]));
% xcorr_freqband = [275 300 maxfreqband-25 maxfreqband]; % Hz
% filteredSig1 = filtsig_in(sig1, TargetFs, xcorr_freqband);
% filteredSig2  = filtsig_in(sig2, TargetFs, xcorr_freqband);

% EMGFromLFP = compute_emg_buzsakiMethod(samplingFrequency, TargetFs, sig1, sig2, smoothWindowEMG, matfilename);

% cd(path);
% cd(AnalogFolder);

% acc_time = readTrodesExtractedDataFile([FileName, '.timestamps.dat']);

% cd(path);
% cd(LFPFolder);
% lfp_time = readTrodesExtractedDataFile([FileName, '.timestamps.dat']);
% plot(lfp_time.fields.data,filteredSig1, 'b', lfp_time.fields.data, filteredSig2, 'r')


%tiledlayout(3,1)

%nexttile
%plot(meeg)
%title('Plot Accelerometer data')

%pace(0,numel(data)/Fs,numel(data)00);

%tiledlayout(3,1)
%nexttile
%plot(lfp_time.fields.data,filteredSig1)
%title('Plot filteredSig1')

%nexttile
%plot(lfp_time.fields.data, filteredSig2)
%title('Plot filteredSig2')

%nexttile
%plot(lfp_time.fields.data,filteredSig1, 'b', lfp_time.fields.data, filteredSig2, 'r')
%title('Plot the signals together')

% tiledlayout(3,2)
% nexttile([1 2])
% plot(lfp_time.fields.data,filteredSig1, 'b', lfp_time.fields.data, filteredSig2, 'r')
% title('Plot the signals together')
% 
% nexttile([1 2])
% plot(lfp_time.fields.data,filteredSig1)
% title('Plot meeg Data')
% 
% nexttile
% histogram(filteredSig1, 100)	
% title('Histogram for filtered signal 1')
% 
% nexttile
% histogram(filteredSig2, 100)
% title('Histogram for filterd signal 2')
% 
% 
%N = normalize(meeg, 'range');

% tiledlayout(2,2)
% nexttile
% histogram(EMGFromLFP.Norm, 10)
% title('EMG-like signal, 10 bins')
% 
% nexttile
% histogram(EMGFromLFP.Norm, 100)
% title('EMG-like signal, 100 bins')
% nexttile
% histogram(N, 10)
% title('accelerometer data, 10 bins')
% 
% nexttile
% histogram(N, 100)
% title('accelerometer data, 100 bins')
