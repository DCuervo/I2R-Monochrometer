function [image_file,status] = waitfor_image1(input_dir,archive_dir,wavelength,file_type)
%Purpose: Wait for a JPEG image to appear and move to images directory
%         for further processing
%Date:    04-24-2015
%Version: 6.0

%input_dir:   directory where images are created.
%archive_dir: directory where images are stored for futher analysis.
if ~exist('input_dir','var')
    input_dir = 'C:\mobile2matlab';
end

if ~exist('archive_dir','var')
    archive_dir = 'C:\mobile2matlab\images';
end

%Initialize image_file
image_file = [];

dir_listing = dir([input_dir filesep '*.' file_type]);

while ~isempty(dir_listing)
    if (numel(dir_listing) == 1)
        fprintf('Filename: %s\n',dir_listing(1).name);
        [pathstr,filename,ext]=fileparts(dir_listing(1).name);
        
        source_file = fullfile(input_dir,[filename ext]);
        if wavelength == 1000
            dest_file = fullfile(archive_dir,[filename '_' num2str(wavelength) '_' 'dark' ext]);
        else
        dest_file   = fullfile(archive_dir,[filename '_' num2str(wavelength) 'nm' ext]);
        end
        [SUCCESS,MESSAGE,MESSAGEID] = copyfile(source_file,dest_file,'f');
        if (SUCCESS == 1)
            delete(source_file);
            image_file = dest_file;
            break;
        end
    end
end

    
status = 1;