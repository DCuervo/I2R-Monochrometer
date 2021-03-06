function measure_all(wavelengthStart, wavelengthStop, stepSize, insta_dark_flag, iterations, outPath)

if ~(outPath(end) == '\')
    outPath(end + 1) = '\';
end
  
newPath = strcat(outPath, strcat(num2str(wavelengthStart), '_', num2str(wavelengthStop), '_', num2str(stepSize), '_', num2str(insta_dark_flag), '_', num2str(iterations), '_0'));
while (exist(newPath))
newPath(end) = newPath(end) + 1;
end
mkdir(newPath);
outPath = newPath;

%Ensure all serial ports are closed.
I = instrfind;
ICOUNT = numel(get(I));
for i=1:ICOUNT
    fclose(I(i));
end

% Create serial object for Multimeter
Multimeter = serial('COM12');
set(Multimeter, 'BaudRate', 19200, 'Terminator','CR','Timeout',1);
fopen(Multimeter);
fprintf(Multimeter,'*rst'); %reset instrument
pause(10);


wavelengths    = wavelengthStart:stepSize:wavelengthStop;
npoints        = length(wavelengths);


% %Power meter file id's and array initializations
% fid_powermeter_light = fopen([outPath '\' 'powermeter.csv'],'wt');
% fid_powermeter_dark =  fopen([outPath '\' 'powermeter_dark.csv'],'wt');
% fprintf(fid_powermeter_light,'%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n','wavelength_in','wavelength_out','S1','S2','S3','S4','S5','S6','S7','S8','S9','S10','pm_lambda','power_mu','power_std','power_med','power_min','power_max');
% fprintf(fid_powermeter_dark, '%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n','wavelength_in','wavelength_out','S1','S2','S3','S4','S5','S6','S7','S8','S9','S10','pm_lambda','power_mu','power_std','power_med','power_min','power_max');
% power_mu_vect       = zeros(1,npoints);
% power_mu_vect_dark  = zeros(1,npoints);

%Keithley file id's and array initializations
fid_keithley_light = fopen([outPath '\'  'keithley.csv'],'wt');
fid_keithley_dark =  fopen([outPath '\'  'keithley_dark.csv'],'wt');
fprintf(fid_keithley_light,'%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n','wavelength_in','wavelength_out','S1','S2','S3','S4','S5','S6','S7','S8','S9','S10','S11','S12','S13','S14','S15','S16','S17','S18','S19','S20','S21','S22','S23','S24','S25','S26','S27','S28','S29','S30','pm_lambda','voltage_mu','voltage_std','voltage_med','voltage_min','voltage_max');
fprintf(fid_keithley_dark, '%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n','wavelength_in','wavelength_out','S1','S2','S3','S4','S5','S6','S7','S8','S9','S10','S11','S12','S13','S14','S15','S16','S17','S18','S19','S20','S21','S22','S23','S24','S25','S26','S27','S28','S29','S30','pm_lambda','voltage_mu','voltage_std','voltage_med','voltage_min','voltage_max');
voltage_mu_vect =       zeros(1,npoints);
voltage_mu_vect_dark =  zeros(1,npoints);


for i=1:npoints
    wavelength_in = wavelengths(i);
           
    [wavelength_out] = set_monochromator(wavelength_in);  %uses Serial RS-232 connection

    voltage_mu_vect = Keithley_Measure(i, fid_keithley_light, wavelength_in, wavelength_out, voltage_mu_vect, iterations, Multimeter);
    %power_mu_vect = PowerMeter_Measure(i, fid_powermeter_light, wavelength_in, wavelength_out, power_mu_vect);
    % Camera call
    
    if insta_dark_flag
        wavelength_in = wavelengths(i);
           
        [wavelength_out] = set_monochromator_dark(wavelength_in);  %uses Serial RS-232 connection
        
        voltage_mu_vect_dark = Keithley_Measure(i, fid_keithley_dark, wavelength_in, wavelength_out, voltage_mu_vect_dark, iterations, s);
        %power_mu_vect_dark = PowerMeter_Measure(i, fid_powermeter_dark, wavelength_in, wavelength_out, power_mu_vect_dark);
    end
end
fclose(fid_keithley_light);
%fclose(fid_powermeter_light);

if insta_dark_flag
    fclose(fid_keithley_dark);
    %fclose(fid_powermeter_dark);
else
    for i=1:npoints
        wavelength_in = wavelengths(i);
           
        [wavelength_out] = set_monochromator_dark(wavelength_in);  %uses Serial RS-232 connection
        
        voltage_mu_vect_dark = Keithley_Measure(i, fid_keithley_dark, wavelength_in, wavelength_out, voltage_mu_vect_dark, iterations, s);
        %power_mu_vect_dark = PowerMeter_Measure(i, fid_powermeter_dark, wavelength_in, wavelength_out, power_mu_vect_dark);
    end
    fclose(fid_keithley_dark);
    %fclose(fid_powermeter_dark);
end



fid_keithley = fopen([outPath '\' 'keithley_final.csv'],'wt');
%fid_powermeter = fopen([outPath '\' 'powermeter_final.csv'],'wt');
for i=1:npoints
    fprintf(fid_keithley,'%15s\t%15g\n',num2str(wavelengths(i)),voltage_mu_vect(i) - voltage_mu_vect_dark(i));
%    fprintf(fid_powermeter,'%15s\t%15g\n',num2str(wavelengths(i)),power_mu_vect(i) - power_mu_vect_dark(i));
end
fclose(fid_keithley);    
%fclose(fid_powermeter);

fprintf(Multimeter,':syst:loc'); %set instrument to local use
fclose(Multimeter);
delete(Multimeter);
clear Multimeter;
end