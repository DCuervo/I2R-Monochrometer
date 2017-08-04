%Purpose: Test serial port communications (fail).
%Date:    04-24-2015
%Version: 6.0
clc;
clear all;
I = instrfind;
ICOUNT = numel(get(I));
for i=1:ICOUNT
 fclose(I(i));
end

s = serial('COM1');

%'Terminator','LF' is the default if not specified.
set(s,'BaudRate',9600,'DataBits',8,'Parity','none','StopBits',1,'Terminator','LF');

fopen(s);
statement = 'GOWAVE ';
parameter = '555';

%See page 20; last paragraph regarding proper termination of statements.
%default; fprintf(s,'%s\n',cmd);
fprintf(s,'%s',[statement parameter]);  

out = fscanf(s);

out

uint8(out)


fclose(s);
delete(s);
clear s;