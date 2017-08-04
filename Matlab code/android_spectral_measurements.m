function android_spectral_measurements(wavelengthStart,wavelengthStop,stepSize,numberOfImagesPerWavelength,outPath,ISO,EXPOSURE_TIME,FRAME_DURATION,file_type,dng_type)
%Purpose: Acquire DN data from an Android device illuminated by a
%         monochromator.
%Date:    04-24-2015
%Version: 6.0

%Input Parameters:
%wavelengthStart                = starting wavelength for measurements
%wavelenghStop                  = ending wavelength for measurements
%stepSize                       = step size for wavelength range for measurements
%numberOfImagesPerWavelength    = number of images to acquire during
%                                   measurements
%outPath                        = directory to store output imagery
%ISO            = Camera sensitivity; range: [100 ... 10000]
%EXPOSURE_TIME  = Duration each pixel is exposed to light: [13231...866975130]ns
%FRAME_DURATION = Duration from start of frame exposure to start of next
%                   frame exposure; max frame duration: 867028050867028050 ns
%file_type      = 'dng'
%dng_type       = 1 - imread; 2 = TIFF class



tic
wavelengths    = wavelengthStart:stepSize:wavelengthStop;
npoints        = length(wavelengths);
for i=1:npoints
    wavelength_in = wavelengths(i);
    tic 
    [wavelength_out] = set_monochromator(wavelength_in); %uses Serial RS-232 Connection
    fprintf('Wavelength In = %f\n',wavelength_in);  
    fprintf('Wavelength Out = %f\n',wavelength_out);  
    %pause(1);
   
    %Spectral Measurement
    image_files = android_camera_measurements(outPath,numberOfImagesPerWavelength,wavelength_in,ISO,EXPOSURE_TIME,FRAME_DURATION,file_type,dng_type); 
    toc
end
toc
 %Dark Frame Capture
wavelength_in = 1000;
tic
  [wavelength_out] = set_monochromator_dark(wavelength_in); %uses Serial RS-232 Connection
    fprintf('Wavelength In = %f\n',wavelength_in);  
    fprintf('Wavelength Out = %f\n',wavelength_out);  
    pause(1);
    image_filesBG = android_camera_measurements(outPath,numberOfImagesPerWavelength,wavelength_in,ISO,EXPOSURE_TIME,FRAME_DURATION,file_type,dng_type);   
 toc
   