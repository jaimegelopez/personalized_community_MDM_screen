% This script takes in results from GNPS and check whether the parent
% molecule and the putative metabolite are linked

%% Import unique untargeted metabolites and parent compounds
clear;clc

mass_cutoff = 0.02;
rt_cutoff = 1;

target_compounds = readtable('targeted_compounds.csv','ReadRowNames',true);

load('novel_untargeted_metabolomics_table.mat');

drug_list = unique(unique_table.drug);

%Add new rows for analysis
col_list = {'link','metabolite_present','drug_present'};
unique_table{:,col_list} = ...
    nan(size(unique_table,1),length(col_list));

% Match drugs to metabolites and check for links
for i = 1:length(drug_list)
    drug = drug_list{i};
    drug_properties = target_compounds{drug,{'product_ion','RT'}};
    
    filename = ['GNPS_analysis/GNPS_results/',drug,'_1000','.txt'];
    drug_metabolite_index = find(contains(unique_table.drug,drug));
    GNPS_results = readtable(filename);
    
    for k = 1:length(drug_metabolite_index)
        metabolite_properties = unique_table{drug_metabolite_index(k),{'mz','RT'}};
        
        [link,metabolite_present,drug_present] = ...
            check_metabolite_relatedness(drug_properties,...
            metabolite_properties,GNPS_results,mass_cutoff,rt_cutoff);
        
        unique_table{drug_metabolite_index(k),'link'} = link;
        unique_table{drug_metabolite_index(k),'metabolite_present'} = metabolite_present;
        unique_table{drug_metabolite_index(k),'drug_present'} = drug_present;
    end
end




%% Export table with reformatted donor numbers
new_donors = arrayfun(@(x) num2str(x{1}'),unique_table.donors,'UniformOutput',false);

export_table = unique_table;
export_table.donors = new_donors;
export_table.mass_diff = export_table.mz - export_table.drug_mz;
writetable(export_table,'unique_metabolites_with_networking.csv',...
    'Delimiter',',','WriteVariableNames',true);
