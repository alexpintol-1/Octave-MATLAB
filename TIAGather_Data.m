##  Function reads the report files of a TIA serial number in the respective 
##  results folder directory and returns a cell containing relevant data  
##  
##  Input: result file directory
##  Output:  serial number
##           collection date
##           collection time
##           version
##           calibration date
##           temperatures 
##           analog gains

function [dat] = TIAGather_Data(fileDir)
  
  % Collect all the report files and find the length of the array size
  filename = copy_ExpRepListV1_0(fileDir);
  l_list = size(filename)(2);
  
  % 3 versions of report files
  versions = {'1.0','1.1','1.2'};
    #ver:       1			2			3	
  
  % For each file find temp data and log it to individual structures  
  for i = 1:l_list
    % parse filename into [1x5] cell then extract collection date and time 
    [dr, name, ~] = fileparts(filename{i});
    splt = strsplit(name);
    dat{i}.ser_num = char(splt(1,size(splt)(2)-4));
    date_var  = char(splt{3});
    dat{i}.coll_date = date_var(1:6);
    dat{i}.coll_time = date_var(8:end);
    
    % check File Opens
    fid = fopen(filename{i});
    if fid == -1
      display('Error: Could not open file in TIAReadReportV1_0.');
      return;
    endif
    
    % Get version:
    a = textscan(fgetl(fid), '%s %s', 1, 'Delimiter', "\t");
    if ((strcmpi(a{1}{1},'Version:'))||(strcmpi(a{1}{1},'Report Version:')))
      dat{i}.ver = a{2}{1};
    else	
      dat{i}.ver = '1.0';
    endif

    [isver,ver] = ismember(dat{i}.ver, versions);
    if ~isver
      display('Error: file version not supported...');
      return;
    endif
    
    % check which version report file is, display version, and skip appropriate amount of lines 
    if ver == 1               # Version 1.0
      for n = 1:2
        fgetl(fid);
      endfor;
      a = textscan(fgetl(fid),'%s %s',1,'Delimiter',"\t");
      if strcmpi(a{1}{1},'Calibration Date:')
        dat{i}.cal_date = a{2}{1};
      endif;
      fgetl(fid);
      fgetl(fid);
      
    elseif ver == 2           # Version 1.1
      for n = 1:3
        fgetl(fid);
      endfor;
      a = textscan(fgetl(fid),'%s %s',1,'Delimiter',"\t");
      if strcmpi(a{1}{1},'Calibration Date:')
        dat{i}.cal_date = a{2}{1};
      endif;  
      fgetl(fid);
      fgetl(fid);
      fgetl(fid);
      
    elseif ver == 3           # Version 1.2
      for n = 1:3      
        fgetl(fid);
      endfor;
      a = textscan(fgetl(fid),'%s %s',1,'Delimiter',"\t");
      if strcmpi(a{1}{1},'Calibration Date:')
        dat{i}.cal_date = a{2}{1};
      endif;
      fgetl(fid);
      fgetl(fid);
      fgetl(fid);
      fgetl(fid);
      
    endif;
    
    % scanning to find temp values
    a = textscan(fgetl(fid), '%s %s %s %s', 1, 'Delimiter', "\t");
    if (strncmpi(a{1}{1},'Temperatures',12))
      
      % extracting average temp
      fgetl(fid); # skip to 'avg' temps
      fgetl(fid);
      b = textscan(fgetl(fid), '%s %s %s %s %s %s', 1, 'Delimiter', "\t");
      if (strcmpi(b{2}{1},'avg:'))
        dat{i}.avgtemps.avg_tia{1} = char(b{3}{1});
        if ver > 1
          dat{i}.avgtemps.avg_room{1} = char(b{4}{1});
        else
          dat{i}.avgtemps.avg_room{1} = char(b{6}{1});
        endif;       
      endif    
    endif
    
    fgetl(fid); % skip lines
    fgetl(fid);
    
    % Read and log analog gain data
    a = textscan(fgetl(fid), '%s %s %s %s %s %s %s', 1, 'Delimiter', "\t");
    if (strcmpi(a{1}{1},'Analog Gains:'))
      fgetl(fid); %skip two lines
      fgetl(fid);
      
      ##10^3
		  a = textscan(fgetl(fid), '%s %s %s %s %s %s %s', 1, 'Delimiter', "\t");
      if (strcmpi(a{2}{1},'10^3'))
        dat{i}.angains.gaindelta{1}= a{6}{1};
        
        ##10^4
			  a = textscan(fgetl(fid), '%s %s %s %s %s %s %s', 1, 'Delimiter', "\t");
			  if (strcmpi(a{2}{1},'10^4'))
          dat{i}.angains.gaindelta{2} = a{6}{1};
          
			    ##10^5
          a = textscan(fgetl(fid), '%s %s %s %s %s %s %s', 1, 'Delimiter', "\t");
          if (strcmpi(a{2}{1},'10^5'))
            dat{i}.angains.gaindelta{3} = a{6}{1};
            
            ##10^6
            a = textscan(fgetl(fid), '%s %s %s %s %s %s %s', 1, 'Delimiter', "\t");
            if (strcmpi(a{2}{1},'10^6'))
              dat{i}.angains.gaindelta{4} = a{6}{1};
              
              ##10^7
              a = textscan(fgetl(fid), '%s %s %s %s %s %s %s', 1, 'Delimiter', "\t");
              if (strcmpi(a{2}{1},'10^7'))
                dat{i}.angains.gaindelta{5} = a{6}{1};
                
                ##10^8
                a = textscan(fgetl(fid), '%s %s %s %s %s %s %s', 1, 'Delimiter', "\t");
                if (strcmpi(a{2}{1},'10^8'))
                  dat{i}.angains.gaindelta{6} = a{6}{1};
                  
                  ##10^9
                  a = textscan(fgetl(fid), '%s %s %s %s %s %s %s', 1, 'Delimiter', "\t");
                  if (strcmpi(a{2}{1},'10^9'))
                    dat{i}.angains.gaindelta{7} = a{6}{1};
                  else 
								    display('Warning...Did not find ''Analog Gains: 10^9''');
                  endif
                else 
								  display('Warning...Did not find ''Analog Gains: 10^8''');                  
                endif
              else 
								display('Warning...Did not find ''Analog Gains: 10^7''');                
              endif
            else 
					    display('Warning...Did not find ''Analog Gains: 10^6''');              
            endif
          else 
					  display('Warning...Did not find ''Analog Gains: 10^5''');            
          endif
        else 
					display('Warning...Did not find ''Analog Gains: 10^4''');  
        endif
      else 
				display('Warning...Did not find ''Analog Gains: 10^3''');      
      endif
    else 
			display('Warning...Did not find ''Analog Gains:''');
    endif
    
    % close current file
    fclose(fid);
  endfor; 
  
endfunction
