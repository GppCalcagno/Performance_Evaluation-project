clear all
close all
clc

dataset = csvread("Traces.csv"); 
index = 1;

ServiceTime = dataset(:,index);

Num = size(ServiceTime,1);
SortedST = sort(ServiceTime);

fprintf(1,"DATASET N: %g\n",index);

%The first five moments
M= zeros(3,1);
for i=1:3
    % .^ is used to do the exponential of all element of the matrix
    M(i)=sum(ServiceTime.^i)/Num;
    fprintf(1,"Moment Num %g: %g \n",i,M(i));
end 
standardDeviation = sqrt(M(2)-M(1)^2);
cv = standardDeviation/M(1);
fprintf(1,"Standard Deviation: %g \n",standardDeviation );
fprintf(1,"coefficient of variation: %g \n",cv);
fprintf(1,"\n") 


%% METHODS OF MOMENTS
%approximated CDF obtained directly from the dataset
plot(SortedST,[1:Num]/Num,"DisplayName",'Approx');
legend
grid on
title("CDF METHOD OF MOMENTS")
xlabel("Service times")
hold on

% Uniform Distrubtion with METHODS OF MOMENTS
a = M(1)- 0.5*sqrt(12*(M(2)-M(1)^2));
b = M(1)+ 0.5*sqrt(12*(M(2)-M(1)^2));
fprintf(1,"Uniform Distrution Parameters: a= %g \t b=%g\n\n",a,b);

%used a time to plot
Time=[0:0.1:max(ServiceTime)]';
plotUniform = zeros(size(Time,1),1);
for i=1:size(Time,1)
    if Time(i)<a
        plotUniform(i)=0;
    elseif Time(i)>b 
        plotUniform(i)=1;
    else 
        plotUniform(i) = (Time(i)-a)/(b-a);
    end
end
plot(Time,plotUniform,"DisplayName",'Uniform');


% Exponential Distrubtion with METHODS OF MOMENTS
lambda = 1/M(1);
fprintf(1,"Exponential Distrution Parameters: l= %g\n\n",lambda);
plotExp = 1-exp(-lambda*Time);
plot(Time,plotExp,"DisplayName",'Exp');

% Hypo-Exponential Distrubtion with METHODS OF MOMENTS
if cv<=1
    fprintf(1,"SOLVING HYPO LAMBDA EQUATION\n");
    options = optimset('Display','off'); %to avoid verbose in fsolve
    HypoExpMoments = @(p) [(1/p(1) + 1/p(2))/M(1)-1, (2*(1/p(1)^2 + 1/(p(1)*p(2))+1/p(2)^2))/M(2)-1];
    lambda= fsolve(HypoExpMoments,[1/(0.3*M(1)),1/(0.7*M(1))],options);
    fprintf(1,"Hypo Lambda Paramenter: l1=%g \t l2=%g\n\n",lambda)

    plotHypo = 1-(lambda(2)*exp(-lambda(1)*Time))/(lambda(2)-lambda(1))+(lambda(1)*exp(-lambda(2)*Time))/(lambda(2)-lambda(1));
    plot(Time,plotHypo,"DisplayName",'Hypo');
else
    fprintf(1,"DATA CANNOT FIT HYPO EXPONENTIAL MODEL\n\n");
end 

% Hyper-Exponential Distrubtion with METHODS OF MOMENTS
if cv>=1
    fprintf(1,"SOLVING HYPER LAMBDA EQUATION\n");
    %par = [p1,l1,l2], option is used to increase the "comutational power" %of fsolve
    options = optimoptions(@fsolve, "MaxFunctionEvaluation",10000000,"MaxIterations",10000000,'Display','off');
    HyperExpMoments = @(par)[(par(1)/par(2)+(1-par(1))/par(3))/M(1)-1,(2*(par(1)/par(2)^2 + (1-par(1))/par(3)^2))/M(2)-1,(6*(par(1)/par(2)^3+(1-par(1))/par(3)^3))/M(3)-1];
    
    lambda = fsolve(HyperExpMoments,[0.4,0.8/M(1), 1.2/M(1)],options); 
    fprintf(1,"Hyper Lambda Paramenter: l1=%g \t l2=%g p1=%g\t \n\n",lambda(2),lambda(3),lambda(1));
    
    plotHyper=1- lambda(1)*exp(-lambda(2)*Time)-(1-lambda(1))*exp(-lambda(3)*Time);
    plot(Time,plotHyper,"DisplayName",'Hyper');
else
    fprintf(1,"DATA CANNOT FIT HYPER EXPONENTIAL MODEL\n\n");
end

fprintf(1,"---------------------------------- \n\n");
%% METHODS OF Maxinum Likehood
%approximated CDF obtained directly from the dataset
figure
plot(SortedST,[1:Num]/Num,"DisplayName",'Approx');
legend
grid on
title("CDF METHOD OF MAXIMUM LIKELIHOOD")
xlabel("Service times")
hold on

%Exponential
lambda = Num/sum(SortedST);
fprintf(1,"Exponential Distrution Parameters: l= %g\n\n",lambda); 
plotExp2 = 1-exp(-lambda*Time);
plot(Time,plotExp2,"DisplayName",'Exp');
 

% Hypo-exponential Distrubtion with METHODS OF MAXIMUM LIKELIHOOD
if cv<=1
    fprintf(1,"SOLVING HYPO LAMBDA EQUATION\n");
    HypoPDF = @(t, l1, l2) [(l1*l2)/(l1-l2)*(exp(-l2*t)-exp(-l1*t))];
    lambda = mle(ServiceTime, 'PDF', HypoPDF, 'Start', [1/(0.3*M(1)),1/(0.7*M(1))], 'LowerBound', [0.00001, 0.00001], 'UpperBound', [Inf, Inf]);
    plotHypo = 1-(lambda(2)*exp(-lambda(1)*Time))/(lambda(2)-lambda(1))+(lambda(1)*exp(-lambda(2)*Time))/(lambda(2)-lambda(1));
    fprintf(1,"Hypo Lambda Paramenter: l1=%g \t l2=%g\n\n",lambda(1), lambda(2));
    plot(Time,plotHypo,"DisplayName",'Hypo');
else
    fprintf(1,"DATA CANNOT FIT HYPO EXPONENTIAL MODEL\n\n");
end 

% Hyper-exponential Distrubtion with METHODS OF MAXIMUM LIKELIHOOD
if cv>=1
    fprintf(1,"SOLVING HYPER LAMBDA EQUATION\n");
    HyperPDF = @(t,l1, l2, p1) (p1*l1*exp(-l1*t) + (1-p1)*l2*exp(-l2*t));
    lambda = mle(ServiceTime, 'PDF', HyperPDF, 'Start', [0.8/M(1), 1.2/M(1), 0.4], 'LowerBound', [0.00001, 0.00001, 0.00001], 'UpperBound', [Inf, Inf, Inf]);
    plotHyper = 1 - ((lambda(3) * exp(-lambda(1)*Time)) + ((1-lambda(3)) * exp(-lambda(2)*Time)));
    fprintf(1,"Hyper Lambda Paramenter: l1=%g \t l2=%g \tp=%g\n\n",lambda)
    plot(Time,plotHyper,"DisplayName",'Hyper');
else
    fprintf(1,"DATA CANNOT FIT HYPER EXPONENTIAL MODEL\n\n");
end