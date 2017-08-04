function correct_power_prototype(in_path)
%Purpose: Import power data and generate statistics.
%Date:    06-02-2015
%Version: 6.0
clc;
Power_in        = csvread(fullfile(in_path,'photodiode.csv'),1);
Power_in_dark   = csvread(fullfile(in_path,'photodiode_dark.csv'),1);

Wavelength      = Power_in(:,1);
Power_mu        = Power_in(:,14);
Power_mu_dark   = Power_in_dark(:,14);

figure('Color',[1 1 1]);
plot(Wavelength,Power_mu,'ko-');
xlabel('Wavelength [nm]');
ylabel('Power [W]');
title('Photodiode Power');

figure('Color',[1 1 1]);
plot(Wavelength,Power_mu_dark,'ko-');
xlabel('Wavelength [nm]');
ylabel('Power [W]');
title('Photodiode Power - Dark');

figure('Color',[1 1 1]);
plot(Wavelength,Power_mu - Power_mu_dark,'ko-');
xlabel('Wavelength [nm]');
ylabel('Power [W]');
title('Photodiode Power - Dark Subtracted');

%Remove value at 410,415,420nm and 455,460,465
index_380 = find(Wavelength == 380);

index_410 = find(Wavelength == 410);
index_415 = find(Wavelength == 415);
index_420 = find(Wavelength == 420);

index_455 = find(Wavelength == 455);
index_460 = find(Wavelength == 460);
index_465 = find(Wavelength == 465);

Wavelength_sub2             = Wavelength;
Wavelength_sub2(index_380)  = NaN;
Power_mu_sub                = Power_mu;
Power_mu_sub(index_380)     = NaN;

Power_mu_dark_sub = Power_mu_dark;
Power_mu_dark_sub(index_380) = NaN;
Power_mu_dark_sub(index_410) = NaN;
Power_mu_dark_sub(index_415) = NaN;
Power_mu_dark_sub(index_420) = NaN;
Power_mu_dark_sub(index_455) = NaN;
Power_mu_dark_sub(index_460) = NaN;
Power_mu_dark_sub(index_465) = NaN;

Wavelength_sub = Wavelength;
Wavelength_sub(index_380) = NaN;
Wavelength_sub(index_410) = NaN;
Wavelength_sub(index_415) = NaN;
Wavelength_sub(index_420) = NaN;
Wavelength_sub(index_455) = NaN;
Wavelength_sub(index_460) = NaN;
Wavelength_sub(index_465) = NaN;

Wavelength_sub2(isnan(Wavelength_sub2))     = [];
Wavelength_sub(isnan(Wavelength_sub))       = [];
Power_mu_dark_sub(isnan(Power_mu_dark_sub)) = [];
Power_mu_sub(isnan(Power_mu_sub))           = [];

Power_mu_dark_corr  = interp1(Wavelength_sub,Power_mu_dark_sub,Wavelength);
Power_mu_corr       = interp1(Wavelength_sub2,Power_mu_sub,Wavelength);

figure('Color',[1 1 1]);
plot(Wavelength,Power_mu_corr - Power_mu_dark_corr,'ko-');
xlabel('Wavelength [nm]');
ylabel('Power [W]');
title('Photodiode Power - Dark Subtracted (Corrected)');

figure('Color',[1 1 1]);
plot(Wavelength,Power_mu_corr,'ko-');
xlabel('Wavelength [nm]');
ylabel('Power [W]');
title('Photodiode Power (Corrected)');

figure('Color',[1 1 1]);
plot(Wavelength,Power_mu_dark_corr,'ko-');
xlabel('Wavelength [nm]');
ylabel('Power [W]');
title('Photodiode Power - Dark (Corrected)');



% [fid] = fopen([in_path '\' 'power_final.csv'],'wt');
% for i=1:numel(Wavelength)
%     fprintf(fid,'%15s\t%15g\n',num2str(Wavelength(i)),Power_mu_corr(i) - Power_mu_dark_corr(i));
% end
% fclose(fid);


