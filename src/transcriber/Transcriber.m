classdef Transcriber
%#########################################################################%
%                           TRANSCRIBER                                   %
%=========================================================================%
% Used to transcribe a note sequence.                                     %
%                                                                         %
% SUPERCLASS:   n/a                                                       %
%#########################################################################%
    
    properties
        wav;        % The waveform
        partWav;    % The partitioned waveform
        partFreq;   % The frequency of the partitioned waveforms
        partNotes;  % The notes of the partitions
        
        Fs; % The sampling frequency of the sequence
        
        signature; % Timing signature
        
        CLIP_SIZE = 0.000; % The percent to trip at the front and back
    end
    
    methods(Access = private)       
        function obj = partitionWaveform(obj, bpm)
        %------------------------------------------------------------------
        % paritionWaveform(bpm)
        % Parition the input waveform to be in segments which are the
        % length of a sixteenth note.
        %
        % PARAMETERS:
        %   bpm     ::  int/float   ::  The tempo of the wavefrom
        %                               (beats/min)
        % RETURN:
        %   The updated Transcriber object. The partWav property in this
        %   object will now be valid. 
        %------------------------------------------------------------------

            % get the size of the partitions
            bps = bpm/60; % beats per second
            timeSixteenth = bps / 8;                                        % TODO: if timing signatures are added this will need to be changed
            parSize = round(timeSixteenth * obj.Fs); % size of partition
            
            % allocate memory for partitioned waveform
            sizeWav = size(obj.wav);
            nRows = ceil(sizeWav(2)/parSize); 
            obj.partWav = cell(nRows, 1);
            
            % parition the waveform
            nTrim = round(parSize * obj.CLIP_SIZE) + 1;
            for i = 1:nRows
                % grab partition
                if(i == nRows)
                    temp = obj.wav(parSize*(i-1)+1:end);
                else
                    temp = obj.wav(parSize*(i-1)+1: parSize*i );
                end
                % copy trimmed section
                obj.partWav{i} = temp(nTrim:end-nTrim);
            end
        end
        
        function obj = analyzeFrequency(obj)
        %------------------------------------------------------------------
        % analyzeFrequency()
        % Analyze the frequency of the partitioned waveform.
        %
        % PARAMETERS:
        %               n/a
        %
        % RETURN:
        %   The updated Transcriber object with parFreq now valid.
        %------------------------------------------------------------------
            nParts = length(obj.partWav);
            obj.partFreq = zeros(1, nParts);
            
            %  analyze the frequency for each 
            for idx = 1:nParts
                % take dft
                dftParWav = fft(obj.partWav{idx});
                
                % find the most significant frequency component
                [~, f_dft] = max(abs(dftParWav));
                if( f_dft >length(dftParWav)/2)
                     f_dft = f_dft - length(dftParWav);
                end
                f = f_dft * obj.Fs / length(dftParWav);
                obj.partFreq(idx) = f;
            end
        end
        
        function obj = classifyNotes(obj)
        %------------------------------------------------------------------
        % classifyNotes()
        % Classify the notes of the partitioned waveforms.
        %
        % PARAMETERS:
        %               n/a
        %
        % RETURN:
        %   The updated Transcriber object.
        %------------------------------------------------------------------
            nParts = length(obj.partFreq);
            
            % classify each note
            for idx = 1:nParts
                obj.partNotes(idx) = round(real(40 + 12 * log2(obj.partFreq(idx)/440))); 
            end
        end           
    end
    
    methods(Access = public)
        function obj = Transcriber(wav_in, Fs_in, tSignature_in)
        %------------------------------------------------------------------
        % Transcriber(wav_in, Fs_in, tSignature_in)
        % Instantiate and instance of the Transcriber class. 
        %
        % PARAMETERS:
        %   wav_in  ::  float   ::  The input waveform.
        %   Fs_in   ::  float   ::  The sampling frequency.
        %   tSignature_in   ::  ??? :: The timing signature.    
        %
        % RETURN:
        %   A new instance of the Transcriber class.
        %------------------------------------------------------------------
            obj.wav = wav_in;
            obj.Fs = Fs_in;
            obj.signature = tSignature_in;
        end
        
        function obj = transcribe(obj, bpm)
        %------------------------------------------------------------------
        % transcribe(bpm)
        % Transcribe the given waveform.
        %
        % PARAMETERS:
        %   bpm     ::  int/float   ::  The number of beats per minute.
        %
        % RETURN:
        %   Updated Transcriber object.
        %------------------------------------------------------------------
            obj = obj.partitionWaveform(bpm);
            obj = obj.analyzeFrequency();
            obj = obj.classifyNotes();
        end
    end
end

