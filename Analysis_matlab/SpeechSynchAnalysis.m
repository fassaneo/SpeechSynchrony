%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Speech Synchrony Analysis %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Analysis for the data obtained with the Speech synchrony Test as decribed in Lizcano et al. 2022.
%%% The script performs the following steps:
%%% (1) Extracts the envelope of the produced speech signal and filters it around the stimulus syllabic rate.
%%% (2) Computes the plv between the produced and perceived filtered envelopes in windows of 5 second length with an overlap of 2 seconds.
%%% (3) Averages the plvs within each audio file (i.e. run1 and run2)
%%% (4) Controls for consistency between runs
%%% (5) Gives the probability of the participant of being a high or a low
%%% synchronizer.
%%% M. Florencia Assaneo 2021 fassaneo@inb.unam.mx

clearvars
close all

subject_code='example';               % Name of the audio file with the recorded speech
Test_Version='ImpFix';                % Version of the test used ImpFix for the Implicit Fixed or ExpAcc for the Explicit Accelerated

addpath('ExtraScriptsData/')
%%% Loads the envelope of the stimulus, its sampling frequency,
%%% and the frequency band at which it was filteres. The PLV will be estimated in this band.
load(['AudioStim/envelope_stimulus_' Test_Version '.mat']);
envelope_heard_filt=envelope_filt;  % Envelope of the perceived signal filtered around the syllabic rate
clear envelope envelope_filt;

figure('name', 'General obverview of the data')
for iRun=1:2
    
    file_name=[subject_code '_run' num2str(iRun) '.wav'];
    
    %%% STEP 1: Loads, demean and takes the envelope of the spoken syllables
    [signal, Fs]=audioread(file_name);
    signal=signal(:,1);
    signal=signal-mean(signal);
    envelope_speech=envelope(file_name, fs_new);
    
    %%% Estimates the spectrum of the envelope for visualization purposes.
    [f,pwr]=powerSpectr(envelope_speech,fs_new);
    
    %%% STEP 2 & 3: Computes the plv between the produced and perceived filtered envelopes
    envelope_speech_filt=bandpass(envelope_speech,freqFilt,fs_new);
    [time, PLV]=PLVevol(envelope_speech_filt,envelope_heard_filt,5,2,fs_new);
    
    plvs(iRun)=mean(PLV(1:end));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Visualization of the data %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Time Evolution of the sychrony within each run
    subplot(2,3,(iRun-1)*3+3)
    plot(time, PLV, '.-');
    ylim([0 1])
    ylabel('Speech synchrony (PLV)')
    xlabel('Time (Sec)')
    title(['Mean PLV: ' num2str(plvs(iRun),'%.2f')], 'FontSize', 12);
    
    %%% Spectral content of the envelope of the produced speech, the peak
    %%% should be above 2 Hz
    subplot(2,3,(iRun-1)*3+2)
    plot(f, pwr);
    ylabel('Power')
    xlabel('Frequency (Hz)')
    title(['Run ' num2str(iRun) ': Spectrum of the produced envelope'], 'FontSize', 12)
    
    %%% Acoustic signal of the produced speech with the envelope
    %%% overimposed in red
    subplot(2,3,(iRun-1)*3+1)
    hold on
    time=(1:length(signal))./Fs;
    plot(time, signal, 'k');
    time=(1:length(envelope_speech))./fs_new;
    plot(time, envelope_speech, 'r', 'LineWidth',2);
    xlim([10 15])
    hold off
    title(['Run ' num2str(iRun) ': Speech signal plus envelope'], 'FontSize', 12)
    
end
windowSize=get(0, 'ScreenSize');
set(gcf, 'Position', windowSize)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Exclusion criteria %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flagExclude=0;

%%% Both PLVs should be within the normal range: above 0.1 and below 0.9
if find(plvs>0.9)
    errordlg(['The plv of Run ' num2str(find(plvs>0.9)) ' is too high.'],'Error')
    flagExclude=1;
end
if find(plvs<0.1)
    errordlg(['The plv of Run ' num2str(find(plvs>0.9)) ' is too low.'],'Error')
    flagExclude=1;
end

%%% STEP 4: Both PLVs should be congruent
load('LinearRegressions.mat')
eval(['fittedPLVs=regression_' Test_Version]);
PLV_bounds = predint(fittedPLVs,plvs(1),0.95,'observation','off');
adjusted_PLV= fittedPLVs.p1*plvs(1)+ fittedPLVs.p2;
[~, side]=min(abs(PLV_bounds-plvs(2)));
if abs(plvs(2)-adjusted_PLV)>abs(adjusted_PLV-PLV_bounds(side))
    errordlg('The plvs across Runs are not congruent!','Error')
    flagExclude=1;
end

%%% STEP 5: If non of the exclusion criteria is reached the probability of
%%% being a High synchronizer (1- prob of Low) is computed.
if flagExclude==0
    load('Gaussian_Mixture_Fits.mat')
    eval(['gm=gm_' Test_Version]);

    speech_synch=mean(plvs);
    sgm=squeeze(gm.Sigma);
    [mu,indx]=sort(gm.mu);
    sgm=sqrt(sgm(indx));
    amps=gm.ComponentProportion;
    amps=amps(indx);
    lows=amps(1)*normpdf(speech_synch,mu(1),sgm(1));
    highs=amps(2)*normpdf(speech_synch,mu(2),sgm(2));

    probHigh=highs./(highs+lows);
    
    message=['The participants degree of synchrony is: ' num2str(speech_synch,'%.2f') ...
        ' and its probability of being a HIGH synchronizer is ' num2str(probHigh,'%.2f')];
    msgbox(message,'Speech Synchrony Test Outcome')
end



