function Synthesizer_GUI()
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Synthesize_GUI()
% Creates the GUI for user input.
%
% PARAMETERS: (void)
%
% RETURN:
%   Key callbacks corresponding to the user selection.
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
addpath('container');
addpath('note');
addpath('..\transcriber');
Fs=44100;
duration=1/4;
global sequence
sequence=NoteSequence();

key_symb={'C4' 'C4#' 'D4' 'D4#' 'E4' 'F4' 'F4#' 'G4' 'G4#' 'A4' 'A4#' ...
'B4' 'C5' 'C5#' 'D5' 'D5#' 'E5' 'F5' 'F5#' 'G5' 'G5#' 'A5' 'A5#' 'B5'};

note_type_symb = {'1/16' '1/8' '3/16' '1/4' '1/2' '1'};

hfig=figure('position',[0 0 1112 500],'name','Music Synthesizer',...
'NumberTitle', 'off');

initial_bpm = 150;
guidata(hfig,struct('hfig',hfig,'Fs',Fs,'key_symb',{key_symb},...
'note_type_duration',duration,'bpm',initial_bpm,'source',1,'effect',1,'wav',[]));
% the shorter name, wav, is used instead of notes_waveforms

for ii=1:24
  uicontrol( 'Parent', hfig, 'style','pushbutton','position', ...
  [100+(ii-1)*38 150 38 60],'string', key_symb(ii) , 'callback', ...
  @key_callback);
end

for ii=1:6
  uicontrol( 'Parent', hfig, 'style','pushbutton','position', ...
  [442+(ii-1)*38 210 38 60],'string', note_type_symb(ii) , 'callback', ...
  @note_type_callback);
end
uicontrol( 'Parent', hfig, 'style','text','position', ...
[500 270 100 40],'string', 'Note Type');

uicontrol( 'Parent', hfig, 'style','pushbutton','position', ...
[100 150-65 60 60],'string', 'End' , 'callback', ...
@end_callback) ;

uicontrol( 'Parent', hfig, 'style','popupmenu','position', ...
[200 400 80 40],'string', '150|120|90|60', 'callback', ...
@bpm_callback);
uicontrol( 'Parent', hfig, 'style','text','position', ...
[191 440 100 40],'string', 'Tempo (bpm)');

uicontrol( 'Parent', hfig, 'style','popupmenu','position', ...
[500 400 100 40],'string', 'Tone|ADSR Tone|ADSR Harmonic', 'callback', ...
@source_callback);
uicontrol( 'Parent', hfig, 'style','text','position', ...
[493 440 100 40],'string', 'Source');
 
uicontrol( 'Parent', hfig, 'style','popupmenu','position', ...
[900 400 80 40],'string', 'None|Tremolo|Echo|Reverb', 'callback', ...
@effect_callback);
uicontrol( 'Parent', hfig, 'style','text','position', ...
[890 440 100 40],'string', 'Effect');

