clear all
close all
clc

rng('default');
num = 50000;

%% Service Time [5,10]
a=5;
b=10;
ServiceTime = rand(num,1).*(b-a)+a;

%% IntraArrivalTimes
lambda = [0.02, 0.2];
prob = [0.1,0.9];
C = cumsum(prob); %quite useless, could be just a if else in the for

IntraArrivalTime = zeros(num,1);
for i=1:num
    r = rand();
    for j=1:2
        if r <=C(j) %first col for pick the branch
            IntraArrivalTime(i)= -log(rand())/lambda(j); %second col for generation
            break;
        end
    end
end


%% computing arrival time
ArrivalTime= zeros(num,1);
%arrival now not start from time 0
ArrivalTime = cumsum(IntraArrivalTime);

%% Computing CompleteTime
CompleteTime=zeros(num,1);
CompleteTime(1)= ArrivalTime(1) + ServiceTime(1);
for i=2:num
    CompleteTime(i) = max(ArrivalTime(i),CompleteTime(i-1))+ServiceTime(i);
end 

%% Computing ResponseTime 
W = CompleteTime - ArrivalTime;

%computing the conficende interval of 95%
bounds= ConfidenceBound95(W);
fprintf(1,"95%% confidence interval of response time:\t %g - %g \n",bounds);

%% Compute Other Confidente Interval
K=200;
M = num/200;
NumJob=zeros(K,1);

% Average Number of Job
for i=0:K-1
    Index1 = i*M+1;
    Index2 = (i+1)*M;
    Time = CompleteTime(Index2)-ArrivalTime(Index1);
    NumJob(i+1)=sum(W(Index1:Index2))/Time;
end
bounds= ConfidenceBound95(NumJob);
fprintf(1,"95%% confidence interval of Number of Job:\t %g - %g \n",bounds);

% Utilization
Utilization = zeros(K,1);
for i=0:K-1
    Index1 = i*M+1;
    Index2 = (i+1)*M;
    Time = CompleteTime(Index2)-ArrivalTime(Index1);
    BusyTime = sum(ServiceTime(Index1:Index2));
    Utilization(i+1) = BusyTime/Time;
end
bounds= ConfidenceBound95(Utilization);
fprintf(1,"95%% confidence interval of Utilization:\t %g - %g \n",bounds);

% Throughput
Throughput = zeros(K,1);
for i=0:K-1
    Index1 = i*M+1;
    Index2 = (i+1)*M;
    Time = CompleteTime(Index2)-ArrivalTime(Index1);
    %We choice the dimension on the sample according to the number of job
    %arrived\Completed, so we have alwais Completed C=M
    Completed = M;
    Throughput(i+1) = Completed/Time;
end
bounds= ConfidenceBound95(Throughput);
fprintf(1,"95%% confidence interval of Throughput:\t %g - %g \n",bounds);


%% function Confidence Bound
function x = ConfidenceBound95(Data)

    num = size(Data,1);
    Average = sum(Data)/num;
    Variance= sum((Data-Average).^2)/(num-1);
    
    d = 1.96;
    
    lowerbound = Average - d*sqrt(Variance/num);
    upperbound = Average + d*sqrt(Variance/num);
    x = [lowerbound,upperbound];
end



