##  Function organizes the cablibrations dates and omits repeat dates into an arrayfun
##
##  input     - cal_date; must be a cell
##  output    - cell containing calibration date and length of calibrations 

function [caldat] = getTIACalDates(cal_dates)
  % initialize arrays and necessary values
  d_length = length(cal_dates);
  calarr = [];
  in = [];
  
  for i=1:d_length
    
    if i==1     % place first element in array along with its index
      calarr{i} = cal_dates{i};
      in(i) = i;
    else        % add caldate if different along with index number
      tf=strcmp(cal_dates{i-1},cal_dates{i});
      if ~tf
        calarr = [calarr, cal_dates{i}];
        in = [in, i];
      endif;
    endif;          
  endfor;
  
  % sort outputs
  caldat.d_length = d_length;
  caldat.calarr = calarr;
  caldat.in = in;
  
endfunction;

