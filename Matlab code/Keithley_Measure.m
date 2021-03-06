function [voltage_mu_vect] = Keithley_Measure(i, fid, wavelength_in, wavelength_out, voltage_mu_vect, iterations, s)
%Purpose: Measures voltage from the Keithley 2000 Multimeter and returns an
%array of voltage mu, std, med, min, and max.

%Measure voltage
fprintf('Keithley Multimeter 200; measuring voltage: \n');
[voltage_mu, voltage_std, voltage_volts, voltage_med, voltage_min, voltage_max] = measure_voltage(iterations, s);
voltage_mu_vect(i) = voltage_mu;
fprintf('\tMonochromator (lambda): \t %f [nm]\n',wavelength_out);
fprintf('\tKeithley Multimeter: \t %f [A]\n', voltage_mu);
fprintf(fid,'%15s\t%15s\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15g\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n',num2str(wavelength_in),num2str(wavelength_out),voltage_volts,'NONE',num2str(voltage_mu),num2str(voltage_std),num2str(voltage_med),num2str(voltage_min),num2str(voltage_max));
fprintf('\n');
end