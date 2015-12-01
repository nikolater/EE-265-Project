classdef NoteSequence
%#########################################################################%
%                           NoteSequence                                  %
%=========================================================================%
% Compound data type used to represent a sequence of musical notes which  %
% are subclasses of the Note_Abstract class found in directory at         %
% '../note' relative to the location of this file.                        %
%                                                                         %
% DEPENDANCIES:                                                           %
%   Class definitions for any children of Note_Abstract whcih are valid   %
%   musical notes to be stored by this data type.                         %
%#########################################################################%
    
properties(Access = private)
        tempo;          % the tempo of the sequence
        samplingFreq;   % the sampling frequency to be played back
        notes;          % an array of the notes themselves
        effects;        % the effect applied to the sequence when 
                        %   the sequence is synthesized
    end
    
    methods(Access = public)
        function obj = NoteSequence()
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % NoteSequence()
        % Instantiate a new note sequence.
        %
        % PARAMETERS: (void)
        %
        % RETURN:
        %   New instance of a note sequence type.
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            obj.effects = [];
        end
       
        function obj = appendNote(obj, newNote)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % appendNote(newNote)
        % Append a new note.
        %
        % PARAMETERS:
        %   newNote     ::   T < Note_Abstract  :: The note to be appended.
        %
        % RETURN:
        %   The updated sequence.
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            len = length(obj.notes);
            obj.notes{len+1} = newNote;
        end
        
        function obj = insertNote(obj, idx, newNote)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % insertNote(idx, newNote)
        % Inster a new note.
        %
        % PARAMETERS:
        %   idx         ::  int     ::  The index of where the new note
        %                               will be inserted.
        %   newNote     ::   T < Note_Abstract  :: The note to be appended.
        %
        % RETURN:
        %   The updated sequence.
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            if(idx > 1 && idx <= length(obj.notes))
            obj.notes{idx+1:end+1} = obj.notes{idx:end};
            obj.notes{idx} = newNote;
            elseif(idx == 1)
                obj.notes{2:end+1} = obj.notes{1:end};
                obj.notes{1} = newNote;
            elseif(idx == length(obj.notes)+1)
                obj.appendNote(newNote);
            else
                ErrorInGUISequence = 'ERROR: idx must be greater than 1'...
                                                        %#ok<NOPRT,NASGU>
            end
        end
        
       
        function obj = removeNote(obj, idx)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % removeNote(idx)
        % Remove a note from the sequence.
        %
        % PARAMETERS:
        %   idx         ::  int     ::  The index of where the note to be
        %                               removed.
        %
        % RETURN:
        %   The updated sequence.
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            if(idx > 1 && idx + 1 <=length(obj.notes))
                obj.notes{idx:end-1} = obj.notes{idx+1:end};
                obj.notes = obj.note{1:end-1};
            elseif(length(obj.notes) == idx)
                obj.notes = obj.notes{1:end-1};
            elseif(idx == 1)
                obj.notes{1:end-1} = obj.notes{2:end};
                obj.notes = obj.notes{1:end-1};
            else
                ErrorInGUISequence = ...
                    'ERROR: cannot remove requested note' %#ok<NOPRT,NASGU>
            end
        end
        
        function obj = addEffect(obj, effect)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % addEffect(e_SequenceEffect)
        % Add a new effect to the seqeunce.
        %
        % PARAMETERS:   
        %   seqeunceEffect  ::  e_SequenceEffect    ::  The new effect
        %
        % RETURN:
        %   The updated object.
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            len = length(obj.effects);
            if(len == 0)
                obj.effects{1,1} = effect;
            else 
                obj.effects{1, len+1} = effect;
            end
        end
        
        function obj = setTempo(obj, tempo_in)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % setTempo(tempo_in)
        % Set the tempo for the sequence to be played at.
        %
        % PARAMETERS:
        %   tempo_in    :: float/int    ::  Playback temp (beats/min)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            obj.tempo = tempo_in;
        end
        
        function obj = setSampleRate(obj, samplingFreq_in)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % setSampleRate(tempo_in)
        % Set the sampling rate that the sequence is to be played at.
        %
        % PARAMETERS:
        %   samplingFreq_in ::  int    ::  Playback sampling rate.
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            obj.samplingFreq = samplingFreq_in;
        end
        
        function wav = synthesize(obj)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % synthesize()
        % Synthesize the sequence of notes.
        %
        % RETURN:
        %   The waveform of the synthesized sequence.
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            wav = [];
            for idx = 1:length(obj.notes)
                wav = [wav, ...
                       obj.notes{idx}.synthesize(obj.tempo, obj.samplingFreq)];
            end
            
            for i = 1:length(obj.effects)
                effect = obj.effects{1,i};
                wav = effect.filter(wav, obj.samplingFreq);
            end
        end
    end
    
end

