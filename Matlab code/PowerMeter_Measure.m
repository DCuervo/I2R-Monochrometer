function [power_mu_vect] = PowerMeter_Measure(i, fid, wavelength_in, wavelength_out, power_mu_vect)
%Purpose: Measures power from the Newport Power Meter 1936-R and returns an
%array of current mu, std, med, min, and max.

%Measure power
fprintf('Newport Power Meter Model 1936-R; measuring power: \n');
[pm_lambda,power_mu,power_std,power_watts,power_med,power_min,power_max] = measure_power(wavelength_in);
power_mu_vect(i) = power_mu;
fprintf('\tMonochromator (lambda):          %f [nm]\n',wavelength_out);
fprintf('\tPower Meter   (lambda):          %f [nm]\n', pm_lambda);
load ('power_watts.mat');
fprintf(fid,'%15s\t%15s\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n',num2str(wavelength_in),num2str(wavelength_out),power_watts,num2str(pm_lambda),num2str(power_mu),num2str(power_std),num2str(power_med),num2str(power_min),num2str(power_max));
fprintf('\n');
end