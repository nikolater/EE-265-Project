classdef Tone_Note < Note_Abstract  
    properties 
    end
    methods(Access = public)
        %% Constructor
        % Instantiate an instance of
        function obj = Tone_Note(type_in, tone_in, amplitude_in)
            obj.type = type_in;
            obj.tone = tone_in;
            obj.amplitude = amplitude_in;
        end
        
        %% synthesize(bpm, Fs)
        % Create the waveform
        function wav = synthesize(obj, bpm, Fs)
            wav = obj.csin(bpm, Fs);
        end
    end
    
end

