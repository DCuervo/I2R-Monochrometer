function power_readings = take_power_reading(dir_out, wavelength_in)

if dir_out(end) ~= filesep
    dir_out = [dir_out filesep];
end

if exist([dir_out 'power_readings.mat'], 'file');
   load([dir_out 'power_readings.mat']);
else
    power_readings = [];
end

%Measure power
fprintf('Newport Power Meter Model 1936-R; measuring power: \n');
[pm_lambda,power_mu,power_std,power_watts,power_med,power_min,power_max] = measure_power(wavelength_in);
power_readings = [power_readings; pm_lambda, power_mu];
fprintf('\tMonochromator (lambda):          %f [nm]\n',wavelength_in);
fprintf('\tPower Meter   (lambda):          %f [nm]\n', pm_lambda);

save([dir_out 'power_readings.mat'], 'power_readings');


[array_rows, array_cols] = size(power_readings);
disp(['Rows: ' num2str(array_rows) ', Cols: ' num2str(array_cols)]);
end



