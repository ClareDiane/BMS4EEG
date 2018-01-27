%% BMS 2: Model Specification and Log-Evidence Estimation via Variational Bayes
% This script takes the images from the previous steps (both for
% spatiotemporal data images or source reconstruction images), and allows
% the user to introduce covariate weights to define the models to be tested.

% These models will be compared via Bayesian Model Selection (BMS) using
% the BMS 3 scripts.

% Once the models are defined, this script calls the modified spm_spm_vb.m 
% script to implement Variational Bayes (VB) to calculate the log of the 
% model evidence (LogEv for short) for each of the defined models,
% for each participant in the M/EEG dataset. The results are stored in
% files ('LogEv.nii' image files) which are kept in folders for each
% participant. At the end of this script you will have (n*participants)
% unique LogEv.nii files, where n is the number of models you defined at
% the start of the script.

% Model specification and estimation is run for every participant individually.
% These LogEv files will be used in the final BMS step, in the next script.

% Please take note of the additional steps that are required before
% performing this script (these steps are listed below).

% For both spatiotemporal and source BMS steps, you need to save the
% relevant spm_spm_vb.m script in the SPM12 folder on your computer.
% Please see this Github repository for the correct script for the
% spatiotemporal and for the source BMS steps.

%For spatiotemporal BMS steps: run this script after the BMS Image Creation
% Script is complete for all participants

%For source BMS steps: run this script after the BMS Image Creation and
% Group Source Inversion have both been completed for all participants

% Requirements for this script:
% - SPM12 installation
% - Trial images per participant and condition saved from completed 
%     BMS1_ST_ImCreat.m Script for spatiotemporal BMS, or from the completed
%     BMS1_source_ImCreate.m' script for source level analysis
% - the correct spm_spm_vb.m script saved in the SPM12 folder
% either for source or spatiotemporal EEG analyses (see the corresponding
% instructions in this GitHub respository)

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

%Potential time points where the user may need to make manual selection:
% 1) When the script first runs, if the directory chosen is not the same
%   folder as the one where the user currently is, then the user will be
%   asked if they wish to change folders and will then need to hit "Enter" or
%   click "Yes" for the script to run.
% 2) There may be two dialogue boxes warning of a file being "overwritten",
%   which you may respond to in the affirmative, however in standard Windows
%   laptops the script may still run even if the user does not respond to
%   these dialogue boxes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Start BMS 2 Process
clear all

Participants = [1:20]; % Enter range of participant numbers in ascending order

fileNames = {'condition_Attended_Standards', ...
    'condition_Unattended_Standards','condition_Attended_Deviants', ...
    'condition_Unattended_Deviants',}
% Enter your experimental conditions above. For an explanation of 
% the conditions listed above, please see Garrido et al. (2017).

%% Collect all image names from an individual participant
for cycle = 1:length(Participants)
    PP = Participants(cycle)
    
    cd(['C:\FolderExample1\SubfolderExample1\' num2str(PP) ...
        '\EEG_allTrials_forBMS_aeTBafdMpspmeeg_' num2str(PP) '_example'])
    % Enter the name and location of the folders for each participant.
    % Check that the folder you are referring to above is the same as the
    % folder that you created in the previous step.
    
    for nextCycle = 1:length(fileNames)
        useTheseIm = cell2mat(fileNames(nextCycle));
        
        thisPart = ['aeafdMpspmeeg_P' num2str(PP)];
        
        %List names of all images in folder for each trial name
        imagefiles = dir([useTheseIm '.nii']);
        filenames = {imagefiles(:).name};
        loadName = cell2mat(filenames);
        
        %Collect all names of images in the folder for this trial name
        metaFileNames = spm_vol([loadName])
        metaInput = struct2cell(metaFileNames)
        inputFileNames = metaInput(1,:)
        
        inputFileNamesBMS = inputFileNames'
        
        for addOn = 1:length(inputFileNamesBMS)
            appendFileName = cell2mat(inputFileNamesBMS(addOn,:));
            inputFileNamesBMS{addOn,:} = [appendFileName ',' num2str(addOn)];
        end
        
        filename = ['P' num2str(PP) '_' num2str(useTheseIm) '_BMS_Trials.mat']
        
        save(filename, 'inputFileNamesBMS')
        clear inputFileNamesBMS
    end
end

%% Model Specification (insert Regressor Covariates for Models)

