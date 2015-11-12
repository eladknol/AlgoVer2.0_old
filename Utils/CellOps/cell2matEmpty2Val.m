function [ mat_data ] = cell2matEmpty2Val( cell_data, val )
%cell2matEmpty2Val transforms cell data into mat, replacing empty cells
%with val
% Inputs - cell_data - cell data
%          val - value to be placed in empty cells
% Outputs - mat_data - data in mat format 

emptyIndex = cellfun(@isempty,cell_data); %# Find indices of empty cells
cell_data(emptyIndex) = {val};    
mat_data=cell2mat(cell_data);

end

