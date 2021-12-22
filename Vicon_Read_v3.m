function [ varargout ] = Vicon_Read_v3(FileName)

% This code permits to read and tabulate VICON.txt data properly
% VICON_READ_V3 Import data from text file (Txt) 
%  [Frequency,Labels,Analog,Markers,ModelOutPut,Force] = Vicon_Read_v3(FileName) reads data from text file
%  FileName for the default selection include path.  Returns as different Structs with the same name used in Vicon.
%  Columns are (X,Y,Z) data 
% 
%  You can even ask less outputs 
%  EXAMPLE: [Frequency, Labels, Analog, Markers] = Vicon_Read_v3(FileName);

%% check arguments
minArgs=1;  
maxArgs=6;
nargoutchk(minArgs,maxArgs);

disp("You requested " + nargout + " outputs.")
w = waitbar(0,'Please wait...','Name','Importing Data');

varargout = cell(nargout,1);
%% Define Opts for reading the file
% clear 
% addpath(genpath(cd));
% file = uipickfiles();
[~,~,ext] = fileparts(FileName);

opts = delimitedTextImportOptions("Encoding", "UTF-8");

% Specify range and delimiter
opts.DataLines = [1, Inf];

switch ext
    case ".txt"
        opts.Delimiter = "\t";
    case ".csv"
        opts.Delimiter = ",";
    otherwise
        disp("File format not supported!")
        waitbar(1,w,"ERROR, File not supported!");
        pause(0.5);
        close(w);        
        return 
end

opts.ExtraColumnsRule = 'addvars';
opts.PreserveVariableNames = 0;

TableData = readtable(FileName,opts); %read and import the whole txt data as TABLE

Data = table2array(TableData);

%% References and Frequencies
%{
References are necessary to find where Different type starts
they are used in particular to select data properly during for cycle, because if
you use data(row:end, column_of_channel) it will select all data in the
sheet and not until the end of analog, the same for model outputs. 
That's why there are different if, because it depends of the different data
exported. This permits the script to work always, also with just analog
data.
ATTENTION WHEN FORCE IS EXPORTED, BECAUSE LABELS HAVE SAME NAME AND THUS
DATA IN ANALOG WILL BE OVERWRITTEN! 

AVOID use this char '-' for labels, because it returns error
%}

% Devices = Analog
% Model Outputs = angle, moments etc.
% Trajectories = Makers

%% Frequencies
Frequency.Analog = str2double(TableData{find(strcmp('Devices',TableData{:,1}))+1,1});
Frequency.ModelOutputs = str2double(TableData{find(strcmp('Model Outputs',TableData{:,1}))+1,1});
Frequency.Markers = str2double(TableData{find(strcmp('Trajectories',TableData{:,1}))+1,1});

%% Reference names/values
Ref_Dev = find(strcmp('Devices',Data(:,1)));
Ref_MOut = find(strcmp('Model Outputs',Data(:,1)));
Ref_Mrk = find(strcmp('Trajectories',Data(:,1)));

waitbar(0.2,w,'Importing Analog(s)...');

%% Analog Data and Labels
if (isempty(Ref_Dev) == false)
    
    Labels.Analog = Data(Ref_Dev+3,(3:end)); % <-- Ref, sempre colonna 3 xkè prime due FRAME e SUBFRAME
    Labels.Analog = Labels.Analog(~cellfun('isempty',Labels.Analog)); %<-- elimina celle vuote
    
    for k=1:length(Labels.Analog)
        
        if (isempty(Ref_MOut) == false)
            Analog.(Labels.Analog{k}) = str2double(Data((Ref_Dev+5):Ref_MOut-1,(2+k)));
        end
        
        if (isempty(Ref_MOut) == true && isempty(Ref_Mrk)== false )
            Analog.(Labels.Analog{k}) = str2double(Data((Ref_Dev+5):Ref_Mrk-1,(2+k)));
        end
        
        if (isempty(Ref_MOut) == true && isempty(Ref_Mrk)== true )
            Analog.(Labels.Analog{k}) = str2double(Data((Ref_Dev+5):end-1,(2+k)));
        end
    end
    
    varargout{3} = Analog;

else 
    varargout{3} = [];
end

waitbar(0.4,w,'Importing Force(s)...');
%% Forces data in a separate var/struct than Analog
Ref_Force = find(contains(Data(Ref_Dev+3,:),'Fx'));

