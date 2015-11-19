note1 = Note( e_SOURCE.TONE, e_EFFECT.NONE, e_TYPE.whole, e_TONE.C5, []);
note2 = Note( e_SOURCE.ADSR, e_EFFECT.ECHO, e_TYPE.quarter, e_TONE.C5, []);
note3 = Note( e_SOURCE.TONE, e_EFFECT.TREMOLO, e_TYPE.whole, e_TONE.C5, []);
note4 = Note( e_SOURCE.ADSR, e_EFFECT.NONE, e_TYPE.sixteenth, e_TONE.C5, []);
note5 = Note( e_SOURCE.TONE, e_EFFECT.NONE, e_TYPE.threeSixteenth, e_TONE.C5, []);
note6 = Note( e_SOURCE.ADSR, e_EFFECT.NONE, e_TYPE.half, e_TONE.C5, []);

seq = GUINoteSequence();
% test append
seq = seq.appendNote(note1);
seq = seq.appendNote(note2);
seq = seq.appendNote(note3);
seq = seq.appendNote(note4);
seq = seq.appendNote(note5);

% test remove
seq = seq.removeNote(5);
seq = seq.removeNote(4);
seq = seq.removeNote(1);
seq = seq.removeNote(2);
seq = seq.removeNote(1);

% test insert
seq = seq.appendNote(note2);
seq = seq.appendNote(note3);
seq = seq.insertNote(1, note1);
seq = seq.insertNote(4, note4);
seq = seq.insertNote(2, note5);
