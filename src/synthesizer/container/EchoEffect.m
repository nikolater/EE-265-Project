classdef EchoEffect < SequenceEffect_Abstract
    %EchoEffect Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        alpha;
        alpha2;
        delay; %in seconds
    end
    
    methods(Access = public)
        function obj = EchoEffect(delay, alpha, alpha2)
            obj.delay = delay;
            obj.alpha = alpha;
            obj.alpha2 = alpha2;
        end
        
        function wav_out = filter(obj, wav_in, Fs)
            % read file

            nd = round(obj.delay * Fs); % get delay in samples
            lwav = length(wav_in); %length of wav_in
            
            % Put in first part of ouput before first echo
            for i=1:nd
                wav_out(1,i) = wav_in(1,i);
            end
            
            % Add in first echo
            for i=nd+1:2*nd-1
                wav_out(1,i) = wav_in(1,i) + obj.alpha*wav_in(1,i-nd);
            end
            
            %Add in second echo plus second echo
            for i=2*nd+1:lwav-1
                wav_out(1,i) = wav_in(1,i) + obj.alpha*wav_in(1,i-nd) + ...
                    obj.alpha2*wav_in(1,i-nd*2);
            end
        end
    end
    
end