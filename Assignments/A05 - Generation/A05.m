clear all
close all
clc

dataset = csvread("random.csv");
Num = size(dataset,1);

%% 1) A continuous uniform distribution between [5, 15]
a=5;
b=15;
ContinueUniformDistribution = dataset(:,2).*(b-a)+a;
printVal("Continue Uniform Distribution",ContinueUniformDistribution);

% Analytic graph 
x_axis = [1:Num]*max(ContinueUniformDistribution)/Num;
AnalyticPlot = UniformCDF(a,b,x_axis);

plotMygraph("Continue Uniform Distribution CDF",AnalyticPlot,ContinueUniformDistribution);

%% 2) A discrete distribution 
DiscreteDistribution= zeros(500,1);
value = [5,10,15];
prob =[0.3,0.4,0.3];
C = cumsum(prob);

for i=1:500
    for j=1:3
        if dataset(i,1)<C(j)
            DiscreteDistribution(i)=value(j);
            break;
        end
    end
end
printVal("Discrete Distribution",DiscreteDistribution);

%graph
Num = 500;
x_axis = [1:Num]*max(DiscreteDistribution)/Num;
AnalyticPlot = zeros(500,1);
for i=1:500
    if x_axis(i)>=value(1)
        AnalyticPlot(i)=C(1);
    end
    if x_axis(i)>=value(2)
        AnalyticPlot(i)=C(2);
    end 
    if x_axis(i)>=value(3)
        AnalyticPlot(i)=C(3);
    end 
end

plotMygraph("Discrete Distribution CDF",AnalyticPlot,DiscreteDistribution);

%% 3) An exponential distribution with average 10
average = 10;
lambda = 1/average;

ExponentialDistribution = -log(dataset(:,2))/lambda;
printVal("Exponential Distribution",ExponentialDistribution);

% Analytic graph 
x_axis = [1:Num]*max(ExponentialDistribution)/Num;
AnalyticPlot = 1-exp(-lambda*x_axis);

plotMygraph("Exponential Distribution CDF",AnalyticPlot,ExponentialDistribution);

%% 4) An hyper-exponential distribution with two stages, characterized by (l1 = 0.05, l2 = 0.175, p1 = 0.3)
lambda = [0.05, 0.175];
prob = [0.3,0.7];
C = cumsum(prob); %quite useless, could be just a if else in the for
HyperExponentialDistribution = zeros(500,1);
for i=1:500
    for j=1:2
        if dataset(i,1)<=C(j) %first col for pick the branch
            HyperExponentialDistribution(i)= -log(dataset(i,2))/lambda(j); %second col for generation
            break;
        end
    end
end
printVal("Hyper Exponential Distribution",HyperExponentialDistribution);

%Analytical Graph
x_axis = [1:Num]*max(HyperExponentialDistribution)/Num;
AnalyticPlot=1- prob(1)*exp(-lambda(1)*x_axis)-prob(2)*exp(-lambda(2)*x_axis);

plotMygraph("Hyper-Exponential Distribution CDF",AnalyticPlot,HyperExponentialDistribution);

%% 5) An hypo-exponential distribution with two stages characterized by (l1 = 0.25, l2 = 0.16667)
lambda = [0.25, 0.16667];
HypoExponentialDistribution = zeros(500,1);
for i=1:500
    %second and third col for generation
    HypoExponentialDistribution(i)= -log(dataset(i,2))/lambda(1)-log(dataset(i,3))/lambda(2); 
end
printVal("Hypo Exponential Distribution",HypoExponentialDistribution);

%Analytical Graph
x_axis = [1:Num]*max(HypoExponentialDistribution)/Num;
AnalyticPlot = 1-(lambda(2)*exp(-lambda(1)*x_axis))/(lambda(2)-lambda(1))+(lambda(1)*exp(-lambda(2)*x_axis))/(lambda(2)-lambda(1));

plotMygraph("Hypo-Exponential Distribution CDF",AnalyticPlot,HypoExponentialDistribution);

%% 6) An Hyper-Erlang characterized by 2 stages, the following branches, and selection probabilities
lambda =[0.05,0.35];
prob = [0.3,0.7];
K=[1,2];
C = cumsum(prob); %quite useless, could be just a if else in the for
HyperErlangExponentialDistribution = zeros(500,1);
for i=1:500
        if dataset(i,1)<=C(1) %first col for pick the branch
            %pick the first branch -> K=1 -> use only  log(dataset(i,2)
            HyperErlangExponentialDistribution(i)= -log(dataset(i,2))/lambda(1); 
        else
            %pick the second branch -> K=2 -> use both column 2 and 3
            HyperErlangExponentialDistribution(i)= -log(dataset(i,2)*dataset(i,3))/lambda(2); 
        end
end
printVal("Hyper-Erlang Exponential Distribution",HyperErlangExponentialDistribution);

x_axis = [1:Num]*max(HyperErlangExponentialDistribution)/Num;
%Because the integral is a linear operator, the integral of a sum is the
%sum of the integral, i take the formula of the CDF and balanced with the
%probabilities
%https://en.wikipedia.org/wiki/Erlang_distribution
AnalyticPlot = prob(1)*(1-(exp(-lambda(1)*x_axis))) + prob(2)*(1-(exp(-lambda(2)*x_axis)+(exp(-lambda(2)*x_axis)).*(lambda(2)*x_axis)));
    

plotMygraph("Hyper-Erlang Exponential Distribution CDF",AnalyticPlot,HyperErlangExponentialDistribution);


%% function used to print the first 10 values of a distrubtion
function x = printVal(Name,val)
fprintf(1,"<strong>Value of the  %s: </strong>\n",Name);
for i=1:10
    fprintf("%d: %g\t",i,val(i));
end
fprintf("\n\n")
end

%% function to compute Uniform CDF 
function x = UniformCDF(a,b,sample)
    x = zeros(500,1);
    for i=1:500
        if sample(i)<a
            x(i)=0;
        elseif sample(i)>b 
            x(i)=1;
        else 
            x(i) = (sample(i)-a)/(b-a);
        end
    end
end

%% function to plot graph
function plotMygraph(name,AnaliticPlot,DataPlot)
    Num = 500;
    x_axis = [1:Num]*max(DataPlot)/Num;
    figure
    plot(x_axis,AnaliticPlot,"DisplayName",'Analytic');
    title(name)
    legend
    grid on
    hold on
    plot(sort(DataPlot),[1:500]/500,".","DisplayName",'Data');
end
