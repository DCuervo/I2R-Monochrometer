function [mu_data,std_data,med_data,min_data,max_data] = statistics(data)
%Calculate statistics for data
    mu_data  =  mean(data(:));
    std_data =  std(data(:));
    med_data =  median(data(:));
    min_data =  min(data(:));
    max_data =  max(data(:));
    return