function nwbMdfObj = exportToMDF(nwbObj, fileLocation)
% exportToMDF Converts a NWB file object to a MDF object
%
% Converts a NWB file object to a MDF object with fields and children
% cooresponding to the NWB file fields
%
% Args:
%   nwbObj: NWB file object
%   fileLocation: Location where MDF will store data files
% 
% Returns:
%   nwbMdfObj: The created MDF object
%

nwbType = class(nwbObj);
nwbMdfObj = mdfObj(nwbType);
nwbMdfObj.setFiles(fileLocation);

nwbProps = properties(nwbObj);

for i = 1:length(nwbProps)
    prop = nwbProps{i};
    value = nwbObj.(prop);
    
    if isa(value, 'types.untyped.Set')
        keys = value.keys;
        if isempty(keys)
            continue;
        end
        
        for j = 1:length(keys)
            setKey = keys{j};
            setValue = value.get(setKey);
            
            createdObj = nwbObjToMDFObj(setValue);
            createdObj.setFiles(fileLocation);
            mdf.addParentChildRelation(nwbMdfObj, createdObj, prop);
            createdObj.save();
        end
        
        clear keys setKey setValue createdObj j;
        
    elseif isa(value, 'types.core.Subject')
        createdObj = nwbObjToMDFObj(value);
        createdObj.setFiles(fileLocation);
        mdf.addParentChildRelation(nwbMdfObj, createdObj, prop);
        createdObj.save();
        
        clear createdObj;
    else        
        if isempty(value)
            continue;
        end
        
        if isa(value, 'types.hdmf_common.DynamicTable')
            value = dynamicTableToStruct(value);
        end
        
        if isa(value, 'types.hdmf_common.DynamicTableRegion')
            continue;
        end
        
        % Load data stub into data
        if isa(value, 'types.untyped.DataStub')
            value = value.load();
            nwbMdfObj.d.(prop) = value;
            continue;
        end
        
        if isa(value, 'datetime')
            value = datestr(value, 'yyyy-MM-dd''T''HH:mm:ss');
        end
        
        % Add to metadata
        nwbMdfObj.md.(prop) = value;        
    end
    
    clear prop value;
end

nwbMdfObj.save();

end

