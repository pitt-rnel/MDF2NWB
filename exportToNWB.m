function exportToNWB(grant)
%EXPORTTONWB Export a grant MDF object to NWB files
%   Each trial is exported as a separate NWB file

% for i = 1:length(grant.subjects(1).trials)
for i = 1:2
    subject = types.core.Subject( ...
        'subject_id', num2str(grant.subjects(1).subjectId), ...
        'age', [grant.subjects(1).age ' ' grant.subjects(1).age_units], ... % TODO: Recommends specific format
        'description', [grant.subjects(1).name ', ' grant.subjects(1).name ' ' ], ...
        'species', 'Cat', ... % TODO: Recommends latin name?
        'sex', grant.subjects(1).sex);
    
    % Create Nwb file
    nwb = NwbFile( ...
        'session_description', grant.description.description, ... % Data description
        'identifier', grant.subjects(1).trials(i).uuid, ... % Trial id
        'session_start_time', datetime(grant.subjects(1).trials(i).absoluteStartTime, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss,SSSSSSSSSXXX', 'TimeZone', 'America/New_York'), ... % Trial start time
        'general_session_id', grant.subjects(1).uuid, ... % Session/Subject id
        'general_institution', 'University of Pittsburgh', ... % Institution (Is this in MDF?)
        'general_lab', 'Research Neural Engineering Lab', ... % Lab info (Is this in MDF?)
        'general_experiment_description', grant.description.description, ... % Data description
        'general_notes', grant.subjects(1).curation.fixes.stim_pulse_width_anode.notes, ... % Trial notes
        'general_protocol', ['IACUC ' grant.subjects(1).IACUC], ... % IACUC number
        'general_keywords', strjoin(grant.description.keywords, ','), ... % IACUC keywords
        'general_subject', subject);
    
    % Initialize the electrode table and data
    elecParams = {'id', 'location'};
    elecTbl = cell2table(cell(0, length(elecParams)), 'VariableNames', elecParams);
    timestamps = [];
    data = [];
    
    % Each eng data element is a different location with 2 electrodes
    for j = 1:length(grant.subjects(1).trials(1).engData)
	
		% Set timestamps if it's no populated yet
        if isempty(timestamps)
            timestamps = grant.subjects(1).trials(i).engData(j).time;
        end
        
        % Populate the electrode table
        for k = 1:length(grant.subjects(1).trials(i).engData(j).channel)
            elecTbl = [elecTbl; {grant.subjects(1).trials(i).engData(j).channel(k), grant.subjects(1).trials(i).engData(j).location}]; % {id, location}
        end
        
		% Data rows correspond to the electrode table
        data = [data; grant.subjects(1).trials(i).engData(j).wf];
    end
        
    electrodesObjectView = types.untyped.ObjectView( ...
        '/general/extracellular_ephys/electrodes');
    electrodeTableRegion = types.hdmf_common.DynamicTableRegion( ...
        'table', electrodesObjectView, ...
        'description', 'all electrodes', ...
        'data', (0:height(elecTbl)-1)');
    
    wfSeries = types.core.ElectricalSeries( ...
        'timestamps', timestamps, ...
        'data', data, ...
        'data_unit', 'volts', ... % TODO: Get actual units
        'electrodes', electrodeTableRegion, ...
        'starting_time_rate', grant.subjects(1).trials(i).engData(j).fs ...
        );
    
    nwb.general_extracellular_ephys_electrodes = util.table2nwb(elecTbl, 'all electrodes');
    nwb.acquisition.set('WFSeries', wfSeries);
    
    nwbExport(nwb, ['subject_' grant.subjects(1).subjectId '_trial_' grant.subjects(1).trials(i).uuid '.nwb']);
end

