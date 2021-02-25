function DRAWFIG(figName, xlab, ylab, mean_, std_, inputTable, adjustHeader, p_, methodName, datasetName, timeWinLen, tableHeader, significantP)
% DRAW(figName, xlab, ylab, mean_, std_, inputTable, adjustHeader, p_, methodName, datasetName, timeWinLen, tableHeader, significantP)

    starPosition = max(mean_ + std_, [], 'all') * 1.05;
    figure('name',figName);
    hold on
    title(sprintf('%s [%s Dataset]', figName, datasetName));
    xlabel(xlab);
    ylabel(ylab);
    for i = 1 : size(mean_, 1)
        errorbar(timeWinLen, mean_(i, :), std_(i, :), '-*', 'LineWidth', 1);
    end
    for i = 1 : length(p_)
        if p_(i) < significantP
            plot(timeWinLen(i), starPosition, 'b*');
        end
    end
    xlim([0, timeWinLen(length(timeWinLen)) + 0.1]);
    if starPosition / 1.05 * 1.1 > 100
        ylim([0, starPosition / 1.05 * 1.1 ]);
    else
        ylim([0, 100]);
    end
    hold off
    legend(methodName, 'Location', 'southeast');
    figure('Name', sprintf('%s (Table)', figName));
    uitable('Data', inputTable,'ColumnName', strcat(tableHeader, adjustHeader), 'RowName', methodName, 'Units', 'Normalized', 'Position', [0, 0, 1, 1]);

end