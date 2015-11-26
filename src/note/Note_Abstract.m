%% Note (Abstract)
% Used to represent a musical note.
classdef Note_Abstract
    properties(Access = protected)
        type;       % the notes type
        tone;       % the tone of the note
        amplitude;  % the amplitude of the waveform
    end    
    
    methods(Access = public)
        %% getFrequency(Fs)
        % Get the frequency of the note in samples/cycle.
        function F = getFrequency(obj, Fs)
            f = 440 * 2 ^ (obj.tone - 40)/12;
            F = f/Fs;
        end
        
        %% getNumSamples(bpm, Fs)
        % Get the number of samples required to produce this note at Fs.
        function n = getNumSamples(obj, bpm, Fs)
            bps = bpm/60; % beats be second
            tWN = bps*2; % time for whole note TODO: FIX
            t = obj.type * tWN; % time of note in seconds
            n = t*Fs; % number of samples per note
        end
        
        %% csin(bpm, Fs)
        % Get the vanilla complex sinusoid from this note.
        function wav = csin(obj, bpm, Fs)
            F = obj.getFrequency(Fs);
            N = obj.getNumSamples(bpm, Fs);
            
            x = 0:(N-1);
            
            wav = obj.amplitude * exp(-1j*2*pi*F*x);
        end
    end
    
    methods(Abstract, Access = public)
        %% synthesize(bpm, Fs)
        % Create the waveform for this note.
        synthesize(obj, bpm, Fs)
    end
end

