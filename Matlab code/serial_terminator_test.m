%Purpose: Test the serial port communications
%Date:    04-24-2015
%Version: 6.0
clc;
clear all;
I = instrfind;
ICOUNT = numel(get(I));
for i=1:ICOUNT
 fclose(I(i));
end

s = serial('COM5');

%'Terminator','LF' is the default if not specified.
set(s,'BaudRate',9600,'DataBits',8,'Parity','none','StopBits',1,'Terminator','LF');

fopen(s);
statement = 'GOWAVE ';
parameter = '455';

%See page 20; last paragraph regarding proper termination of statements
%default; fprintf(s,'%s\n',[statement parameter char(10)]);
fprintf(s,[statement parameter]);  

%Echo returned from command; see page 20 Commands section.
out = fscanf(s);

out

uint8(out)

fclose(s);
delete(s);
clear s;