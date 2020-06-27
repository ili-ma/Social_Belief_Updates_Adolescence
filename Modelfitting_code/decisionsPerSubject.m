function dps = decisionsPerSubject(data, exclusions)
    subjectList = setdiff(unique(data.subjid), exclusions);
    nSubjects = numel(subjectList);
    nDecisions = NaN(nSubjects, 1);
    for subjid = 1:nSubjects
        subjectNr = subjectList(subjid);
        selection = data.subjid == subjectNr;
        nDecisions(subjid, 1) = sum(selection);
    end
    dps = [subjectList nDecisions];