function datasubj = subjectData(subNr, data)
    idx = find(data.subjid == subNr);
    datasubj.subjid = data.subjid(idx);
    datasubj.red    = data.red(idx);
    datasubj.green  = data.green(idx);
    datasubj.choice = data.choice(idx);
    datasubj.rawChoice = data.rawChoice(idx);
end

