function nwbFile = exportToNWB(mdfObj, configFile)

try
    configStruct = ReadYaml(configFile);
catch ME
    error(['Unable to read config file: ' ME])
end

if ~isfield(configStruct, 'description')
    error('Config file must contain a description section')
end

if ~isfield(configStruct, 'map')
    error('Config file must contain a map section')
end

configDescription = configStruct.description;

if ~isfield(configDescription, 'filename')
    error('Config file must contain a filename')
end

nwbFilename = configDescription.filename;
if ~endsWith(nwbFilename, '.nwb')
    nwbFilename = [nwbFilename '.nwb'];
end

nwbMap = containers.Map();
configMap = configStruct.map;
for i = 1:length(configMap)
    map = configMap{i};
    
    if isfield(map, 'properties')
        % Class is declared using the properties syntax
        props = map.properties;
        propFields = fields(props);
        
        nwbObj = feval(map.name);
        for j = 1:length(propFields)
            propName = propFields{j};
            propValue = props.(propName);
            
            captGroups = regexp(propValue, '^\$lambda -> (.+)$', 'tokens');
            if ~isempty(captGroups)
                funcStr = ['@(mdfRoot) ' captGroups{1}{1}];
                anonFunc = str2func(funcStr);
                nwbObj.(propName) = feval(anonFunc, mdfObj);
                continue;
            end
            
            captGroups = regexp(propValue, '^\$lambda ([a-zA-Z0-9]+) -> (.+)$', 'tokens');
            if ~isempty(captGroups)
                funcStr = ['@(' captGroups{1}{1} ') ' captGroups{1}{2}];
                anonFunc = str2func(funcStr);
                nwbObj.(propName) = feval(anonFunc, mdfObj);
                continue;
            end
            
            captGroups = regexp(propValue, '^\$func -> (.+)$', 'tokens');
            if ~isempty(captGroups)
                funcStr = captGroups{1}{1};
                anonFunc = str2func(funcStr);
                nwbObj.(propName) = feval(anonFunc, mdfObj);
                continue;
            end

        end
        nwbMap(map.type) = nwbObj;
        
    elseif isfield(map, 'func')
        % Class is declared using the func syntax
        
        nonIterableTypes = {'types.core.NWBFile', 'types.core.Subject'};
        
        if ~isfield(map, 'iterations')
            map.iterations = 1;
        end
        
        if ~exist('lazyMaps', 'var')
            lazyMaps = map;
        else
            lazyMaps(length(lazyMaps) + 1) = map;
        end
    end
end

if isKey(nwbMap, 'types.core.NWBFile')
    nwbFile = nwbMap('types.core.NWBFile');
else
    error('Config file must contain a ''types.core.NWBFile'' type')
end

if isKey(nwbMap, 'types.core.Subject')
    nwbFile.general_subject = nwbMap('types.core.Subject');
end

if exist('lazyMaps', 'var') && ~isempty(lazyMaps)
    
    for i = 1:length(lazyMaps)
        lazyMap = lazyMaps(i);
        propertyName = lazyMap.property;
        func = str2func(lazyMap.func);
        for j = 1:lazyMap.iterations
            [resultName, result] = feval(func, mdfObj, j);
            nwbFile.(propertyName).set(resultName, result);
            nwbExport(nwbFile, nwbFilename);
            nwbFile = nwbRead(nwbFilename);
        end
    end
end

end