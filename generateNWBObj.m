function nwbObj = generateNWBObj(obj, name, namespace)

nwbObjName = getExtensionName(name);
nsType = ['types.' strrep(namespace, '-', '_')];

nwbObj = eval([nsType '.' nwbObjName]);

fieldNames = fieldnames(obj);
if ~isempty(fieldNames)
    numFields = length(fieldNames);
    
    for i = 1:numFields
        fieldName = fieldNames{i};
        fieldValue = obj.(fieldName);
        
        if isa(fieldValue, 'struct') || isa(fieldValue, 'mdfObj')
            nwbObj.(fieldName) = generateNWBObj(fieldValue, fieldName, namespace);
        elseif isa(fieldValue, 'cell')
            nwbObj.(fieldName) = [fieldValue{:}];
        else
            nwbObj.(fieldName) = fieldValue;
        end
    end
end
