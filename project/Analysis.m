clear all;
close all;
clc;

n=20;
%JMT data, computed considering time in H
Throughput = [1.39E-3; 2.26E-3; 2.79E-3; 3.11E-3; 3.30E-3; 3.45E-3; 3.54E-3; 3.63E-3; 3.70E-3; 3.74E-3; 3.76E-3; 3.82E-3; 3.78E-3; 3.87E-3; 3.86E-3; 3.90E-3; 3.94E-3; 3.92E-3; 3.92E-3; 3.96E-3];
ResponseTime = [718.9931; 887.6033; 1074.2360; 1281.5385; 1515.7943; 1736.2454; 1978.6516; 2202.8958; 2432.0111; 2680.0225; 2924.5095; 3137.0353; 3398.0398; 3629.4295; 3867.1649; 4116.8773; 4336.0466; 4573.4398; 4846.5942; 5046.9626];


%% SystemPower
% Usually, we want to find the best tradeoff between
% high throughput and low system response time
SystemPower = Throughput./ResponseTime;

figure
legend
grid on
plot([1:n],SystemPower,"DisplayName",'SystemPower');
xlabel("Num of Job")
xticks([1:n]);
ylabel("SystemPower")

%the index idx rerpesents the number of job in the system
[val, idx]  = max (SystemPower);

%% Throughput
figure
grid on
hold on
yyaxis left
xticks([1:n]);
plot([1:n],Throughput,"DisplayName",'Throughput');

ylabel("Throughput [job/h]")

%% Response Time
%figure
yyaxis right
plot([1:n],ResponseTime,"DisplayName",'ResponseTime');
xlabel("Num of Job")
ylabel("ResponseTime [h]")

xline(idx,'--',{'Best ','Value'},"DisplayName",'Max SystemPower');



