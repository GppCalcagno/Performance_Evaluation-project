clear all


lambda = 1200;
D = 1.25/1000;
mi = 1/D;

k=16;


%% Computing Performance M/M/1/16
fprintf(1,"<strong>Computing Performance M/M/1/16</strong>\n")
rho = lambda/mi;
% Compute the average utilization of the channel
averageUtilization=(rho-rho^(k+1))/(1-rho^(k+1));
fprintf(1,"\tAverage utilization :\t %f\n",averageUtilization); 

% Compute the probability of having 14 packets in the system
% suppose that is EXACLY 14 packets
prob14=(1-rho)/(1-rho^(k+1))*rho^14;
fprintf(1,"\tProbability of having 14 packets in the system :\t %f\n",prob14);

% Compute the average number of packets in the system
N=rho/(1-rho)-(k+1)*rho^(k+1)/(1-rho^(k+1));
fprintf(1,"\tAverage number of packets in the system:\t %f\n",N);

% Compute the throughput and the drop rate
pk=(rho^k-rho^(k+1))/(1-rho^(k+1));
dropRate=lambda*pk;
throughput = lambda-dropRate;
fprintf(1,"\tThroughput:\t %f\n",throughput);
fprintf(1,"\tDrop Rate:\t %f\n",dropRate);

% Compute the average response time and the average time spend in the queue
AverageResponseTime = N/(lambda*(1-pk));
AverageTimeSpendInQueue=AverageResponseTime-D;
fprintf(1,"\tAverage Response Time :\t %f\n",AverageResponseTime);
fprintf(1,"\tAverage Time Spend in the Queue:\t %f\n",AverageTimeSpendInQueue);

%% Conpute State probability M/M/2/16
c=2;
pn = zeros(1, k+1);
pd = zeros(1, k+1);
%starting element
pn(1,1) = 0;
pd(1,1) = 0;

% due to the fact that vector start from 1 in matlab,i scale the "representation by 1",
% so element 1 represent the state with 0 element in the queue
for i=1:k %da 0 a 16 elementi (vettori partono da 1) 
    %here, as in the example, the formula to compute alpha has been
    %applied, but it it spiltted for stability reason
	pn(1, i+1) = pn(1,i) + log(lambda);
    if i==1
	    pd(1, i+1) = pd(1,i) + log(mi);
    else
        pd(1, i+1) = pd(1,i) + log(mi*c);
    end
end

%here, as in the example, the formula to compute the probaiblities has been
%applied, but it it spiltted for stability reason
p = exp(pn - pd);
p = p / sum(p);


%% Computing Performance M/M/2/16
fprintf(1,"<strong>Computing Performance M/M/2/16</strong>\n")
% Compute the average utilization of the channel

% because the index start from 1, i have to pay attention to the fact that
% p(1) is equal to 0 job in the system
Utilization=sum(p(1:c+1).*(0:c))+c*sum(p(c+2:end));
averageUtilization=Utilization/c;
fprintf(1,"\tAverage utilization :\t %f\n",averageUtilization);

%Compute the probability of having 14 packets in the system
% suppose that is EXACLY 14 packets
prob14=p(15);
fprintf(1,"\tProbability of having 14 packets in the system :\t %f\n",prob14);

%Compute the average number of packets in the system
N=sum(p.*(0:16));
fprintf(1,"\tAverage number of packets in the system:\t %f\n",N);

% Compute the throughput and the drop rate
pk=p(17); %probability of have 16 elements in the system
dropRate=lambda*pk;
throughput = lambda-dropRate;
fprintf(1,"\tThroughput:\t %f\n",throughput);
fprintf(1,"\tDrop Rate:\t %f\n",dropRate);

%  Compute the average response time and the average time spend in the queue
% Compute the average response time and the average time spend in the queue
AverageResponseTime = N/(lambda*(1-pk));
AverageTimeSpendInQueue=AverageResponseTime-D;
fprintf(1,"\tAverage Response Time :\t %f\n",AverageResponseTime);
fprintf(1,"\tAverage Time Spend in the Queue:\t %f\n",AverageTimeSpendInQueue);











