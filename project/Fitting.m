clear all
close all
clc

%NOTE: this script should be inthe same directory of the Traces folder 
files =["Traces/TraceC-Spec.txt";"Traces/TraceC-Design.txt";"Traces/TraceC-Breadbrd.txt";"Traces/TraceC-Software.txt";"Traces/TraceC-Test.txt"];
file = files(2);
fprintf(1,"Using File: "+file+"\n\n")
ServiceTime = csvread(file);
n = size(ServiceTime,1);

figure 
legend
grid on
hold on


%% Compute Metrics

M= zeros(3,1);
for i=1:3
    % .^ is used to do the exponential of all element of the matrix
    M(i)=sum(ServiceTime.^i)/n;
    fprintf(1,"Moment Num %g: %f \n",i,M(i));
end 
standardDeviation = sqrt(M(2)-M(1)^2);
cv = standardDeviation/M(1);
fprintf(1,"Standard Deviation: %f \n",standardDeviation );
fprintf(1,"coefficient of variation: %f \n",cv);
fprintf(1,"\n")

%% METHODS OF MOMENTS
%approximated CDF obtained directly from the dataset
plot(sort(ServiceTime),[1:n]/n,".","DisplayName",'Approx');
legend
grid on
title("CDF METHOD OF MOMENTS")
xlabel("Service times")
hold on

%compute the best range for the x axis 
x_axis=[0:max(ServiceTime)]';

% Uniform Distrubtion with METHODS OF MOMENTS
a = M(1)- 0.5*sqrt(12*(M(2)-M(1)^2));
b = M(1)+ 0.5*sqrt(12*(M(2)-M(1)^2));
fprintf(1,"1) Uniform Distrution Parameters: a= %g \t b=%g\n\n",a,b);


plotUniform = zeros(size(x_axis,1),1);
for i=1:size(x_axis,1)
    if x_axis(i)<a
        plotUniform(i)=0;
    elseif x_axis(i)>b 
        plotUniform(i)=1;
    else 
        plotUniform(i) = (x_axis(i)-a)/(b-a);
    end
end
plot(x_axis,plotUniform,"DisplayName",'Uniform');


% Exponential Distrubtion with METHODS OF MOMENTS
lambda = 1/M(1);
fprintf(1,"2) Exponential Distrution Parameters: l= %g\n\n",lambda);
plotExp = 1-exp(-lambda*x_axis);
plot(x_axis,plotExp,"DisplayName",'Exp');

% Hypo-Exponential Distrubtion with METHODS OF MOMENTS
if cv<=1
    fprintf(1,"SOLVING HYPO LAMBDA EQUATION\n");
    options = optimset('Display','off'); %to avoid verbose in fsolve
    HypoExpMoments = @(p) [(1/p(1) + 1/p(2))/M(1)-1, (2*(1/p(1)^2 + 1/(p(1)*p(2))+1/p(2)^2))/M(2)-1];
    lambda= fsolve(HypoExpMoments,[1/(0.3*M(1)),1/(0.7*M(1))],options);
    fprintf(1,"3)Hypo Lambda Paramenter: l1=%g \t l2=%g\n\n",lambda)

    plotHypo = 1-(lambda(2)*exp(-lambda(1)*x_axis))/(lambda(2)-lambda(1))+(lambda(1)*exp(-lambda(2)*x_axis))/(lambda(2)-lambda(1));
    plot(x_axis,plotHypo,"DisplayName",'Hypo');
    
    % Erlang Distrubtion with METHODS OF MOMENTS
    k=round(1/cv^2);
    lambda=k/M(1);
    plotErlang = computeErlang(k,lambda,x_axis);
    plot(x_axis,plotErlang,"DisplayName",'Erlang');

    fprintf(1,"4)Erlang Paramenter: k=%g \t lambda=%g\n\n",k,lambda)
else
    fprintf(1,"DATA CANNOT FIT HYPO EXPONENTIAL MODEL\n\n");
end 

% Hyper-Exponential Distrubtion with METHODS OF MOMENTS
if cv>=1
    fprintf(1,"SOLVING HYPER LAMBDA EQUATION\n");
    % option is used to increase the "comutational power" of fsolve
    options = optimoptions(@fsolve, "MaxFunctionEvaluation",10000000,"MaxIterations",10000,'Display','off');
    %par = [p1,l1,l2]
    HyperExpMoments = @(par)[(par(1)/par(2)+(1-par(1))/par(3))/M(1)-1,(2*(par(1)/par(2)^2 + (1-par(1))/par(3)^2))/M(2)-1,(6*(par(1)/par(2)^3+(1-par(1))/par(3)^3))/M(3)-1];
    
    lambda = fsolve(HyperExpMoments,[0.4,0.8/M(1), 1.2/M(1)],options); 
    fprintf(1,"3) Hyper Lambda Paramenter: l1=%g \t l2=%g p1=%g\t \n\n",lambda(2),lambda(3),lambda(1));
    
    plotHyper=1- lambda(1)*exp(-lambda(2)*x_axis)-(1-lambda(1))*exp(-lambda(3)*x_axis);
    plot(x_axis,plotHyper,"DisplayName",'Hyper');
else
    fprintf(1,"DATA CANNOT FIT HYPER EXPONENTIAL MODEL\n\n");
end


% Gamma Distrubtion with METHODS OF MOMENTS
k = 1/cv^2;
theta = M(1)/k;
% Define the CDF function
plotGamma = gamcdf(x_axis,k,theta);
plot(x_axis,plotGamma,"DisplayName",'Gamma');
fprintf(1,"5)Gamma Paramenter: k=%g \t theta=%g\n\n",k,theta)


function x = computeErlang(k,lambda,Time)
    val=zeros(size(Time,1),1);
    for i=0:k-1
        val = val+(1/factorial(i)).*exp(-lambda*Time).*(lambda*Time).^i;
    end
    x=1-val;
end


