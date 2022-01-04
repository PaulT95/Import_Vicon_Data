# Import_Vicon_Data
***** IMPORT VICON NEXUS DATA in MATLAB *****
This simple function permits to import properly all data stored in a txt file exported with Vicon Nexus
It imports the data in different structs with the name saved in Nexus for each channel/marker like:
- Frequencies
- Labels (of the analog,markers and model outputs for using in a for/do while cycle)
- Analog
- Markers (e.g. HEAD_Markers with 3 column which correspond to X,Y,Z)
- Model Outputs
- Force


PS: sorry if the description is not that good, or even a couple of comments in italian but I had to write quickly notes while I was programming ;)  
