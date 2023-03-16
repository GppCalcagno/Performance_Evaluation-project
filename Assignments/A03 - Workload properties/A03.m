clear all
dataset = csvread("Data4.txt");
Num = size(dataset,1); 

%The first five moments
moment= zeros(5);
for i=1:5
    % .^ is used to do the exponential of all element of the matrix
    moment(i)=sum(dataset.^i)/Num;
    fprintf(1,"Moment Num %g: %g \n",i,moment(i));
end 
fprintf(1,"\n")

%The second, third, fourth and fifth centered moments
centeredMoment= zeros(5);
mean = moment(1);
arg =dataset-mean;
for i=2:5
    centeredMoment(i)= sum((arg).^i)/Num;
    fprintf(1,"Centered Moment Num %g: %g \n",i,centeredMoment(i));
end
fprintf(1,"\n")

%The third and fourth standardized moments
standardizedMoment = zeros(5);
sigma = sqrt(centeredMoment(2));
arg= (dataset-moment(1))/sigma;
for i=3:5
    standardizedMoment(i)= sum((arg).^i)/Num;
    fprintf(1,"Standardized Moment Num %g: %g \n",i,standardizedMoment(i));
end
fprintf(1,"\n")

%Standard Deviation, Coefficient of Variation and Kurtosis
StandardDeviation = sigma; %sqrt (Variance = Second Center Moment)
CoefficientOfVariation = StandardDeviation/mean;
Kurtosis = standardizedMoment(4)-3;

fprintf(1,"StandardDeviation : %g \n",StandardDeviation);
fprintf(1,"CoefficientOfVariation : %g \n",CoefficientOfVariation);
fprintf(1,"Kurtosis : %g \n\n",Kurtosis);

%CDF from samples
dataset(:,2)= sort(dataset);
line(dataset(:,2),[1:Num]/Num);
grid on
title("Approximated CDF")
xlabel("Inter-arrival times")

%The 10%, 25%, 50%, 75% and 90% percentiles
percentile_index  = [0.10, 0.25, 0.50, 0.75, 0.90];
percentile = zeros(5);
for i = 1:5
    h = (Num-1)*percentile_index(i)+1;
    H=floor(h);
    if isequal(h, Num)
        percentile(i)=dataset(Num,2); %pick the ordered column
    else
        percentile(i)=dataset(H,2)+(h-H)*(dataset(H+1,2)-dataset(H,2));%pick the ordered column
    end 
    fprintf(1,"Percentile %g : %g\n",percentile_index(i)*100,percentile(i));
end
fprintf(1,"\n");

% The cross-covariance for lags m=1, m=2 and m=3
crossCovariance = zeros(3);
for m=1:3
    % .* to do a element*element moltiplication
    %in the second element m+1 is used because m is the distace between the
    %2 elements

    arg = (dataset(1:Num-m,1)-mean).*(dataset(m+1:Num,1)-mean);%pick the NON-ordered column ????
    crossCovariance(m) =sum(arg)/(Num-m);
    fprintf(1,"crossCovariance %g : %g\n",m,crossCovariance(m));
end
fprintf(1,"\n");

%The Pearson Correlation Coefficient for lags m=1, m=2, m=3
PearsonCorrelationCoefficient = crossCovariance /centeredMoment(2);
for i=1:3
    fprintf(1,"PearsonCorrelationCoefficient %g : %g\n",i,PearsonCorrelationCoefficient(i));
end 




