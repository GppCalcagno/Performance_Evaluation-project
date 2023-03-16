clear all
close all
clc

%% Conpute State probability M/M/1
brate = 50;
D = 15/1000;
drate = 1/D;

%starting element
pn(1,1) = 0;
pd(1,1) = 0; 
i=1;
% due to the fact that vector start from 1 in matlab,i scale the "representation by 1",
% so element 1 represent the state with 0 element in the queue

while 1 %da 0 a 16 elementi (vettori partono da 1)
    %here, as in the example, the formula to compute alpha has been
    %applied, but it it spiltted for stability reason
	pn(1, i+1) = pn(1,i) + log(brate);
	pd(1, i+1) = pd(1,i) + log(drate);
    p = exp(pn - pd);
    p = p / sum(p);

    if p(end)<0.0000001 %quite 0
        break
        %break the loop when a value became 0
    end 
    i=i+1;
end


% fprintf(1,"PROBABILITY OF EACH STATE:\n")
% for i=0:i
%     fprintf(1,"%d\t: %f\n",i,p(i+1));
% end
% fprintf(1,"\n");

%% Compute Performance Index 1
fprintf("WITH 1 SERVER: \n")
% 1. The utilization of the system [%]
Utilization = sum(p(2:end));
fprintf(1,"\tthe utilization of the system:\t %f\n",Utilization); 
% 2. The probability of having exactly one job in the system 
P1job= p(2); %(1-Utilization)*Utilization è uguale
fprintf(1,"\tprobability of having exactly one job in the system:\t %f\n",P1job);
% 3. The probability of having less than 4 job s in the system
PLess4 = sum(p(1:4)); % 1-Utilization^4 è uguale
fprintf(1,"\tThe probability of having less than 4 jobs in the system:\t %f\n",PLess4);
% 4. The average queue length (job not in service) [job]
AverageQueueLenght = Utilization^2/(1-Utilization);
fprintf(1,"\tThe average queue length (job not in service):\t %f\n",AverageQueueLenght);
% 5. The average response time [s]
ResponseTime = D/(1-Utilization);
fprintf(1,"\tThe average response time:\t %f\n",ResponseTime);
% 6. The probability that the response time is greater than 0.5 s
RespGreaterThan05= exp(-0.5/ResponseTime);
fprintf(1,"\tThe probability that the response time is greater than 0.5 s:\t %f\n",RespGreaterThan05);
% 7. The 90 percentile of the response time distribution
percentile = -log(1-90/100)*ResponseTime;
fprintf(1,"\tThe 90 percentile of the response time distribution:\t %f\n",percentile);

%% Conpute State probability M/M/2

brate = 85;
D = 15/1000;
c=2;

pn2(1,1) = 0;
pd2(1,1) = 0;
i=1;
% due to the fact that vector start from 1 in matlab,i scale the "representation by 1",
% so element 1 represent the state with 0 element in the queue

while 1 %da 0 a 16 elementi (vettori partono da 1)
    %here, as in the example, the formula to compute alpha has been
    %applied, but it it spiltted for stability reason
    if i==1 %%WARNING: ci va 1 o 2???
        drate = 1/D;
    else
        drate = (1/D) * c; %Exploiting Parallel computation 
    end
	pn2(1, i+1) = pn2(1,i) + log(brate);
	pd2(1, i+1) = pd2(1,i) + log(drate);
    p2 = exp(pn2 - pd2);
    p2 = p2 / sum(p2);

    if p2(end)<0.000000001 %quite 0
        break
        %break the loop when a value became 0
    end 
    i=i+1;
end
% 
% fprintf(1,"PROBABILITY OF EACH STATE:\n")
% for i=0:i
%     fprintf(1,"%d\t: %f\n",i,p2(i+1));
% end
% fprintf(1,"\n");

%% Compute Performance Index 2
fprintf("\nWITH 2 SERVERs: \n")
% 1. The total utilization of the system [%]
drate = 1/D;
TotalUtilization = brate/drate;
fprintf(1,"\tTotal utilization of the system:\t %f\n",TotalUtilization);
% 1.1 The Average utilization of the system [%]
AverageUtilization = TotalUtilization/c;
fprintf(1,"\tAverage utilization of the system:\t %f\n",AverageUtilization);

% 2. The probability of having exactly one job in the system 
P1job= p2(2); %2*(1-AverageUtilization)/(1+AverageUtilization)*AverageUtilization gives the same result
fprintf(1,"\tprobability of having exactly one job in the system:\t %f\n",P1job);

% 3. The probability of having less than 4 jobs in the system
PLess4 = sum(p2(1:4));  %same as sum the formula above, sum from 0 to 3 jobs  
fprintf(1,"\tThe probability of having less than 4 jobs in the system:\t %f\n",PLess4);

% 4. The average queue length (job not in service) [job]
% Note that  c*AverageUtilization is used to exlude job in service
AverageQueueLenght = 2*AverageUtilization/(1-AverageUtilization^2) - c*AverageUtilization;
fprintf(1,"\tThe average queue length (job not in service):\t %f\n",AverageQueueLenght);

% 5. The average response time [s]
ResponseTime = D/(1-AverageUtilization^2);
fprintf(1,"\tThe average response time:\t %f\n",ResponseTime);





