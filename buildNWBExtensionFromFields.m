function [exts, extName] = buildNWBExtensionFromFields(obj, objName, exts)

if ~exist('exts', 'var')
    exts = struct('neurodata_type_def', cell(0,0), ...
                  'neurodata_type_inc', cell(0,0), ...
                  'doc', '', ...
                  'attributes', cell(0,0), ...
                  'groups', cell(0,0));
end

extName = getExtensionName(objName);

fieldNames = fieldnames(obj);
if ~isempty(fieldNames)
    numFields = length(fieldNames);
    
    attrs = struct('name', cell(1, numFields), ...
                   'doc', cell(1, numFields), ...
                   'dtype', cell(1, numFields), ...
                   'required', false);
    groups = struct('name', cell(1, numFields), ...
                    'neurodata_type_inc', cell(1, numFields));
    
    for i = 1:numFields
        fieldName = fieldNames{i};
        fieldValue = obj.(fieldName);
        
        if isa(fieldValue, 'struct') || isa(fieldValue, 'mdfObj')
            [exts, type] = buildNWBExtensionFromFields(fieldValue, fieldName, exts);
            groups(i).name = fieldName;
            groups(i).neurodata_type_inc = type;
        else
            attrs(i).name = fieldName;
            attrs(i).doc = fieldName;
            if isa(fieldValue, 'char')
                attrs(i).dtype = 'text';
            elseif isa(fieldValue, 'numeric')
                attrs(i).dtype = 'numeric';
            elseif isa(fieldValue, 'cell')
                attrs(i).dtype = 'text';
            end
        end
    end
    
    % Prune attrs and groups
    prunedAttrs = attrs(~cellfun('isempty', {attrs.name}));
    prunedGroups = groups(~cellfun('isempty', {groups.name}));
    
    ext = struct('neurodata_type_def', extName, ...
                 'doc', extName, ...
                 'neurodata_type_inc', 'LabMetaData', ...
                 'attributes', struct, ...
                 'groups', struct);
    
    if ~isempty(prunedAttrs)
        ext.attributes = prunedAttrs;
    end
    
    if ~isempty(prunedGroups)
        ext.groups = prunedGroups;
    end
    
    exts(length(exts)+1) = ext;
end
