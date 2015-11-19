%% GUINoteSequence
% Used to store a sequence of notes input by the user in the GUI.
classdef GUINoteSequence
    
    properties
        tempo;          % the tempo of the sequence
        samplingFreq;   % the sampling frequency to be played back
        notes;          % an array of the notes themselves
    end
    
    methods
        %% GUINoteSequence()
        % Create an instance of the GUINoteSequence class
        function obj = GUINoteSequence()
        end
        %% appendNote(obj, newNote)
        % Append a note to the list of notes.
        function obj = appendNote(obj, newNote)
            obj.notes = [obj.notes, newNote];
        end
        %% insertNote(obj, idx, newNote)
        % Insert a note at index idx.
        function obj = insertNote(obj, idx, newNote)
            if(idx > 1 && idx <= length(obj.notes))
            obj.notes = [   obj.notes(1:(idx-1)), ...
                            newNote, ...
                            obj.notes(idx:end)          ];
            elseif(idx == 1)
                obj.notes = [newNote, obj.notes];
            elseif(idx == length(obj.notes)+1)
                obj.notes = [obj.notes, newNote];
            else
                ErrorInGUISequence = 'ERROR: idx must be greater than 1'...
                                                        %#ok<NOPRT,NASGU>
            end
        end
        
        %% removeNote(obj, idx)
        % Remove the note at index idx.
        function obj = removeNote(obj, idx)
            if(idx > 1 && idx + 1 <=length(obj.notes))
            obj.notes = [obj.notes(1:idx-1), obj.notes(idx+1:end)];
            elseif(length(obj.notes) == idx)
                obj.notes = obj.notes(1:idx-1);
            elseif(idx == 1)
                obj.notes = obj.notes(2:end);
            else
                ErrorInGUISequence = ...
                    'ERROR: cannot remove requested note' %#ok<NOPRT,NASGU>
            end
        end
        
        %% setTempo(tempo_in)
        % Set the tempo of the note sequence.
        function obj = setTempo(tempo_in)
            obj.tempo = tempo_in;
        end
        
        %% setSamplingFreq(samplingFreq_in)
        % Set the sampling frequence for the playback of the sequence.
        function obj = setSamplingFreq(samplingFreq_in)
            obj.samplingFreq = samplingFreq_in;
        end
    end
    
end

