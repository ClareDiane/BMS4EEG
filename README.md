# BMS4EEG: Bayesian Model Selection Maps for group studies using M/EEG data

This repository allows you to construct posterior probability maps (PPMs) for Bayesian Model Selection (BMS) at the group level using electroencephalography (EEG) data. The method has only recently been used for EEG data (Garrido et al., 2017), after originally being introduced and applied in the context of functional magnetic resonance imaging (fMRI) analysis (Rosa et al., 2010). Here, we describe how this method can be adapted for EEG data analysis using the Statistical Parametric Mapping (SPM) software package for MATLAB (The MathWorks, Inc.). The method enables the comparison of an arbitrary number of computational models at each and every voxel in the brain and/or in the scalp-time volume, both within participants and at the group level.

If you use these scripts, please cite: Harris C.D., Rowe, E.G., Randeniya, R. and Garrido, M.I. (2018). Bayesian Model Selection Maps for group studies using M/EEG data. 

To use these scripts, you will first need the following: 
•	EEG data pre-processed in SPM prior to averaging across conditions (if you do not want to work with your own data, the pre-processed data at the link given above is downloadable and ready to use)
•	Statistical Parametric Mapping (SPM12) toolbox (SPM12) installation
•	MATLAB: version 2016b advised (because this is the system for which the scripts are optimised)
•	Advised: Windows computer and operating system (this is the system for which the scripts are optimised)

For saving the correct spm_spm_vb.m files, the suggested steps are as follows:
1.	Find and open the spm12 folder on your computer.
2.	Find the spm_spm_vb.m script in that folder, and rename this to spm_spm_vb_fMRI.m. Then add the spm_spm_vb_ST.m and spm_spm_vb_source.m scripts (saved in the associated Github repository) to your spm12 folder.
3.	Before undertaking either the spatiotemporal BMS or source BMS steps, rename the currently-relevant script from the above step to spm_spm_vb.m. Once you have finished the BMS steps, rename the script back to its original name, to re-identify it as being for either the spatiotemporal (‘spm_spm_vb_ST.m’) or source BMS (‘spm_spm_vb_source.m’). In this way, you will keep track of which spm_spm_vb.m script to use for whichever BMS steps you are about to do.

For spatiotemporal (“scalp”) PPMs:
1.	BMS script 1: Change the file paths to reflect the location of ERP data. 
2.	Run BMS script 1: BMS1_ST_ImCreate.m.
3.	Ensure the correct spm_spm_vb.m file is saved in SPM12 folder.
4.	Run BMS script 2: BMS2_ModelSpec_VB.m.
5.	Run BMS script 3: BMS3_PPMs.m. Threshold is set to 0.75 and adjustable.

For source PPMs:
1.	BMS script 1: Change the file paths to reflect location of source reconstructed images.
2.	Run BMS script 1: BMS1_Source_ImCreate.m.
3.	Ensure the correct spm_spm_vb.m file is saved in SPM12 folder.
4.	Run BMS script 2: BMS2_ModelSpec_VB.m.
5. 	Replace NaNs with zeros in the LogEv.nii files: BMS2b_Source_NaNtoZeros.m.
6. 	Run BMS script 3: BMS3_PPMs.m. Adjust probability threshold as desired.

We hope you find this M/EEG data analysis method useful for addressing your neuroscientific questions.
