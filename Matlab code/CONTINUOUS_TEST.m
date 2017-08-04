s = serial('COM12');
set(s, 'BaudRate', 19200, 'Terminator','CR','Timeout',1);
fopen(s);
fprintf(s,'*rst'); %reset instrument
pause(10);
current_amps = [];
i = 1;
tic
while(~(toc > 60))

    try
        fprintf(s,'curr:dc:rang 0.01'); % set current range
        fprintf(s,'func "curr:dc";:read?'); %read current range
        current_amps(i,1) = toc;
        out = fscanf(s);
        out(double(out)<43)=[];
        %out = eval(out(2:end-2)); %remove extra characters and eval
        
        current_amps(i,2) = eval(out);
    catch
        fprintf('Error');
        break;
%         i = i-1;
%         fprintf(s,'*rst'); %reset instrument
%         pause(0.1);
%         fprintf('Failed to read multimeter. Trying again\n');
    end
    i=i+1;
end
fclose(s);
clear s;
