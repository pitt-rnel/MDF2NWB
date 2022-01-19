function [name, metadata] = mapGrantMetaData(grant, ~)
% mapGrantMetaData Maps MDF sparc epidural grant metadata to NWB extension 
% GrantMetaData
%
% Maps MDF sparc epidural grant metadata to NWB extension GrantMetaData. 
% This is an example of the function mapping format.
% 
% Args:
%   grant: MDF grant object
%   iterNum: The current number of times this function has been called
%            by the main mapping function (not used since there's only one
%            GrantMetaData object in the NWB file).
%
% Returns:
%   name: The unique name that is used by the main mapping function to
%         identify the GrantMetaData from other GrantMetaData types
%   metadata: The created GrantMetaData NWB extension object that is stored 
%             in the NWBfile object
%

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
    
    colNames = {'contributor_name', 'contributor_affiliation', 'is_contact_person', 'contributor_role', 'contributor_orcid_id'};
    contribTable = cell2table(cell(0, length(colNames)), 'VariableNames', colNames);
    
    for i = 1:contribLength
        contribRow = { ...
            contributors(i).contributor_name, ...
            strjoin(contributors(i).contributor_affiliation, '; '), ...
            num2str(contributors(i).is_contact_person), ...
            strjoin(contributors(i).contributor_role, '; '), ...
            contributors(i).contributor_orcid_id ...
            };
        contribTable = [contribTable; contribRow];
    end
    
    metadata.contributors = util.table2nwb(contribTable, 'contributors to the grant');
    
    name = 'GrantMetaData';
end

