%%SD
% load summaryORA3
%load estimates_uncertaintyFull3_ORA_20March2019.mat 

function dupd = deltaUPerDecision_SD_ORA(data, pars_est)
    exclude = [];    
    decisionIdx = data.rawChoice ~= 0;
    nRows = sum(decisionIdx);
    dupd = NaN(nRows, 3);
    startRow = 1;
    subjectList = setdiff(unique(data.subjid), exclude);
    for subjIndex = 1:numel(subjectList);
        subjectNr = subjectList(subjIndex);
        T = 25;
        m = 2;
        risk = 0;
        alpha_0 = pars_est(subjIndex, 4);
        beta_0 = pars_est(subjIndex, 5);
        deltaUtable = computeDeltaUtable(T, m, alpha_0, beta_0, risk);
        
        subjIdx = data.subjid == subjectNr;
        selection = subjIdx & decisionIdx;
        nSubjRows = sum(selection);
        lastRow = startRow + nSubjRows - 1;
        reds = data.red(selection);
        greens = data.green(selection);
        opens = reds + greens;
        size(deltaUtable);
        deltaUs = deltaUtable(sub2ind(size(deltaUtable), greens + 1, opens + 1));
        dupd(startRow:lastRow, 1) = subjectNr;
        dupd(startRow:lastRow, 2) = deltaUs;
        dupd(startRow:lastRow, 3) = data.rawChoice(selection);
        
        startRow = startRow + nSubjRows;
    end
    dupd = dupd(1:startRow-1, :);
    
    