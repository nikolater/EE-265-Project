classdef Tone_Note < Note_Abstract 
%#########################################################################%
%                               Tone_Note                                 %
%=========================================================================%
% Represents a simple musical note of a single frequency.                 %
%                                                                         %
% SUPERCLASS: Note_Abstract                                               %
%#########################################################################%
    methods(Access = public)
        function obj = Tone_Note(type_in, tone_in, amplitude_in)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Tone_Note(type_in, tone_in, amplitude_in)
        % Instantiate and instance of the Tone_Note class.
        % 
        % PARAMETERS:
        %   type_in         ::  e_NoteType  ::  The type of note. ie. 1/4
        %   tone_in         ::  e_NoteTone  ::  The tone of the note.
        %   amplitude_in    ::  float       ::  The amplitude.
        % 
        % RETURN:
        %   The instance of the Tone_Note
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % initialize superclass properties
            obj.type = type_in;
            obj.tone = tone_in;
            obj.amplitude = amplitude_in;
        end
        
        function wav = synthesize(obj, bpm, Fs)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % synthesize(bpm, Fs)
        % Synthesize the note sequence.
        %
        % PARAMETERS:
        %   bpm     ::  int     ::  The number of beats per minute.
        %   Fs      ::  int     ::  The sampling frequency.
        %
        % RETURN:
        %   The waveform of the synthesized note (complex).
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            wav = obj.csin(bpm, Fs);
        end
    end
    
end

