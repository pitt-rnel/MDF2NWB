function nwbMdfObj = nwbObjToMDFObj(nwbObj)
% nwbObjToMDFObj Converts a NWB object to a MDF object
%
% Converts a NWB object to a MDF compatible matlab equivalent
% Args:
%   nwbObj: NWB object to be converted
%
% Returns:
%   nwbMdfObj: The created MDF object
%

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