end
 

 function key_callback(hObject,eventdata)
 data = guidata(hObject);
 str=char(get(hObject, 'String'));
 
 tremolo_effect = TremoloEffect(10, 0.8);
 no_effect = NoEffect();
 
 for ii=1:24
     switch strcmp(data.key_symb(ii),str);
         case 1
            noteTone(1)=ii+39;
     end
 end
 
 noteType(1)=data.note_type_duration;
 
 switch data.source;
     case 1
         newNote=Tone_Note(noteType(1), noteTone(1), 1);
     case 2
         newNote=ADSR_Note(noteType(1), noteTone(1), 1, 0.5,0.3,0.4,0.2,0.4);
     case 3
         newNote=ADSR_Harmonic_Note(noteType(1), noteTone(1), 1, 0.5, 0.3, 0.4, 0.2, 0.4);         
 end
 
 echo_effect = EchoEffect(0.2, 0.3, 0.2);
 reverb_effect = ReverbEffect(0.2, 0.3);
       
 global sequence
 sequence = sequence.appendNote(newNote);
 seqtemp = NoteSequence();
 seqtemp = seqtemp.setSampleRate(data.Fs);
 seqtemp = seqtemp.setTempo(data.bpm);
 seqtemp = seqtemp.appendNote(newNote);
 
 
 switch data.effect;
     case 1
         sequence = sequence.addEffect(no_effect);
     case 2
         seqtemp = seqtemp.addEffect(tremolo_effect);
         sequence = sequence.addEffect(tremolo_effect);
     case 3
         seqtemp = seqtemp.addEffect(echo_effect);
         sequence = sequence.addEffect(echo_effect);
     case 4
         seqtemp = seqtemp.addEffect(reverb_effect);
         sequence = sequence.addEffect(reverb_effect);
 end
 
 wav=real(seqtemp.synthesize());
 soundsc(wav, data.Fs);
 
 guidata(data.hfig,struct('hfig',data.hfig,'Fs',data.Fs, ...
 'key_symb',{data.key_symb},'note_type_duration',data.note_type_duration,...
 'bpm',data.bpm,'source',data.source,'effect',data.effect,'wav',data.wav));
end

function note_type_callback(hObject,eventdata)
 data = guidata(hObject);
 str=get(hObject, 'String');
 
 switch str{1};
     case '1/16'
         data.note_type_duration=1/16;
     case '1/8'
         data.note_type_duration=1/8;
     case '3/16'
         data.note_type_duration=3/16;
     case '1/4'
         data.note_type_duration=1/4;
     case '1/2'
         data.note_type_duration=1/2;
     case '1'
         data.note_type_duration=1;
 end
 
 guidata(data.hfig,struct('hfig',data.hfig,'Fs',data.Fs, ...
 'key_symb',{data.key_symb},'note_type_duration',data.note_type_duration,...
 'bpm',data.bpm,'source',data.source,'effect',data.effect,'wav',data.wav));
end

function end_callback(hObject,eventdata)
 data = guidata(hObject);
 
 global sequence
 sequence = sequence.setSampleRate(data.Fs);
 sequence = sequence.setTempo(data.bpm);
 wav=real(sequence.synthesize());
 sequence = NoteSequence(); 
 audiowrite('output.wav', wav, data.Fs);
 soundsc(wav, data.Fs);
 
 
 guidata(data.hfig,struct('hfig',data.hfig,'Fs',data.Fs, ...
 'key_symb',{data.key_symb},'note_type_duration',data.note_type_duration,...
 'bpm',data.bpm,'source',data.source,'effect',data.effect,'wav',[]));
end
  
function bpm_callback(hObject,eventdata)
 data = guidata(hObject);
 val=get(hObject, 'Value');
 
 switch val;
     case 1
         data.bpm=150;
     case 2
         data.bpm=120;
     case 3
         data.bpm=90;
     case 4
         data.bpm=60;
 end
 
 guidata(data.hfig,struct('hfig',data.hfig,'Fs',data.Fs, ...
 'key_symb',{data.key_symb},'note_type_duration',data.note_type_duration,...
 'bpm',data.bpm,'source',data.source,'effect',data.effect,'wav',data.wav));
end

function effect_callback(hObject,eventdata)
 data = guidata(hObject);
 val=get(hObject, 'Value');
 
 data.effect=val;
 
 guidata(data.hfig,struct('hfig',data.hfig,'Fs',data.Fs, ...
 'key_symb',{data.key_symb},'note_type_duration',data.note_type_duration,...
 'bpm',data.bpm,'source',data.source,'effect',data.effect,'wav',data.wav));
end

function source_callback(hObject,eventdata)
 data = guidata(hObject);
 val=get(hObject, 'Value');
 
 data.source=val;
     
 guidata(data.hfig,struct('hfig',data.hfig,'Fs',data.Fs, ...
 'key_symb',{data.key_symb},'note_type_duration',data.note_type_duration,...
 'bpm',data.bpm,'source',data.source,'effect',data.effect,'wav',data.wav));
end
