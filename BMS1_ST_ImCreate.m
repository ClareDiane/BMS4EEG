%% BMS 1: Spatiotemporal Image Creation Script
% This script creates trial images for every trial, for every participant 
% and for every condition (in the same way that one would create images 
% of each condition's average per participant in flexible full factorial 
% designs, except that  this script uses the file prior to averaging across
% conditions. (For example, use the 'afdespm12.mat’ file per participant
% instead of the final 'bfmaeafdespm12.mat’ file. The full names of the 
% preprocessed files we used are aeTBafdMpspmeeg_[sub-no]_EEG.mat.)

% N.B. No smoothing is performed in this step (apply if required).

% Requirements for this script:
% - Statistical Parametric Mapping (SPM12) toolbox (SPM12) installation
% - EEG data preprocessed in SPM prior to averaging across conditions  

% This script was run on EEG data that were preprocessed in the following
% order (but can also be run on EEG data preprocessed using SPM in
% any chosen order of steps - selected files must be PRIOR to averaging): 
%   1) conversion of data files to MATLAB files
%   2) montaging by referencing all electrodes against each other
%   3) downsampling to 200 Hz; 
%   4) bandpass filtering (between 0.5 to 40 Hz)
%   5) eyeblink correction to remove trials marked with eyeblink artefacts
%      (measured with the VEOG and HEOG channels)
%   6) epoching using a peri-stimulus window of -100 to 400 ms
%   7) artefact rejection (with 100 uV cut-off)
%   8) robust averaging
%   9) low-pass filtering (40 Hz; to remove any high frequency noise)
%   10) baseline correction (-100 to 0 ms window). 
% Note: pre-processed data files we used were from after step 7 was applied

% We used data from an auditory oddball paradigm (as described in 
% Garrido et al., 2017), obtained from the Queensland Brain Institute, 
% Australia, using a 64 channel EEG Biosemi system. For the raw data, 
% please see: https://figshare.com/s/1ef6dd4bbdd4059e3891 and for the 
% preprocessed data, please see: https://figshare.com/s/c6e1f9120763c43e6031

% For further information on data collection and on this analysis method 
% see: Garrido, M.I., Rowe, E.G., Halasz, V., & Mattingley, J. (2017). 
% Bayesian mapping reveals that attention boosts neural responses to 
% predicted and unpredicted stimuli. Cerebral Cortex, 1-12.
% DOI: 10.1093/cercor/bhx087

% If you use these scripts, please cite:
% Harris C.D., Rowe, E.G., Randeniya, R. and Garrido, M.I. (2018). 
% Bayesian Model Selection Maps for group studies using M/EEG data. 

% Scripts written by Elise Rowe, July 2016.
% Further changes made by Clare Harris and Elise Rowe, April 2017.

% Please note that these scripts have been optimised for MATLAB 2016b.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Create images for each trial for each participant

clear all;

Participants = [1:20] % Enter your participant numbers in ascending order

% Ensure preprocessed images are contained in folders numbered by
% participant number -- see below for full filepath example:
% ['C:\FolderExample1\SubfolderExample1\1\aeTBafdMpspmeeg_1_example.mat'];

filePath = ['C:\FolderExample1\SubfolderExample1\'] %enter the file path

for cycle = 1:length(Participants) %loop through participant list
    PP = Participants(cycle);
    
    spm('defaults', 'EEG');
    
    spm_jobman('initcfg');
    
    filename = [filePath num2str(PP) '\aeTBafdMpspmeeg_' num2str(PP) '_example.mat']; 
    % Above, enter the filename of the preprocessed images. 

    matlabbatch{1}.spm.meeg.images.convert2images.D = {filename};
    matlabbatch{1}.spm.meeg.images.convert2images.mode = 'scalp x time'; %spatiotemporal data
    matlabbatch{1}.spm.meeg.images.convert2images.conditions = { 
    'Attended_Standards'
    'Unattended_Standards'
    'Attended_Deviants'
    'Unattended_Deviants'};
     % In the above lines, name your experimental conditions if using your 
     % data. If using the data on Figshare, please see Garrido et al. (2017) 
     % for explanations of each condition written above.

    matlabbatch{1}.spm.meeg.images.convert2images.channels{1}.type = 'EEG'; 
    matlabbatch{1}.spm.meeg.images.convert2images.timewin = [0 400]; 
    % Our chosen desired peristimulus time interval was 0 to 400 ms
    
    matlabbatch{1}.spm.meeg.images.convert2images.freqwin = [-Inf Inf]; 
    % Frequency window is here set to include all frequencies 
    
    matlabbatch{1}.spm.meeg.images.convert2images.prefix = 'EEG_allTrials_forBMS_'; 
    % Choose your desired prefix for the resulting saved files 
    % NB: please take note of the resulting saved file names, because you 
    % will need to enter these at the start of the next script.
    
    spm_jobman('serial',matlabbatch);
    
end