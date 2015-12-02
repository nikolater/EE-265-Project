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

initial_bpm = 120;
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
[200 400 80 40],'string', '120|60', 'callback', ...
@bpm_callback);
uicontrol( 'Parent', hfig, 'style','text','position', ...
[191 440 100 40],'string', 'Tempo (bpm)');

uicontrol( 'Parent', hfig, 'style','popupmenu','position', ...
[500 400 100 40],'string', 'Tone|ADSR Tone', 'callback', ...
@source_callback);
uicontrol( 'Parent', hfig, 'style','text','position', ...
[493 440 100 40],'string', 'Source');
 
uicontrol( 'Parent', hfig, 'style','popupmenu','position', ...
[900 400 80 40],'string', 'None|Tremolo', 'callback', ...
@effect_callback);
uicontrol( 'Parent', hfig, 'style','text','position', ...
[890 440 100 40],'string', 'Effect');

end
 

 function key_callback(hObject,eventdata)
 data = guidata(hObject);
 str=char(get(hObject, 'String'));
 
 for ii=1:23
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
         newNote=ADSR_Note(noteType(1), noteTone(1), 1, 0.5,0.3,0.4,0.2,0.5);
 end
        
 wav=real(newNote.synthesize(data.bpm,data.Fs));
 soundsc(wav, data.Fs);
 global sequence
 sequence = sequence.appendNote(newNote);
 
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
 sequence=sequence.setSampleRate(data.Fs);
 sequence=sequence.setTempo(data.bpm);
 wav=real(sequence.synthesize());
 soundsc(wav, data.Fs);
 
 guidata(data.hfig,struct('hfig',data.hfig,'Fs',data.Fs, ...
 'key_symb',{data.key_symb},'note_type_duration',data.note_type_duration,...
 'bpm',data.bpm,'source',data.source,'effect',data.effect,'wav',[]));
end
  
function bpm_callback(hObject,eventdata)
 data = guidata(hObject);
 str=get(hObject, 'String');
 val=get(hObject, 'Value');
 
 switch str(val);
     case '120'
         data.bpm=120;
     case '60'
         data.bpm=60;
 end
 
 guidata(data.hfig,struct('hfig',data.hfig,'Fs',data.Fs, ...
 'key_symb',{data.key_symb},'note_type_duration',data.note_type_duration,...
 'bpm',data.bpm,'source',data.source,'effect',data.effect,'wav',data.wav));
end

function effect_callback(hObject,eventdata)
 data = guidata(hObject);
 str=get(hObject, 'String');
 val=get(hObject, 'Value');
 
 switch str(val);
     case 'Tone'
         data.source=1;
     case 'ADSR Tone'
         data.source=2;
 end
 
 
 guidata(data.hfig,struct('hfig',data.hfig,'Fs',data.Fs, ...
 'key_symb',{data.key_symb},'note_type_duration',data.note_type_duration,...
 'bpm',data.bpm,'source',data.source,'effect',data.effect,'wav',data.wav));
end

function source_callback(hObject,eventdata)
 data = guidata(hObject);
 str=get(hObject, 'String');
 val=get(hObject, 'Value');
 
 switch str(val);
     case 'None'
         data.effect=1;
     case 'Tremolo'
         data.effect=2;
 end
     
 
 guidata(data.hfig,struct('hfig',data.hfig,'Fs',data.Fs, ...
 'key_symb',{data.key_symb},'note_type_duration',data.note_type_duration,...
 'bpm',data.bpm,'source',data.source,'effect',data.effect,'wav',data.wav));
end
