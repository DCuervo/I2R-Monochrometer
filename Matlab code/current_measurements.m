function current_measurements(wavelengthStart,wavelengthStop,stepSize,outPath)

wavelengths    = wavelengthStart:stepSize:wavelengthStop;
npoints        = length(wavelengths);


fid = fopen([outPath '\'  'photodiode.csv'],'wt');
fprintf(fid,'%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n','wavelength_in','wavelength_out','S1','S2','S3','S4','S5','S6','S7','S8','S9','S10','pm_lambda','current_mu','current_std','current_med','current_min','current_max');

current_mu_vect = zeros(1,npoints);


for i=1:npoints
    wavelength_in = wavelengths(i);
           
    [wavelength_out] = set_monochromator(wavelength_in);  %uses Serial RS-232 connection
    fprintf('Wavelength In = %f\n',wavelength_in);  
    fprintf('Wavelength Out = %f\n',wavelength_out);  
    pause(1);

    %Measure current
    fprintf('Keithley Multimeter 2000; measuring current: \n');
    [current_mu,current_std,current_amps,current_med,current_min,current_max] = measure_current(wavelength_in);
    current_mu_vect(i) = current_mu;
    fprintf('\tMonochromator (lambda):          %f [nm]\n',wavelength_out);
    fprintf('\tMultimeter:                      %e [A]\n', current_mu);
    %load ('current_amps.mat');
    fprintf(fid,'%15s\t%15s\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n',num2str(wavelength_in),num2str(wavelength_out),current_amps,'NONE',num2str(current_mu),num2str(current_std),num2str(current_med),num2str(current_min),num2str(current_max));

    fprintf('\n');
end
fclose(fid);


fid = fopen([outPath '\'  'photodiode_dark.csv'],'wt');
fprintf(fid,'%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n','wavelength_in','wavelength_out','S1','S2','S3','S4','S5','S6','S7','S8','S9','S10','pm_lambda','current_mu','current_std','current_med','current_min','current_max');
current_mu_vect_dark = zeros(1,npoints);
for i=1:npoints
    wavelength_in = wavelengths(i);
           
    [wavelength_out] = set_monochromator_dark(wavelength_in);  %uses Serial RS-232 connection
    fprintf('Wavelength In = %f\n',wavelength_in);  
    fprintf('Wavelength Out = %f\n',wavelength_out);  
    pause(1);

    %Measure current
    fprintf('Keithley Multimeter 2000; measuring current: \n');
    [current_mu,current_std,current_amps,current_med,current_min,current_max] = measure_current(wavelength_in);
    current_mu_vect_dark(i) = current_mu;
    fprintf('\tMonochromator (lambda):          %f [nm]\n',wavelength_out);
    fprintf('\tMultimeter:          %e [A]\n', current_mu);
    %load ('current_amps.mat');
    fprintf(fid,'%15s\t%15s\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n',num2str(wavelength_in),num2str(wavelength_out),current_amps,'NONE',num2str(current_mu),num2str(current_std),num2str(current_med),num2str(current_min),num2str(current_max));

    fprintf('\n');
end
fclose(fid);


fid = fopen([outPath '\' 'current_final.csv'],'wt');
for i=1:npoints
    fprintf(fid,'%15s\t%15g\n',num2str(wavelengths(i)),current_mu_vect(i) - current_mu_vect_dark(i));
end
fclose(fid);


end