function [ output_args ] = test( obj )
%TEST Summary of this function goes here
%   Detailed explanation goes here
correlation = [];
for i = 1:length(obj.partWav)-1
    
    currTemp = (obj.partWav{i});
    nextTemp = (obj.partWav{i+1});
    
    %currTemp = findpeaks(real(currTemp));
    %nextTemp = findpeaks(real(nextTemp));
    
    maxIdx = min(length(currTemp), length(nextTemp));
    
    sampleSpacing = length(currTemp)/10;
    currSample = currTemp(1:floor(sampleSpacing):maxIdx);
    nextSample = nextTemp(1:floor(sampleSpacing):maxIdx);
    
    correlation = [correlation corr(currSample', nextSample', 'rows', 'pairwise')];
    
end
figure
stem(correlation);
stdCorr = std(correlation);
for i = 1:length(correlation)
    
    
end
end

