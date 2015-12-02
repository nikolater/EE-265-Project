classdef Note_Abstract
%#########################################################################%
%                           Note_Abstract               (Abstract Class)  %
%=========================================================================%
% Abstract class for representing a musical note played.                  %
%                                                                         %
% SUBCLASS:     Tone_Note                                                 %
%               ADSR_Note                                                 %
%#########################################################################%

    properties(Access = protected)
        type;       % the type of note. ie. quarter note
        tone;       % the tone of the note
        amplitude;  % the amplitude of the waveform
    end    
    
    methods(Access = public)
        
        function F = getFrequency(obj, Fs)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % getFrequency(Fs)
        % Get the discrete-time frequency of the note
        %
        % PARAMETERS:
        %   Fs  ::  int     ::  Sampling frequency of the playback.
        %
        % RETURN:
        %   The frequency of the note in cycles/sample
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            
            % calculate the frequency of the key
            f = (440 * 2^((obj.tone - 49)/12));                               % TODO: double check that this is the correct formula 
            
            F = f/Fs; % return the frequency in cycle/sample

        end
        
        function n = getNumSamples(obj, bpm, Fs)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % getNumSamples(bpm, Fs)
        % Get the number of samples required to produce the note.
        %
        % PARAMETERS:
        %   bpm     ::  int/float   ::  The number of beats per minute of
        %                               the playback.
        %   Fs      ::  int         ::  The sampling frequency of the
        %                               playback.
        % RETURN:
        %   The number of samples needed to produce the note
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
            bps = bpm/60; % beats be second                                 % TODO: this method could be improved
            t = obj.type * (1/bps) * 4; % time of note in seconds
            n = t*Fs; % number of samples per note
        end
        
        function wav = csin(obj, bpm, Fs)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % csin(bpm, Fs)
        % Generate the complex sinusiod of the basic note from its tone and
        % type.
        %
        % PARAMETERS:
        %   bpm     ::  float/int   ::  Playback tempo (beats/minute)
        %   Fs      ::  int         ::  Playback sampling frequency
        %
        % RETURN:
        %   The complex sinusoid of the basic note.
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
            % get frequency and number of samples
            F = obj.getFrequency(Fs);
            N = obj.getNumSamples(bpm, Fs);
            
            % generate complex sine wave
            x = 0:(N-1);
            wav = obj.amplitude * exp(-1j*2*pi*F*x);                        % TODO : should this be negative?
        end
    end
    
    methods(Abstract, Access = public)
        % synthesize(bpm, Fs)       :: Abstract Method
        % Synthesize the note. 
        %
        % PARAMETERS:
        %   bpm     ::  int/float   :: Playback temp(beats/minutes)
        %   Fs      ::  int         :: Playback sampling frequency.
        synthesize(obj, bpm, Fs)
    end
end

