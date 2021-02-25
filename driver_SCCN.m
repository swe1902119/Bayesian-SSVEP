clc;
clear all;
close all;

%% Dataset details
fprintf("Initializing...\n");

datasetName = 'SCCN';
subjectsDir = dir('SCCN data/');
ALL_SUBJECT = 10;
ALL_TARGET = 12;
ALL_BLOCK = 15;
ALL_CHANNEL = 8;
samplingRate = 256;
prestimulus = 39;
harmonic = 3;

minTime = 0.1;
maxTime = 1;
stepTime = 0.1;

foldLen = 0.06;

methodName = {'Basic CCA Recognition', 'Proposed method'};

evidenceMin = 0.0001;

significantP = 0.01;

relatedChannels = [1 : ALL_CHANNEL];
freqs=[9.25, 11.25, 13.25, 9.75, 11.75, 13.75, 10.25, 12.25, 14.25, 10.75, 12.75, 14.75];

EEG_DATA = @(ALL_DATA, subject, prestimulus, timeWindow, block) ALL_DATA{subject}.eeg(:, :, prestimulus + 1 : prestimulus + timeWindow, block);

%% Loading data and prepare reference signal
refSig = zeros(ALL_TARGET, harmonic * 2, 5 * samplingRate);
for i = 1 : ALL_TARGET
    refSig(i, :, :) = REFSIG(freqs(i), harmonic, 5 * samplingRate, samplingRate);
end

ALL_DATA = cell(1, ALL_SUBJECT);
for i = 1 : ALL_SUBJECT
    ALL_DATA{i} = load([subjectsDir(i + 2).folder, '\', subjectsDir(i+2).name], "eeg");
    % target * channel * time * block
end
fprintf("Preparation completed\n");

%% Start Experiment
main;
additional;