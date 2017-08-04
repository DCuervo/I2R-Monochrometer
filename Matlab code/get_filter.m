function filterNumber = get_filter(s)
%Purpose: Get filter number the monochromator is set to.
%Date:    04-24-2015
%Version: 6.0


%Clear buffers
%clear_serial_port_buffer(s);

%Query monochromator for filter number
fprintf(s,'FILTER?');
fscanf(s);
out  = fscanf(s);
temp = sscanf(out,'%d');
filterNumber = temp(1); 