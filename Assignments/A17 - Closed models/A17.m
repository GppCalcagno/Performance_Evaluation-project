clear all;
clc;

N=530;
% Moodle server, File Server, DB server
ServiceTime = [80,120,11]./1000;    %s
Visits = [1,0.75,10];
Z = 2*60;   %s

% 1. The demand of the three station
Demands = Visits.*ServiceTime;
fprintf(1,"1. The demand of the three station:\t MoodleS: %f \t FileS: %f \t DBS: %f \n",Demands);

%2. The system throughput
%4. The system response time

%inizialization at time 0 (0 job)
NumOfJob=0;
Nk=[0 0 0];  
for i=(1:N) 
    NumOfJob=NumOfJob+1;
    Rk= Demands.*(Nk+1); %ResidenceTime with 1 more job in the system
    ResponseTime=sum(Rk);
    X=NumOfJob/(ResponseTime+Z); %X with NumOfJob jobs in the system [job/s]
    Nk=X*Rk;
end 

fprintf(1,"2. The system throughput: %f with %d jobs\n",X,NumOfJob);
fprintf(1,"4. The system response time: %f with %d jobs\n",ResponseTime,NumOfJob);

%3. The utilization of the three stations
Uk=Demands*X;
fprintf(1,"3. The utilization of the three stations: \t MoodleS: %f \t FileS: %f \t DBS: %f \t  (%d jobs)\n",Uk,NumOfJob);

%5. The average number of students "not thinking”
NotThinking = sum(Nk);
fprintf(1,"5. The average number of students not thinking: %f with %d jobs\n",NotThinking,NumOfJob);

