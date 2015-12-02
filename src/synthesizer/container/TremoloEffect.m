classdef TremoloEffect < SequenceEffect_Abstract
%%######################################################################%% 
%                             TremoloEffect                              %
%========================================================================%
% Represents a tremolo effect to be added to the sequence.               %
%                                                                        %
% SUPERCLASS: SequenceEffect_Abstract                                    %
% ########################################################################
    
    
    properties
        alpha;
        fc;
    end
    
    methods(Access = public)
        function obj = TremoloEffect(fc, alpha)
            obj.fc = fc;
            obj.alpha = alpha;
        end
        
        function wav_out = filter(obj, wav_in, Fs)
            % read file

            Fc = obj.fc/Fs; % get frequency
            n = 0:length(wav_in)-1; % sample points

            wav_out = (1+obj.alpha*sin(2*pi*Fc*n)).*wav_in; % generate new waveform
            wav_out = wav_out/max(abs(wav_out)); % normalize
        end
    end
    
end

