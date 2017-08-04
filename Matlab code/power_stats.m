function power_stats(in_path)
%Purpose: Import power data and generate statistics.
%Date:    04-24-2015
%Version: 6.0

Power_in        = csvread(fullfile(in_path,'photodiode.csv'),2);
Power_in_dark   = csvread(fullfile(in_path,'photodiode_dark.csv'),2);

Wavelength      = Power_in(:,1);
Power_mu        = Power_in(:,14);
Power_mu_dark   = Power_in_dark(:,14);

figure('Color', [1,1,1]);
S1 = plot(Power_in(:,1),Power_in(:,3),'r+-');hold on;
S2 = plot(Power_in(:,1),Power_in(:,4),'go-');
S3 = plot(Power_in(:,1),Power_in(:,5),'b+-');
S4 = plot(Power_in(:,1),Power_in(:,6),'yo-');
S5 = plot(Power_in(:,1),Power_in(:,7),'m+-');
S6 = plot(Power_in(:,1),Power_in(:,8),'co-');
S7 = plot(Power_in(:,1),Power_in(:,9),'bo-');
S8 = plot(Power_in(:,1),Power_in(:,10),'k+-');
S9 = plot(Power_in(:,1),Power_in(:,11),'g+-');
S10 = plot(Power_in(:,1),Power_in(:,12),'ro-');
grid on;
xlabel('Wavelength [nm]');
ylabel('Photodiode Power W');
title('Photodiode Power Measurements - Raw');
legend([S1 S2 S3 S4 S5 S6 S7 S8 S9 S10],'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10');

hold off


figure('Color',[1 1 1]);
plot(Power_in(:,1),Power_in(:,14),'ko-');xlabel('Wavelength [nm]');ylabel('Power [W]');title('Photodiode Power');
grid on;


subplot(2,2,1);
plot(Power_in(:,1),Power_in(:,15),'ko-');xlabel('Wavelength [nm]');ylabel('Power STD [W]');title('Photodiode Power STD');
grid on;

subplot(2,2,2);
plot(Power_in(:,1),Power_in(:,16),'ko-');xlabel('Wavelength [nm]');ylabel('Power Median [W]');title('Photodiode Median Power');
grid on;

subplot(2,2,[3,4]);
plot(Power_in(:,1),Power_in(:,17),'b-o',Power_in(:,1),Power_in(:,18),'r--*');xlabel('Wavelength [nm]');ylabel('Power [W]');title('Photodiode Power Min/Max');
grid on;

figure('Color', [1,1,1]);
Power_final_S1 = plot(Power_in(:,1),Power_in(:,3)-Power_in_dark(:,3),'r+-');hold on;
Power_final_S2 = plot(Power_in(:,1),Power_in(:,4)-Power_in_dark(:,4),'go-');
Power_final_S3 = plot(Power_in(:,1),Power_in(:,5)-Power_in_dark(:,5),'b+-');
Power_final_S4 = plot(Power_in(:,1),Power_in(:,6)-Power_in_dark(:,6),'yo-');
Power_final_S5 = plot(Power_in(:,1),Power_in(:,7)-Power_in_dark(:,7),'m+-');
Power_final_S6 = plot(Power_in(:,1),Power_in(:,8)-Power_in_dark(:,8),'co-');
Power_final_S7 = plot(Power_in(:,1),Power_in(:,9)-Power_in_dark(:,9),'bo-');
Power_final_S8 = plot(Power_in(:,1),Power_in(:,10)-Power_in_dark(:,10),'k+-');
Power_final_S9 = plot(Power_in(:,1),Power_in(:,11)-Power_in_dark(:,11),'g+-');
Power_final_S10 = plot(Power_in(:,1),Power_in(:,12)-Power_in_dark(:,12),'ro-');
grid on;
xlabel('Wavelength [nm]');
ylabel('Photodiode Power W');
title('Photodiode Power Measurements - Dark Subtracted');
legend([S1 S2 S3 S4 S5 S6 S7 S8 S9 S10],'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10');

hold off

figure('Color',[1 1 1]);
plot(Power_in(:,1),Power_in(:,14)-Power_in_dark(:,14),'ko-');xlabel('Wavelength [nm]');ylabel('Power [W]');title('Photodiode Power');
grid on;

subplot(2,2,1);
plot(Power_in(:,1),Power_in(:,15)-Power_in_dark(:,15),'ko-');xlabel('Wavelength [nm]');ylabel('Power STD [W]');title('Photodiode Dark Subtracted Power STD');
grid on;

subplot(2,2,2);
plot(Power_in(:,1),Power_in(:,16)-Power_in_dark(:,16),'ko-');xlabel('Wavelength [nm]');ylabel('Power Median [W]');title('Photodiode Dark Subtracted Median Power');
grid on;

Power_min = Power_in(:,17)-Power_in_dark(:,17);
Power_max = Power_in(:,18)-Power_in_dark(:,18);

subplot(2,2,[3,4]);
plot(Power_in(:,1),Power_min,'b-o',Power_in(:,1),Power_max,'r--*');xlabel('Wavelength [nm]'),ylabel('Power [W]'),title('Photodiode Dark Subtracted Power Min/Max');
grid on;

%Box whisker plot
%Power_in        = csvread(fullfile(in_path,'photodiode.csv'),2);
%Power_in_dark   = csvread(fullfile(in_path,'photodiode_dark.csv'),2);

title_str  = 'Power Meter Meas.';
xlabel_str = 'Sample Wavelength';
ylabel_str = 'W';
hfig = [];
for isample = 1:size(Power_in,1)
    dataSet = Power_in(isample,3:12);
    hfig = box_whisker_plot(hfig,dataSet,isample,title_str,xlabel_str,ylabel_str);
end


title_str  = 'Power Meter Bkgd. Meas.';
xlabel_str = 'Sample Wavelength';
ylabel_str = 'W';
hfig = [];
for isample = 1:size(Power_in_dark,1)
    dataSet = Power_in_dark(isample,3:12);
    hfig = box_whisker_plot(hfig,dataSet,isample,title_str,xlabel_str,ylabel_str);
end