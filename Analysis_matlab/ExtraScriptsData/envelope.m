function output=envelope(wavName, fs_new)


[signal, Fs]=audioread(wavName);
signal=signal(:,1);
signal=signal-mean(signal);

hi=hilbert(signal);
output=abs(hi);

%%% Smooths and shows the envelope with the original signal
n_average=0.01*Fs;
coeff= ones(1, n_average)/n_average;
output= filtfilt(coeff, 1, output);
output=resample(output, fs_new,Fs);

output=output-mean(output);

end