function power_measurements(wavelengthStart,wavelengthStop,stepSize,outPath)
%Purpose: Acquire DN data from a device (Android or webcam) illuminated by a
%         monochromator.
%Date:    04-24-2015

%Version: 6.0
tic
wavelengths    = wavelengthStart:stepSize:wavelengthStop;
npoints        = length(wavelengths);
[fid] = fopen([outPath '\'  'photodiode.csv'],'wt');
fprintf(fid,'%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n','wavelength_in','wavelength_out','pm_lambda','power_mu','power_std','power_med','power_min','power_max');
power_mu_vect       = zeros(1,npoints);
power_mu_vect_dark  = zeros(1,npoints);
for i=1:npoints
    wavelength_in = wavelengths(i);
           
    [wavelength_out] = set_monochromator(wavelength_in);  %uses Serial RS-232 connection
    fprintf('Wavelength In = %f\n',wavelength_in);  
    fprintf('Wavelength Out = %f\n',wavelength_out);  
    pause(1);
    
    valid_power_measurement = 0;
    while (valid_power_measurement == 0)
        %Measure power
        fprintf('Newport Power Meter Model 1936-R; measuring power: \n');
        [pm_lambda,power_mu,power_std,power_watts,power_med,power_min,power_max] = measure_power(wavelength_in);
        power_mu_vect(i) = power_mu;
        fprintf('\tMonochromator (lambda):          %f [nm]\n',wavelength_out);
        fprintf('\tPower Meter   (lambda):          %f [nm]\n', pm_lambda);
        load ('power_watts.mat');
        fprintf(fid,'%15s\t%15s\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n',num2str(wavelength_in),num2str(wavelength_out),power_watts,num2str(pm_lambda),num2str(power_mu),num2str(power_std),num2str(power_med),num2str(power_min),num2str(power_max));
        valid_power_measurement = 1;
    end
    fprintf('\n');
end
fclose(fid);


wavelengths    = wavelengthStart:stepSize:wavelengthStop;
npoints        = length(wavelengths);
[fid] = fopen([outPath '\'  'photodiode_dark.csv'],'wt');
fprintf(fid,'%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n','wavelength_in','wavelength_out','S1','S2','S3','S4','S5','S6','S7','S8','S9','S10','pm_lambda','power_mu','power_std','power_med','power_min','power_max');
for i=1:npoints
    wavelength_in = wavelengths(i);
    load ('power_watts.mat');       
    [wavelength_out] = set_monochromator_dark(wavelength_in);  %uses Serial RS-232 connection
    fprintf('Wavelength In = %f\n',wavelength_in);  
    fprintf('Wavelength Out = %f\n',wavelength_out);  
    pause(1);
    
    valid_power_measurement = 0;
    while (valid_power_measurement == 0)
        %Measure power
        fprintf('Newport Power Meter Model 1936-R; measuring power: \n');
        [pm_lambda,power_mu,power_std,power_watts,power_med,power_min,power_max] = measure_power(wavelength_in);
        power_mu_vect_dark(i) = power_mu;
        fprintf('\tMonochromator (lambda):          %f [nm]\n',wavelength_out);
        fprintf('\tPower Meter   (lambda):          %f [nm]\n', pm_lambda);
        
        fprintf(fid,'%15s\t%15s\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n',num2str(wavelength_in),num2str(wavelength_out),power_watts,num2str(pm_lambda),num2str(power_mu),num2str(power_std),num2str(power_med),num2str(power_min),num2str(power_max));
        valid_power_measurement = 1;
    end
    fprintf('\n');
end

fclose(fid);

[fid] = fopen([outPath '\' 'power_final.csv'],'wt');
for i=1:npoints
    fprintf(fid,'%15s\t%15g\n',num2str(wavelengths(i)),power_mu_vect(i) - power_mu_vect_dark(i));
end
fclose(fid);

if exist('power_watts.mat')
   delete('power_watts.mat');
toc
end