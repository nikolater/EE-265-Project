classdef ADSR_Note < Note_Abstract
    %ADSR_NOTE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = protected)
        A_period;
        D_period;
        S_period;
        R_period;
        As;
    end
    
    methods(Access = public)
        function obj = ADSR_Note(type_in, tone_in, volume_in, ...
                                    A, D, S, R, As_in)
            obj.type = type_in;
            obj.tone = tone_in;
            obj.amplitude = volume_in;
            obj.A_period = A;
            obj.D_period = D;
            obj.S_period = S;
            obj.R_period = R;
            obj.As = As_in;
        end
        
        function adsr = envelope(obj, len)
            nA = round(obj.A_period*len);          % length of A region
            nD = round(obj.D_period*len);          % length of D region
            nS = round(obj.S_period*len);          % length of S region
            nR = len - nA - nD - nS;    % lenght of R region
            
            kA = obj.amplitude/nA;              % slope of A
            kD = (obj.amplitude - obj.As)/nD;   % slope of D
            kR = obj.As/nR;                     % slope of R 
            
            adsr = [ kA * [1:nA], ...
                            obj.amplitude - kD * [1:nD], ...
                            obj.As * ones(1,nS),...
                            obj.As - kR * [1:nR] ];            
        end
        
        function wav = synthesize(obj, bpm, Fs)
            wav = obj.csin(bpm, Fs);
            wav = wav .* obj.envelope( obj.getNumSamples(bpm, Fs));
        end
    end
    
end

