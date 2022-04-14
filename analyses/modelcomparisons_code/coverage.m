% Computes a 2D grid that says how often a subjects has observed a certain
% state on average.
function imagedata = coverage(data)
    exclude = [];
    subjects = setdiff(unique(data.subjid), exclude);

    t = data.red + data.green;
    T = max(t) + 1;
    imagedata = nan(T);
    for data_row = 1:length(data.red)
        if ~ismember(data.subjid(data_row), exclude)
            row = data.green(data_row) + 1;
            col = t(data_row) + 1;
            imagedata(row, col) = max(imagedata(row, col), 0) + 1;
        end
    end
    imagedata = imagedata / length(subjects);
end