##  Similar to TIAGather_Data, this function collects temperature data of the CS TIA
##  of a certain date and time and returns them as a cell
##
##  Input: collection date and collection time
##
##  Output: version
##          average temperatures  

function [ref_dat] = ref_data(collref_date_in,colltime_t)
  
  % List all report files for 3300B-051 and find length of list
  filename = copy_ExpRepListV1_0('Z:\3300B-051\Results');
  l_list = size(filename)(2);
  ref_found = 0;
  
  % For each list, compare coll_ref_date to target collection ref_date
  % Once found extract ref_data from report file of that ref_data
  for i=1:l_list
    [dr, name, ~] = fileparts(filename{i});
    splt = strsplit(name);
    ref_date_var = char(splt{3});
    coll_ref_date = ref_date_var(1:6);    
    
    % compare coll_ref_date to target collref_date (collref_date_in)
    % if match, store coll_ref_date in array
    if strcmp(coll_ref_date, collref_date_in)
      ref_file = strcat(dr,'\',name,'.txt');
      
      % collection time comparison
      ref_dat.coll_time = ref_date_var(8:length(ref_date_var));
      temp_val = ge(str2num(colltime_t),str2num(ref_dat.coll_time));
      if temp_val == 0
        ref_dat.comp = temp_val-1;
      else
        ref_dat.comp = ge(str2num(colltime_t),str2num(ref_dat.coll_time));
      endif;
      ref_found = 1;
    endif
  endfor
  
  if ref_found == 0
    display('Error: Could not find report file of target collection ref_date')
    return;
  endif
  
  % similar to TIAgather_ref_data, gather only temp ref_data (TIA and room)
  
  % 3 versions of report files
  versions = {'1.0','1.1','1.2'};
    #ver:       1			2			3	
    
  %open file
  fid = fopen(ref_file);
  if fid == -1
    display('Error: Could not open file.');
    return;
  endif
  
  % Get version:
  a = textscan(fgetl(fid), '%s %s', 1, 'Delimiter', "\t");
  if ((strcmpi(a{1}{1},'Version:'))||(strcmpi(a{1}{1},'Report Version:')))
    ref_dat.ver = a{2}{1};
  else	
    ref_dat.ver = '1.0';
  endif

  [isver,ver] = ismember(ref_dat.ver, versions);
  if ~isver
    display('Error: file version not supported...');
    return;
  endif  
  
  % check which version report file is, display version, and skip appropriate amount of lines
  if ver == 1               # Version 1.0
    for n = 1:5       
      fgetl(fid);
        if n == 6
          disp('Version 1.0')
        endif;
    endfor;
  elseif ver == 2           # Version 1.1
    for n = 1:7
      fgetl(fid);
        if n == 8
          disp('Version 1.1')
        endif;              
    endfor;
  elseif ver == 3           # Version 1.2
    for n = 1:8      
      fgetl(fid);
        if n == 9
          disp('Version 1.2')
        endif;
    endfor;
  endif;

  % scanning to find temp values
  a = textscan(fgetl(fid), '%s %s %s %s', 1, 'Delimiter', "\t");
  if (strncmpi(a{1}{1},'Temperatures',12))
      
    % extracting average temp
    fgetl(fid); # skip to 'avg' temps
    fgetl(fid);
    b = textscan(fgetl(fid), '%s %s %s %s %s %s', 1, 'Delimiter', "\t");
    if (strcmpi(b{2}{1},'avg:'))
      ref_dat.avgtemps.avg_tia{1} = char(b{3}{1});
      if ver > 1
        ref_dat.avgtemps.avg_room{1} = char(b{4}{1});
      else
        ref_dat.avgtemps.avg_room{1} = char(b{6}{1});
      endif;       
    endif    
  endif

  % close file
  fclose(fid);  
endfunction
