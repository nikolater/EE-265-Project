classdef Transcriber
    %TRANSCRIBER Summary of this class goes here
    %   Detailed explanation goes here
    
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
        function parWav = partitionWaveform(obj, bpm)
            % get the size of the partitions
            bps = bpm/60; % beats per second
            timeSixteenth = bps / 8;                                        % TODO: if timing signatures are added this will need to be changed
            parSize = round(timeSixteenth * obj.Fs); % size of partition
            
            % allocate memory for partitioned waveform
            sizeWav = size(obj.wav);
            nRows = ceil(sizeWav(2)/parSize); 
            parWav = cell(nRows, 1);
            
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
                parWav{i} = temp(nTrim:end-nTrim);
            end
        end
        
        function parFreq = analyzeFrequency(obj, parWav)
            nParts = length(parWav);
            parFreq = zeros(1, nParts);
            
            %  analyze the frequency for each 
            for idx = 1:nParts
                % take dft
                dftParWav = fft(parWav{idx});
                
                % find the most significant frequency component
                [~, f_dft] = max(abs(dftParWav));
                if( f_dft >length(dftParWav)/2)
                     f_dft = f_dft - length(dftParWav);
                end
                f = f_dft * obj.Fs / length(dftParWav);
                parFreq(idx) = f;
            end
        end
        
        function obj = classifyNotes(obj, parFreq)
            nParts = length(parFreq);
            
            % classify each note
            for idx = 1:nParts
                obj.notes(idx) = round(real(40 + 12 * log2(parFreq(idx)/440))); 
            end
        end           
    end
    
    methods(Access = public)
        function obj = Transcriber(wav_in, Fs_in, tSignature_in)
            obj.wav = wav_in;
            obj.Fs = Fs_in;
            obj.signature = tSignature_in;
        end
        
        function obj = transcribe(obj, bpm)
            parWav = obj.partitionWaveform(bpm);
            parFrq = obj.analyzeFrequency(parWav);
            obj = obj.classifyNotes(parFrq);
        end
    end
end

