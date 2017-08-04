function [rgb_img,bits_per_sample] = dng2rgb(dng_filename,type)
%Purpose:  Read a DNG file and convert to a RGB image
%Date   :  4-24-2015
%Version:  6.0
%Input  :   
%       dng_filename - absolute path to DNG file
%       type         - 1=DNG imread type
%                      2=DNG TIFF class type
%Output :
%       rgb_img      - matrix of image demosaiced to three bands


%Number of histogram bins
hist_bins = 64;

%Extract filename from absolute path of filename
[~,filename] = fileparts(dng_filename);

%Bayer type of mosaiced image. Pattern of four pixels that image is
%organized in.
bayer_type          = 'rggb';

%Read DNG image; DNG image is basically a TIFF file.
if type == 1
    raw                 = imread(dng_filename);
    raw_info            = imfinfo(dng_filename);
    bits_per_sample     = raw_info.BitsPerSample;
elseif type == 2
   % - - - Reading file - - -
    warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning
    t = Tiff(dng_filename,'r');
    offsets = getTag(t,'SubIFD');
    setSubDirectory(t,offsets(1));
    raw = read(t);
    close(t);
    warning on MATLAB:tifflib:TIFFReadDirectory:libraryWarning
    meta_info = imfinfo(dng_filename);
    x_origin = meta_info.SubIFDs{1}.ActiveArea(2)+1;
    width = meta_info.SubIFDs{1}.DefaultCropSize(1);
    y_origin = meta_info.SubIFDs{1}.ActiveArea(1)+1;
    height = meta_info.SubIFDs{1}.DefaultCropSize(2);
    raw =raw(y_origin:y_origin+height-1,x_origin:x_origin+width-1);
    bits_per_sample = [];
end

%Demosaic image into RGB image.
rgb_img             = double(demosaic(raw,bayer_type));

%Create three bands of r,g,b data for display purposes.
r = rgb_img(:,:,1);
g = rgb_img(:,:,2);
b = rgb_img(:,:,3);
fig_flag = 0;

%Statistics
[mu_r,std_r,med_r,min_r,max_r] = statistics(r);
[mu_g,std_g,med_g,min_g,max_g] = statistics(g);
[mu_b,std_b,med_b,min_b,max_b] = statistics(b);


if (fig_flag == 1)
    %figure('Color',[1 1 1]);
    %imagesc(raw);colormap(gray(256));
    %ht = title(['Original: ' filename]);set(ht,'Interpreter','none');
    %xlabel('Cols');
    %ylabel('Rows');

    figure('Color',[1 1 1]);
    subplot(2,3,1);
    imagesc(r);colormap(gray(256));axis equal; axis tight;
    ht = title([filename '; demosaic: red']);set(ht,'Interpreter','none');
    xlabel('Cols');
    ylabel('Rows');
    [y,x] = hist(r(:),hist_bins);
    subplot(2,3,4);
    plot(x,y,'r-');
    xlabel('DN');
    ylabel('Counts\\Bin');
    %annotation('textbox', [0,1.0,0.1,0.1],'String', ['mu: ' num2str(mu_r)],['std: ' num2str(std_r)],['med: ' num2str(med_r)],['min: ' num2str(min_r)],['max: ' num2str(max_r)]);

    
    subplot(2,3,2);
    imagesc(g);colormap(gray(256));axis equal;axis tight;
    ht = title([filename '; demosaic: green']);set(ht,'Interpreter','none');
    xlabel('Cols');
    ylabel('Rows');
    [y,x] = hist(g(:),hist_bins);
    subplot(2,3,5);
    plot(x,y,'g-');
    xlabel('DN');
    ylabel('Counts\\Bin');

    
    subplot(2,3,3);
    imagesc(b);colormap(gray(256));axis equal; axis tight;
    ht = title([filename '; demosaic: blue']);set(ht,'Interpreter','none');
    xlabel('Cols');
    ylabel('Rows');
    [y,x] = hist(b(:),hist_bins);
    subplot(2,3,6);
    plot(x,y,'b-');
    xlabel('DN');
    ylabel('Counts\\Bin');

    rn = (r - min(r(:)))./(max(r(:)) - min(r(:)));
    gn = (g - min(g(:)))./(max(g(:)) - min(g(:)));
    bn = (b - min(b(:)))./(max(b(:)) - min(b(:)));

    rgbn(:,:,1) = rn;
    rgbn(:,:,2) = gn;
    rgbn(:,:,3) = bn;

    %figure;
    %image(rgbn);
    %xlabel('Cols');
    %ylabel('Rows');
    %ht = title([filename '; demosaic: RGB']);
    %set(ht,'Interpreter','none');
end



