%% Script for Replacing NaNs with Zeros in Source LogEv.nii files
% Before running the final script (BMS3) when performing source BMS steps,
% use this script to replace non-number values (NaNs) with zeros in the
% LogEv.nii files that were created in BMS2_ModelSpec_VB.m script

% This way, the sparseness of the data does not prevent PPMs from being
% able to be made in the final BMS script.

% Requirements for this script:
% - SPM12 installation
% - LogEv.nii files created from the BMS2_ModelSpec_VB.m step

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Replace NaNs in the source LogEv files with zeros
PNo = 1:20; % Enter range of participant numbers in ascending order
filename = ['LogEv.nii']; % filename for log evidence images

for pp = 1:length(PNo) 
    
    participantNo = PNo(pp);
    
    for model = 1:2 %enter the number of models being compared
        cd(['C:\FolderExample1\SubfolderExample1\P' num2str(participantNo) '\BMS_Model' num2str(model) '\'])
        %Above, write the directory where the LogEv.nii files are stored.

        img = spm_vol(filename);
        img_data = spm_read_vols(img);
        
        for i = 1:size(img_data)
            img_data(isnan(img_data)) = 0; % replace all NaNs within the image with '0's
            img.fname = 'nLogEv.nii'; % save it as a new filename, and remember to edit
            % BMS script 3 (BMS2_PPMs.m) so that the LogEv filename matches
            spm_write_vol(img, img_data);
        end
    end
end
