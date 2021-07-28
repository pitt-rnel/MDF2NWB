function nwbMdfObj = exportToMDF(nwb)

%% NWBFile

nwbMdfObj = mdfObj('NWB');
nwbMdfObj.setFiles('<DATA_BASE>/test/nwb');

% contributors
for i = 1:8
    contributor = nwb.general.get('GrantMetaData').contributors.vectordata.get(['Contributor ' num2str(i)]).data.load();
    contributors(i).name = contributor{1};
    contributors(i).affiliation = contributor{2};
    contributors(i).is_contact_person = contributor{3};
    contributors(i).role = contributor{4};
    contributors(i).orcid_id = contributor{5};
end
nwbMdfObj.md.contributors = contributors;

% experiment_description
nwbMdfObj.md.experiment_description = nwb.general_experiment_description;

% institution
nwbMdfObj.md.institution = nwb.general_institution;

% keywords
keywords = nwb.general_keywords.load();
nwbMdfObj.md.keywords = strsplit(keywords, ', ');

% lab
nwbMdfObj.md.lab = nwb.general_lab;

% protocol
nwbMdfObj.md.protocol = nwb.general_protocol;

% identifier
nwbMdfObj.md.identifier = nwb.identifier;

% timestamps_reference_time
nwbMdfObj.md.timestamps_reference_time = datestr(nwb.timestamps_reference_time, 'yyyy-MM-dd''T''HH:mm:ss');

%% Subject

subject = mdfObj('Subject');
subject.setFiles('<DATA_BASE>/test/nwb');
subject.md.age = nwb.general_subject.age;
subject.md.session_id = nwb.general_session_id;
subject.md.notes = nwb.general_notes;
subject.md.session_description = nwb.session_description;
subject.md.session_start_time = datestr(nwb.session_start_time, 'yyyy-MM-dd''T''HH:mm:ss');
subject.md.date_of_birth = datestr(nwb.general_subject.date_of_birth, 'yyyy-MM-dd''T''HH:mm:ss');
subject.md.description = nwb.general_subject.description;
subject.md.sex = nwb.general_subject.sex;
subject.md.species = nwb.general_subject.species;
subject.md.subject_id = nwb.general_subject.subject_id;
subject.md.weight = nwb.general_subject.weight;

mdf.addParentChildRelation(nwbMdfObj, subject, 'subjects')
nwbMdfObj.save()
subject.save()

%% Trials
elecIds = nwb.general_extracellular_ephys_electrodes.id.data.load();
elecLocs = nwb.general_extracellular_ephys_electrodes.vectordata.get('location').data.load();
for i = 1:5
    nwbTrial = nwb.acquisition.get(['Trial ' num2str(i)]);
    
    trial = mdfObj('Trial');
    trial.setFiles('<DATA_BASE>/test/nwb');
    trial.md.stim_description = nwbTrial.stim_description;
    trial.md.stim_location = nwbTrial.stim_location;
    trial.md.comments = nwbTrial.comments;
    trial.md.data_unit = nwbTrial.data_unit;
    
    trial.d.timestamps = nwbTrial.timestamps.load();
    trial.d.stim_times = nwbTrial.stim_times.load();
    
    trialData = nwbTrial.data.load();
    [numElecs, ~] = size(trialData);
    for j = 1:numElecs
        elec = mdfObj('Electrode');
        elec.setFiles('<DATA_BASE>/test/nwb');
        elec.md.id = elecIds(j);
        elec.md.location = elecLocs{j};
        elec.d.eng = trialData(j, :)';
        mdf.addParentChildRelation(trial, elec, 'electrodes')
        elec.save();
    end
    
    mdf.addParentChildRelation(subject, trial, 'trials')
    trial.save();
end
subject.save()
nwbMdfObj.save()

end

