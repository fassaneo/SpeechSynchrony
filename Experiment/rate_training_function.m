function rate_training_function(subject, fh,version, iR)

tiempo=10;

%%%%%%%%%%%%
%%%%% Training the rythm
%%%%%%%%%%%%%

name_output=[subject '/train' num2str(iR) '.wav']
[listen_sound, Fs]=audioread(['WAVS/example_' version '.wav']);
listen_sound=listen_sound';

%%%%% Instructions
text=['Now we will show you how to whisper the syllable tah continuously. First, you will hear a string of sounds. Just pay attention to it.'...
    ' Press the SpaceBar to start.'];
fh=instruction(fh, text, ' ');

%%%%% Play the example
optext=sprintf('Do not whisper, just pay attention.');
figure(fh)
htext_ca  = uicontrol('Style','text','FontName','Courier', 'String',optext,'Units','normalized', ...
    'BackgroundColor','w','ForegroundColor',[0. 0. 0.],'Position',[0.1, 0.6, 0.8, 0.3],'FontSize',32,'HorizontalAlignment', 'center');
drawnow;
WaitSecs(1);

% Perform low-level initialization of the sound driver:
InitializePsychSound(1);
% Provide some debug output:
PsychPortAudio('Verbosity', 10);
% Open the default audio device [], with mode 2 (== Only audio capture),
% and a required latencyclass of 2 == low-latency mode, as well as
% a frequency of Fs Hz and 2 sound channels for stereo capture.
% This returns a handle to the audio device:
% Open default audio device [] for playback (mode 1), low latency (2), Fs Hz,
% stereo output
paoutput = PsychPortAudio('Open', [], 1, 2, Fs, 1);
PsychPortAudio('FillBuffer', paoutput, listen_sound);
PsychPortAudio('Start', paoutput, 0, 0, 1);
WaitSecs(tiempo);
PsychPortAudio('Stop', paoutput, 1);
PsychPortAudio('Close');

delete(htext_ca);
drawnow;
%%%%%


%%%%% The subject whispers tah with the same rate as the one of the example
text=['OK. Now you will press the SpaceBar and right after start whispering "Tah Tah Tah..." with the same rhythm of the previous audio.'...
    ' Remember to WHISPER, do not speak loudly'];
fh=instruction(fh, text, ' ');

figure(fh)
optext=sprintf('Recording.\nKeep whispering.')
htext_ca  = uicontrol('Style','text','FontName','Courier', 'String',optext,'Units','normalized', ...
    'BackgroundColor','w','ForegroundColor',[0. 0. 0.],'Position',[0.1, 0.6, 0.8, 0.3],'FontSize',32,'HorizontalAlignment', 'center');
drawnow;
% Perform low-level initialization of the sound driver:
InitializePsychSound(1);
% Provide some debug output:
PsychPortAudio('Verbosity', 10);
% Open the default audio device [], with mode 2 (== Only audio capture),
% and a required latencyclass of 2 == low-latency mode, as well as
% a Fsuency of Fs Hz and 2 sound channels for stereo capture.
% This returns a handle to the audio device:
painput = PsychPortAudio('Open', [], 2, 0, Fs, 1);
% Preallocate an internal audio recording  buffer with a capacity of :
PsychPortAudio('GetAudioData', painput, tiempo);
% Start audio capture
PsychPortAudio('Start', painput, 0, 0, 1);
uiwait(fh, tiempo-0.1);
[audiodata, offset, overrun] = PsychPortAudio('GetAudioData', painput);
PsychPortAudio('Stop', painput, 1);
PsychPortAudio('Close');

%%%% Saves the training just in case...
audiowrite(name_output,audiodata, Fs);
delete(htext_ca);
drawnow;
WaitSecs(1);

text=['Great! You already know how to pronounce the syllables. Lets move to the next task! '...
    ' Press the SpaceBar to continue.'];
fh=instruction(fh, text, ' ');

end


