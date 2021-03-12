function [nsFile, extFile] = generateNWBExtension(mdfObj, namespace, extDir)

if ~exist(extDir, 'dir')
    mkdir(extDir)
end

%% Build and write metadata extension files
[exts, ~] = buildNWBExtensionFromFields(mdfObj.metadata, mdfObj.type);

f = struct('groups', exts);
extname = [namespace '-extension.yaml'];
extpath = fullfile(extDir, extname);
WriteYaml(extpath, f);

extFile = extpath;

%% Build and write namespace file
namespaces = struct();
namespaces.author = {'Tyler Madonna'};
namespaces.contact = {'tjm159@pitt.edu'};
namespaces.doc = 'for storing metadata for RNEL';
namespaces.name = namespace;
namespaces.schema = {struct('namespace', 'core', ...
    'neurodata_types', {'LabMetaData'}), ...
    struct('source', extname)};
namespaces.version = '0.1.0';

f = struct();
f.namespaces = {namespaces};

nsname = [namespace '-namespace.yaml'];
nspath = fullfile(extDir, nsname);
WriteYaml(nspath, f);

nsFile = nspath;
