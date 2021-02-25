function [mean_, std_, inputTable, adjustHeader, p_] = STAT(input, significantP)
% Calculate mean, standard deviation and P-value of input
% Also generate necessary variable for plotting
%   [mean_, std_, inputTable, adjustHeader, p_] = STAT(input, significantP)
%   mean_: the mean value of input data 

    cellFunNum2Str = @(input) num2str(input);
    timeWinNo = size(input, 3);
    mean_ = squeeze(mean(input, 2));
    std_ = squeeze(std(input, 0, 2));
    inputTable = strcat(cellfun(cellFunNum2Str , num2cell(mean_), 'UniformOutput', false), ' ±', cellfun(cellFunNum2Str, num2cell(std_), 'UniformOutput', false));
    adjustHeader = cell(timeWinNo, 1);
    p_ = zeros(timeWinNo, 1);
    for i = 1 : timeWinNo
        p_(i) = anova1(input(:, :, i)', [1 : size(input, 1)], 'off');
        if p_(i) < significantP
            adjustHeader{i} = '*';
        end
    end
end