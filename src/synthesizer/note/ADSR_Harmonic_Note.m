classdef ADSR_Harmonic_Note < Note_Abstract
%%######################################################################%% 
%                             ADSR_Note                                  %
%========================================================================%
% Represents a musical note scaled by an ADSR envelope.                  %
%                                                                        %
% SUPERCLASS: Note_Abstract                                              %
% ########################################################################
    
    properties(Access = protected)
        A_period;   % period of A region
        D_period;   % period of D region
        S_period;   % period of S region
        R_period;   % period of R region
        As;         % amplitude of S region
    end
    
    methods(Access = public)
        
        function obj = ADSR_Harmonic_Note(type_in, tone_in, volume_in, ...
                                     A, D, S, R, As_in)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % ADSR_NOTE(type_in, tone_in, volume_in, A, D, S, R, As_in) 
        % Instantiate an instance of an ADSR note.
        %
        % PARAMETERS:
        %   type_in     ::  e_NoteType  ::  The type of note ie. quarter.
        %   tone_in     ::  e_NoteTone  ::  The tone of the note.
        %   volume_in   ::  float       ::  The amplitude of the note.
        %   A, D, S, R  ::  float       ::  Amplitude of ADSR envelope.
        %   As          ::  float       ::  Amplitude of S region.
        %
        % RETURN:
        %   Instance of the ADSR_Note
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
            % initialize superclass properties
            obj.type = type_in;
            obj.tone = tone_in;
            obj.amplitude = volume_in;
            
            % normalize ADSR vars
            norm = A + D + S + R;
            
            % initialize properties
            obj.A_period = A/norm;
            obj.D_period = D/norm;
            obj.S_period = S/norm;
            obj.R_period = R/norm;
            obj.As = As_in;
        end
           
        function adsr = envelope(obj, len)
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % adsr(len)
        % Create the notes ADSR envelope.
        %
        % PARAMETERS:
        %   len     ::  int     :: Desired length of output vector.
        %
        % RETURN:
        %   The notes ADSR envelope.
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
            nA = round(obj.A_period*len);           % length of A region
            nD = round(obj.D_period*len);           % length of D region
            nS = round(obj.S_period*len);           % length of S region
            nR = len - nA - nD - nS;                % lenght of R region
            
            kA = obj.amplitude/nA;              % slope of A region
            kD = (obj.amplitude - obj.As)/nD;   % slope of D region
            kR = obj.As/nR;                     % slope of R region
            
            % generate envelope
            adsr = [ kA * [1:nA], ...
                            obj.amplitude - kD * [1:nD], ...
                            obj.As * ones(1,nS),...
                            obj.As - kR * [1:nR] ];            
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
            
            % get complex sinusoid from superclass
            F = obj.getFrequency(Fs);
            fm = [F F*2 F*3 F*4 F*5 F*6 F*7 F*8];
            Ah = [1.0 1.4898 0.3262 0.3010 0.2452 0.1614 0.1194 0.1645];
            N = obj.getNumSamples(bpm, Fs);
            n = 0:(N-1);
            
            for i=1:length(fm)
                wav(1,:) = Ah(i) .* exp(-j*2*pi*fm(i)*n);
            end
            
            %wav = obj.csin(bpm, Fs);
            
            % scale the sinusioud by the adsr envelope
            wav = wav .* obj.envelope( obj.getNumSamples(bpm, Fs));
        end
        
    end
    
end

