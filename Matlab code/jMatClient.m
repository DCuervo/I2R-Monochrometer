%1. To use this function, you need to add the directory containing 
%   Client.class from jMatClient to MATLAB's dynamic classpath using the
%   javaaddpath('') command like so:
%
%   >> javaaddpath('C:\My_Matlab_Workspace\that_has_Client_class_inside\');
%
%2. Available command arguments:    
%       ACQUIRE_PICTURE                                 
%       GET_CAMERA_SETTINGS
%       SET_CAMERA_SETTINGS
%
%2a. SET_CAMERA_SETTINGS options:
%
%       ('ISO', 'EXPOSURE_TIME', 'FRAME_DURATION') need to be set as a
%       whole group: overrides ISO and AE
%
%       ('AWB', 'WB_GAIN', 'RGB_TRANSFORM') need to be set as a whole
%       group: overrides AWB if AWB is set to OFF, does nothing otherwise
%
%3. A jMatClient is only allowed to communicate to a MatInstrument device
%   and vice versa. In this version, we specifically use TCP port 56893 in
%   order to ensure that only jMatClient and MatInstrument devices connect
%   to each other.
%
%4. Please ensure that the remote MatInstrument device has a stable WiFi
%   connection and is able to communicate with this client at all times.
%   If MatInstrument's background network service is terminated, then
%   an Exception will be thrown on this client.
%
% examples:
% jMatClient('127.0.0.1','ACQUIRE_PICTURE','1');
% jMatClient('127.0.0.1','SET_CAMERA_SETTINGS','1', 'ISO', 'EXPOSURE_TIME','FRAME_DURATION','~X','400', '62500000', '500000000');
% jMatClient('127.0.0.1','SET_CAMERA_SETTINGS','1','AWB','WB_GAIN','RGB_TRANSFORM','~X','OFF','1.0,0.5,0.5,1.0','124,128;0,128;0,128;0,128;128,128;0,128;0,128;0,128;127,128');
% jMatClient('127.0.0.1','SET_CAMERA_SETTINGS','1','AWB','WB_GAIN','RGB_TRANSFORM','~X','OFF','0.5,1.0,1.0,0.75','124,128;0,128;0,128;0,128;128,128;0,128;0,128;0,128;127,128');
% jMatClient('127.0.0.1','SET_CAMERA_SETTINGS','1','AWB','WB_GAIN','RGB_TRANSFORM','~X','OFF','1.0,1.0,1.0,1.0','124,128;0,128;0,128;0,128;128,128;0,128;0,128;0,128;127,128');


%function exitCode = jMatClient(remote, command, iterations, varargin)
function exitCode = jMatClient(varargin)
    
    driver = Driver;
    
    driver.mainM(varargin);
    
    exitCode = 0;
    
    pause(0.5); %safety delay
    
end