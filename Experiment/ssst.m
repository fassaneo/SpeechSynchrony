function ssst(iR, SubjectName,fh, version)

%%%%%% Rate training STEP
rate_training_function(SubjectName,fh, version, iR);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Uploads the corresponding stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileOut=[SubjectName  '/output_' num2str(iR) '.wav'];
[listen_sound, Fs]=audioread(['WAVS/stimulus_' version '.wav']);
listen_sound=4*listen_sound;
tiempo_L=size(listen_sound,1)/Fs;
KbReleaseWait;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Main instructions for the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch version
    case  'ExpAcc'
        intro=['You will be listening to a train of syllables during 60 seconds. '...
            'Your goal is to WHISPER "Tah tah tah..." with EXACTLY the same rhythm as the syllables you are listening to. '...
            'You MUST be in synch with the external audio. '...
            'Do not change the audio volume and fix your eyes on the red dot. Press the spaceBar to continue.'];
    case 'ImpFix'
        intro=['You will be listening to a train of syllables during 60 seconds. Stay really focused on the audio, '...
            'you will have to identify some syllables after the presentation. '...
            'To increase the difficulty of the task you have to WHISPER "Tah tah tah..." during the WHOLE presentation. '...
            'Do not change the audio volume and fix your eyes on the red dot. Press the spaceBar to continue.'];
end
fh=instruction(fh, intro, ' ');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Main task
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(fh)
%%%% SET THE FIXATION CROSS
h=plot(1,2,'r.','MarkerSize',100);
axis(gca,'off');
drawnow;
%%%%%

% Parform low-level initialization of the sound driver:
InitializePsychSound(1);
% Provide some debug output:
PsychPortAudio('Verbosity', 10);
% Open the default audio device [], with mode 2 (== Only audio capture),
% and a required latencyclass of 2 == low-latency mode, as well as
% a Fsuency of Fs Hz and 2 sound channels for stereo capture.
% This returns a handle to the audio device:
painput = PsychPortAudio('Open', [], 2, 0, Fs, 1);
% Preallocate an internal audio recording  buffer with a capacity of :
PsychPortAudio('GetAudioData', painput, tiempo_L);

% Open default audio device [] for playback (mode 1), low latency (2), Fs Hz,
% stereo output
paoutput = PsychPortAudio('Open', [], 1, 0, Fs, 1);
PsychPortAudio('FillBuffer', paoutput, listen_sound');
% Start audio capture
painputstart = PsychPortAudio('Start', painput, 0, 0, 1);
% Start the playback engine
playbackstart = PsychPortAudio('Start', paoutput, 0, 0, 1);
delay=playbackstart-painputstart;
WaitSecs(tiempo_L-delay-0.01);

delete(h);
drawnow;

[audiodata, ~, ~] = PsychPortAudio('GetAudioData', painput);
PsychPortAudio('Stop', painput, 1);
PsychPortAudio('Stop', paoutput, 1);
PsychPortAudio('Close');
audiowrite(fileOut,audiodata,Fs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clf

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Two atlternative forced choice
%%% Only for the implicit Version
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(version, 'ImpFix')
    
    %%%%% Instructions
    text=['STOP WHISPERING!! You finished the syllable presentation. '...
        'Lets see if you can identify them. '...
        'Press the spaceBar to read the instructions.'];
    fh=instruction(fh, text, ' ');
    
    text=['Do not whisper during the testing phase. In each trial you should answer if you heard a syllable '...
        'by pressing Y for yes N for no. '...
        ' Good luck and press the spaceBar to begin.'];
    fh=instruction(fh, text, ' ');
    
    
    syllables={'PAH';  'FEE'; 'KOH' ; 'DOO'};
    [syllables, ~]=Shuffle(syllables);
    for iS=1:4
        flagA=0;
        while flagA==0
            intro1=sprintf(['\nDid you hear the syllable ' syllables{iS} ' ?\n\n\nPress Y for yes N for no. ']);
            htext_ca  = uicontrol('Style','text','FontName','Courier', 'String',intro1,'Units','normalized', ...
                'BackgroundColor','w','ForegroundColor',[0. 0. 0.],'Position',[0.1, 0.05, 0.8, 0.9],'FontSize',32,'HorizontalAlignment', 'left');
            uiwait(fh);
            ch = get(fh, 'Userdata');
            delete(htext_ca);
            drawnow;
            %%% 110=N and 121=Y
            if ch==121 || ch==110
                flagA=1;
            end
        end
        WaitSecs(0.5);
    end
end
end



