function equalize_noise(fh,sound_name)

[listen_sound, Fs]=audioread(sound_name);
listen_sound=4*listen_sound';

text=['Turn the volume to its middle range.'...
    ' Press the SpaceBar when you are done'];
fh=instruction(fh, text, ' ')


text=['When the audio begins, start whispering TAH and increse the volume until you stop hearing your own whisper.'...
    ' Press the SpaceBar to start.'];
fh=instruction(fh, text, ' ')


% Perform low-level initialization of the sound driver:
InitializePsychSound(1);
% Provide some debug output:
PsychPortAudio('Verbosity', 10);

% Open default audio device [] for playback (mode 1), low latency (2), Fs Hz,
% stereo output
paoutput = PsychPortAudio('Open', [], 1, 0, Fs, 1);
PsychPortAudio('FillBuffer', paoutput, listen_sound);

% Start the playback engine
playbackstart = PsychPortAudio('Start', paoutput, 0, 0, 1);
text='Press the SpaceBar when the volume is loud enough.';
fh=instruction(fh, text, ' ')
PsychPortAudio('Stop', paoutput, 1);
PsychPortAudio('Close');

end
