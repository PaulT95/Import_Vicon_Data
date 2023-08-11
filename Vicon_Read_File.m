function [ varargout ] = Vicon_Read_File(FileName)
%%This code permits to read and tabulate VICON.txt/csv data properly
% VICON_READ_V3 Import data from text file (Txt/Csv) 
%  [Frequency,Labels,Analog,Markers,ModelOutPut] = Vicon_Read_File(FileName) reads data from text file
%  FileName for the default selection include path.  Returns as different Structs with the same name used in Vicon.
%  Columns are (X,Y,Z) data 
% 
%  You can even ask less outputs 
%  EXAMPLE: [Frequency, Labels, Analog, Markers] = Vicon_Read_File(FileName);
%  
%  If your label is just a number or it contains invalid chars for a
%  fieldname in the struct, it will saved as "Var_" + "name of field
%  Author: Paolo Tecchio (Paolo.Tecchio@rub.de)
%TO DO: fix the positions of the model outputs matrixes
%% check arguments
minArgs=1;  
maxArgs=5;
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

AVOID to  use this char '-' for labels, because it returns error
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
if (isempty(Ref_Dev) == false && nargout > 2)
    
    Labels.Analog = Data(Ref_Dev+3,3:end); %
    Labels.Analog = Labels.Analog(~cellfun('isempty',Labels.Analog)); %<-- remove empty cells
    
    %position = find(~cellfun(@isempty,Labels.Analog));
    
    %Check whether more Fx (force plates are present)
    pos = find(contains(Labels.Analog,'Fx'));

    if (numel(pos) > 1)
        %pos(1) = []; %first we get rid as it does not need to be change
        for n_plat = 1:numel(pos)
            sub_string = ['_' num2str(n_plat)];
            if (n_plat ~= length(pos))
                Labels.Analog(pos(n_plat):pos(n_plat+1)-1) = strcat(Labels.Analog(pos(n_plat):pos(n_plat+1)-1), sub_string);
            else
                Labels.Analog(pos(n_plat):end) = strcat(Labels.Analog(pos(n_plat):end), sub_string);
            end
        end
    end

    %add the data for each analog ch
    for k=1:length(Labels.Analog)
        
        if(~isvarname(Labels.Analog{k})) %check whether the field name is not a valid for the struch
           Labels.Analog{k} = "Var_" + string(k);% strtrim(Labels.Analog{k}); %add "Var_" so fix the problem of field name
        end
        
        if (isempty(Ref_MOut) == false)
            Analog.(Labels.Analog{k}) = str2double(Data((Ref_Dev+5):Ref_MOut-1,k+2));
        end
        
        if (isempty(Ref_MOut) == true && isempty(Ref_Mrk)== false )
            Analog.(Labels.Analog{k}) = str2double(Data((Ref_Dev+5):Ref_Mrk-1,k+2));
        end
        
        if (isempty(Ref_MOut) == true && isempty(Ref_Mrk)== true )
            Analog.(Labels.Analog{k}) = str2double(Data((Ref_Dev+5):end-1,k+2));
        end
    end
    
    varargout{3} = Analog;

else 
    varargout{3} = [];
end

waitbar(0.4,w,'Importing Marker(s)...');

