function [sat_flag,status] = saturation_test(filename,dng_type)
%Purpose: Test if image in file is saturated.
%Date:    04-24-2015
%Version: 6.0

%Input:   filename - image file to test for saturation
%         type     - 1 imread
%                  - 2 Tiff class
tic
if ~exist('filename','var')
   [filename,pathname] = uigetfile('*.jpg'); 
   filename = fullfile(pathname,filename);
end


[file_path,file_name,file_ext] = fileparts(filename);
if (strcmp(file_ext,'.jpg')==1)
    I = single(imread(filename));
    max_dn = 255;
elseif (strcmp(file_ext,'.dng')==1)
    [I,bps] = dng2rgb(filename,dng_type);
    I       = single(I);
    if isempty(bps)
       sat_flag = [];
       status   = -1;
       return;
    end
    max_dn  = (2.^bps - 1);
else
   sat_flag = [];
   status   = -1;
   return;
end

Ir = I(:,:,1);
Ig = I(:,:,2);
Ib = I(:,:,3);

Ir_ndcs = find(Ir==max_dn);
Ig_ndcs = find(Ig==max_dn);
Ib_ndcs = find(Ib==max_dn);

fprintf('Saturation Test: %s\n',filename);

if (numel(Ir_ndcs) > 0) 
   fprintf('Image is saturated in red band.\n'); 
   sat_flag = 1;
end

if (numel(Ig_ndcs) > 0) 
   fprintf('Image is saturated in green band.\n'); 
   sat_flag = 1;
end

if (numel(Ib_ndcs) > 0) 
   fprintf('Image is saturated in blue band.\n'); 
   sat_flag = 1;
end

if ((numel(Ir_ndcs) == 0) && (numel(Ig_ndcs) == 0) && (numel(Ib_ndcs) == 0))
    fprintf('Image is not saturated in any band.\n');
    sat_flag = 0;
end
toc    
status = 1;
