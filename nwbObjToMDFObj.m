function nwbMdfObj = nwbObjToMDFObj(nwbObj)

nwbType = class(nwbObj);
nwbMdfObj = mdfObj(nwbType);

nwbProps = properties(nwbObj);

for i = 1:length(nwbProps)
    prop = nwbProps{i};
    
    value = nwbObj.(prop);
    if isempty(value)
        continue;
    end
    
    if isa(value, 'types.hdmf_common.DynamicTable')
        value = dynamicTableToStruct(value);
    end
    
    if isa(value, 'types.hdmf_common.DynamicTableRegion')
        continue;
    end
    
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

end