for cycle = 1:length(Participants)
    PP = Participants(cycle);
    for model = 1:2 % Change this to reflect the number of models considered
        
        cd(['C:\FolderExample1\SubfolderExample1\' num2str(PP) ...
            '\EEG_allTrials_forBMS_aeTBafdMpspmeeg_' num2str(PP) '_example'])
        
        load(['P' num2str(PP) '_' cell2mat(fileNames(1)) '_BMS_Trials.mat'])
        scan1 = inputFileNamesBMS;
        load(['P' num2str(PP) '_' cell2mat(fileNames(2)) '_BMS_Trials.mat'])
        scan2 = inputFileNamesBMS;
        load(['P' num2str(PP) '_' cell2mat(fileNames(3)) '_BMS_Trials.mat'])
        scan3 = inputFileNamesBMS;
        load(['P' num2str(PP) '_' cell2mat(fileNames(4)) '_BMS_Trials.mat'])
        scan4 = inputFileNamesBMS;
        
        spm('defaults', 'EEG');
        spm_jobman('initcfg');
        
        if model == 1
            makeFolder = ['C:\FolderExample1\SubfolderExample1\P' num2str(PP) '\BMS_Model1'];
            mkdir(makeFolder)
            designDir = makeFolder;
        else
            makeFolder = ['C:\FolderExample1\SubfolderExample1\P' num2str(PP) '\BMS_Model2'];
            mkdir(makeFolder)
            designDir = makeFolder;
        end
        
        %% Model definition/specification step
        % Define your model weights (higher values = larger responses)
        modelOne_Weights = [2,1,3,2]; % apply covariate weights according to first model
        modelTwo_Weights = [4,1,3,2]; % apply covariate weights for model two
        
        matlabbatch{1}.spm.stats.factorial_design.dir = {designDir};
        
        %%
        matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(1).scans = (scan1)
        matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(2).scans = (scan2)
        matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(3).scans = (scan3)
        matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(4).scans = (scan4)
        
        %%
        %%
        matlabbatch{1}.spm.stats.factorial_design.des.anova.dept = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.anova.variance = 1;
        matlabbatch{1}.spm.stats.factorial_design.des.anova.gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.anova.ancova = 0;
        
        %% Input the Covariates
        %(multiplies the covariate weights per condition trial number)
        if model == 1
            matlabbatch{1}.spm.stats.factorial_design.cov.c = ...
                [(ones(1,length(scan1)))*(modelOne_Weights(1)) ...
                (ones(1,length(scan2)))*(modelOne_Weights(2)) ...
                (ones(1,length(scan3)))*(modelOne_Weights(3)) ...
                (ones(1,length(scan4)))*(modelOne_Weights(4))]';
            matlabbatch{1}.spm.stats.factorial_design.cov.cname = 'Model1';
            matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1;
            matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 5;
        elseif model == 2
            matlabbatch{1}.spm.stats.factorial_design.cov.c = ...
                [(ones(1,length(scan1)))*(modelTwo_Weights(1)) ...
                (ones(1,length(scan2)))*(modelTwo_Weights(2)) ...
                (ones(1,length(scan3)))*(modelTwo_Weights(3)) ...
                (ones(1,length(scan4)))*(modelTwo_Weights(4))]';
            matlabbatch{1}.spm.stats.factorial_design.cov.cname = 'Model2';
            matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1;
            matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 5;
        end
        
        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
        matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
        
        spm_jobman('serial',matlabbatch);
        clear matlabbatch; clear scan1; clear scan2; clear scan3; clear scan4;
        
    end
end

%% VB Model specification and LogEvidence calculation

for cycle = 1:length(Participants)
    PP = Participants(cycle);
    for model = 1:2 % Change this to reflect the number of models considered
        
        %Load the SPM files for each participant
        if model == 1
            filePath = ['C:\FolderExample1\SubfolderExample1\P' num2str(PP) '\BMS_Model1\SPM.mat']
            designDirBMS = filePath;
        elseif model == 2
            filePath = ['C:\FolderExample1\SubfolderExample1\P' num2str(PP) '\BMS_Model2\SPM.mat']
            designDirBMS = filePath;
        end
        
        %% Adapting to EEG data
        % The below five lines change the data structure so that the EEG data is
        % able to be examined with scripts that were originally designed for fMRI
        load(filePath)
        SPM.Sess(1).row = size(SPM.xX.X,1);
        SPM.Sess(1).col = SPM.xX.iC;
        save(filePath, 'SPM')
        clear SPM
        
        %% VB Model Specification
        % See SPM12 manual for full explanation of input measures
        spm('defaults', 'EEG');
        spm_jobman('initcfg');
        
        matlabbatch{1}.spm.stats.fmri_est.spmmat = {designDirBMS};
        %Select the SPM.mat file that contains the design specification.        
        matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
        % 0 means images are not written to disk; 1 means they are
        matlabbatch{1}.spm.stats.fmri_est.method.Bayesian.space.slices.numbers = 1:91;
        %1:number of time slices (an x-by-1 array must be entered)
        matlabbatch{1}.spm.stats.fmri_est.method.Bayesian.space.slices.block_type = 'Slices';
        % enter the block type i.e. "Slices" or "Subvolumes." - here, we use 'Slices'
        matlabbatch{1}.spm.stats.fmri_est.method.Bayesian.signal = 'Global';
        % Global Shrinkage prior. As explained in SPM12 help or manual
        matlabbatch{1}.spm.stats.fmri_est.method.Bayesian.ARP = 3;
        % An  AR  model order of 3 is the default. Cardiac and respiratory artifacts are
        % periodic  in  nature  and  therefore  require  an  AR  order of at least 2. In
        % previous  work,  voxel-wise selection of the optimal model order showed that a
        % value of 3 was the highest order required.
        matlabbatch{1}.spm.stats.fmri_est.method.Bayesian.noise.UGL = 1;
        % Unweighted  graph-Laplacian.  This  is the default option.
        matlabbatch{1}.spm.stats.fmri_est.method.Bayesian.LogEv = 'Yes';
        % Important: Log evidence map - Computes  the  log evidence for each voxel.
        matlabbatch{1}.spm.stats.fmri_est.method.Bayesian.anova.first = 'No';
        % ANOVA first-level implemented using Bayesian model comparison.  
        % Computationally demanding: recommended option is therefore NO.
        matlabbatch{1}.spm.stats.fmri_est.method.Bayesian.anova.second = 'No';
        % ANOVA second-level. Tells SPM to automatically generate the simple contrasts
        % necessary  to produce the contrast images for a second-level (between-subject) ANOVA
        matlabbatch{1}.spm.stats.fmri_est.method.Bayesian.gcon = struct('name', {}, 'convec', {});
        % Name contrast vector: contrasts  used to generate PPMs which characterise effect sizes at
        % each voxel.
        spm_jobman('serial',matlabbatch);
        clear matlabbatch
    end
end