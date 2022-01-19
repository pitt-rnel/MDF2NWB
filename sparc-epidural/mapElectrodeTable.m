function table = mapElectrodeTable(grant)
% mapElectrodeTable Maps the MDF grant object to a NWB electrode table
%
% Maps the MDF grant object to a NWB electrode table
%
% Args:
%   grant: MDF grant object
% 
% Returns:
%   table: Created NWB electrode table
%

elecParams = {'id', 'location'};
elecTbl = cell2table(cell(0, length(elecParams)), 'VariableNames', elecParams);
timestamps = [];
data = [];

trial = grant.subjects(1).trials(1);

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

table = util.table2nwb(elecTbl, 'all electrodes');

end

