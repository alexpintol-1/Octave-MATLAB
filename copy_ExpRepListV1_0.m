# COPY VERSION
# Version 1.0 

function replist = copy_ExpRepListV1_0(flDr);
# fileDirlist: file/directory list
# fileList:    list of files names with directory names replaced with a list of 
#              files within the directory. Directories within the directory are ignored
m=1;
filelist = []; 
if ~(exist(flDr)==2||exist(flDr)==7)#check if a valid file/dir
	fprintf('Warning: Bad Path/File:\r\n\t %s\r\n', flDr);

else   
	#folder handling 
	if (exist(flDr)==7) 
		if (flDr(length(flDr)) != '\') #if EoL is not \ append \
			flDr = strcat(flDr,'\');
		endif
		[dr, name, ~] = fileparts(flDr); #add files within directory to list
		a = dir(dr);
		a = a(3:end);
		for j=1:length(a)
			if ~a(j).isdir 
				filelist{m} = fullfile(flDr, a(j).name);
				m++;
			endif
		end
	#file handling  
	elseif (exist(flDr)==2) #add files to list
		filelist{m} = flDr;
		m++;
	else
		display('Error: Code should not reach this point. ExpFileListV1_0');
		return;
	endif
endif


#check if same as first TIA XXX & 'Rprt' file fom filename
#3300B-XXX Data yymmdd-hhmm Rprt yymmdd-hhmmss     filename format
# 1          2      3        4       5        6
sn = {['NaN']};
prevDate = {['NaN']};
j = 1;

##splt = strsplit(name)
##dat.colldate = char(splt(1,size(splt)(2)-1))
##dat.repdate = char(splt(1,size(splt)(2)))


if length(filelist) #len > 0
	for i=1:length(filelist)
		[dr, name, ~] = fileparts(filelist{i});
		splt = strsplit(name);
		#check that is 'Rprt; & sn the same
		if ( (size(splt)(2) >= 5) && (strcmp(splt(4),'Rprt')) )
			#assign sn to fisrt read in rept's sn, only accept that sn after
			if (strcmp(sn ,'NaN'))
				sn = splt(1);
			endif
			if strcmp(splt(1), sn)
				if !(strcmp(splt(3), prevDate))
					replist(j) = filelist(i);
					j = j+1;
					prevDate = splt(3);
				else
					display(sprintf('\"%s\" is a duplicate of collection date: %s', name, prevDate{}));
				endif
			else	
				display(sprintf('\"%s\" does not match SN of first file: %s', name, sn{}));
			endif
		else 
			display(sprintf('\"%s\" is not a Rprt file, or the file name has the wrong format', name));
		endif	
	end
else 
	display(sprintf('Error: no files within ''%s''',flDr));
	return;
endif

replist= sort(replist);

endfunction




