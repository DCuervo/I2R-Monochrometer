function asynchronous()
%Purpose: Asynchronous scanning
%Date:    09-20-2015

tic
% masterwavelength provides wvalength vector

mastewavelengths
npoints        = length(wavelengths);


for i=1:npoints
    wavelength_in = wavelengths(i);
           
    [wavelength_out] = set_monochromator(wavelength_in);  %uses Serial RS-232 connection 
    fprintf('\n');  
    pause(9);
    
    
end

toc

end