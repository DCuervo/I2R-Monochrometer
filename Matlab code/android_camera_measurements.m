function image_files = android_camera_measurements(archive_dir,total_image_count,actual_wavelength,ISO,EXPOSURE_TIME,FRAME_DURATION,file_type,dng_type)
%Purpose: Collect data with monochrometer using handheld keypad
%Date:    04-24-2015
%Version: 6.0

        image_files =[];
    
        javaaddpath(pwd);
        
        if isempty(total_image_count)
            fprintf('mobile2phone: total_image_count must be specified at command line.\n');
            image_files=[];
            return;
        end

        %IP address of server(Android phone)
        host = '127.0.0.1';
        
        %Initialize camera settings
        %Original Default Values: 
        %ISO             = '800';
        %EXPOSURE_TIME   = '62500000';
        %FRAME_DURATION  = '500000000';
        jMatClient('127.0.0.1','SET_CAMERA_SETTINGS','1','ISO', 'EXPOSURE_TIME', 'FRAME_DURATION','~X',ISO, EXPOSURE_TIME, FRAME_DURATION);           
        jMatClient('127.0.0.1','SET_CAMERA_SETTINGS','1','AWB','WB_GAIN','RGB_TRANSFORM','~X','OFF','1.0,1.0,1.0,1.0','124,128;0,128;0,128;0,128;128,128;0,128;0,128;0,128;127,128');
        
        %Acquire image with Android.        
        image_count = 0;

        input_dir   = pwd;        
tic
        while image_count < total_image_count    
            %Increment counter
            image_count = image_count + 1;

            fprintf('mobile2phone: acquiring image %d of %d...\n',image_count,total_image_count);
            try
                %Issue command for Android to take picture and store on phone
%                 nStatusCode = 0;
%                 nStatusCode = 
                exitCode = 1;
                jMatClient(host, 'ACQUIRE_PICTURE','1');
                                
                if (exitCode == 1)
                    fprintf('mobile2phone: jMatClient(''ACQUIRE_PICTURE'') command completed.\n');
                elseif (exitCode == -1)
                    fprintf('mobile2phone: jMatClient(''ACQUIRE_PICTURE'') command failed.\n');
                elseif (exitCode == -4)
                    fprintf('mobile2phone: jMatClient(''ACQUIRE_PICTURE'') command failed.\n');
                    fprintf('\tfilesystem or file related errors detected on remote device.\n');
                elseif (exitCode == -5)
                    fprintf('mobile2phone: jMatClient(''ACQUIRE_PICTURE'') command failed.\n');
                    fprintf('\the UI or Camera on the Android device is not running.\n');
                else
                    fprintf('mobile2phone: unknown status code: %d\n',exitCode);
                end
            catch
                fprintf('mobile2phone: jMatClient(''ACQUIRE_PICTURE'') command failed.\n');                
                image_count = image_count - 1;
                str = input('Retry? (Y/N)','s');
                if (strcmpi(str,'N') == 1)
                    image_files=[];
                    break;
                else
                    continue;
                end
            end

            %Move image from server to client
            [image_file,status] = waitfor_image1(input_dir,archive_dir,actual_wavelength,file_type);
          
                      
            %Rel. Spectral Resp. code checks for saturation
%             if (sat_flag == 1)
%                 image_count = 0;
%                 
%                 str = input('Image is saturated. Re-acquire image? (Y/N)','s');
%     
%                 if (strcmpi(str,'N') == 1)
%                     break;
%                 else
%                     continue;
%                 end
%             end
            
            if isempty(image_file)
                fprintf('mobile2phone: Failed.\n') 
            else
                fprintf('mobile2phone: Complete. Image File: %s\n',image_file);   
                image_files{image_count} = image_file;
                
                [sat_flag,status] = saturation_test(image_file,dng_type);
                if isempty(sat_flag)
                    fprintf('mobile2phone: WARNING: Saturation cannot be determined: %s\n',image_file);   
                end
            end          
        end        
toc                    
        fprintf('\n\n');
        return;