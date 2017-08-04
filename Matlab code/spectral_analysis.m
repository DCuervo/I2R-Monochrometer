function spectral_analysis(type,inPath,wavelengthStart,wavelengthStop,stepSize,file_type,dng_type)
%Purpose: Perform spectral analysis on image data taken with camera.
%Date:    04-24-2015
%Version: 6.0
%Input:   type   - 1 = android
%                - 2 = webcam
%         inPath - input directory of data
%         wavelenghStart - starting wavelength of analysis
%         wavelengthStop - ending wavelength of analysis
%         stepSize       - wavelength increment
%         file_type      - 'jpg' or 'dng'
%         dng_type       - 1:imread
%                        - 2:TIFF class


%Type of Region of Interest calc.
roi_type = 2; %1=Auto; 2=Manual

if roi_type == 1
    
    %Defining a Region of Interest
    if type == 1 %android
        inFiles_ROI  = dir(fullfile([inPath '\IMG*' '_560nm.' file_type]));
    elseif type == 2 %webcam
        inFiles_ROI  = dir(fullfile([inPath '\560nm.' file_type]));
    end
    
    if (strcmp(file_type,'jpg')==1)
        imageROI = imread([inPath '\' inFiles_ROI(1).name]); %read in standard image for defining ROI
    end
    
    if (strcmp(file_type,'dng')==1)
        imageROI = dng2rgb([inPath '\' inFiles_ROI(1).name],dng_type);
    end
    
    
    [row1,col1]= find(imageROI(:,:,1) == max(max(imageROI(:,:,1)))); %find locations of maximum DN value for each band
    [row2,col2]= find(imageROI(:,:,2) == max(max(imageROI(:,:,2))));
    [row3,col3] = find(imageROI(:,:,3) == max(max(imageROI(:,:,3))));       
    dnList = [];
    j = 1;
    k = 1;
    l = 1;
    m = 1;
    while j <= length(row1) %loop through Red band max value locations recording DN values
        dnList(m,1:3) = impixel(imageROI,col1(j),row1(j));
        dnList(m,4) = row1(j); dnList(m,5) = col1(j); %record row and column location
        j = j + 1;
        m = m + 1;
    end
    while k <= length(row2) %loop through Green band max value locations recording DN values
        dnList(m,1:3) = impixel(imageROI,col2(k),row2(k));
        dnList(m,4) = row2(k); dnList(m,5) = col2(k); %record row and column location
        k = k + 1;
        m = m + 1;
    end
    while l <= length(row3) %loop through Blue band max value locations recording DN values
        dnList(m,1:3) = impixel(imageROI,col3(l),row3(l));
        dnList(m,4) = row3(l); dnList(m,5) = col3(l); %record row and column location
        l = l + 1;
        m = m + 1;
    end
    roiRows = dnList(:,4) > 100; %filter out values too close to top and bottom edge
    roiCols = find(dnList(:,5) > 100); %Only rows are limited currently. columns may need to be.     
    dnListROI = dnList(roiCols,:,:);
    dnListMax = sum(dnListROI(:,1:3),2); %sum DN values across RGB bands and find maximum
    maxPos = find(dnListMax  == max(dnListMax));
    rowMax = dnListROI(maxPos(1),4);
    colMax = dnListROI(maxPos(1),5);

    %Calculated Region of Interest:
    row_start = rowMax-25;   row_end   = rowMax+25;
    col_start = colMax-25;   col_end   = colMax+25;
end

if roi_type == 2
    %roi = [x_min x_max y_min y_max];
    roi = roi_testfig;
    if isempty(roi)
        fprintf('spectral_analysis: region of interest selection cancelled.\n');
        return;
    end
    x_min = roi(1);
    x_max = roi(2);
    y_min = roi(3);
    y_max = roi(4);    
    row_start = round(y_min);
    row_end   = round(y_max);
    col_start = round(x_min);
    col_end   = round(x_max);
end
    
if type == 1 %android
    inFiles_dark  = dir(fullfile([inPath '\IMG*' '_dark.' file_type]));  
     device_type = 'camera';
elseif type == 2 %webcam
    inFiles_dark  = dir(fullfile([inPath '\dark*.' file_type]));    
     device_type = 'webcam';
end

% % Import the photodiode data from the csv. First column is wavelength, and
% % the second is the measurement in W
photodiodeFile = [inPath '\' 'power_final.csv'];
photodiodeIn   = load(photodiodeFile);

% % wavelengths defined - currently used to read in imagery
    waves  = wavelengthStart:stepSize:wavelengthStop;
%     
%plot photodiode data: power vs. wavelength
h1 = figure('Color',[1 1 1]);
plot(photodiodeIn(:,1),photodiodeIn(:,2),'ko-');
xlabel('Wavelength [nm]');
ylabel('Power [W]');
title('Photodiode Power');
saveas(h1,[inPath '\' 'photodiode_power.fig']);
saveas(h1,[inPath '\' 'photodiode_power.png']);


image_spatial_mu_vect_r = [];
image_spatial_mu_vect_g = [];
image_spatial_mu_vect_b = [];

image_spatial_mu_vect_r_dark = [];
image_spatial_mu_vect_g_dark = [];
image_spatial_mu_vect_b_dark = [];

imageIn_rv_mu   = [];
imageIn_gv_mu   = [];
imageIn_bv_mu   = [];

imageIn_rv_med_mu = [];
imageIn_gv_med_mu = [];
imageIn_bv_med_mu = [];

imageIn_rv_min  = [];
imageIn_gv_min  = [];
imageIn_bv_min  = [];

imageIn_rv_max  = [];
imageIn_gv_max  = [];
imageIn_bv_max  = [];

%compute mean dark
for ifile = 1:numel(inFiles_dark)
    fprintf('%s; ',inFiles_dark(ifile).name);
end
fprintf('\n');
imageIn_rm = [];
imageIn_gm = [];
imageIn_bm = [];

[fid_drk_red] = fopen([inPath '\'  device_type '_dark_red.csv'],'wt');
fprintf(fid_drk_red,'%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n', ...
    'wavelength', ...
    'S1','S2','S3','S4','S5', ...
    'temporal mean', ...
    'temporal std', ...
    'temporal med', ...
    'temporal min',...
    'temporal max');

[fid_drk_grn] = fopen([inPath '\'  device_type '_dark_grn.csv'],'wt');
fprintf(fid_drk_grn,'%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n', ...
    'wavelength', ...
    'S1','S2','S3','S4','S5', ...
    'temporal mean', ...
    'temporal std', ...
    'temporal med', ...
    'temporal min',...
    'temporal max');

[fid_drk_blu] = fopen([inPath '\'  device_type '_dark_blu.csv'],'wt');
fprintf(fid_drk_blu,'%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n', ...
    'wavelength', ...
    'S1','S2','S3','S4','S5', ...
    'temporal mean', ...
    'temporal std', ...
    'temporal med', ...
    'temporal min',...
    'temporal max');

for ndx = 1:length(inFiles_dark)
    fprintf('\tReading %s\n',inFiles_dark(ndx).name);
    
    % read in the metadata
    info = imfinfo([inPath '\' inFiles_dark(ndx).name]);
       
    % load the imagery   
    if (strcmp(file_type,'jpg')==1)
        imageIn = single(imread([inPath '\' inFiles_dark(ndx).name])); %read in standard image for defining ROI
    end
    
    if (strcmp(file_type,'dng')==1)
        imageIn = single(dng2rgb([inPath '\' inFiles_dark(ndx).name],dng_type));
    end
    
    imageIn_r = imageIn(row_start:row_end,col_start:col_end,1);
    imageIn_g = imageIn(row_start:row_end,col_start:col_end,2);
    imageIn_b = imageIn(row_start:row_end,col_start:col_end,3); 
    
    imageIn_rm(:,:,ndx) = imageIn_r;
    imageIn_gm(:,:,ndx) = imageIn_g;
    imageIn_bm(:,:,ndx) = imageIn_b; 
    
    image_spatial_mu_vect_r_dark(ndx) = mean(imageIn_r(:));
    image_spatial_mu_vect_g_dark(ndx) = mean(imageIn_g(:));
    image_spatial_mu_vect_b_dark(ndx) = mean(imageIn_b(:));
end

temporal_mu  =  mean(image_spatial_mu_vect_r_dark(:));
temporal_std =  std(image_spatial_mu_vect_r_dark(:));
temporal_med =  median(image_spatial_mu_vect_r_dark(:));
temporal_min =  min(image_spatial_mu_vect_r_dark(:));
temporal_max =  max(image_spatial_mu_vect_r_dark(:));
fprintf(fid_drk_red,'%15s\t%15g\t%15g\t%15g\t%15g\t%15g\t%15s\t%15s\t%15s\t%15s\t%15s\n',...
        num2str(1000.0), ...
        image_spatial_mu_vect_r_dark, ...
        num2str(temporal_mu), ...
        num2str(temporal_std), ...
        num2str(temporal_med), ...
        num2str(temporal_min), ...
        num2str(temporal_max));
    
temporal_mu  =  mean(image_spatial_mu_vect_g_dark(:));
temporal_std =  std(image_spatial_mu_vect_g_dark(:));
temporal_med =  median(image_spatial_mu_vect_g_dark(:));
temporal_min =  min(image_spatial_mu_vect_g_dark(:));
temporal_max =  max(image_spatial_mu_vect_g_dark(:));
fprintf(fid_drk_grn,'%15s\t%15g\t%15g\t%15g\t%15g\t%15g\t%15s\t%15s\t%15s\t%15s\t%15s\n',...
        num2str(1000.0), ...
        image_spatial_mu_vect_g_dark, ...
        num2str(temporal_mu), ...
        num2str(temporal_std), ...
        num2str(temporal_med), ...
        num2str(temporal_min), ...
        num2str(temporal_max));
    
temporal_mu  =  mean(image_spatial_mu_vect_b_dark(:));
temporal_std =  std(image_spatial_mu_vect_b_dark(:));
temporal_med =  median(image_spatial_mu_vect_b_dark(:));
temporal_min =  min(image_spatial_mu_vect_b_dark(:));
temporal_max =  max(image_spatial_mu_vect_b_dark(:));
fprintf(fid_drk_blu,'%15s\t%15g\t%15g\t%15g\t%15g\t%15g\t%15s\t%15s\t%15s\t%15s\t%15s\n',...
        num2str(1000.0), ...
        image_spatial_mu_vect_b_dark, ...
        num2str(temporal_mu), ...
        num2str(temporal_std), ...
        num2str(temporal_med), ...
        num2str(temporal_min), ...
        num2str(temporal_max));
fclose(fid_drk_red);    
fclose(fid_drk_grn);
fclose(fid_drk_blu);

%Dark Image median
imageIn_rmedian_dark = median(imageIn_rm,3);
imageIn_gmedian_dark = median(imageIn_gm,3);
imageIn_bmedian_dark = median(imageIn_bm,3);
    
%Dark Image mean
imageIn_rmean_dark = mean(imageIn_rm,3);
imageIn_gmean_dark = mean(imageIn_gm,3);
imageIn_bmean_dark = mean(imageIn_bm,3);


[fid_red] = fopen([inPath '\'  device_type '_red.csv'],'wt');
[fid_grn] = fopen([inPath '\'  device_type '_grn.csv'],'wt');
[fid_blu] = fopen([inPath '\'  device_type '_blu.csv'],'wt');

fprintf(fid_red,'%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n', ...
    'wavelength', ...
    'S1','S2','S3','S4','S5', ...
    'temporal mean', ...
    'temporal std', ...
    'temporal med', ...
    'temporal min',...
    'temporal max');

fprintf(fid_grn,'%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n', ...
    'wavelength', ...
    'S1','S2','S3','S4','S5', ...
    'temporal mean', ...
    'temporal std', ...
    'temporal med', ...
    'temporal min',...
    'temporal max');

fprintf(fid_blu,'%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\t%15s\n', ...
    'wavelength', ...
    'S1','S2','S3','S4','S5', ...
    'temporal mean', ...
    'temporal std', ...
    'temporal med', ...
    'temporal min',...
    'temporal max');

for w = 1:length(waves)
    file_wave   = num2str(waves(w));     
     
    if type == 1 %android
        inFiles_data  = dir(fullfile([inPath '\IMG*' '_' file_wave 'nm.' file_type]));
    elseif type ==2 %webcam
        inFiles_data  = dir(fullfile([inPath '\' file_wave 'nm*.' file_type]));
    end
        
    % do it this way so that individual wavelengths can be skipped above
    % (using the waves variable) if necessary
%     photoIDX      = find(photodiodeIn(:,1) == waves(w));
%     photodiode(w) = photodiodeIn(photodiodeIn(:,1) == waves(w),2);
%     
    % find all of the image files for each wavelength
    
    fprintf('Files to process; lambda = %s:\n',file_wave);
    for ifile = 1:numel(inFiles_data)
        fprintf('%s; ',inFiles_data(ifile).name);
    end
    fprintf('\n');
        
    % initialize variables
    idx = 0;    imageVec = [];
    % loop through the image files for each wavelength and sum   
    
    imageIn_rm = [];
    imageIn_gm = [];
    imageIn_bm = [];
            
    
    
    for ndx = 1:length(inFiles_data)
        fprintf('\tReading %s\n',inFiles_data(ndx).name);
        % read in the metadata
        info    = imfinfo([inPath '\' inFiles_data(ndx).name]);
        if type == 1 %android
            [exp_time,fnum,iso,ap] = extract_image_parameters([inPath '\' inFiles_data(ndx).name]);
        end
        numRows = info.Height;
        numCols = info.Width;        
       
        % load the imagery        
        if (strcmp(file_type,'jpg')==1)
            imageIn = single(imread([inPath '\' inFiles_data(ndx).name])); %read in standard image for defining ROI
        end
    
        if (strcmp(file_type,'dng')==1)
            imageIn = single(dng2rgb([inPath '\' inFiles_data(ndx).name],dng_type));
        end
        
        %Extract spatial region; where monochromator is known to have
        %produced an image.
        imageIn_r = imageIn(row_start:row_end,col_start:col_end,1);
        imageIn_g = imageIn(row_start:row_end,col_start:col_end,2);
        imageIn_b = imageIn(row_start:row_end,col_start:col_end,3);
        
        imageIn_rm(:,:,ndx) = imageIn_r;
        imageIn_gm(:,:,ndx) = imageIn_g;
        imageIn_bm(:,:,ndx) = imageIn_b;    
        
        image_spatial_mu_vect_r(ndx) = mean(imageIn_r(:));
        image_spatial_mu_vect_g(ndx) = mean(imageIn_g(:));
        image_spatial_mu_vect_b(ndx) = mean(imageIn_b(:));
    end
    
    temporal_mu  =  mean(image_spatial_mu_vect_r(:));
    temporal_std =  std(image_spatial_mu_vect_r(:));
    temporal_med =  median(image_spatial_mu_vect_r(:));
    temporal_min =  min(image_spatial_mu_vect_r(:));
    temporal_max =  max(image_spatial_mu_vect_r(:));
    fprintf(fid_red,'%15s\t%15g\t%15g\t%15g\t%15g\t%15g\t%15s\t%15s\t%15s\t%15s\t%15s\n',...
        file_wave, ...
        image_spatial_mu_vect_r, ...
        num2str(temporal_mu), ...
        num2str(temporal_std), ...
        num2str(temporal_med), ...
        num2str(temporal_min), ...
        num2str(temporal_max));
    
    temporal_mu  =  mean(image_spatial_mu_vect_g(:));
    temporal_std =  std(image_spatial_mu_vect_g(:));
    temporal_med =  median(image_spatial_mu_vect_g(:));
    temporal_min =  min(image_spatial_mu_vect_g(:));
    temporal_max =  max(image_spatial_mu_vect_g(:));
    fprintf(fid_grn,'%15s\t%15g\t%15g\t%15g\t%15g\t%15g\t%15s\t%15s\t%15s\t%15s\t%15s\n',...
        file_wave, ...
        image_spatial_mu_vect_g, ...
        num2str(temporal_mu), ...
        num2str(temporal_std), ...
        num2str(temporal_med), ...
        num2str(temporal_min), ...
        num2str(temporal_max));
    
    temporal_mu  =  mean(image_spatial_mu_vect_b(:));
    temporal_std =  std(image_spatial_mu_vect_b(:));
    temporal_med =  median(image_spatial_mu_vect_b(:));
    temporal_min =  min(image_spatial_mu_vect_b(:));
    temporal_max =  max(image_spatial_mu_vect_b(:));
    fprintf(fid_blu,'%15s\t%15g\t%15g\t%15g\t%15g\t%15g\t%15s\t%15s\t%15s\t%15s\t%15s\n',...
        file_wave, ...
        image_spatial_mu_vect_b, ...
        num2str(temporal_mu), ...
        num2str(temporal_std), ...
        num2str(temporal_med), ...
        num2str(temporal_min), ...
        num2str(temporal_max));
    
    
    %Image mean; dark subtracted
    imageIn_rmu = mean(imageIn_rm,3);
    imageIn_gmu = mean(imageIn_gm,3);
    imageIn_bmu = mean(imageIn_bm,3);
    
    imageIn_rmu = mean(imageIn_rm,3) - imageIn_rmean_dark;
    imageIn_gmu = mean(imageIn_gm,3) - imageIn_gmean_dark;
    imageIn_bmu = mean(imageIn_bm,3) - imageIn_bmean_dark;
    
    
     %Image median; dark subtracted
    imageIn_rmedian = median(imageIn_rm,3);
    imageIn_gmedian = median(imageIn_gm,3);
    imageIn_bmedian = median(imageIn_bm,3);
    
    imageIn_rmedian = median(imageIn_rm,3) - imageIn_rmedian_dark;
    imageIn_gmedian = median(imageIn_gm,3) - imageIn_gmedian_dark;
    imageIn_bmedian = median(imageIn_bm,3) - imageIn_bmedian_dark;
    
    %Spatial mean from meas. median
%     imageIn_rv_med_mu(w) = mean(imageIn_rmedian(:));
%     imageIn_gv_med_mu(w) = mean(imageIn_gmedian(:));
%     imageIn_bv_med_mu(w) = mean(imageIn_bmedian(:));

%   Spatial median from meas. mean
    imageIn_rv_med_mu(w) = median(imageIn_rmu(:));
    imageIn_gv_med_mu(w) = median(imageIn_gmu(:));
    imageIn_bv_med_mu(w) = median(imageIn_bmu(:));

        
    %Spatial mean,min,max from meas. mean
    imageIn_rv_mu(w)   = mean(imageIn_rmu(:));
    imageIn_gv_mu(w)   = mean(imageIn_gmu(:));
    imageIn_bv_mu(w)   = mean(imageIn_bmu(:));

    imageIn_rv_min(w)   = min(imageIn_rmu(:));
    imageIn_gv_min(w)   = min(imageIn_gmu(:));
    imageIn_bv_min(w)   = min(imageIn_bmu(:));

    imageIn_rv_max(w)   = max(imageIn_rmu(:));
    imageIn_gv_max(w)   = max(imageIn_gmu(:));
    imageIn_bv_max(w)   = max(imageIn_bmu(:));
    
    %Dark subtracted median
    intValue_red(w) = sum(sum(imageIn_rmedian));
    intValue_grn(w) = sum(sum(imageIn_gmedian));
    intValue_blu(w) = sum(sum(imageIn_bmedian));
     
    
    %erodeImage_red = imerode(imageIn_rmedian,strel('disk',5));
    %erodeImage_grn = imerode(imageIn_gmedian,strel('disk',5));
    %erodeImage_blu = imerode(imageIn_bmedian,strel('disk',5));
    
    %figure('Color',[1 1 1]);
    %subplot(1,3,1);imagesc(erodeImage_red);colormap(gray(256));title([file_wave ' - Red Band (Eroded Median)']);  axis image;colorbar;xlabel('Cols');ylabel('Rows');
    %subplot(1,3,2);imagesc(erodeImage_grn);colormap(gray(256));title([file_wave ' - Green Band (Eroded Median)']);axis image;colorbar;xlabel('Cols');ylabel('Rows');
    %subplot(1,3,3);imagesc(erodeImage_blu);colormap(gray(256));title([file_wave ' - Blue Band (Eroded Median)']); axis image;colorbar;xlabel('Cols');ylabel('Rows');
    
    %figure('Color',[1 1 1]);
    %subplot(1,3,1);imagesc(imageIn_rmu);colormap(gray(256));title([file_wave ' - Red Band (Mean)']);  axis image;colorbar;xlabel('Cols');ylabel('Rows');
    %subplot(1,3,2);imagesc(imageIn_gmu);colormap(gray(256));title([file_wave ' - Green Band (Mean)']);axis image;colorbar;xlabel('Cols');ylabel('Rows');
    %subplot(1,3,3);imagesc(imageIn_bmu);colormap(gray(256));title([file_wave ' - Blue Band (Mean)']); axis image;colorbar;xlabel('Cols');ylabel('Rows');
    
    %FIGURES USED
    %Make a movie of these figure frames
    %figure('Color',[1 1 1]);
    %subplot(1,3,1);imagesc(imageIn_rmedian);colormap(gray(256));title([file_wave ' - Red Band (Median)']);  axis image;colorbar;xlabel('Cols');ylabel('Rows');
    %subplot(1,3,2);imagesc(imageIn_gmedian);colormap(gray(256));title([file_wave ' - Green Band (Median)']);axis image;colorbar;xlabel('Cols');ylabel('Rows');
    %subplot(1,3,3);imagesc(imageIn_bmedian);colormap(gray(256));title([file_wave ' - Blue Band (Median)']); axis image;colorbar;xlabel('Cols');ylabel('Rows');
end

fclose(fid_red);
fclose(fid_grn);
fclose(fid_blu);

%Integrated DN
smoothWaves         = waves(1):waves(end);
smoothIntValue_red  = interp1(waves,intValue_red,smoothWaves);
smoothIntValue_grn  = interp1(waves,intValue_grn,smoothWaves);
smoothIntValue_blu  = interp1(waves,intValue_blu,smoothWaves);
figure('Color',[1 1 1]);

hr = plot(smoothWaves,smoothIntValue_red,'ro-');hold on;
hg = plot(smoothWaves,smoothIntValue_grn,'go-');
hb = plot(smoothWaves,smoothIntValue_blu,'bo-');
grid on;
xlabel('Wavelength [nm]');
ylabel('Integrated Image DN');
if type == 1 %android
    title('Android Integrated Image Values per Wavelength');
elseif type == 2 %webcam
    title('Webcam Integrated Image Values per Wavelength');
end
legend([hr hg hb],'Red Band','Green Band', 'Blue Band');

%Apply power measurement
photodiode              = photodiodeIn(:,2);
ratioValue_red          = intValue_red(:)./photodiode(:);
smoothNormValue_red     = interp1(waves,ratioValue_red,smoothWaves);
normValue_red           = smoothNormValue_red./max(smoothNormValue_red(:));
normValue_red(normValue_red<0)=0;

ratioValue_grn          = intValue_grn(:)./photodiode(:);
smoothNormValue_grn     = interp1(waves,ratioValue_grn,smoothWaves);
normValue_grn           = smoothNormValue_grn./max(smoothNormValue_grn(:));
normValue_grn(normValue_grn<0)=0;

ratioValue_blu          = intValue_blu(:)./photodiode(:);
smoothNormValue_blu     = interp1(waves,ratioValue_blu,smoothWaves);
normValue_blu           = smoothNormValue_blu./max(smoothNormValue_blu(:));
normValue_blu(normValue_blu<0)=0;

outputTable = [intValue_red(:) ratioValue_red(:)./max(ratioValue_red(:)) intValue_grn(:) ratioValue_grn(:)./max(ratioValue_grn(:)) intValue_blu(:) ratioValue_blu(:)./max(ratioValue_blu(:))];


h2 = figure('Color',[1 1 1]);
hr = plot(smoothWaves,normValue_red,'ro-');hold on;
hg = plot(smoothWaves,normValue_grn,'go-');
hb = plot(smoothWaves,normValue_blu,'bo-');
grid on;

xlabel('Wavelength [nm]')
ylabel('Spectral Response');
if type == 1 %android
    title('Android Normalized Spectral Response per Wavelength');
elseif type == 2 %webcam
    title('Webcam Normalized Spectral Response per Wavelength');
end
legend([hr hg hb],'Red Band','Green Band', 'Blue Band');
saveas(h2,[inPath '\' 'spectral_response.fig']);
saveas(h2,[inPath '\' 'spectral_response.png']);
            
h3 = figure('Color',[1 1 1]);
plot(waves,imageIn_rv_med_mu,'ro-');
xlabel('Wavelength [nm]');
ylabel('DN');
title('Spatial Median of Mean Meas. (Red)');
grid on;
saveas(h3,[inPath '\' 'spatial_median_of_mean_meas_red.png']);
saveas(h3,[inPath '\' 'spatial_median_of_mean_meas_red.fig']);

h4 = figure('Color',[1 1 1]);
plot(waves,imageIn_gv_med_mu,'go-');
xlabel('Wavelength [nm]');
ylabel('DN');
title('Spatial Median of Mean Meas. (Green)');
grid on;
saveas(h4,[inPath '\' 'spatial_median_of_mean_meas_green.png']);
saveas(h4,[inPath '\' 'spatial_median_of_mean_meas_green.fig']);

h5 = figure('Color',[1 1 1]);
plot(waves,imageIn_bv_med_mu,'bo-');
xlabel('Wavelength [nm]');
ylabel('DN');
title('Spatial Median of Mean Meas. (Blue)');
grid on;
saveas(h5,[inPath '\' 'spatial_median_of_mean_meas_blue.png']);
saveas(h5,[inPath '\' 'spatial_median_of_mean_meas_blue.fig']);


h6 = figure('Color',[1 1 1]);
hr_mu  = plot(waves,imageIn_rv_mu,'ro-');hold on;
hr_min = plot(waves,imageIn_rv_min,'bv--');
hr_max = plot(waves,imageIn_rv_max,'b^-.');
legend([hr_mu hr_min hr_max],'Mean','Min','Max');
xlabel('Wavelength [nm]');ylabel('DN');
title('Red');
grid on;
saveas(h6,[inPath '\' 'mean_min_max_red.png']);
saveas(h6,[inPath '\' 'mean_min_max_red.fig']);

h7 = figure('Color',[1 1 1]);
hg_mu  = plot(waves,imageIn_gv_mu,'go-');hold on;
hg_min = plot(waves,imageIn_gv_min,'rv--');
hg_max = plot(waves,imageIn_gv_max,'r^-.');
legend([hg_mu hg_min hg_max],'Mean','Min','Max');
xlabel('Wavelength [nm]');ylabel('DN');title('Green');
grid on;
saveas(h7,[inPath '\' 'mean_min_max_green.png']);
saveas(h7,[inPath '\' 'mean_min_max_green.fig']);

h8 = figure('Color',[1 1 1]);
hb_mu  = plot(waves,imageIn_bv_mu,'bo-');hold on;
hb_min = plot(waves,imageIn_bv_min,'rv--');
hb_max = plot(waves,imageIn_bv_max,'r^-.');
legend([hb_mu hb_min hb_max],'Mean','Min','Max');
xlabel('Wavelength [nm]');ylabel('DN');title('Blue'); 
grid on;
saveas(h8,[inPath '\' 'mean_min_max_blue.png']);
saveas(h8,[inPath '\' 'mean_min_max_blue.fig']);

end


