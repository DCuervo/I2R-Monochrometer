%Purpose: Retrieve camera settings
%Date:    04-24-2015
%Version: 6.0

javaaddpath(pwd);
        total_image_count = 1;
        if isempty(total_image_count)
            fprintf('mobile2phone: total_image_count must be specified at command line.\n');
            image_files=[];
            return;
        end
        
        %Acquire image with Android.        
        image_count = 0;
        
            
        %IP address of server(Android phone)
        host                     = '192.168.0.12';
        host                     = '127.0.0.1';

        input_dir   = pwd;        
tic
        while image_count < total_image_count    
            %Increment counter
            image_count = image_count + 1;

            fprintf('mobile2phone: Get_Camera_Settings %d of %d...\n',image_count,total_image_count);
            try
                %Issue command for Android to take picture and store on phone
%                 nStatusCode = 0;
%                 nStatusCode = 
                exitCode = 1;
                jMatClient(host, 'Get_Camera_Settings','1')
                                
                if (exitCode == 1)
                    fprintf('mobile2phone: jMatClient(''Get_Camera_Settings'') command completed.\n');
                elseif (exitCode == -1)
                    fprintf('mobile2phone: jMatClient(''Get_Camera_Settings'') command failed.\n');
                elseif (exitCode == -4)
                    fprintf('mobile2phone: jMatClient(''Get_Camera_Settings'') command failed.\n');
                    fprintf('\tfilesystem or file related errors detected on remote device.\n');
                elseif (exitCode == -5)
                    fprintf('mobile2phone: jMatClient(''Get_Camera_Settings'') command failed.\n');
                    fprintf('\the UI or Camera on the Android device is not running.\n');
                else
                    fprintf('mobile2phone: unknown status code: %d\n',exitCode);
                end
            catch
                fprintf('mobile2phone: jMatClient(''Get_Camera_Settings'') command failed.\n');  
                total_image_count = 0;
%                 image_count = image_count - 1;
                str = input('Retry? (Y/N)','s');
                if (strcmpi(str,'N') == 1)
                    image_files=[];
                    break;
                else
                    continue;
                end
            end
        end