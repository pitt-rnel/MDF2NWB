# MDF2NWB

MDF2NWB is a proof of concept, experimental tool for converting Multipurpose Data Framework (MDF) formats to Neurodata Without Borders (NWB) formats and vice versa.

## Requirements
- [mdf](https://github.com/pitt-rnel/mdf)
- [matnwb](https://github.com/NeurodataWithoutBorders/matnwb)

## Exporting from MDF to NWB
``` matlab
% Make sure mdf2nwb is the current directory

grant = mdf.load('Replace with UUID of root Grant object');
nwbFile = exportToNWB(grant, './sparc-epidural/map.yaml');
```

## Exporting from NWB to MDF
``` matlab
% Make sure mdf2nwb is the current directory
% Make sure sparc-epidural-alexanderkeith.nwb is in the current directory
% Make sure the directory MDFdatafile exists in the current directory

nwbFile = nwbRead('./sparc-epidural-alexanderkeith.nwb');
mdfObj = exportToMDF(nwbFile, './MDFdatafile')
```