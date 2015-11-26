%% NoteSequence
% Used to store a sequence of notes input by the user in the GUI.
classdef NoteSequence
    
    properties(Access = private)
        tempo;          % the tempo of the sequence
        samplingFreq;   % the sampling frequency to be played back
        notes;          % an array of the notes themselves
    end
    
    methods(Access = public)
        %% GUINoteSequence()
        % Create an instance of the GUINoteSequence class
        function obj = NoteSequence()
        end
        %% appendNote(obj, newNote)
        % Append a note to the list of notes.
        function obj = appendNote(obj, newNote)
            len = length(obj.notes);
            obj.notes{len+1} = newNote;
        end
        %% insertNote(obj, idx, newNote)
        % Insert a note at index idx.
        function obj = insertNote(obj, idx, newNote)
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
        
        %% removeNote(obj, idx)
        % Remove the note at index idx.
        function obj = removeNote(obj, idx)
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
        
        %% setTempo(tempo_in)
        % Set the tempo of the note sequence.
        function obj = setTempo(obj, tempo_in)
            obj.tempo = tempo_in;
        end
        
        %% setSamplingFreq(samplingFreq_in)
        % Set the sampling frequence for the playback of the sequence.
        function obj = setSampleRate(obj, samplingFreq_in)
            obj.samplingFreq = samplingFreq_in;
        end
        
        %% synthesize()
        % Synthesize the sequence of notes.
        function wav = synthesize(obj)
            wav = [];
            for idx = 1:length(obj.notes)
                wav = [wav, ...
                       obj.notes{idx}.synthesize(obj.tempo, obj.samplingFreq)];
            end
        end
    end
    
end

