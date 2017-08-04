function [wavelength_out] = set_monochromator_dark(wavelength_in)
%Purpose: Set monochronometer wavelength to a value and return the
%         actual wavelength 
%Date:    04-24-2015
%Version: 6.0

if (~exist('wavelength_in','var'))
    wavelength_in = 1000.0;
end

%Ensure all serial ports are closed.
I = instrfind;
ICOUNT = numel(get(I));
for i=1:ICOUNT
 fclose(I(i));
end

%On Windows7 64 bit machine there are four COM ports 1,2,4,5
%Ports Attempted: COM4
s = serial('COM5');
set(s,'BaudRate',9600,'DataBits',8,'Parity','none','StopBits',1);
fopen(s);

filterNumber = 3;

try    
    currentFilterNumber = get_filter(s);
    
    if (filterNumber ~= currentFilterNumber)
        fprintf('Changing filters from: %d to %d\n',currentFilterNumber,filterNumber);
        fprintf(s,['FILTER ' num2str(filterNumber) char(10)]);    
        fscanf(s);   %70   73   76   84   69   82   32   49   10
        fscanf(s);   %10
        pause(10);
    end
    
    wavelength_out       = 0.0;
    wavelength_threshold = .1;
    
    while (abs(wavelength_out - wavelength_in) > wavelength_threshold)
        
        fprintf(s,['GOWAVE ' num2str(wavelength_in) char(10)]);
        %clear_serial_port_buffer(s);
        fscanf(s);   %71   79   87   65   86   69   32   53   48   48   10
        fscanf(s);   %10
    
        fprintf(s,['WAVE?' uint8(10)]);      
        fscanf(s);
        fscanf(s);
        out  = fscanf(s);
        temp = sscanf(out,'%f');
        wavelength_out = temp(1); 
        
        fprintf('Wavelength In  : %f\n',wavelength_in);
        fprintf('Wavelength Out : %f\n\n',wavelength_out);
    end
catch
    fprintf('Error: monochromator wavelength not set.\n');
    wavelength_out = [];
    return;
end

fclose(s);
delete(s);
clear s;
    
return;





        