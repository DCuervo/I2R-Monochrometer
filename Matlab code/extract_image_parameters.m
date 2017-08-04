function [exp_time,fnum,iso,ap] = extract_image_parameters(file_to_process)
%Purpose: Extract image parameters: ExposureTime, FNumber, ISOSpeedRatings, Aperture
%Date:    04-24-2015
%Version: 6.0

exp_time = [];
fnum     = [];
iso      = [];
ap       = [];
                
imginfo = imfinfo(file_to_process);
if ~isempty(imginfo)
    if isfield(imginfo,'DigitalCamera')
        if (isfield(imginfo.DigitalCamera,'ExposureTime') && ...
            isfield(imginfo.DigitalCamera,'FNumber')      && ...
            isfield(imginfo.DigitalCamera,'ISOSpeedRatings') && ...
            isfield(imginfo.DigitalCamera,'ApertureValue'))
                fprintf('\tExposure Time = %f\n',imginfo.DigitalCamera.ExposureTime); %0.0588
                fprintf('\tF#            = %f\n',imginfo.DigitalCamera.FNumber);      %2.6500
                fprintf('\tISO Ratings   = %d\n',imginfo.DigitalCamera.ISOSpeedRatings);                
                fprintf('\tAperture      = %f\n\n',imginfo.DigitalCamera.ApertureValue);
                
                exp_time = imginfo.DigitalCamera.ExposureTime;
                fnum     = imginfo.DigitalCamera.FNumber;
                iso      = imginfo.DigitalCamera.ISOSpeedRatings;
                ap       = imginfo.DigitalCamera.ApertureValue;
        end
    end
end