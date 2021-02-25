%% Space allocation
timeWinNo = length([minTime : stepTime : maxTime]);
precomputeTime = zeros(ALL_SUBJECT, ALL_BLOCK, timeWinNo);
trainingTime = zeros(ALL_SUBJECT, ALL_BLOCK, timeWinNo);
computeTime = zeros(2, ALL_SUBJECT, ALL_BLOCK, timeWinNo);
accuracy = zeros(2, ALL_SUBJECT, timeWinNo);

%% Computing basic CCA recognition
fprintf('Computing basic CCA recognition...\n');
result = zeros(ALL_SUBJECT, 1);
index_t = 0;
for tw = minTime : stepTime : maxTime
    fprintf('Time window = %.2f ...', tw);
    timeWindow = floor(tw * samplingRate);
    index_t = index_t + 1;
    for subject = 1 : ALL_SUBJECT
        block_CCA_out = zeros(ALL_TARGET, ALL_BLOCK);
        for block = 1 : ALL_BLOCK
            tic;
            signal = EEG_DATA(ALL_DATA, subject, prestimulus, timeWindow, block);
            block_CCA_out(:, block) = CCA_OUT(CCA(signal, refSig(:, :, 1 : timeWindow)));
            computeTime(1, subject, block, index_t) = toc / ALL_TARGET;
        end
        result(subject) = ACC(block_CCA_out);
    end
    fprintf('Done\n');
    accuracy(1, :, index_t) = result;
end

%% Simple Bayesian
fprintf('Computing Bayes-CCA recognition...\n');
result = zeros(ALL_SUBJECT, 1);
index_t = 0;
timeWindow = floor(foldLen * samplingRate);
for tw = minTime : stepTime : maxTime
    index_t = index_t + 1;
    fprintf('Time window = %.2f\n', tw);
    fold = floor(tw / foldLen);
    for subject = 1 : ALL_SUBJECT
        fprintf('\tSubject %d', subject);
        block_CCA_out = zeros(ALL_TARGET, ALL_BLOCK);
        precompute = zeros(ALL_TARGET, fold, ALL_BLOCK);
        for block = 1 : ALL_BLOCK
            tic;
            startTime = prestimulus + 1;
            for f = 1 : fold
                signal = EEG_DATA(ALL_DATA, subject, startTime, timeWindow, block);
                precompute(:, f, block) = CCA_OUT(CCA(signal, refSig(:, :, 1 : timeWindow)));
                startTime = startTime + timeWindow;
            end
            precomputeTime(subject, block, index_t) = toc;
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
                trainingTime(subject, crossedBlock, index_t) = trainingTime(subject, crossedBlock, index_t) + precomputeTime(subject, block, index_t);
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

            tic;
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
            computeTime(2, subject, crossedBlock, index_t) = toc / ALL_TARGET;
        end
        result(subject) = ACC(block_CCA_out);
        fprintf(']...Done\n');
    end
    accuracy(2, :, index_t) = result;
end

%% Compute necessary data for plotting
fprintf('Processing experiment result...');

timeWinLen = [minTime : stepTime : maxTime];
tableHeader = strcat(split(num2str(timeWinLen)), 's');

accuracy = accuracy * 100;
[meanAcc, stdAcc, accTable, accAdjustHeader, p_Acc] = STAT(accuracy, significantP);

subjectTrainTime = squeeze(mean(trainingTime, 2));
[meanTrainTime, stdTrainTime, TTTable, TT_AdjustHeader, p_TT] = STAT(subjectTrainTime, significantP);

subjectCompTime = squeeze(mean(computeTime, 2));
[meanCompTime, stdCompTime, CTTable, CT_AdjustHeader, p_CT] = STAT(subjectCompTime, significantP);

%% Plot result

DRAWFIG('Accuracy of Different Method', ...
        'Time Window (second)', ...
        'Accuracy (%)', ...
        meanAcc, stdAcc, ...
        accTable, accAdjustHeader, p_Acc, methodName, ...
        datasetName, timeWinLen, tableHeader, significantP);

fprintf('Experiment Done\n');

%% Alert User
s = beep;
beep on;
beep;
if beep == "off"
    beep off;
end