%% Forces data in a separate var/struct than Analog
% waitbar(0.4,w,'Importing Force(s)...');
% Ref_Force = find(contains(Data(Ref_Dev+3,:),'Fx'));
% 
% % quick check to select which is the end
% if (isempty(Ref_MOut) == false)
%     Ref_Cut_Force = Ref_MOut;
% 
% elseif (isempty(Ref_MOut) == true && isempty(Ref_Mrk)== false )
%     Ref_Cut_Force = Ref_Mrk;
% 
% elseif (isempty(Ref_MOut) == true && isempty(Ref_Mrk)== true )
%     Ref_Cut_Force = numel( Data(1:end,1) ); %end of the first column
% end
% 
% %if there are more Fx in the file means there were more Force Plats
% if sum(contains(Data(Ref_Dev+3,:),'Fx'))>1
% 
%     for num = 1:sum(contains(Data(Ref_Dev+3,:),'Fx'))
% 
%         Force.('FP'+string(num))(:,1) = str2double(Data((Ref_Dev+5):Ref_Cut_Force-1,Ref_Force(num)));
%         Force.('FP'+string(num))(:,2) = str2double(Data((Ref_Dev+5):Ref_Cut_Force-1,Ref_Force(num)+1));
%         Force.('FP'+string(num))(:,3) = str2double(Data((Ref_Dev+5):Ref_Cut_Force-1,Ref_Force(num)+2));
% 
%     end
% 
% end
% 
% if sum(contains(Data(Ref_Dev+3,:),'Fx'))==1
% 
%     Force.Fx = str2double(Data((Ref_Dev+5):Ref_Cut_Force-1,Ref_Force(1)));
%     Force.Fy = str2double(Data((Ref_Dev+5):Ref_Cut_Force-1,Ref_Force(1)+1));
%     Force.Fz = str2double(Data((Ref_Dev+5):Ref_Cut_Force-1,Ref_Force(1)+2));
% 
% end
% 
% % check if the Force values are empty, if it's true delete the struct
% % if any( structfun(@isempty, Force)) == 1
% %     clear Force;
% % end
%% Markers data and labels
if (isempty(Ref_Mrk) == false && nargout > 3) %just check, if there are not marker data, skip

    Labels.Markers = Data(Ref_Mrk+2,:);
    position = find(~cellfun(@isempty,Labels.Markers));

    Labels.Markers = Labels.Markers(~cellfun('isempty',Labels.Markers));
    Labels.Markers = split(Labels.Markers,':');
    
    Subject = Labels.Markers(1,1,1);
    Labels.Markers = Labels.Markers(:,:,2);     %<-- delete subject name

    for k=1:length(Labels.Markers)

        if(~isvarname(Labels.Markers{k})) %check whether the field name is not a valid for the struct
            Labels.Markers{k} = "Var_" + string(k); %strtrim(Labels.Markers{k}); %add "Var_" so fix the problem of field name
        end
        %(1:3) because x,y,z
        Markers.(Labels.Markers{k})(:,1:3) = str2double(Data((Ref_Mrk+5):end,(position(k) : position(k)+2)));  

    end

    varargout{4} = Markers;

else
    varargout{4} = [];
end

waitbar(0.8,w,'Importing Model Output(s)...');

%% ModelOutputs data and Labels

if (isempty(Ref_MOut) == false && nargout > 4) %just check, if there are not ModelOutputs data, skip
   
    Labels.ModelOutputs = Data(Ref_MOut+2,:); %<-- +2 xkè a +3 ci sono x,y,z,tx etc.;
    Labels.ModelOutputs = regexprep(Labels.ModelOutputs,[Subject ':'],'');
    position = find(~cellfun(@isempty,Labels.ModelOutputs));
    Labels.ModelOutputs =  Labels.ModelOutputs(~cellfun('isempty',Labels.ModelOutputs));
    Labels.ModelOutputs = unique(Labels.ModelOutputs);

    for k = 1: length(Labels.ModelOutputs)

        if k == length(Labels.ModelOutputs)           

           ModelOutputs.(Labels.ModelOutputs{k}) = str2double(Data(Ref_MOut+5:Ref_Mrk-1,(position(k) : end) )  );
        else
           ModelOutputs.(Labels.ModelOutputs{k}) = str2double(Data(Ref_MOut+5:Ref_Mrk-1,(position(k) : position(k+1)-1) )  );
        end
    end

    
    varargout{5} = ModelOutputs;
else
    varargout{5} = [];
end

waitbar(1,w,'Finishing');
pause(0.25)
close(w)
%% Outputs

% 
% If you don't even have any Frequency or Label it means it was an empty
% or non Vicon file
varargout{1} = Frequency;
varargout{2} = Labels;
% 
% if (isempty(Ref_Force))
%     varargout{6} = [];
% else
%     varargout{6} = Force;
% end
