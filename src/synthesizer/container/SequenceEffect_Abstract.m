classdef SequenceEffect_Abstract
    %SEQUENCEEFFECT_BASE Summary of this class goes here
    %   Detailed explanation goes here
        
    methods(Abstract)
        filter(obj, wav_in);
    end
    
end

