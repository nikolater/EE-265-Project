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
        noTrimSize; % Size of the partitions before trimming
        partWav;    % The partitioned waveform
        partFreq;   % The frequency of the partitioned waveforms
        partNotes;  % The notes of the partitions
        
        amplitudeAnalysisNoteIndex; % new note index determined by
                                    % amplitude analysis
        
        partAMean;
        partAStDev;
        
        notes;
        
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
            obj.noTrimSize = parSize;
            
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
                                                                            hold all
                                                                            plot(parSize*(i-1)+1:length(obj.wav),real(temp))
                else
                    temp = obj.wav(parSize*(i-1)+1: parSize*i );            hold all
                                                                            plot(parSize*(i-1)+1: parSize*i,real(temp))
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
                obj.partNotes(idx) ...
                    = round(real(40 + 12 * log2(obj.partFreq(idx)/440))); 
            end
        end 
        
        function obj = analyzeAmplitude(obj)
            nParts = length(obj.partWav);
                       
            % allocate cells
            obj.partAMean = cell(1, nParts);
            obj.partAStDev = cell(1, nParts);
            
            % calculate mean amplitude and standard deviation
            for i = 1:nParts
                amplitudes = findpeaks(real(obj.partWav{i}));
                obj.partAMean{i} = mean(amplitudes);
                obj.partAStDev{i} = std(amplitudes);
            end    
        end
        
        function obj = determineNoteType(obj)
            nParts = length(obj.partWav);
            
            
            % find positions where absolute value of amplitude is zero
            [ampl, loc] = findpeaks(real(obj.wav));
            zeroLoc = find( abs(ampl) < 0.01 );                             % Magic number here
            contBound = ones(1, nParts - 1);
            for i = 1:length(zeroLoc)
                idxNewNote = loc(zeroLoc(i));
                boundaryLocation = ...
                    round( idxNewNote / obj.noTrimSize);
                if(boundaryLocation ~= nParts && boundaryLocation ~= 0)
                    contBound(boundaryLocation) = 0;
                end
            end
            
            
            
            
            % check if amplitude is continous across paritions
            % check if frequence is continous across paritions
            % if so then it is the same note
            for i = 1:(nParts-1)
                
                % check that keyNumber is continous across boundary
                if(contBound(i))
                    contBound(i) = obj.partNotes(i) == obj.partNotes(i+1);
                end
                
                % check if both notes are tone notes
                if(obj.partAStDev{i} < 0.01 ...
                        && obj.partAStDev{i} < 0.01 ...
                        && contBound(i) )
                    meanDiff = abs(obj.partAMean{i} - obj.partAMean{i+1});
                    minStDev = min([obj.partAStDev{i}, obj.partAStDev{i}]);
                    if( meanDiff > minStDev )
                        contBound(i) = 0;
                    end
                end
            end
            
            % now contBound is '1' across boundaries which are the same
            % note
            numNotes = sum(contBound(:) == 0) + 1;                          % sort of magic 1
            obj.notes = cell( numNotes, 2);
            
            % classify first note
            obj.notes{1,1} = obj.partNotes(1);
            obj.notes{1,2} = 1/16;
            
            idx = 1;
            for i = 1:nParts
                if(contBound(i) == 0) % if boundary is not continous
                    hold all
                    plot([i*obj.noTrimSize,i*obj.noTrimSize] ,[-1,1], 'k--') 
                    idx = idx + 1;
                    obj.notes{idx, 1} = obj.partNotes(i+1);                 % Magic 1
                    obj.notes{idx, 2} = 1/16;
                else 
                    obj.notes{idx, 2} = obj.notes{idx,2} + 1/16;
                end
            end
            
        end
        
        function obj = determineNotes(obj)
            prevIndex = 0;
            partIndex = 1;
            for i = 1:length(obj.amplitudeAnalysisNoteIndex)
                
                partIndex = round(obj.amplitudeAnalysisNoteIndex(i)/obj.noTrimSize);
                
                obj.notes(i,1) = obj.partNotes(partIndex);
                obj.notes(i,2) = (1/16) * (partIndex - prevIndex);
                prevIndex = partIndex;
            end
            for i = length(obj.notes):-1:1
                if(obj.notes(i,2) ==0)
                    obj.notes(i,:) = [];
                end
            end
            
        end
    end
    methods(Access = public)
        function obj = amplitudeAnalysis(obj)
            APX_ZERO = 0.0012;
            DW2_MIN = 0.3;
            
            diffKernel = [-1, 0, 1];
            [amplitude, loc] = findpeaks(abs(real(obj.wav)));
            
            newNoteIndex = [];
            temp = find(amplitude < APX_ZERO );
            for i = 1:length(temp)
                newNoteIndex = [newNoteIndex, loc(temp(i))];
            end
            
            % first diff convolution
            dW1 = abs(conv(amplitude, 2*diffKernel, 'same'));
            dW2 = abs(conv(dW1, 2*diffKernel, 'same'));
            
            temp = find(dW2 > DW2_MIN);
            
            for i = 1:length(temp)
                newNoteIndex = [newNoteIndex, loc(temp(i))];
            end
            
            % remove copies
            COPY_SIZE = 400;   % about 400 looks best
            
            newNoteIndex = sort(newNoteIndex);
            
            while(newNoteIndex(1) < COPY_SIZE)
                 newNoteIndex(1) = [];
            end
            
            for i = length(newNoteIndex):-1:2
                if(abs(newNoteIndex(i) - newNoteIndex(i-1)  ) < COPY_SIZE)
                    newNoteIndex(i) = [];
                end
            end
            
            plot(real(obj.wav));
            
            for i = 1:length(newNoteIndex)
                hold all
                plot( [newNoteIndex(i), newNoteIndex(i)], [-1,1], 'r--');
            end
            
           % subplot(2,1,2)
           % plot(dW2);
           
            obj.amplitudeAnalysisNoteIndex = newNoteIndex;          
            
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
            subplot(2,1,1) 
            obj = obj.partitionWaveform(bpm);
            obj = obj.analyzeFrequency();
            obj = obj.classifyNotes();
            subplot(2,1,2)
            obj = obj.amplitudeAnalysis();
            obj = obj.determineNotes();
        end
    end
end

