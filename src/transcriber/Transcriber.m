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
        
        function obj = classifyNoteTones(obj)
        %------------------------------------------------------------------
        % classifyNoteTones()
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
    end
    
    methods(Access = public)
       
		
		function newNoteIndex = note_amplitudeAnalysis(obj)
        %------------------------------------------------------------------
		% note_amplitudeAnalysis()
		% Analyze the amplitude of the waveform to determine note positions
		%
		% PARAMETERS:
		%		n/a
		%
		%------------------------------------------------------------------  
			APX_ZERO = 0.0012; 	% Threshold for zero-amplitude
            DW2_MIN = 0.3;		% Threshold for edges after second convolution
            
            diffKernel = [-1, 0, 1];	% Edge detection kernel
            [amplitude, loc] = findpeaks(abs(real(obj.wav))); % get waveform 
																% amplitude
            
            newNoteIndex = [];	% vector of new notes
            
			% Find the location's where amplitude is zero. This will be the
			% start or end of a note
			temp = find(amplitude < APX_ZERO );
            for i = 1:length(temp)
                newNoteIndex = [newNoteIndex, loc(temp(i))];
            end
            
            % Detect edges with differentiating convolution
            dW1 = abs(conv(amplitude, 2*diffKernel, 'same'));
            dW2 = abs(conv(dW1, 2*diffKernel, 'same'));
            
			% Detect edges
            temp = find(dW2 > DW2_MIN);
            
			% locate these edges
            for i = 1:length(temp)
                newNoteIndex = [newNoteIndex, loc(temp(i))];
            end
            
        end
		
		function obj = classifyNotes(obj)
        %------------------------------------------------------------------
        % classifyNotes()
        % Classify the notes in the waveform.
        %
        % PARAMETERS:
        %       n/a
        %
        % RETURN:
        %   The updated object who's notes have been classified.
        %------------------------------------------------------------------
			nParts = length(obj.partWav); % number of partitions in waveform decomp
			
			newNoteIndex = [];
			newNoteIndexesAmplitude = [];
			% take note of anywhere where there is a transition in frequency
			for i = 1:nParts-1
				if(obj.partNotes(i) ~= obj.partNotes(i+1))
					% new note detected!
					newNoteIndexesAmplitude = [newNoteIndexesAmplitude, i * obj.noTrimSize];
				end
            end
            newNoteIndexesAmplitude = [newNoteIndexesAmplitude, nParts*obj.noTrimSize];
			
			% get new note indecies detected from amplitude analysis
			
            newNoteIndexesAmplitude = [newNoteIndexesAmplitude, obj.note_amplitudeAnalysis()];
            newNoteIndexesCorrelation = obj.amplitudeCorrelation();
            
            t1 = unique(round((newNoteIndexesAmplitude / obj.noTrimSize)));
            if(length(t1) < length(newNoteIndexesCorrelation))
                newNoteIndex = [newNoteIndex, newNoteIndexesAmplitude];
            else
                newNoteIndex = [newNoteIndex, newNoteIndexesCorrelation];
            end
            
            %newNoteIndex = [newNoteIndex, obj.note_amplitudeAnalysis()];
			%newNoteIndex = [newNoteIndex, obj.amplitudeCorrelation()];              % SWAP HERE
            % sort notes before classification
            newNoteIndex = sort(newNoteIndex);
            
			% classify the detected notes
			prevIdx = 0;
            noteIdx = 1;
			for i = 1:length(newNoteIndex);
				currIdx = round(newNoteIndex(i)/obj.noTrimSize);
				
				noteLength =  currIdx - prevIdx;
				if(noteLength ~= 0)
					obj.notes{1,noteIdx} = obj.partNotes(currIdx);
					obj.notes{2,noteIdx} = noteLength * (1/16);
                    noteIdx = noteIdx + 1;
				end
				prevIdx = currIdx;
            end
			
            % show the notes that were classified
            plot(real(obj.wav));
            wavIdx = 1;
            for i = 1:length(obj.notes)
                wavIdx = wavIdx + 16 * obj.notes{2,i} * obj.noTrimSize;
                hold all
                plot([wavIdx, wavIdx], [-1,1], 'r--');
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
        
        function [newNoteIdx] = amplitudeCorrelation(obj)
            nSamples = 5;
            notConverged = 1;
            
            prevNewNoteIdx = [];
            prev2NewNoteIdx = [];
            
            plotProgress = 0;
            
            while(notConverged)
                nSamples = nSamples*2;
                jointCorr = [];
                for i = 1:length(obj.partWav)-1
                    currTemp = (obj.partWav{i});
                    nextTemp = (obj.partWav{i+1});

                    maxSampleIdx = min(length(currTemp), length(nextTemp));
                    sampleSpacing = floor(maxSampleIdx/nSamples);

                    currSample = currTemp(1:floor(sampleSpacing):maxSampleIdx);
                    nextSample = nextTemp(1:floor(sampleSpacing):maxSampleIdx);

                    jointCorr = [jointCorr corr(currSample', nextSample', 'rows', 'pairwise')];
                end

                % calculate standard deviation
                stdCorr = std(jointCorr);
                if(plotProgress)                                                                                        
                                                                                                        clf('reset')
                end
                newNoteIdx = [find(abs(jointCorr) < stdCorr), length(jointCorr)+1];
                if(plotProgress)                                                                                        
                                                                                                        subplot(2,1,1)
                                                                                                        plot(real(obj.wav));
                end
                temp = [];
                for i = 1:length(newNoteIdx)
                    x = (newNoteIdx(i)) * obj.noTrimSize; 
                    temp = [temp, x];
                    if(plotProgress)
                                                                                                        hold all
                                                                                                        plot([x, x], [-1,1], 'r--');
                    end
                end
                if(plotProgress) 
                                                                                                        subplot(2,1,2)
                                                                                                        plot([0, length(jointCorr)], [stdCorr, stdCorr], 'r-');
                                                                                                        hold all
                                                                                                        stem(abs(jointCorr));
                end

                newNoteIdx = temp;
                
                if(isequal(newNoteIdx, prevNewNoteIdx)...
                    && isequal(newNoteIdx, prev2NewNoteIdx))
                    notConverged = 0;
                else
                    prev2NewNoteIdx = prevNewNoteIdx;
                    prevNewNoteIdx = newNoteIdx;
                end
            end
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
            subplot(3,1,1) 
            obj = obj.partitionWaveform(bpm);
            obj = obj.analyzeFrequency();
            obj = obj.classifyNoteTones();
            subplot(3,1,2)
            obj = obj.classifyNotes();
            subplot(3,1,3)
            noteTones = [];
            for i = 1:length(obj.notes)
                noteTones = [noteTones, obj.notes{1,i}];
            end
            stem(noteTones);
            ylim([27 52]);
        end
    end
end

