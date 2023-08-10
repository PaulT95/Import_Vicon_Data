# Import_Vicon_Data
***** IMPORT VICON NEXUS DATA in MATLAB *****
This simple function permits to import properly all data stored in a txt or csv file exported with Vicon Nexus
It imports the data in different structs with the name saved in Nexus for each channel/marker:

- Frequencies (will contain up to 3 variables with the frequencies of Analog data, Marker and Model Outputs)
- Labels (of the analog, markers and model outputs for using in a for/do while cycle)
- Analog (IMPORTANT! If you have more force platforms please ask also the Force output which is the last one. Look at the code why)
- Markers (e.g. HEAD_Marker with 3 columns which corresponds to X,Y,Z)
- Model Outputs

Test and work on both TXT and CSV exported from Vicon Nexus 2.6, 2.7, and 2.12 
PS: sorry if the description is not that good, or even a couple of comments in italian but I had to write quick notes while I was programming ;)  

BE CAREFUL IF YOU EXPORT TRAJECTORIES or other additional parameters as they will affect the reference locations
