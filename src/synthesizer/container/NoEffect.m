classdef NoEffect < SequenceEffect_Abstract
    %NOEFFECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Access = public)
        
        function obj = NoEffect()
        end
        
        function wav_out = filter(obj, wav_in, Fs)
            wav_out = wav_in;
        end
    end
end

