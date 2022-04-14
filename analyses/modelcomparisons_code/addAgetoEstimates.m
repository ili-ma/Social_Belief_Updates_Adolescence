%load('estimates_uncertaintyFull_preppedInf_ORA_29Jan2019.mat')
%load('allBICdiffs.mat')
load('estimates_uncertaintyFull_Beta_ORA_9feb2019.mat')

fid = fopen('ppngegevens_beta.csv');
  tline = fgetl(fid)
  subjidx = 1;
  
  while ischar(tline)
      parts = strsplit(tline, ',');
      ppnparts = strsplit(parts{1}, '-');
      tline
      ppn = str2num(ppnparts{2})

      ppgegevens.ppn(subjidx) = ppn;
      if contains(parts{2}, "M")
         ppgegevens.gender(subjidx) = 0;
      else
         ppgegevens.gender(subjidx) = 1;
      end
      ppgegevens.ageExact(subjidx) = str2num(parts{3});
      ppgegevens.age(subjidx) = str2num(parts{4});
      tline = fgetl(fid);
      subjidx = subjidx + 1;
  end
  fclose(fid);
  
  NewdataAge = [];
for rownr = 1:length(pars_est)
    ppn = pars_est(rownr, 1);
       idx = find(ppgegevens.ppn == ppn);
       if idx > 0
           NewdataAge = [NewdataAge; pars_est(rownr, :) ppgegevens.gender(idx) , ppgegevens.ageExact(idx) , ppgegevens.age(idx)];
       else
           fprintf('subject %d missing in excel file', ppn);
       end
end