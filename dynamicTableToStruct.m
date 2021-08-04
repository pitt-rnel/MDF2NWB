function outStruct = dynamicTableToStruct(dt)

outStruct = struct('description', dt.description);

ids = num2cell(dt.id.data.load());

colDescriptionStruct = struct();
dataStruct = struct('id', ids);

colNames = dt.colnames;
numCols = length(colNames);

for i = 1:numCols
    colName = colNames{i};
    
    if strcmp(colName, 'id')
       continue; 
    end
    
    colVectorSet = dt.vectordata.get(colName);
    colDescriptionStruct.(colName) = colVectorSet.description;

    colData = colVectorSet.data.load();
    [dataStruct.(colName)] = colData{:};
end

outStruct.columnDescriptions = colDescriptionStruct;
outStruct.data = dataStruct;

end

