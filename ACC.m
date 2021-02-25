function accuracy = ACC(CCA_output, blockDim, correctSeq)
% Check accuracy of CCA output (target * 1 or target * block)

    if nargin < 2
        blockDim = 2;
    end
    if nargin < 3
        correctSeq = [1: size(CCA_output, 1)]';
    end
    if length(size(CCA_output)) > 2
        error("Expected 2D matrix or a vector");
    end
    if blockDim == 1
        CCA_output = CCA_output';
    end
    
    accuracy = 0;
    for i = 1 : size(CCA_output, 2)
        accuracy = accuracy + mean(CCA_output(:, i) == correctSeq);
    end
    accuracy = accuracy / size(CCA_output, 2);
    
end