##  Calls functions: getTempCoeff, getTIACalDates, ref_data, and TIAGather_Data
##  Script is used to find data points from these functions and plot the data points

#   insert TIA results path
function m = TIACorrectedGainPlot(fileDir)
  
  % gather TIA result data, initialize gain titles, and resistor box temperature coefficient
  [dat] = TIAGather_Data(fileDir);
  l_dat = length(dat);
  ResBox_TC = -44.92;
  A = {'10^3', '10^4', '10^5', '10^6', '10^7', '10^8', '10^9'};
  
  % initialize arrays
  room_temp = [];
  ref_room_temp = [];
  tia_temp = [];
  ref_tia_temp = [];
  tia_gains = zeros(7,l_dat);
  dates = [];
  caldate = [];
  
  % collection time comparison (IGNORE)
  times = [];
  ref_times = [];
##  comp = [];
  
  % extract serial number from input and corresponding temperature coefficient
  sernum = dat{1}.ser_num(8:9);
  temp_coeff = getTempCoeff(sernum);
  
  % extract data and place them in their corresponding arrays
  for i = 1:l_dat
    dates{i} = dat{i}.coll_date;
    caldate{i} = dat{i}.cal_date;
    times{i} = dat{i}.coll_time;
    room_temp(i) = str2double(dat{i}.avgtemps.avg_room);
    tia_temp(i) = str2double(dat{i}.avgtemps.avg_tia);
    for j = 1:length(A)
      tia_gains(j,i)=str2double(dat{i}.angains.gaindelta{j});
    endfor;  
  endfor
 
  % extract temperature (internal and room) ref data into corresponding array
  for i = 1:length(dates)
    [ref_dat] = ref_data(dates(i),times{i});
    ref_times{i} = ref_dat.coll_time;
        
    % collection time comparison
##    comp{i} = ref_dat.comp;
    
    ref_room_temp(i) = str2double(ref_dat.avgtemps.avg_room);
    ref_tia_temp(i) = str2double(ref_dat.avgtemps.avg_tia);
  endfor
 
  % Find corrected gains and delta temperatures
  corrected_gains = [];
  rs_corrected_gains = [];
  gain_change = [];
  TC_gains = [];
  rs_gains = [];
  
  % sort data for plotting
  for i=1:length(room_temp)
    
    % corrected gains based off TC and delta room temp.
    delta_room_temp(i) = room_temp(i)-ref_room_temp(i);
    corrected_gains(i) = (-1)*(room_temp(i)-ref_room_temp(i))*temp_coeff;
    TC_gains(i) = tia_gains(7,i)+corrected_gains(i); 
    
    % corrected gains based off resbox TC
    rs_corrected_gains(i) =(room_temp(i)-ref_room_temp(i))*ResBox_TC;
    rs_gains(i) = tia_gains(7,i)+rs_corrected_gains(i);
    
    % TIA gain change
    if i==1
      gain_change(i) = 0;
    else
      gain_change(i) = abs(tia_gains(7,i)-tia_gains(7,i-1));
    endif;
  endfor
  
  % date format initialization/plot name 
  for i=1:l_dat
    temp_val{i} = datenum(dat{i}.coll_date, 'yymmdd');
    datnum = [temp_val{}];
  endfor;   
  name = fileDir(4:12);
  
  % Plot data point calibration date labels and offset
  dy = 0.25;
  [caldat] = getTIACalDates(caldate);
  
  % Plots and plotting format 
  figure
  
  % TIA gain
  subplot(2,1,1)
  plot(datnum,tia_gains(7,:),'color','green','-o',datnum,gain_change,'color','red','--')     
  title(sprintf('%s | Gain: %s',name,A{7})); 
  for i = 1:length(caldat.calarr)   % add labels to data points when calibration is done 
    text(datnum(caldat.in(i)),tia_gains(7,caldat.in(i)) - tia_gains(7,caldat.in(i))*dy,caldat.calarr{i},'FontSize',14)
  endfor;
  legend('TIA Gain','TIA gain change','Location','bestoutside');
  xlabel('Collection Date')
  ylabel('Gain Diff from Nominal (ppm)')
  datetick('yymmdd'); 
  grid on
  
  % Room temperature
  subplot(2,1,2)
  plot(datnum,room_temp,'color','red','-o')
  title('Room Temperature at time of test')
  for i = 1:length(caldat.calarr)   % add labels to data points when calibration is done 
    text(datnum(caldat.in(i)),room_temp(caldat.in(i)),caldat.calarr{i},'FontSize',14)
  endfor;
  legend('Room Temp','Location','bestoutside');                                  
  xlabel('Collection Date')
  ylabel('\degC');
  datetick('yymmdd');
  grid on
  
  figure
 
  % ResBox TC corrected gain 
  subplot(3,1,1)
  plot(datnum,rs_corrected_gains,'color','blue','--')     
  title(sprintf('%s | Gain: %s',name,A{7}));
  for i = 1:length(caldat.calarr)   % add labels to data points when calibration is done 
    text(datnum(caldat.in(i)),rs_corrected_gains(caldat.in(i))-rs_corrected_gains(caldat.in(i))*dy,caldat.calarr{i},'FontSize',14)
  endfor;
  legend('ResBox TC Correction','Location','bestoutside');
  xlabel('Collection Date') 
  ylabel('Gain Diff from Nominal (ppm)')
  datetick('yymmdd'); 
  grid on
  
  % Internal resistor TC corrected gain
  subplot(3,1,2)
  plot(datnum,corrected_gains,'color','red','--')     
  title(sprintf('%s | Gain: %s',name,A{7}));
  for i = 1:length(caldat.calarr)   % add labels to data points when calibration is done 
    text(datnum(caldat.in(i)),corrected_gains(caldat.in(i))-corrected_gains(caldat.in(i))*dy,caldat.calarr{i},'FontSize',14)
  endfor;
  legend('Int. TC Correction','Location','bestoutside'); 
  xlabel('Collection Date')
  ylabel('Gain Diff from Nominal (ppm)')
  datetick('yymmdd'); 
  grid on
  
  % delta room temp plot
  subplot(3,1,3)      
  plot(datnum,delta_room_temp,'color','green','-o')                                          
  title('\Delta Room Temperature of CS vs TIA');
  for i = 1:length(caldat.calarr)   % add labels to data points when calibration is done 
    text(datnum(caldat.in(i)),delta_room_temp(caldat.in(i))-delta_room_temp(caldat.in(i))*dy,caldat.calarr{i},'FontSize',14)
  endfor;  
  legend('\DeltaRoom Temp','Location','bestoutside');                                   
  xlabel('Collection Date')
  ylabel('\degC');
  datetick('yymmdd');
  grid on
  
  figure
  
  %Combined TIA gain and corrected gains
  plot(datnum,tia_gains(7,:),'color','green','-o',datnum,TC_gains,'color','red','-o',datnum,rs_gains,'color','blue','-o')     
  title(sprintf('%s | Gain: %s',name,A{7})); 
  for i = 1:length(caldat.calarr)   % add labels to data points when calibration is done 
    text(datnum(caldat.in(i)),tia_gains(7,caldat.in(i)) - tia_gains(7,caldat.in(i))*dy,caldat.calarr{i},'FontSize',14)
  endfor;
  legend('TIA Gain','Int. TC Corrected','ResBox TC Corrected','Location','bestoutside');
  xlabel('Collection Date') 
  ylabel('Gain Diff from Nominal (ppm)')
  datetick('yymmdd'); 
  grid on
  
endfunction
