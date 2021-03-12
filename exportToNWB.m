function nwbObj = exportToNWB(mdfObj, namespace, extPath)

if ~exist('extPath', 'var')
    extPath = '.';
end

%% Generate 
[nsFile, extFile] = generateNWBExtension(mdfObj, namespace, extPath);
generateExtension(nsFile);

metaObj = mdfObj.metadata;
metaNwbObj = generateNWBObj(metaObj, mdfObj.type, namespace);

% Just return the meta object for now
nwbObj = metaNwbObj;
