function [name, metadata] = mapGrantMetaData(grant, ~)
%mapGrantMetaData Function for mapping MDF bladder grant metadata to NWB GrantMetaData
%   Detailed explanation goes here

    curatedGrant = grant.curatedGrant;

    metadata = types.ndx_rnel.GrantMetaData;

    metadata.project_number = curatedGrant.projectNumber;
    metadata.fullname = curatedGrant.fullname;
    metadata.sparc_award_number = curatedGrant.submission.sparc_award_number;
    metadata.milestone_completion_date = curatedGrant.submission.milestone_completion_date;
    metadata.milestone_achieved = curatedGrant.submission.milestone_achieved;
    metadata.description = curatedGrant.dataset_description.description;
    metadata.subtitle = curatedGrant.dataset_description.subtitle;
    metadata.number_of_subjects = curatedGrant.dataset_description.number_of_subjects;
    metadata.protocol_url = curatedGrant.dataset_description.protocol_url;
    metadata.protocol_title = curatedGrant.dataset_description.protocol_title;
    metadata.funding = curatedGrant.dataset_description.funding;
    metadata.keywords = curatedGrant.dataset_description.keywords;
    metadata.name = curatedGrant.dataset_description.name;
    metadata.grant_uuid = curatedGrant.grantUuid;
    
    contributors = curatedGrant.dataset_description.contributors;
    contribLength = length(contributors);
    
    contributorsTable = types.ndx_rnel.ContributorsTable;
    contributorsTable.colnames = {'contributor_name', 'contributor_affiliation', 'is_contact_person', 'contributor_role', 'contributor_orcid_id'};
    contributorsTable.description = 'contributors to the grant';
    contributorsTable.id = types.hdmf_common.ElementIdentifiers('data', 1:contribLength);
        
    for i = 1:contribLength
        vdata = types.hdmf_common.VectorData;
        vdata.description = ['Contributor ' num2str(i)];
        vdata.data = { ...
            contributors(i).contributor_name, ...
            strjoin(contributors(i).contributor_affiliation, '; '), ...
            num2str(contributors(i).is_contact_person), ...
            strjoin(contributors(i).contributor_role, '; '), ...
            contributors(i).contributor_orcid_id ...
            };
        contributorsTable.vectordata.set(['Contributor ' num2str(i)], vdata);
    end
    
    metadata.contributors = contributorsTable;
    
    
    
%     contribLength = length(contributors);
%     contribStruct = struct( ...
%             'contributor_name', cell(1, contribLength), ...
%             'contributor_affiliation', cell(1, contribLength), ...
%             'is_contact_person', cell(1, contribLength), ...
%             'contributor_role', cell(1, contribLength), ...
%             'contributor_orcid_id', cell(1, contribLength) ...
%     );
%     
%     for i = 1:length(contributors)
%         contribStruct(i) = struct( ...
%             'contributor_name', contributors(i).contributor_name, ...
%             'contributor_affiliation', strjoin(contributors(i).contributor_affiliation, '; '), ...
%             'is_contact_person', contributors(i).is_contact_person, ...
%             'contributor_role', strjoin(contributors(i).contributor_role, '; '), ...
%             'contributor_orcid_id', contributors(i).contributor_orcid_id ...
%         );
%     end
    
%     metadata.contributors = struct2table(contribStruct);

%         contributorsTable(i).contributor_name = contributors(i).contributor_name;
%         contributorsTable(i).contributor_affiliation = strjoin(contributors(i).contributor_affiliation, '; ');
%         contributorsTable(i).is_contact_person = contributors(i).is_contact_person;
%         contributorsTable(i).contributor_role = strjoin(contributors(i).contributor_role, '; ');
%         contributorsTable(i).contributor_orcid_id = contributors(i).contributor_orcid_id;
                               
    name = 'GrantMetaData';
end

