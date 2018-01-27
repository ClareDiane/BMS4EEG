%% Source Level Analysis for BMS (With Group Inversion)
% This script needs to be run on the preprocessed EEG data before source BMS can proceed.
% This script batches together the data files (therefore Group Inversion will be
% done automatically). This is the prefered method for group analysis.

%Steps completed by this script include:
% 1. Source space modeling (specifying head model template : MRI in MNI coordinates)
% 2. Data co-registration (Specify locations that can link the MRI MNI
% coordinates and EEG space (fiducials))
% 3. Forward computation (Computing the effect which each dipole on the
% cortical mesh will have on the sensors)
% 4. Inverse reconstruction, and
% 5. Summarising results of inverse reconstruction as an image.

% The final output file is 'bfmaeTBafdMspmeeg_1001_[Name]_1_t0_400_f_1' 
% up to 'bfmaeTBafdMspmeeg_1001_[Name]_1_t0_400_f_4'

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

% Generated using SPM12 by Roshini Randeniya, April 2017.

% Please note that these scripts have been optimised for MATLAB 2016b.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Create images for each trial for each participant
clear all

Participants = [1:20]'; % Enter range of participant numbers in ascending order

filepath = 'C:\FolderExample1\SubfolderExample1\'; % Enter the file path
filesuffix = '_[Name].mat'; % Enter the file suffix

%% Run Script
spm('defaults', 'EEG')

spm_jobman('initcfg');

%  Template, Coregister, Forward Model
for PP = 1:length(Participants) 
    currname = num2str(Participants(PP));
    matlabbatch{1}.spm.meeg.source.headmodel.D{PP,1} = [filepath currname '\aeTBafdMpspmeeg_' ...
        currname filesuffix];
end

matlabbatch{1}.spm.meeg.source.headmodel.val = 1;
matlabbatch{1}.spm.meeg.source.headmodel.comment = 'Source';
matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.template = 1;
matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshres = 2; % 1 = coarse, 
% 2 = normal, 3 = fine
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregdefault = 1; % 1= yes
matlabbatch{1}.spm.meeg.source.headmodel.forward.eeg = 'EEG BEM';
matlabbatch{1}.spm.meeg.source.headmodel.forward.meg = 'Single Shell';

%Invert, Window
matlabbatch{2}.spm.meeg.source.invert.D(1) = cfg_dep('Head model specification: M/EEG dataset(s) with a forward model', ...
    substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','D'));
matlabbatch{2}.spm.meeg.source.invert.val = 1;
matlabbatch{2}.spm.meeg.source.invert.whatconditions.all = 1;
matlabbatch{2}.spm.meeg.source.invert.isstandard.standard = 1;
matlabbatch{2}.spm.meeg.source.invert.modality = {'EEG'};

%Window, Images
matlabbatch{3}.spm.meeg.source.results.D(1) = cfg_dep('Source inversion: M/EEG dataset(s) after imaging source reconstruction', ...
    substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','D'));
matlabbatch{3}.spm.meeg.source.results.val = 1;
matlabbatch{3}.spm.meeg.source.results.woi = [0 400]; % time of interest
matlabbatch{3}.spm.meeg.source.results.foi = [0 0]; % frequency window specify
matlabbatch{3}.spm.meeg.source.results.ctype = 'trials'; % 'evoked' 'induced' or single 'trials'
matlabbatch{3}.spm.meeg.source.results.space = 1; % 1 = MNI or Native
matlabbatch{3}.spm.meeg.source.results.format = 'image';
matlabbatch{3}.spm.meeg.source.results.smoothing = 12; % mm voxel smoothing value (the default is 8x8x8 mm 
%however the setting for this script is 12x12x12 mm)

spm_jobman('serial',matlabbatch);

clear all

