%  Copyright (C) 2010: Simon-Shlomo Poil
function nbt_importGroupInfos(startpath)
if(~exist('startpath','var'))
    startpath = uigetdir(pwd,'Select folder with NBT analysis files');
end

%SubjectInfo properties
%projectInfo
%researcherID
%subjectID
%conditionID
%lastUpdate
%listOfBiomarkers

% load('NBTelementBase.mat')
%NBTelement structure

Project = nbt_NBTelement(1,'1',[]);
Subject = nbt_NBTelement(2, '2.1',1);
Condition = nbt_NBTelement(3,'3.2.1',2);

Project.Class = 'subjectInfo';
Subject.Class = 'subjectInfo';
Condition.Class = 'subjectInfo';
   
Signals = nbt_NBTelement(4,'4.3.2.1',3);
Signals.Identifier = true;
Signals.Class = 'Identifier';


% could include last Update

NextID = 5;

%determine tree
FileList = nbt_ExtractTree(startpath,'mat','analysis');
disp('Importing files');
for i=1:length(FileList)
    disp(FileList{1,i})
    
    %we first clear everything from the old file.
    s = whos;
    for ii=1:length(s)
        if(~strcmp(s(ii).class,'nbt_NBTelement') && ~strcmp(s(ii).name,'s') && ~strcmp(s(ii).name,'FileList') && ~strcmp(s(ii).name,'i') && ~strcmp(s(ii).name,'NextID'))
            clear([s(ii).name])
        end
    end
    
    
    load(FileList{1,i}) %load analysis file
    load([ FileList{1,i}(1:end-12) 'info.mat']) % load info file
    
    signalFields = nbt_extractSignals([ FileList{1,i}(1:end-12) 'info.mat']);
    subjectFields = fields(SubjectInfo.info);
    BiomarkerObjects=nbt_extractBiomarkers;
    SubjectInfo.listOfBiomarkers = BiomarkerObjects';
    subjectBiomarkerFields = SubjectInfo.listOfBiomarkers;
    
    for m=1:length(subjectFields)
        % create NBTelement, unless it exists
        NBTelementName = ['NBTe_' subjectFields{m}];
        eval(['NBTelementClass = class(SubjectInfo.info.' NBTelementName(6:end) ');']);
        eval(['NBTelementData = SubjectInfo.info.' NBTelementName(6:end) ';']);
        
        
        addflag = ~exist(NBTelementName,'var');
        if(addflag)
            eval([NBTelementName '= nbt_NBTelement(' int2str(NextID) ',''' int2str(NextID) '.3.2.1'', 3);']);
            eval([NBTelementName '.Class = NBTelementClass;']);
            NextID = NextID + 1;
        end
        
        Project = nbt_SetData(Project, {SubjectInfo.projectInfo(1:end-4)}, []);
        Subject = nbt_SetData(Subject, SubjectInfo.subjectID, {Project, SubjectInfo.projectInfo(1:end-4)});
        Condition = nbt_SetData(Condition, {SubjectInfo.conditionID}, {Subject, SubjectInfo.subjectID; Project, SubjectInfo.projectInfo(1:end-4)});
        
        if strcmp(NBTelementClass,'char')
            eval([NBTelementName '= nbt_SetData(' NBTelementName ', {NBTelementData}, {Condition, SubjectInfo.conditionID; Subject, SubjectInfo.subjectID; Project, SubjectInfo.projectInfo(1:end-4)});']);
        else
            eval([NBTelementName '= nbt_SetData(' NBTelementName ', NBTelementData, {Condition, SubjectInfo.conditionID; Subject, SubjectInfo.subjectID; Project, SubjectInfo.projectInfo(1:end-4)});']);
        end
        
    end
    
    for m = 1:length(subjectBiomarkerFields)
        %importing biomarkers not related to signals
        eval(['QB = ~isa(' subjectBiomarkerFields{m} ',' ''' nbt_QBiomarker' ''');']);
        if(QB)
            continue;
        end
        
        eval(['NBTelementName = [''NBTe_'' class(' subjectBiomarkerFields{m} ')];']);
         
        
        addflag = ~exist(NBTelementName,'var');
        if addflag
            eval([NBTelementName '= nbt_NBTelement(' int2str(NextID) ',''' int2str(NextID) '.3.2.1'', 3);'])
            eval([NBTelementName '.Class = ''nbt_QBiomarker'' ;']);
            NextID = NextID + 1;
        end
        %Create the Data cell
        
        eval(['NumBiomarkers = length(' subjectBiomarkerFields{m} '.biomarkers);']);
        if(NumBiomarkers ~=0)
            for dd = 1:NumBiomarkers
                eval( ['DataString = nbt_cellc(' subjectBiomarkerFields{m} '.biomarkers,dd);']);
                eval(['Data{dd,1} = ' subjectBiomarkerFields{m} '.' DataString ';']);
                eval([NBTelementName '.Biomarkers{ dd ,1} = DataString; '])
                
            end
            eval([NBTelementName ' = nbt_SetData(' NBTelementName ', Data, {Condition, SubjectInfo.conditionID; Subject, SubjectInfo.subjectID;Project, SubjectInfo.projectInfo(1:end-4)});']);
            
            clear Data
        end
    end
    
    
    for mm = 1:length(signalFields)
        Signals = nbt_SetData(Signals,{signalFields{mm}},{Condition, SubjectInfo.conditionID; Subject, SubjectInfo.subjectID; Project, SubjectInfo.projectInfo(1:end-4)});
        BiomarkerList = SubjectInfo.listOfBiomarkers;
        for m = 1:length(BiomarkerList)
        eval(['QB = isa(' BiomarkerList{m} ',' ''' nbt_QBiomarker' ''');']);
        if(QB)
            continue;
        end
            % create NBTelement, unless it exists
            eval(['NBTelementName = [''NBTe_'' class(' BiomarkerList{m} ')];']);
            NumIdentifiers  = eval([BiomarkerList{m} '.uniqueIdentifiers;']);
            
            connector = 'Signals';
            connectorKeys = 'Signals,signalFields{mm};Condition, SubjectInfo.conditionID; Subject, SubjectInfo.subjectID; Project, SubjectInfo.projectInfo(1:end-4)';
            for ni = 1:length(NumIdentifiers)    
                addflag = ~exist([NBTelementName '_' NumIdentifiers{ni}],'var');
                if(addflag)
                    newkey = eval(['[''' int2str(NextID) '.'' ' connector '.Key]']);
                    uplink = eval(['num2str(' connector '.ElementID);']);
                    eval([NBTelementName '_' NumIdentifiers{ni} '= nbt_NBTelement(' int2str(NextID) ',''' newkey ''',' uplink ');']); 
                    eval([NBTelementName '_' NumIdentifiers{ni} '.Identifier = true;']);
                    eval([NBTelementName '_' NumIdentifiers{ni} '.Class = ''Identifier'';']);
                    NextID = NextID + 1;
                end
                
                eval(['connector = ''' NBTelementName '_' NumIdentifiers{ni} ''';']);
                
                connectorValue = {num2str(eval([BiomarkerList{m} '.' NumIdentifiers{ni}]))};
                oldValue{ni} = num2str(eval([BiomarkerList{m} '.' NumIdentifiers{ni}]));
                
                newStuff = eval(['''' NBTelementName '_' NumIdentifiers{ni} ', oldValue{' num2str(ni) '}''']);
                
                    
                eval([NBTelementName '_' NumIdentifiers{ni} '= nbt_SetData(' NBTelementName '_' NumIdentifiers{ni} ', connectorValue ,{' connectorKeys '});']);
                
                
                connectorKeys = [newStuff, ';' ,  connectorKeys];
                
            end
            
            
            ky = eval([connector '.Key']);
            kid = eval([connector '.ElementID']); 
            addflag = ~exist(NBTelementName,'var');
            if(addflag)
                eval([NBTelementName '= nbt_NBTelement(' int2str(NextID) ',''' int2str(NextID)  '.' ky '''  , ' num2str(kid) ');'])    
                superClass =  superclasses(NBTelementName(6:end));
                superClass = superClass{1};
                if strcmp(superClass,'nbt_CrossChannelBiomarker')
                    eval([NBTelementName '.Class = ''nbt_CrossChannelBiomarker'';']);
                else
                    if strcmp(superClass,'nbt_SignalBiomarker')
                        eval([NBTelementName '.Class = ''nbt_SignalBiomarker'';']);
                    else
                        disp([NBTelementName '.Class = ''unknown'';']);    
                        eval([NBTelementName '.Class = ''unknown'';']) ;        
                    end
                end
                NextID = NextID + 1;
            else  % then we just update the Key and Uplink
                eval([NBTelementName '.Key =' '[num2str(' NBTelementName '.ElementID' ') ''' '.' ky '''' '];' ])
                eval([NBTelementName '.Uplink = ' num2str(kid) ';'])
            end
            
            %Create the Data cell
            eval(['NumBiomarkers = length(' BiomarkerList{m} '.biomarkers);']);
            eval(['BiomarkerType = ' BiomarkerList{m} '.biomarkerType;']);
            
            if(NumBiomarkers ~=0)
                for dd = 1:NumBiomarkers
                    eval( ['DataString = nbt_cellc(' BiomarkerList{m} '.biomarkers,dd);']);
                    eval(['Data{dd,1} = ' BiomarkerList{m} '.' DataString ';']);
                    eval([NBTelementName '.Biomarkers{ dd ,1} = DataString; '])
                    eval([NBTelementName '.BiomarkerType{dd} = BiomarkerType{dd}; '])
                end
                
                eval([NBTelementName ' = nbt_SetData(' NBTelementName ', Data, {' connectorKeys '});']);
                
                
                clear Data
            end
        end
    end
end

s = whos;
for ii=1:length(s)
    if(~strcmp(s(ii).class,'nbt_NBTelement') && ~strcmp(s(ii).name,'s'))
        clear([s(ii).name])
    end
end
clear s
clear ii


save NBTelementBase.mat -v7.3
disp('NBTelements imported')
disp('NBTelementBase.mat saved in')
disp(pwd)
end