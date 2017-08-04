function [value_mu,value_std,value_units,value_med,value_min,value_max] = measure_value(wavelength, type)

if (~exist('wavelength','var'))
     wavelength = 700.0;
end


%Ensure all serial ports are closed.
I = instrfind;
ICOUNT = numel(get(I));
for i=1:ICOUNT
    fclose(I(i));
end


s = serial('COM12');
set(s, 'BaudRate', 19200, 'Terminator','CR','Timeout',1);
fopen(s);
fprintf(s,'*rst'); %reset instrument

value_units = zeros(1,10);
i = 1;
while(i < 11)
	if strcmp(type,'current')
					try
				fprintf(s,'curr:dc:rang 0.01'); % set current range
				fprintf(s,'func "curr:dc";:read?'); %read current range
				out = fscanf(s);
				out(double(out)<43)=[];
				current_amps(i) = eval(out);
			catch
				i = i-1;
				fprintf(s,'*rst'); %reset instrument
				pause(1);
				fprintf('Failed to read multimeter. Trying again\n');
			end
			i=i+1;
	end
	else if strcmp(type, 'voltage')
		try
			fprintf(s,'volt:dc:rang 0.01'); % set voltage range
			fprintf(s,'func "volt:dc";:read?'); %read voltage range
			out = fscanf(s);
			out(double(out)<43)=[];
			voltage_volts(i) = eval(out);
		catch
			i = i-1;
			fprintf(s,'*rst'); %reset instrument
			pause(1);
			fprintf('Failed to read multimeter. Trying again\n');
		end
		i=i+1;
	end
end
		

value_mu  = mean(value_units);
value_std = std(value_units);
value_med = median(value_units);
value_min = min(value_units);
value_max = max(value_units);

fprintf(s,':syst:loc'); %set instrument to local use
fclose(s);
delete(s);
clear s;
end
