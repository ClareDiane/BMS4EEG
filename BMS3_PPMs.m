%% PPM Creation Script
% This script creates posterior probability maps (PPMs) and exceedance
% probability maps (EPMs); please see line 72 if you want PPMs only.
% One PPM is created for each model that was defined and estimated in 
% the previous script (BMS 2). PPMs combine the log evidence across all 
% participants in the dataset and are used to determine the best model.

% Requirements for this script:
% - SPM12 installation
% - Log Evidence (logEv.nii) images per participant and model from 
%    completed BMS2 script (spatiotemporal) and LogEv.nii files AFTER
%    replacement of NaNs using the BMS2b script (source)
% - the correct spm_spm_vb.m script saved in the SPM12 folder
%    either for source or spatiotemporal EEG analyses (see the corresponding
%    instructions in this GitHub respository)

% We used data from an auditory oddball paradigm (as described in
% Garrido et al., 2017), obtained from the Queensland Brain Institute,
% Australia, using a 64 channel EEG Biosemi system. For the raw data, 
% please see: https://figshare.com/s/1ef6dd4bbdd4059e3891 and for the 
% preprocessed data, please see: https://figshare.com/s/c6e1f9120763c43e6031

% For further information on data collection and on this analysis method
% see: Garrido, M., Rowe, E., Halasz, V., & Mattingley, J. (2017).
% Bayesian mapping reveals that attention boosts neural responses to
% predicted and unpredicted stimuli. Cerebral Cortex, 1-12.
% DOI: 10.1093/cercor/bhx087

% If you use these scripts, please cite:
% Harris C.D., Rowe, E.G., Randeniya, R. and Garrido, M.I. (2018). 
% Bayesian Model Selection Maps for group studies using M/EEG data. 

% Scripts written by Elise Rowe, July 2016.
% Further changes made by Clare Harris and Elise Rowe, April 2017.

% Please note that these scripts have been optimised for MATLAB 2016b.

% NOTE: Set 'showModel' value for specific model results to visualise.
% Also set: PP, lovEvFilename & modelPath prior to running scripts.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Start BMS 3 Process
clear all
spm('defaults', 'EEG');

PP = [1:20]; % Enter range of participant numbers in ascending order
logEvFilename = ['nLogEv']; % Change this depending on spatiotemporal or source analysis

spm_jobman('initcfg');

%% BMS at Second Level for Posterior Probability Maps
matlabbatch{1}.spm.stats.bms_map.inference.dir = {'C:\FolderExample1\SubfolderExample1\'}; 
% Write BMS files to the location specified above 

for pNo = 1:length(PP)
    usePNo = PP(pNo);
    
    for model=1:2 % Change this to reflect the number of models considered
        matlabbatch{1}.spm.stats.bms_map.inference.sess_map{pNo}.mod_map{model,1} = ...
            ['C:\FolderExample1\SubfolderExample1\P' num2str(usePNo) '\BMS_Model' num2str(model) '\' num2str(logEvFilename) '.nii,1'];
            % Change the file name to LogEv.nii when performing spatiotemporal BMS.
        
    end
end
                                                            
matlabbatch{1}.spm.stats.bms_map.inference.mod_name = {
                                                       'Model1' 
                                                       'Model2'
                                                       };
% Above, name your models (you can enter more than 2)
% For an explanation of Model1 (Opposition Model) and Model2 
% (Interaction Model) please see Garrido et al., 2017.
matlabbatch{1}.spm.stats.bms_map.inference.method_maps = 'RFX'; %RFX = random effects, FFX = fixed effects
matlabbatch{1}.spm.stats.bms_map.inference.out_file = 1; % 0 = output PPMs only, 1 = output PPMs and EPMs
matlabbatch{1}.spm.stats.bms_map.inference.mask = {''}; % blank for no mask

spm_jobman('serial',matlabbatch);
 
clear matlabbatch

%% Show PPM for one model (at a time)
showModel = 'Model1'; % Show results for this model - change as desired
modelPath = ['C:\FolderExample1\SubfolderExample1\' num2str(showModel) '_model_xppm.nii,1'];
% The above line sets the path for model results.

spm('defaults', 'EEG');
spm_jobman('initcfg');

matlabbatch{1}.spm.stats.bms_map.results.file = {'C:\FolderExample1\SubfolderExample1\BMS.mat'};
matlabbatch{1}.spm.stats.bms_map.results.img = {modelPath}; 
matlabbatch{1}.spm.stats.bms_map.results.thres = 0.75; % set probability of winning model here
matlabbatch{1}.spm.stats.bms_map.results.k = [1 1]; % extend results this many voxels
matlabbatch{1}.spm.stats.bms_map.results.scale = [1]; % 1 = log; 0 = none; [] = serial mode

spm_jobman('serial',matlabbatch);
