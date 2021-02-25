function corelation = CCA(eegSig, refSig)
% Perform CCA corelation to EEG signal and reference signal
%
%   corelation = CCA(2D_eegSig, 2D_refSig);
%       return corelation (scalar) of the input EEG signal (channel * time)
%       and reference signal (channel * time), these two signal may have
%       different length of time
%
%   corelation = CCA(2D_eegSig, 3D_refSig);
%       return corelation (vector, length = number of target) of the input
%       EEG signal (channel * time) and reference signal (target *
%       channel * time), these two signal may have different length of time
%       Each corelation can be accessed by corelation(refSigTargetNo)
%
%   corelation = CCA(3D_eegSig, 3D_refSig);
%       return corelation (matrix, rank = number of target) of the input
%       EEG signal (target * channel * time) and reference signal (target *
%       channel * time), these two signal may have different length of time
%       Each corelation can be accessed by corelation(eegSigTargetNo, 
%       refSigTargetNo)
    if nargin ~= 2
        error("Not enough input");
    end
    
    switch length(size(eegSig))
        case 2
            switch length(size(refSig))
                case 2
                    %[~, ~, temp] = CCA(eegSig, refSig);
                    [~, ~, temp] = canoncorr(eegSig', refSig');
                    corelation = temp(1);
                    
                case 3
                    corelation = zeros(1, size(refSig, 1));
                    for i = 1 : size(refSig, 1)
                        corelation(i) = CCA(eegSig, squeeze(refSig(i, :, :)));
                    end
                    
                otherwise
                    error("Expected refSig in 2D or 3D");
            end
                    
        case 3
            if length(size(refSig)) ~= 3
                error("Expected a 3D reference signal (target * channel * time)");
            end
            if size(eegSig, 1) ~= size(refSig, 1)
                error("Expected same number of target");
            end
            corelation = zeros(size(eegSig, 1));
            for i = 1 : size(eegSig, 1)
                corelation(i, :) = CCA(squeeze(eegSig(i, :, :)), refSig);
            end
        otherwise
            error("Expected EEG signal in 2D or 3D");
    end
end