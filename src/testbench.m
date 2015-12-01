addpath('synthesizer\container');
addpath('synthesizer\note');
addpath('transcriber');

close all;

possibleType = [ 1/16, 1/8, 3/16, 1/4, 1/2, 1];
possibleAmplitude = linspace(0.2,1,9);


clear('t', 'wav', 'sequence');
% generate 10 random notes
sequence = NoteSequence();
for i = 1:10
    noteType(i) = possibleType(ceil(6 * rand(1))); %#ok<*SAGROW>
    noteTone(i) = 28 + round(23*rand(1));
    amplitude = possibleAmplitude(ceil(9*rand(1)));
    if(rand(1) > 0.5)
        newNote = ADSR_Note(noteType(i), noteTone(i), amplitude, rand(1), rand(1), rand(1), rand(1), amplitude*0.5);
        sequence = sequence.appendNote(newNote);
    else 
        newNote = Tone_Note(noteType(i), noteTone(i), amplitude);
        sequence = sequence.appendNote(newNote);
    end
end
sequence = sequence.setSampleRate(44100);
sequence = sequence.setTempo(100);
%tremolo_effect = TremoloEffect(500, 0.8);
%sequence = sequence.addEffect(tremolo_effect);
wav = sequence.synthesize();
%stem(wav)

t = Transcriber(wav, 44100, 1);
t = t.transcribe(100);

correctTones = 0;
correctType = 0;

upperBound = min([length(t.notes),length(noteTone)]);

for i = 1:upperBound
    if(t.notes{1,i} == noteTone(i))
        correctTones = correctTones + 1;
    end
    
    if(t.notes{2,i} == noteType(i))
        correctType = correctType + 1;
    end
end

soundsc(real(wav), 44100);




