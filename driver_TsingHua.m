clc;
clear all;
close all;

%% Dataset details
fprintf("Initializing...\n");

datasetName = 'TsingHua';
subjectsDir = dir('TsingHua data/');
ALL_SUBJECT = 35;
ALL_TARGET = 40;
ALL_BLOCK = 6;
ALL_CHANNEL = 6;    % 64 in total, only 6 channels are used
samplingRate = 250;
prestimulus = 125;
harmonic = 3;

minTime = 0.1;
maxTime = 1;
stepTime = 0.1;

foldLen = 0.06;

methodName = {'Basic CCA Recognition', 'Proposed method'};
          
evidenceMin = 0.0001;

significantP = 0.01;

relatedChannels = [55,56,57,61,62,63];
load("TsingHua data/Freq_Phase.mat", "freqs");

EEG_DATA = @(ALL_DATA, subject, prestimulus, timeWindow, block) ALL_DATA{subject}.data(:, :, prestimulus + 1 : prestimulus + timeWindow, block);

%% Loading data and prepare reference signal
refSig = zeros(ALL_TARGET, harmonic * 2, 5 * samplingRate);
for i = 1 : ALL_TARGET
    refSig(i, :, :) = REFSIG(freqs(i), harmonic, 5 * samplingRate, samplingRate);
end

ALL_DATA = cell(1, ALL_SUBJECT);
for i = 1 : ALL_SUBJECT
    ALL_DATA{i} = load([subjectsDir(i + 3).folder, '\', subjectsDir(i + 3).name]);
    % target * channel * time * block
    ALL_DATA{i}.data = permute(ALL_DATA{i}.data(relatedChannels, :, :, :), [3, 1, 2, 4]);
end
fprintf("Preparation completed\n");

%% Start Experiment
main;
additional;