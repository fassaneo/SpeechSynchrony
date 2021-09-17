function [f,pwr]=powerSpectr(sg,fs)

sg=sg-mean(sg);
L=length(sg);
NFFT = 2^nextpow2(2*L); % Next power of 2 from length of y
Y = fft(sg,NFFT)/L;
f = fs/2*linspace(0,1,NFFT/2+1);
%%% Frequencies below 10 Hz
f=f(f<10);
Y=Y(1:size(f,2));
pwr= abs(Y).^2;

df=f(3)-f(2);
n_average=round(0.2/df);
coeff= ones(1, n_average)/n_average;
pwr= filter(coeff, 1, pwr);
pwr=pwr/max(pwr);
end
