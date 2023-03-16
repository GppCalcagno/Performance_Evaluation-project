interArrival = csvread("Log4.csv");

Num = size(interArrival,1);
%average inter arrival time [s] and the arrival rate [1/s]
AverageInterArrival = sum(interArrival)/Num;    
ArrivalRate = 1/AverageInterArrival;
fprintf(1,"Average Inter Arrival: %g\n",AverageInterArrival);
fprintf(1,"Arrival Rate: %g\n",ArrivalRate);

%Determine its variability computing the standard deviation of its arrival times
StandardDeviation = std(interArrival);
fprintf(1,"Standard Deviation: %g\n",StandardDeviation);

%Study the correlation with the plot explained during the lessons
Correlation=[interArrival(1:end-1),interArrival(2:end)];
plot(Correlation(:,1),Correlation(:,2),".");

%Assuming that each request is executed in exactly 1.2 seconds, and that jobs are 
%performed one at a time, without interruption and in order of arrival, determine the 
%average response time

%assuming time starting from 0, Calculating Arrival Time
ArrivalTime(:,1)=0;
for i=2:Num
    ArrivalTime(i)=ArrivalTime(i-1)+interArrival(i-1);
end 
ArrivalTime=ArrivalTime'; %traspose the row

%CompleteTime Comutation
CompeteTime(1)= ArrivalTime(1) + 1.2;
for i=2:Num
    CompeteTime(i) = max(ArrivalTime(i),CompeteTime(i-1))+1.2;
end 
CompeteTime = CompeteTime';

%Compute Average Reponse Time [job/s]
W = CompeteTime- ArrivalTime;   
AverageResposeTime = sum(W)/Num;

%forse non va bene così
fprintf(1,"Average Response Time %g\n",AverageResposeTime);
