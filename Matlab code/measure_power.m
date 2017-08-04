function [pm_lambda,power_mu,power_std,power_watts,power_med,power_min,power_max] = measure_power(wavelength)
%Purpose: Measure power from Newport Power 1936-R.
%Date:    04-24-2015
%Version: 6.0


if (~exist('wavelength','var'))
    wavelength = 700.0;
end

%Ensure all serial ports are closed.
I = instrfind;
ICOUNT = numel(get(I));
for i=1:ICOUNT
    fclose(I(i));
end

%On Windows7 64 bit machine there are four COM ports 1(Monochrom),2,4,5
% tic;
s = serial('COM4');
set(s,'BaudRate',38400,'Parity','none','DataBits',8,'StopBits',1,'Terminator','CR');
fopen(s);
% toc;

%Disable echo
statement = 'ECHO?';
fprintf(s,statement); %One parameter returned if echo off or echo statement if echo is on

%documentation for fscanf serial: Use fscanf to read the peak-to-peak voltage as a floating-point number, and exclude the terminator.
%applied to %s.
out = fscanf(s,'%s');
if strcmp(out,'ECHO?')   
    out = str2double(fscanf(s));     
else
    out = str2double(out);
end

%Disable echo of enabled
if (out == 1)
    statement = 'ECHO ';
    parameter = '0';
    fprintf(s,[statement parameter]); 
    fscanf(s); %ECHO 0 returned as echo always
end

power_watts = zeros(1,10);
wavelength_out = 0;

while abs(wavelength_out - wavelength) > .01
    statement = 'PM:Lambda ';
    parameter = num2str(wavelength);
    fprintf(s,[statement parameter]);

    statement  = 'PM:Lambda?';
    fprintf(s,statement);
    out_a = fscanf(s); %500->  53   48   48   13   10    
    wavelength_out = str2double(out_a);
end

pause(1);

for i=1:10    
    try
        statement = 'PM:PWS?';
        fprintf(s,statement);
        out_a = fscanf(s);
        temp  = sscanf(out_a,'%f');
        power_watts(i) = temp(1);    
    catch
        fprintf('measure_power: error on iteration: %d of %d\n',i,10);
    end
end

pm_lambda = wavelength_out;

% Cannot use this. Not 2D.
% T = cell2table(power_watts,'VariableNames',{'S1','S2','S3','S4','S5','S6','S7','S8','S9','S10'});
% writetable(T,'Power_data.txt', 'RowNames', wavelength);

power_mu  = mean(power_watts);
power_std = std(power_watts);
power_med = median(power_watts);
power_min = min(power_watts);
power_max = max(power_watts);


fprintf('PM Lambda: %f\tMean Power = %e ± %e [W]\n',pm_lambda,power_mu,power_std);

fclose(s);
delete(s);
clear s;
if ~exist('power_watts.mat')
    save ('power_watts.mat','power_watts');
else
    save ('power_watts.mat','power_watts','-append');
end
