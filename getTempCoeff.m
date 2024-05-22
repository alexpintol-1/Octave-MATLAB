##  This file has temperature coefficients of all TIAs (For 10^9 gain)
##
##  Input: TIA serial number
##  Output: temperature coefficient

function temp_coeff = getTempCoeff(ser_num)
  
  % TC list for every TIA serial number
  tc_list = [47, 44, 51, 46, 85, 47, 47, 47, 48, 45, 56, 46, 47, 47, 50, 49, 49, 46, 45, 50, 44, 50, 52, 48, 40, 55, 49, 67, 71, 46, 43, 44, 47, 48, 47, 38, 42, 49, 44, 40, 41, 48, 45];
  L = length(tc_list);
  
  % Converts input to number
  x = str2num(ser_num);
  if x > 101 || x < 59
    display('Error: Serial number does not exist.')
    return;
  else   
    % goes through array to find the correct TC for the given TIA serial number
    for i = 1:L  
      index = 58 + i;
      if x == index
        temp_coeff = tc_list(i);
      endif
    endfor
  endif
endfunction
