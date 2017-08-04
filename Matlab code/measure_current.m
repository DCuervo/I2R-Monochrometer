function [current_mu,current_std,current_amps,current_med,current_min,current_max] = measure_current(wavelength)

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

current_amps = zeros(1,10);
i = 1;
while(i < 11)

    try
        fprintf(s,'curr:dc:rang 0.01'); % set current range
        fprintf(s,'func "curr:dc";:read?'); %read current range
        out = fscanf(s);
        out(double(out)<43)=[];
        %out = eval(out(2:end-2)); %remove extra characters and eval
        current_amps(i) = eval(out);
    catch
        i = i-1;
        fprintf(s,'*rst'); %reset instrument
        pause(1);
        fprintf('Failed to read multimeter. Trying again\n');
    end
    i=i+1;
end

current_mu  = mean(current_amps);
current_std = std(current_amps);
current_med = median(current_amps);
current_min = min(current_amps);
current_max = max(current_amps);

fprintf(s,':syst:loc'); %set instrument to local use
fclose(s);
delete(s);
clear s;
end