addpath('synthesizer\container');
addpath('synthesizer\note');
addpath('transcriber');

close all


sequence = NoteSequence();

note0 = Tone_Note(e_NoteType.quarter, e_NoteTone.C5, 0.5);
note1 = Tone_Note(e_NoteType.quarter, e_NoteTone.C4, 0.5);
note2 = Tone_Note(e_NoteType.quarter, e_NoteTone.C4, 0.8);
note3 = Tone_Note(e_NoteType.quarter, e_NoteTone.C5, 0.5);

sequence = sequence.appendNote(note0);
sequence = sequence.appendNote(note1);
sequence = sequence.appendNote(note2);
sequence = sequence.appendNote(note3);

sequence = sequence.setSampleRate(44100);
sequence = sequence.setTempo(100);

wav = sequence.synthesize();


t = Transcriber(wav, 44100, 1);
t = t.transcribe(100);
