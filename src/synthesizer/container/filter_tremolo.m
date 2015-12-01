function [ wav_out ] = filter_tremolo( wav_in, Fs, Fc, alpha )
%TREMOLO creates a trembling effect on the soundfile 'input_snd.wav'. The
%frequency of this tremelo is Fc.

Fc = 1000;
alpha = 1.0;

% read file

fc = Fc/Fs; % get frequency
n = 0:length(wav_in)-1; % sample points

wav_out = (1+alpha*sin(2*pi*fc*n)).*wav_in; % generate new waveform
wav_out = wav_out/max(abs(wav_out)); % normalize

end

