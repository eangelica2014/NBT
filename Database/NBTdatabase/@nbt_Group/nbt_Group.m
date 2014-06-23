classdef nbt_Group %NBT GroupObject - contain group definitions + Database pointers.
    properties
        DatabaseType %e.g. NBTelement, File
        DatabaseLocation %path to files 
        ProjectID %
        SubjectID
        Age
        Gender
        ConditionID
        Biomarker
        FreqBand
        Parameters %for additional search parameters.
    end
    
    methods (Access = public)
        function GrpObj = nbt_Group %object contructor
            GrpObj.DatabaseType = 'NBTelement';
        end
                
        nbt_DataObject = getData(nbt_GroupObject, Parameters) %Returns a nbt_Data Object based on the GroupObject and additional parameters
        
        InfoCell = getInfo(nbt_GroupObject) %Returns a cell with information about the database.
    end 
    
    methods (Static = true)
        nbt_GroupObject = defineGroup %Returns a group object based on selections (e.g., from the GUI) 
    end
end

