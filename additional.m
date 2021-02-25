%% Space Allocation
maxIter = 17;
minTime = 0.03; % To compute CCA, a minimum length of data is needed
add_Acc = zeros(2, maxIter, ALL_SUBJECT);
%% Proposed method with different number of fold
fprintf('Computing Additional Bayes-CCA recognition...\n');
result = zeros(ALL_SUBJECT, 1);
for iter = 1 : maxIter
    index_t = 0;
    fprintf('=====Iteration %d=====\n', iter);
    for tw = 0.5 : 0.5 : 1
        index_t = index_t + 1;
        fprintf('Time window = %.1f\n', tw);
        timeWindow = floor((minTime + iter / 100) * samplingRate);
        fold = floor(tw * samplingRate / timeWindow);
        
        for subject = 1 : ALL_SUBJECT
            fprintf('\tSubject %d', subject);
            block_CCA_out = zeros(ALL_TARGET, ALL_BLOCK);
            precompute = zeros(ALL_TARGET, fold, ALL_BLOCK);
            for block = 1 : ALL_BLOCK
                %tic;
                startTime = prestimulus + 1;
                for f = 1 : fold
                    signal = EEG_DATA(ALL_DATA, subject, startTime, timeWindow, block);
                    temp = CCA(signal, refSig(:, :, 1 : timeWindow));
                    precompute(:, f, block) = CCA_OUT(temp);
                    startTime = startTime + timeWindow;
                end
                %precomputeTime(fold, subject, block, index) = toc;
            end
            fprintf(' ... [');
            for crossedBlock = 1 : ALL_BLOCK
                % Calculation of likehood and evidence
                likehood = zeros(ALL_TARGET, ALL_TARGET, fold);      % dim2 denote correct frequency, dim1 denote frequancy with highest correlation coefficient
                for block = 1 : ALL_BLOCK
                    if block == crossedBlock
                        continue;
                    end
                    for f = 1 : fold
                        for i = 1 : ALL_TARGET
                            likehood(precompute(i, f, block), i, f) = likehood(precompute(i, f, block), i, f) + 1;
                        end
                    end
                    %trainingTime(fold, subject, crossedBlock, index) = trainingTime(fold, subject, crossedBlock, index) + precomputeTime(fold, subject, block, index);
                end
                likehood = likehood / ((ALL_BLOCK - 1) * ALL_TARGET);
                evidence = squeeze(sum(likehood, 2));
                for e = 1 : ALL_TARGET
                    for f = 1 : fold
                        if evidence(e, f) == 0
                            evidence(e, f) = evidenceMin;
                        end
                    end
                end
                prior = ones(ALL_TARGET) / ALL_TARGET;

                fprintf('=');

                %tic;
                startTime = prestimulus + 1;
                for f = 1 : fold
                    signal = EEG_DATA(ALL_DATA, subject, startTime, timeWindow, block);
                    test_CCA_out = CCA_OUT(CCA(signal, refSig(:, :, 1 : timeWindow)));
                    for i = 1 : ALL_TARGET
                        prior(i, :) = prior(i, :) .* likehood(test_CCA_out(i), :, f) ./ evidence(:, f)';
                    end
                    startTime = startTime + timeWindow;
                end
                block_CCA_out(:, crossedBlock) = CCA_OUT(prior);
                %computeTime(fold + 1, subject, crossedBlock, index) = toc / ALL_TARGET;
            end
            result(subject) = ACC(block_CCA_out);
            fprintf(']...Done\n');
        end
        add_Acc(index_t, iter, :) = result;
    end
end
%% Prepare data for plotting
add_Acc = add_Acc * 100;

%% Plot
figure('name','Additional Experiment');
hold on
    for i = 1 : index_t
        errorbar([minTime + 0.01: 0.01 :(minTime + maxIter / 100)], mean(add_Acc(i, :, :), 3), std(add_Acc(i, :, :), 0, 3), '-*', 'LineWidth', 1);
    end
hold off
title(sprintf('Accuracy of Proposed Method with Different Fold Length [%s Dataset]', datasetName));
xlabel('Length of a fold (s)');
ylabel('Accuracy (%)');
xlim([0, (minTime + (maxIter + 1) / 100)]);
ylim([0, 100]);
legend({'Accuracy of Proposed Method (TW = 0.5s)', 'Accuracy of Proposed Method (TW = 1s)'}, 'Location', 'southwest');

fprintf('Additional experiment done\n');

%% Alert user
s = beep;
beep on;
beep;
if beep == "off"
    beep off;
end