%ref see: Hjorth 1970, EEG ANALYSIS BASED ON TIME DOMAIN PROPERTIES. 
classdef nbt_hjorthpara < nbt_SignalBiomarker

   properties
       activity
       mobility
       complexity
   end
   methods 
       function BiomarkerObject=nbt_hjorthpara(NumChannels)
           BiomarkerObject.activity = nan(NumChannels,1);
           BiomarkerObject.mobility = nan(NumChannels,1);
           BiomarkerObject.complexity = nan(NumChannels,1);
           BiomarkerObject.primaryBiomarker = 'activtiy';
           BiomarkerObject.biomarkers = {'activity', 'mobility', 'complexity'};
           BiomarkerObject.biomarkerType = {'nbt_SignalBiomarker', 'nbt_SignalBiomarker', 'nbt_SignalBiomarker'};
       end
   end
end 
