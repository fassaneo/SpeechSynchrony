%%%%% Estimates the PLV evolution between sg1 and sg2 whete T is the time window to
%%%%% estimate each PLV and shift how much it is shifted in each iteration
%%%%% (time discretization) fs is the sampling rate for both signals

function [time, PLV]=PLVevol(sg1,sg2,T,shift,fs)

    sg1=hilbert(sg1);
    phi1=angle(sg1);
    
    sg2=hilbert(sg2);
    phi2=angle(sg2);
    
    tmp=min(length(phi1),length(phi2));
    phase_diff=phi1(1:tmp)-phi2(1:tmp);
    
    %%% Calculates the PLV
    nT=round(fs*T);
    nshift=round(fs*shift);
    n_ant=1;
    i=1;
    while (n_ant+nT)<length(phase_diff)+nT
        if (n_ant+nT)<length(phase_diff)
            PLV(i)=abs(sum(exp(1i*phase_diff(n_ant:n_ant+nT))))/nT;
            time(i)=0.5*(n_ant+n_ant+nT)./fs;
        else
            PLV(i)=abs(sum(exp(1i*phase_diff(n_ant:end))))./(length(phase_diff)-n_ant);
            time(i)=0.5*(length(phase_diff)+n_ant)./fs;
        end
        
        n_ant=n_ant+nshift;
        i=i+1;
    end
end