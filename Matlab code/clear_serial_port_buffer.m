function [status] = clear_serial_port_buffer(s)
%Purpose: Clear the serial port buffer.
%Date:    04-24-2015
%Version: 6.0


warning('off','MATLAB:serial:fscanf:unsuccessfulRead');
try
    while (~isempty(fscanf(s)))
    end
    status = 1;
catch
   status = 0; 
end
warning('on','MATLAB:serial:fscanf:unsuccessfulRead');




