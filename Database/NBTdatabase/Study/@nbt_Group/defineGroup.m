%The method defines new groups. If called with empty input the
%defineGroupGUI is called.
function GrpObj = defineGroup(GrpObj)
GUIswitch = 0;

if(isempty(GrpObj))
    GrpObj = nbt_Group;
    GUIswitch = 1;
end
%First we load information about the content of the database
[InfoCell, BioCell, IdentCell] = getSubjectInfo(GrpObj);

%next we transform the InfoCell numbers into strings
for i=1:size(InfoCell,1)
    if(isnumeric(InfoCell{i,2}))
        for m = 1:length(InfoCell{i,2})
            tmp{1,m} = num2str(InfoCell{i,2}(m));
        end
        InfoCell{i,2} = tmp;
        clear tmp;
    end
end


% in case of the GUI
if(GUIswitch)
    GrpObj = defineSubjectGroupGUI(GrpObj, InfoCell, BioCell, IdentCell);
else
    % command line
    idxNr = 0;
    disp('Parameters:')
    for i=1:size(InfoCell,1)
        disp([ int2str(i) ':' InfoCell{i,1} ])
    end
    
    idxList = input('Please select parameters above ');
    
    for i=1:length(idxList)
        disp(InfoCell{idxList(i),1});
        disp('Labels:')
        for mm=1:size(InfoCell{idxList(i),2},2)
            disp([int2str(mm) ':' InfoCell{idxList(i),2}{1,mm}])
        end
        idxLabels = input('Please select labels above ');
        eval(['GrpObj.parameters.' InfoCell{idxList(i),1} ' = [];']);
        for j = 1:length(idxLabels)
            eval(['GrpObj.parameters.' InfoCell{idxList(i),1} ' = [GrpObj.parameters.' InfoCell{idxList(i),1} '; InfoCell{idxList(i),2}{1,idxLabels(j)}];']);
        end
    end
    GrpObj.biomarkerList = BioCell;
    GrpObj.identList = IdentCell;
    GrpObj.groupName = input('Group name? ','s');
end
end