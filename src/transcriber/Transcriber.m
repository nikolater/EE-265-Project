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
			
			newNoteIndex = []; %#ok<*NASGU>
			newNoteIndexesAmplitude = [];
            
			% take note of anywhere where there is a transition in frequency
            
            
            
            % ---------- Take note of transitions in frequency --------
            % Loop through the paritioned waveforms and see where fruency
            % changes
            newFreqIndex = [];
            for i = 1:nParts-1
				if(obj.partNotes(i) ~= obj.partNotes(i+1))
					% new note detected!
					newFreqIndex = [newFreqIndex, i * obj.noTrimSize];
				end
            end
            % Make sure to catch the last note. This is just a convinient
            % place to put it.
            newFreqIndex = [newFreqIndex, nParts*obj.noTrimSize]; 
            
            % ------------- Method 1 -------------
            % Determine note lengths based on zero amplitude and diff
            % convolution.
            newNoteIndex_m1 = [newFreqIndex, obj.note_amplitudeAnalysis()];
			
            % ------------- Method 2 -------------
            % Determine note length based on correlation between paritioned
            % wave chunks.
            newNoteIndex_m2 = [newFreqIndex, obj.amplitudeCorrelation()];
			
			% Deterermine note placement
            noteJointIndex_m1 = unique(round(newNoteIndex_m1/obj.noTrimSize));
            noteJointIndex_m2 = unique(round(newNoteIndex_m2/obj.noTrimSize));
            noteFreqJoint = unique(round(newFreqIndex/obj.noTrimSize));
            
            % Sort chunk joins
			noteJointIndex_m1 = sort(noteJointIndex_m1);
            noteJointIndex_m2 = sort(noteJointIndex_m2);
            
            % Plot a comparison of the methods
            figure
            subplot(3,1,1)
            [y,x] = findpeaks(real(obj.wav));
            plot(x,y);
            title('Method 1: Amplitude Analysis')
            hold all
            for i = 1:length(noteJointIndex_m1)
                x = noteJointIndex_m1(i) * obj.noTrimSize;
                plot([x, x], [0, 1], 'r--')
            end
            ylim([0, 1]);
            
            subplot(3,1,2)
            for i = 1:length(obj.partWav)
                y = real(obj.partWav{i,:});
                x = 1+obj.noTrimSize*(i-1):obj.noTrimSize*(i-1)+length(y); 
                hold all
                plot(x,y);
            end
            title('Method 2: Waveform  Chunk Correlation')
            hold all
            for i = 1:length(noteJointIndex_m2)
                x = noteJointIndex_m2(i) * obj.noTrimSize;
                plot([x, x], [-1, 1], 'r--')
            end
            
            % Take joints where methods agree plus changes in frequency
            comb = sort([noteJointIndex_m1, noteJointIndex_m2]);
            [~,loc] = find(diff(comb) == 0);
            newNoteIndex = unique([comb(loc), noteFreqJoint]);
            
            newNoteIndex = sort(newNoteIndex);
            
            subplot(3,1,3)
            plot(real(obj.wav));
            title('Agreeable Note Joints')
            hold all
            for i = 1:length(newNoteIndex)
                x = newNoteIndex(i) * obj.noTrimSize;
                plot([x, x], [-1, 1], 'r--')
            end
            
			% classify the detected notes
			prevIdx = 0;
            noteIdx = 1;
			for i = 1:length(newNoteIndex);
				currIdx = newNoteIndex(i);
				noteLength =  currIdx - prevIdx;
				if(noteLength ~= 0)
					obj.notes{1,noteIdx} = obj.partNotes(currIdx);
					obj.notes{2,noteIdx} = noteLength * (1/16);
                    noteIdx = noteIdx + 1;
				end
				prevIdx = currIdx;
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
        %------------------------------------------------------------------
        % amplitudeCorrelation()
        % Calculate the correlation between joints to determine note
        % indexes
        %
        % PARAMETERS:
        %       n/a
        %
        % PRECONDITION:
        %   The wave must be partitioned before this function can be called
        %
        % RETURN:
        %   A vector of the newNoteIndexes. The method does not change any
        %   attribute of the Trascriber class.
        %------------------------------------------------------------------
        
            jointCorr = [];     % vector to house joint correlations 
            plotProcess = 0;    % flag for whether or not to plot the process
            
            % calcualte the correlation between all partitioned waveforms
            for i = 1:length(obj.partWav)-1
                currTemp = (obj.partWav{i});    % current partition
                nextTemp = (obj.partWav{i+1});  % next parition
                
                % max sample index of the two paritions
                maxSampleIdx = min(length(currTemp), length(nextTemp));
                
                % get the samples
                currSample = currTemp(1:maxSampleIdx);
                nextSample = nextTemp(1:maxSampleIdx);
                
                % calculate their correlation
                jointCorr = [jointCorr corr(currSample', nextSample', 'rows', 'pairwise')]; %#ok<*AGROW>
            end
            
             % calculate standard deviation of correlation for data set
             stdCorr = std(jointCorr);
             
             if(plotProcess)
                figure
             end
             
             % new notes are joints where correlation is > std
             % Note: This method works because the outlier skew the
             % standard deviation. This skewed standard deviation can
             % then be used to find outliers.
             newNoteIdx = [find(abs(jointCorr) < stdCorr), length(jointCorr)+1];
             
             if(plotProcess)
                 subplot(2,1,1) %#ok<*UNRCH>
                 plot(real(obj.wav));
             end
             
             temp = [];
             for i = 1:length(newNoteIdx)
                 x = (newNoteIdx(i)) * obj.noTrimSize;
                 temp = [temp, x];
                 
                 if(plotProcess)
                     hold all
                     plot([x, x], [-1,1], 'r--');
                 end
             end
             
             if(plotProcess)
                 subplot(2,1,2)
                 plot([0, length(jointCorr)], [stdCorr, stdCorr], 'r-');
                 hold all
                 stem(abs(jointCorr));
             end
             
             newNoteIdx = temp;
                
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
            obj = obj.classifyNoteTones();
            obj = obj.classifyNotes();
            figure
            noteTones = [];
            for i = 1:length(obj.notes)
                noteTones = [noteTones, obj.notes{1,i}];
            end
            stem(noteTones);
            ylim([27 52]);
        end
    end
end

