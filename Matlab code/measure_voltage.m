function [voltage_mu,voltage_std,voltage_volts,voltage_med,voltage_min,voltage_max] = measure_voltage(iterations,s)

if s.status == 'closed'
    error('Serial object closed or not configured properly');
end

voltage_volts = zeros(1,iterations);
i = 1;
while(i < (iterations + 1))

    try
        fprintf(s,'volt:dc:rang 0.01'); % set voltage range
        fprintf(s,'func "volt:dc";:read?'); %read voltage range
        out = fscanf(s);
        out(double(out)<43)=[];
        %out = eval(out(2:end-2)); %remove extra characters and eval
        voltage_volts(i) = eval(out);
    catch
        i = i-1;
        fprintf(s,'*rst'); %reset instrument
        pause(1);
        fprintf('Failed to read multimeter. Trying again\n');
    end
    i=i+1;
end

voltage_mu  = mean(voltage_volts);
voltage_std = std(voltage_volts);
voltage_med = median(voltage_volts);
voltage_min = min(voltage_volts);
voltage_max = max(voltage_volts);
end