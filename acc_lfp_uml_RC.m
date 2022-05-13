tic
clear all; close all; clc
% selecting the .rec file first 
[file,path]=uigetfile('*.rec','Select the .rec file to be analyzed');
FileName = file(1:end-4);
%TargetFs = 1000;
%Our target now is 500
TargetFs = 500;
LFPFolder = [FileName, '.LFP'];
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

sm_meeg = smooth(meeg);

%% choose the lfp channel to analyze 
% channelsToAnalyze = [17 1;9 1]; % please put the tetrode number first then electrode/channel number
cd(path)
cd(LFPFolder)
prompt = {'Enter tetrode number:','Enter channel number:'};
dlgtitle = 'Channels to analyze';
dims = [1 35];
channelsToAnalyze = inputdlg(prompt,dlgtitle,dims);

tetrodeNum = str2num(channelsToAnalyze{1});
channelNum = str2num(channelsToAnalyze{2});
%%

for i = 1:numel(tetrodeNum)
    lfpToExtract = [LFPFolder,'_','nt',num2str(tetrodeNum(i)),'ch',num2str(channelNum(i)),'.dat'];
    dataTrodes = readTrodesExtractedDataFile(lfpToExtract);
    eeg_data{i} = double(dataTrodes.fields.data);
end

%% Define channel for prefrontal cortex and for hippocampus
lfpPFC = eeg_data{1};
lfpHPC = eeg_data{2};

%% Get timestamps for meeg
acc_time = readTrodesExtractedDataFile([FileName, '.timestamps.dat']);
acc_time = acc_time.fields.data;
meeg_time = linspace(0, numel(acc_time)/TargetFs, numel(meeg)); 

cd(path)
