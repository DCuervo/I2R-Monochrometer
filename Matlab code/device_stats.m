function device_stats(in_path,device_file_in,device_file_in_dark,band_str)
%Purpose: Import device data and generate statistics.
%Date:    04-24-2015
%Version: 6.0

%Input:
%   device_file_in = name of csv file for camera\android DN data
%   device_file_in_dark = name of csv file for camera\android dark DN data
%   band_str = 'blu', 'grn', 'red'

Device_in        = csvread(fullfile(in_path,device_file_in),1);
Device_in_dark   = csvread(fullfile(in_path,device_file_in_dark),1);
Wavelength       = Device_in(:,1);

figure('Color', [1,1,1]);
S1 = plot(Wavelength,Device_in(:,2),'r+-');hold on;
S2 = plot(Wavelength,Device_in(:,3),'go-');
S3 = plot(Wavelength,Device_in(:,4),'b+-');
S4 = plot(Wavelength,Device_in(:,5),'yo-');
S5 = plot(Wavelength,Device_in(:,6),'m+-');

grid on;
xlabel('Wavelength [nm]');
ylabel('DN');
title(['Device Measurements - DN; ' band_str]);
legend([S1 S2 S3 S4 S5],'S1', 'S2', 'S3', 'S4', 'S5');

hold off

%temporal mean	   temporal std	   temporal med	   temporal min	   temporal max
Device_in_mu  = Device_in(:,7);
Device_in_std = Device_in(:,8);
Device_in_med = Device_in(:,9);
Device_in_min = Device_in(:,10);
Device_in_max = Device_in(:,11);

Device_in_mu_dark  = Device_in_dark(:,7);
Device_in_std_dark = Device_in_dark(:,8);
Device_in_med_dark = Device_in_dark(:,9);
Device_in_min_dark = Device_in_dark(:,10);
Device_in_max_dark = Device_in_dark(:,11);

figure('Color',[1 1 1]);
plot(Wavelength,Device_in_mu,'ko-');xlabel('Wavelength [nm]');ylabel('DN');title(['Device Meas. Mean; ' band_str]);
grid on;

subplot(2,2,1);
plot(Wavelength,Device_in_std,'ko-');xlabel('Wavelength [nm]');ylabel('DN');title(['Device Meas. STD; ' band_str]);
grid on;

subplot(2,2,2);
plot(Wavelength,Device_in_med,'ko-');xlabel('Wavelength [nm]');ylabel('DN');title(['Device Meas. Median; ' band_str]);
grid on;

subplot(2,2,[3,4]);
plot(Wavelength,Device_in_min,'b-o',Wavelength,Device_in_max,'r--*');xlabel('Wavelength [nm]');ylabel('DN');title(['Device Meas. Min/Max; ' band_str]);
grid on;

figure('Color', [1,1,1]);
S1 = plot(Wavelength,Device_in(:,2)-Device_in_dark(:,2),'r+-');hold on;
S2 = plot(Wavelength,Device_in(:,3)-Device_in_dark(:,3),'go-');
S3 = plot(Wavelength,Device_in(:,4)-Device_in_dark(:,4),'b+-');
S4 = plot(Wavelength,Device_in(:,5)-Device_in_dark(:,5),'yo-');
S5 = plot(Wavelength,Device_in(:,6)-Device_in_dark(:,6),'m+-');
grid on;
xlabel('Wavelength [nm]');
ylabel('Device Meas. [DN]');
title(['Device Meas.; Dark Subtracted; ' band_str]);
legend([S1 S2 S3 S4 S5],'S1', 'S2', 'S3', 'S4', 'S5');

hold off

figure('Color',[1 1 1]);
plot(Wavelength,Device_in_mu-Device_in_mu_dark,'ko-');xlabel('Wavelength [nm]');ylabel('Device Meas. DN');title(['Device Meas. Mean; Dark Subtracted; ' band_str]);
grid on;

%subplot(2,2,1);
%plot(Power_in(:,1),Device_in_std-Device_in_std_dark,'ko-');xlabel('Wavelength [nm]');ylabel('Device Meas. DN');title(['Device Meas. STD; Dark Subtracted; ' band_str]);
%grid on;

subplot(2,2,2);
plot(Wavelength,Device_in_med-Device_in_med_dark,'ko-');xlabel('Wavelength [nm]');ylabel('Device Meas. DN');title(['Device Meas. Median; Dark Subtracted; ' band_str]);
grid on;

subplot(2,2,[3,4]);
plot(Wavelength,Device_in_min-Device_in_min_dark,'b-o',Wavelength,Device_in_max-Device_in_max_dark,'r--*');xlabel('Wavelength [nm]');ylabel('Device Meas. DN');title(['Device Meas. Min/Max; Dark Subtracted; ' band_str]);
grid on;


title_str  = ['Device Meas.; ' band_str];
xlabel_str = 'Sample Wavelength';
ylabel_str = 'DN';
hfig = [];
for isample = 1:size(Device_in,1)
    dataSet = Device_in(isample,2:6);
    hfig = box_whisker_plot(hfig,dataSet,isample,title_str,xlabel_str,ylabel_str);
end

title_str  = ['Device Bkgd. Meas.; ' band_str];
xlabel_str = 'Sample Wavelength';
ylabel_str = 'DN';
hfig = [];
for isample = 1:size(Device_in_dark,1)
    dataSet = Device_in_dark(isample,2:6);
    hfig = box_whisker_plot(hfig,dataSet,isample,title_str,xlabel_str,ylabel_str);
end