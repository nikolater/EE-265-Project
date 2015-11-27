includePaths

note1 = Tone_Note(e_NoteType.sixteenth, e_NoteTone.C5, 0.8);
note2 = Tone_Note(e_NoteType.sixteenth, e_NoteTone.B5, 0.8);
note3 = Tone_Note(e_NoteType.sixteenth, e_NoteTone.E5, 0.8);
note4 = Tone_Note(e_NoteType.sixteenth, e_NoteTone.C5, 0.8);
note5 = ADSR_Note(e_NoteType.sixteenth, e_NoteTone.B5, 0.8, 0.25, 0.25, 0.25, 0.25, 0.4); 
note6 = ADSR_Note(e_NoteType.sixteenth, e_NoteTone.E5, 0.8, 0.25, 0.3, 0.2, 0.25, 0.4);
note7 = ADSR_Note(e_NoteType.sixteenth, e_NoteTone.D5, 0.8, 0.25, 0.25, 0.25, 0.25, 0.4);
note8 = ADSR_Note(e_NoteType.sixteenth, e_NoteTone.F5, 0.8, 0.25, 0.25, 0.25, 0.25, 0.4);

seq = NoteSequence();
seq = seq.appendNote(note1);
seq = seq.appendNote(note2);
seq = seq.appendNote(note3);
seq = seq.appendNote(note4);
seq = seq.appendNote(note5);
seq = seq.appendNote(note6);
seq = seq.appendNote(note7);
seq = seq.appendNote(note8);

seq = seq.setTempo(100);
seq = seq.setSampleRate(44100);

wav = seq.synthesize();
stem(wav)