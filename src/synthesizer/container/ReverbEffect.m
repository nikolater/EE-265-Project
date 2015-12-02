classdef ReverbEffect < SequenceEffect_Abstract
%%######################################################################%% 
%                             ReverbEffect                               %
%========================================================================%
% Represents a reverb effect to be added to the sequence.                %
%                                                                        %
% SUPERCLASS: SequenceEffect_Abstract                                    %
% ########################################################################
    
    properties
        alpha;  %amplitude of the effect
        delay;  %in seconds
    end
    
    methods(Access = public)
        function obj = ReverbEffect(delay, alpha)
            obj.delay = delay;
            obj.alpha = alpha;
        end
        
        function wav_out = filter(obj, wav_in, Fs)
            % read file

            nd = round(obj.delay * Fs); % get delay in samples
            lwav = length(wav_in); %length of wav_in
            
            for i=1:nd
                wav_out(1,i) = wav_in(1,i);
            end
            
            for i=nd+1:lwav-1
                wav_out(1,i) = wav_in(1,i) + obj.alpha*wav_out(1,i-nd);
            end
            
        end
    end
    
end