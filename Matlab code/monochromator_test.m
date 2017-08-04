function monochromator_test
%Purpose: Test commands sent to the monochromator
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

%Set using page 13 of Oriel Instruments; CORNERSTONE 260; MOTORIZED 1/4m
%MONOCHROMATOR.
set(s,'BaudRate',9600,'DataBits',8,'Parity','none','StopBits',1,'Terminator','LF');
fopen(s);

statement = 'GOWAVE ';
parameter = '500';
fprintf(s,[statement parameter]);
out_a = fscanf(s);   %71   79   87   65   86   69   32   53   48   48   10


statement  = 'WAVE?';
fprintf(s,[statement]);
%WAVE? echo and response
out_a = fscanf(s);   % 87   65   86   69   63   10
out_b = fscanf(s);   % 53   48   48   46   48   49   48   13   10

%Termination discussed on page 20 of Oriel Instruments; CORNERSTONE 260; MOTORIZED 1/4m
%MONOCHROMATOR.
%statement = 'FILTER ';
%parameter = '1';
%fprintf(s,[statement parameter char(10)]);  
%out_a = fscanf(s);   %70   73   76   84   69   82   32   49   10
%out_b = fscanf(s);   %10

statement = 'FILTER?';
fprintf(s,[statement char(10)]);
out_a = fscanf(s); %70   73   76   84   69   82   63   10
out_b = fscanf(s); %10
out_c = fscanf(s); %49   13   10



fclose(s);
delete(s);
clear s;