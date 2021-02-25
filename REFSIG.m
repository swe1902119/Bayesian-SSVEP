function refSig = REFSIG(freq, harmonic, timePoint, samplingRate)
% return an reference signal with same number of channel, depend on the
% type of reference signal, the number of channel and frequency of 
% reference signal might need to be specified
%   refSig = REFSIG(freq, harmonic, timePoint, samplingRate);
%       Return sine-cosine wave with specified properties

    harmonic = harmonic * 2;
    refSig = zeros(harmonic, timePoint);
    for i = 1 : harmonic
        for t = 1 : timePoint
            refSig(i, t) = sin(ceil(i / 2) * 2 * pi * freq * t / samplingRate + pi / 2 * mod(i - 1, 2));
                %harmony * 2pi * freq * time / samplingRate
        end
    end
end