%if there are more Fx in the file means there were more Force Plats
if sum(contains(Data(Ref_Dev+3,:),'Fx'))>1
    
    for num = 1:sum(contains(Data(Ref_Dev+3,:),'Fx'))
        
        Force.('FP'+string(num))(:,1) = str2double(Data((Ref_Dev+5):Ref_MOut-1,Ref_Force(num)));
        Force.('FP'+string(num))(:,2) = str2double(Data((Ref_Dev+5):Ref_MOut-1,Ref_Force(num)+1));
        Force.('FP'+string(num))(:,3) = str2double(Data((Ref_Dev+5):Ref_MOut-1,Ref_Force(num)+2));
        
    end
    
end

if sum(contains(Data(Ref_Dev+3,:),'Fx'))==1
    
    Force.Fx = str2double(Data((Ref_Dev+5):Ref_MOut-1,Ref_Force(1)));
    Force.Fy = str2double(Data((Ref_Dev+5):Ref_MOut-1,Ref_Force(1)+1));
    Force.Fz = str2double(Data((Ref_Dev+5):Ref_MOut-1,Ref_Force(1)+2));
    
end

% check if the Force values are empty, if it's true delete the struct
% if any( structfun(@isempty, Force)) == 1
%     clear Force;
% end
waitbar(0.6,w,'Importing Marker(s)...');
%% Markers data and labels
if (isempty(Ref_Mrk) == false) %just check, if there are not marker data, skip
    
    Labels.Markers = Data(Ref_Mrk+2,:); 
    Labels.Markers = Labels.Markers(~cellfun('isempty',Labels.Markers)); %<-- elimina celle vuote
    Labels.Markers = split(Labels.Markers,':');
    Subject = Labels.Markers(1,1,1);
    Labels.Markers = Labels.Markers(:,:,2);     %<-- elimina nome soggetto 

    j = 1;      % <-- index for catching x,y,z

    for k=1:length(Labels.Markers)

             Markers.(Labels.Markers{k})(:,1) = str2double(Data((Ref_Mrk+5):end,(2+j)));    %X
             j = j+1;

             Markers.(Labels.Markers{k})(:,2) = str2double(Data((Ref_Mrk+5):end,(2+j)));    %Y
             j = j+1;

             Markers.(Labels.Markers{k})(:,3) = str2double(Data((Ref_Mrk+5):end,(2+j)));    %Z
             j = j+1;

    end
    
    varargout{4} = Markers;
    
else 
    varargout{4} = [];
end

waitbar(0.8,w,'Importing Model Output(s)...');
%% ModelOutputs data and Labels
if (isempty(Ref_MOut) == false) %just check, if there are not ModelOutputs data, skip
    
    Labels.ModelOutputs = Data(Ref_MOut+2,(3:end)); %<-- +2 xkè a +3 ci sono x,y,z,tx etc.;
    Labels.ModelOutputs = regexprep(Labels.ModelOutputs,[Subject ':'],'');
    
    MO_NoEmpty =  Labels.ModelOutputs(~cellfun('isempty',Labels.ModelOutputs)); %<-- elimina celle vuote
    MO_NoEmpty = unique(MO_NoEmpty); %remove duplicates
    
    for k=1:length(MO_NoEmpty)
        
        %remove possible duplicates
        
        
        if (k==length(MO_NoEmpty))
            
            inizio = find(strcmpi(MO_NoEmpty{k},Labels.ModelOutputs));
            ModelOutputs.(MO_NoEmpty{k}) = str2double(Data(Ref_MOut+5:end,inizio:inizio+8));
            
        else
            
            inizio = find(strcmpi(MO_NoEmpty{k},Labels.ModelOutputs));
            fine = find(strcmpi(MO_NoEmpty{k+1},Labels.ModelOutputs)) -1;
            
            if(length(inizio) > 1)
                inizio(end) = [];
                fine(end) = [];
            end
            
            ModelOutputs.(MO_NoEmpty{k}) = str2double(Data(Ref_MOut+5:end,inizio:fine));
            
        end
        
    end
    
    Labels.ModelOutputs =  Labels.ModelOutputs(~cellfun('isempty',Labels.ModelOutputs)); %<-- elimina celle vuote
    Labels.ModelOutputs = unique(Labels.ModelOutputs);   
    
    varargout{5} = ModelOutputs;
else 
    varargout{5} = [];
end

waitbar(1,w,'Finishing');
pause(0.5)
close(w)
%% Outputs

% 
% If you don't even have any Frequency or Label it means it was an empty
% or non Vicon file
varargout{1} = Frequency;
varargout{2} = Labels;

if (isempty(Ref_Force))
    varargout{6} = [];
else
    varargout{6} = Force;
end
