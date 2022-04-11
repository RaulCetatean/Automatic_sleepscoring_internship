EMG = EMGFromLFP.Norm;
%EMG = EMGFromLFP.data;

numpeaks = 1;
numbins = 12;
if sum(isnan(EMG))>0
   error('EMG seems to have NaN values...') 
end

while numpeaks ~=2 
    [EMGhist,EMGhistbins]= hist(EMG,numbins);

    [PKS,LOCS] = findpeaks([0 EMGhist],'NPeaks',2);
    LOCS = sort(LOCS)-1;
    numbins = numbins+1;
    numpeaks = length(LOCS);
    
    if numpeaks ==100
        display('Something is wrong with your EMG')
        return
    end
end

EMGdiptest = bz_hartigansdiptest(EMG);

betweenpeaks = EMGhistbins(LOCS(1):LOCS(2));
[dip,diploc] = findpeaks(-EMGhist(LOCS(1):LOCS(2)),'NPeaks',1,'SortStr','descend');

EMGthresh = betweenpeaks(diploc);
%% Now plot the EMG-like signal as from the code of Buzsaki lab

histogram(EMG, numbins)
xlabel('EMG')
title('Step 2: EMG for Muscle Tone')
hold on;
xline(EMGthresh,'r','LineWidth', 2) 

%tiledlayout(3, 2)
%nexttile([1 2])
plot(EMGFromLFP.timestamps, EMGFromLFP.Norm)
title('Normalized EMG data')
xlabel('timestamps')
ylabel('EMG signal')
hold on;
yline(EMGthresh,'r','LineWidth', 2)

% nexttile([1 2])
% plot(EMGFromLFP.timestamps,  EMGFromLFP.data)
% title('EMG data')
% xlabel('timestamps')
% ylabel('EMG signal')
% hold on;
% yline(EMGthresh,'r','LineWidth', 2)
% 
% nexttile([1 2])
% plot(EMGFromLFP.timestamps, EMGFromLFP.smoothed)
% title('EMG smoothed data')
% xlabel('timestamps')
% ylabel('EMG signal')
% hold on;
% yline(EMGthresh,'r','LineWidth', 2)

%% Try to do the same with the acccelerometer data 

numpeaks = 1;
numbins = 12;
if sum(isnan(meeg))>0
   error('meeg seems to have NaN values...') 
end

while numpeaks ~=2
    [meeghist, meeghistbins]= hist(meeg,numbins);

    [PKS,LOCS] = findpeaks([0 meeghist],'NPeaks',2);
    LOCS = sort(LOCS)-1;
    numbins = numbins+1;
    numpeaks = length(LOCS);
    
    if numpeaks ==100
        display('Something is wrong with your meeg')
        return
    end
end

meegdiptest = bz_hartigansdiptest(meeg);
betweenpeaks = meeghistbins(LOCS(1):LOCS(2));
[dip,diploc] = findpeaks(-meeghist(LOCS(1):LOCS(2)),'NPeaks',1,'SortStr','descend');

meegthresh = betweenpeaks(diploc);

m = mean(meeg);
s = std(meeg);
x = [m-s m m+s EMGthresh];

histogram(meeg, numbins)
xlabel('meeg')
title('Accelerometer data')
hold on;
xline(meegthresh, 'r','LineWidth', 2, 'DisplayName', 'meeg threshold') 
hold on;
xline(m-s,'Color','#D95319','LineWidth', 2,'DisplayName','mean-sd')
hold on;
xline(m,'k','LineWidth', 2,'DisplayName','mean')
hold on;
xline(m+s,'Color','#D95319','LineWidth', 2,'DisplayName','mean+sd')
legend('show');

%% The first graph should be almost done
% accelerometer raw data with the meeg thresh

%% Now plot the difference