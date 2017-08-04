function powermeter_test
%Purpose: Test commands sent to the power meter
%Date:    04-24-2015
%Version: 6.0



%monochromator test
%fprintf(s,['GOWAVE ' num2str(wavelength_in) char(10)]);
%fprintf(s,['FILTER ' num2str(filterNumber) char(10)]);   
clear all;
I = instrfind;
ICOUNT = numel(get(I));
for i=1:ICOUNT
 fclose(I(i));
end

s = serial('COM1');
set(s,'BaudRate',38400,'Parity','none','DataBits',8,'StopBits',1,'Terminator','CR');
fopen(s);

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

statement = 'PM:Lambda ';
parameter = '504';
fprintf(s,[statement parameter]); %No Parameters returned

statement  = 'PM:Lambda?';
fprintf(s,statement);
out_a = fscanf(s); %500->  53   48   48   13   10

statement = 'PM:PWS?';
fprintf(s,statement);
out_a = fscanf(s); %8.683533E-008 118 0.000000E+000 170 -> 56   46   56   53   53   50   50 ... 13   10


fclose(s);
delete(s);
clear s;




