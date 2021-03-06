classdef nbt_spiderplot < nbt_PairedStat
    properties
    end
    
    methods
%         function obj = nbt_ttest(obj)
%             obj.testOptions.tail = 'both';
%         end        
        
        function obj = calculate(obj, StudyObj)
            %Get data
            
            n_groups = length(obj.groups);
            
            for j=1:n_groups
                
                Data_groups{j} = StudyObj.groups{obj.groups(j)}.getData({obj,j}); 
                
            end
            
%             %Perform test
%             sigBios = 0;
%             ccBios = 0;
%             qBios = 0;
            
            for bID=1:size(Data_groups{1}.dataStore,1)
                switch (obj.group{1}.classes{bID})
                    case 'nbt_SignalBiomarker' 
                      
                        disp(['Spider plot supported only for questionnaire data']);
                        
                    case 'nbt_CrossChannelBiomarker'
                      
                        disp(['Spider plot supported only for questionnaire data']);
                       
                    case 'nbt_QBiomarker'
                       % qBios = qBios + 1;
                        
                        sig_dim = [];

                        error_measure = 'CI'; % ask in query
                        %error_measure = 'SD';
                        %error_measure = 'SEM';

                        % n_groups = size(StudyObj.groups,1);

                        for i = 1:n_groups
                            conditions{i} = char(StudyObj.groups{obj.groups(i),1}.groupName);
                        end

                        data = [];
                        
                        for i = 1:n_groups
                            
                            data_group = Data_groups{i};
                            
                            if strcmp(obj.group{1}.biomarkers,'NBTe_nbt_ARSQ')
                                data_group = computeFactors(data_group{bID,1});
                            end
                            
                            data_all_groups{i} = data_group;
% 
%                             dat_name = strcat('Data',num2str(i));  
%                             data_group = eval([dat_name '{bID, 1}']); % n_answers x n_subjects
% 
%                             data_group_factors = computeFactors(data_group);
%
%                             data_all_groups{i} = data_group_factors;

                            if strcmp(error_measure,'SEM')    
                                mean_group = nanmean(data_group);
                                int_group = nanstd(data_group)/sqrt(length(data_group));

                            elseif strcmp(error_measure,'SD')
                                mean_group = nanmean(data_group);
                                int_group = nanstd(data_group);

                            elseif strcmp(error_measure,'CI') %% 95% conf int
                                mean_group = nanmean(data_group);
                                int_group = nanstd(data_group)/sqrt(length(data_group))*1.96;

                            end

                            data = [data (mean_group-int_group)' mean_group' (mean_group+int_group)'];

                        end

                        %% find significant dimensions

                        if n_groups == 2
                        %      [h p] = ranksum(data_all_groups{1},data_all_groups{2});
                        %      sig_dim = find(h==1);
                            gr1 = data_all_groups{1};
                            gr2 = data_all_groups{2};
                            for j=1:size(gr1,2)
                                [p h] = ranksum(gr1(:,j),gr2(:,j));
                                sig_dim(j) = h;
                            end
                        else
                            % p = kruskalwallis()
                        end
                        
                        if strcmp(obj.group{1}.biomarkers,'NBTe_nbt_ARSQ')
                            bioms_name = 'ARSQ';
                            load Factors
                            dimension_names = Factors.factorLabels;
                        else
                            bioms_name = char(obj.group{1}.biomarkers);
                            bioms_name = bioms_name(10:end);
                            dimension_names = []; % ?????
                        end
                         
                        spider_plot(data, bioms_name,[0 5], dimension_names, conditions, sig_dim) 
                        
            %            [D1, D2]=nbt_MatchVectors(Data1{bID,1}, Data2{bID,1}, getSubjectList(Data1,bID), getSubjectList(Data2,bID), 0, 0);
                     %   [~, obj.qPValues(:,qBios)] = ttest(Data1{bID,1}',Data2{bID,1}','tail',  obj.testOptions.tail);
                end
                %[~, obj.qPValues(:,qBios), ~, obj.statStruct{bID,1}] = ttest(D1',D2','tail',  obj.testOptions.tail);
                
            end
            %options
            
        end
    end
    
end


