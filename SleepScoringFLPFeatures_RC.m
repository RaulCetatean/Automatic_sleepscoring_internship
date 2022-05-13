% function lfpFeatures = GetLFPFeatures(DataHPC,DataPFC,samplingrate,TargetSampling, ...
%     scoredstates)
%% Synthesis of power band features for each band from the raw sleep dataset
% [DataHPC, TimeVectLFP, HeadingData] = load_open_ephys_data_faster('100_CH47_0.continuous');
% [DataPFC, ~, ~] = load_open_ephys_data_faster('100_CH53_0.continuous');
% % extracting the sampling frequency of the data
% samplingrate = HeadingData.header.sampleRate;  
% % Downsample the data to different sampling rates for fast processing
% TargetSampling = 1250;  % The goal sampling rate
% %TargetSampling = 500; %same as the accelerometer data
% timesDownSamp  = samplingrate / TargetSampling;   % Number of times of downsample the data
% lfpPFCDown = decimate(DataPFC,timesDownSamp,'FIR');
% lfpHPCDown = decimate(DataHPC,timesDownSamp,'FIR');
% timVect = linspace(0,numel(lfpPFCDown)/TargetSampling,numel(lfpPFCDown));

%% Get accelerometer data from .rec file
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
%% Using directly the LFP files to extract the features
% You get lfpPFC and lfpHPC after running the acc_lfp_uml_RC.m file
samplingrate = 1000; % All LFP files from HM are already downsampled to 1000
TargetSampling = 500;
timesDownSamp  = samplingrate / TargetSampling;   % Number of times of downsample the data
lfpPFCDown = decimate(lfpPFC,timesDownSamp,'FIR');
lfpHPCDown = decimate(lfpHPC,timesDownSamp,'FIR');
timVect = linspace(0,numel(lfpPFCDown)/TargetSampling,numel(lfpPFCDown));

%% Broadband slow wave or delta band

DeltaBandPFC = compute_delta_buzsakiMethod(lfpPFCDown,timVect,TargetSampling,'DeltaBandPFCMat');
DeltaBandHPC = compute_delta_buzsakiMethod(lfpHPCDown,timVect,TargetSampling,'DeltaBandHPCMat');
%% Narrowband Theta wave

ThetaBandPFC = compute_theta_buzsakiMethod(lfpPFCDown,timVect,TargetSampling,'ThetaBandPFCMat');
ThetaBandHPC = compute_theta_buzsakiMethod(lfpHPCDown,timVect,TargetSampling,'ThetaBandHPCMat');
%% beta wave

BetaBandPFC = compute_beta_buzsakiMethod(lfpPFCDown,timVect,TargetSampling,'BetaBandPFCMat');
BetaBandHPC = compute_beta_buzsakiMethod(lfpHPCDown,timVect,TargetSampling,'BetaBandHPCMat');
%% Gamma Band

GammaBandPFC = compute_gamma_buzsakiMethod(lfpPFCDown,timVect,TargetSampling,'GammaBandPFCMat');
GammaBandHPC = compute_gamma_buzsakiMethod(lfpHPCDown,timVect,TargetSampling,'GammaBandHPCMat');
%% EMGlike Signal
% samplingFrequencyEMG = 5;
% smoothWindowEMG = 10;
% 
% EMGFromLFP = compute_emg_buzsakiMethod(samplingFrequencyEMG, TargetSampling, lfpPFCDown, lfpHPCDown, smoothWindowEMG,'EMGLikeSignalMat');
% 
% prEMGtime = DeltaBandPFC.timestamps<EMGFromLFP.timestamps(1) | DeltaBandPFC.timestamps>EMGFromLFP.timestamps(end);
% DeltaBandPFC.data(prEMGtime) = []; 
% DeltaBandHPC.data(prEMGtime) = [];
% ThetaBandPFC.data(prEMGtime) = [];
% ThetaBandHPC.data(prEMGtime) = []; 
% GammaBandPFC.data(prEMGtime) = [];
% GammaBandHPC.data(prEMGtime) = [];
% DeltaBandPFC.timestamps(prEMGtime) = [];
% 
% %interpolate to FFT time points;
% EMG = interp1(EMGFromLFP.timestamps,EMGFromLFP.smoothed,DeltaBandPFC.timestamps,'nearest');
% 
% %Min/Max Normalize
% EMG = bz_NormToRange(EMG,[0 1]);
%% Accelerometer data
% They smoothed the data and interpolated it before normalizing for the EMG
% I need to understand why it saves it as just as DeltaBand and not
% DeltaBandPFC , meeg appears again to have only NaN values
interp_meeg = interp1(meeg_time, sm_meeg, DeltaBandPFC.timestamps, 'nearest');
meeg = bz_NormToRange(interp_meeg, [0 1]);
%% Combining and saving the feature matrix
matfilename = 'LFPBuzFeatures4_long_g';
%lfpFeatures = zeros(length(EMG),5);
lfpFeatures = zeros(length(meeg),5);
lfpFeatures(:,1) = DeltaBandPFC.data;
%lfpFeatures(:,2) = DeltaBandHPC.data;
%lfpFeatures(:,3) = ThetaBandPFC.data;
lfpFeatures(:,2) = ThetaBandHPC.data;
lfpFeatures(:,3) = BetaBandPFC.data;
%lfpFeatures(:,6) = BetaBandHPC.data;
lfpFeatures(:,4) = GammaBandHPC.data;
%lfpFeatures(:,5) = EMG;
lfpFeatures(:,5) = meeg;

save(matfilename,'lfpFeatures')
%% Plotting the features for further analysis
[status, msg, msgID] = mkdir('FeaturePlots');
cd FeaturePlots
%FeaturePlots(DeltaBandPFC,ThetaBandPFC,BetaBandPFC,EMG,'PFC')
%FeaturePlots(DeltaBandHPC,ThetaBandHPC,BetaBandHPC,EMG,'HPC')

%FeaturePlots(DeltaBandPFC,ThetaBandPFC,BetaBandPFC,EMG,'PFC')
%FeaturePlots(DeltaBandHPC,ThetaBandHPC,BetaBandHPC,EMG,'HPC')
FeaturePlots(DeltaBandPFC,ThetaBandPFC,BetaBandPFC,meeg,'PFC')
FeaturePlots(DeltaBandHPC,ThetaBandHPC,BetaBandHPC,meeg,'HPC')


cd ../
%% Downsampling the scored states to match with the features
% I don't think I need this part

States = load('2019-05-21_14-56-02_Post-trial5-states.mat');
%downsampledStates = downsample(States.states,8);
downsampledStates = States.states(1:10837);
save states.mat downsampledStates