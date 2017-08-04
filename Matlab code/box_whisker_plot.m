function hfig = box_whisker_plot(hfig,dataSet,data_set_number,title_str,xlabel_str,ylabel_str)
%Purpose: Define a data set with 3 vectors of data
%Date:    04-24-2015
%Version: 6.0



if ~exist('dataSet','var')
    dataSet = randn(30,1);
    data_set_number = 1;
end

if isempty(hfig)
    hfig = figure('Color',[1 1 1]);
else
    figure(hfig);hold on;
end


% A box and whisker plot can be made manaully:
% loop through each vector of data
%for s = 1:3
    s = data_set_number;
    
    % assign each vector to a variable
    %X = dataSet(:,s);
    X = dataSet;
    
    % find the mean and median of the data vector
    meanX(s) = mean(X);
    medianX(s) = median(X);
    
    % find the 1rst and 3rd quartiles of the data vector
    q1X(s) = median(X(X < medianX(s)));
    q3X(s) = median(X(X > medianX(s)));
    
    % find the interquartile range
    IQR(s) = q3X(s) - q1X(s);
    
    % find the maximum and minimum values of the data set
    qmaxX(s) = max(X);    qminX(s) = min(X);
   
    % plot the statistics into a box plot
    v = [s-0.25,q1X(s),0.5,IQR(s)];
    if (isnan(v)==0)
        rectangle('Position',[s-0.25,q1X(s),0.5,IQR(s)]);
    else
        fprintf('box_whisker_plot: quartile values are NaN; data set number = %d\n',data_set_number);
    end
    hold on
    line([s-0.25 s+0.25],[medianX(s) medianX(s)],'Color','r')
    plot(s,meanX(s),'b+')
    line([s s],[q1X(s) qminX(s)],'Color','k','LineStyle','--')
    line([s s],[q3X(s) qmaxX(s)],'Color','k','LineStyle','--')
    line([s-0.15 s+0.15],[qminX(s) qminX(s)],'Color','k')
    line([s-0.15 s+0.15],[qmaxX(s) qmaxX(s)],'Color','k')   
%end
title(title_str);
xlabel(xlabel_str); ylabel(ylabel_str);


% The statistics toolbox has a box and whisker plot as well:
% An alternate version of the plot, ends the whiskers at Q1 - 1.5*IQR and
% Q3 + 1.5*IQR, and shows outliers as well.
%figure
%boxplot(dataSet,'Whisker',1.5)
%title('Box and Whisker Plot Using Statistics Toolbox')
%xlabel('Data Set Number'); ylabel('X with Outliers')


