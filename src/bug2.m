addpath('synthesizer\container');
addpath('synthesizer\note');
addpath('transcriber');

close all


sequence = NoteSequence();

note0 = Tone_Note(e_NoteType.quarter, e_NoteTone.C5, 0.4);
a = rand(1);
d = rand(1);
s = rand(1);
r = rand(1);
top = rand(1);
st = top*rand(1)
note1 = ADSR_Note(e_NoteType.half, e_NoteTone.C4, 0.8,...
                            a, d, s, r, 0.04);
note3 = Tone_Note(e_NoteType.quarter, e_NoteTone.C5, 0.4);

sequence = sequence.appendNote(note0);
sequence = sequence.appendNote(note1);
sequence = sequence.appendNote(note3);
tremolo = TremoloEffect(800, 1);
sequence = sequence.addEffect(tremolo)

sequence = sequence.setSampleRate(44100);
sequence = sequence.setTempo(100);

wav = sequence.synthesize();


t = Transcriber(wav, 44100, 1);
t = t.transcribe(100);
