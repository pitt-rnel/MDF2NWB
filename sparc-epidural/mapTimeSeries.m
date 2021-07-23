function [name, series] = mapTimeSeries(grant, iterNum)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

elecParams = {'id', 'location'};
elecTbl = cell2table(cell(0, length(elecParams)), 'VariableNames', elecParams);
timestamps = [];
data = [];

trial = grant.subjects(1).trials(iterNum);

% Each eng data element is a different location with 2 electrodes
for j = 1:length(trial.engData)

    % Set timestamps if it's no populated yet
    if isempty(timestamps)
        timestamps = trial.engData(j).time;
    end

    % Populate the electrode table
    for k = 1:length(trial.engData(j).channel)
        elecTbl = [elecTbl; {trial.engData(j).channel(k), trial.engData(j).location}]; % {id, location}
    end

    % Data rows correspond to the electrode table
    data = [data; trial.engData(j).wf];
end

electrodesObjectView = types.untyped.ObjectView('/general/extracellular_ephys/electrodes');

electrodeTableRegion = types.hdmf_common.DynamicTableRegion( ...
    'table', electrodesObjectView, ...
    'description', 'all electrodes', ...
    'data', (0:height(elecTbl)-1)' ...
);

% Time series
wfSeries = types.ndx_rnel.ElectricalStimSeries( ...
    'timestamps', timestamps, ...
    'data', data, ...
    'data_unit', 'volts', ... % TODO: Get actual units
    'electrodes', electrodeTableRegion, ...
    'starting_time_rate', trial.engData(j).fs, ...
    'comments', 'Data row indices correspond to electrode indices', ...
    'stim_location', trial.stimLocation.location, ...
    'stim_description', trial.stimLocation.description, ...
    'stim_times', 1:25 ... % Can't find actual stim times in mdf
);

name = ['Trial ' num2str(iterNum)];
series = wfSeries;
end

