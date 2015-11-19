classdef GUINoteSequence
    %GUINOTESEQUENCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tempo;
        sampling_freq;
        notes;
    end
    
    methods
        function [] = addNewNote(note)
            notes(notes.length() + 1) = note;
        end
    end
    
end

