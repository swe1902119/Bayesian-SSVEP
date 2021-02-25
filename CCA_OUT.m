function output = CCA_OUT(CCA_Result)
% Translate CCA result to CCA detection output
    switch length(size(CCA_Result))
        case 1
            [~, output] = max(CCA_Result);
        case 2
            [~, output] = max(CCA_Result,[], 2);
        otherwise
            error("Expected vector or 2D matrix");
    end
end