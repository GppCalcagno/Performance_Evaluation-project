clear all;
clc;

%Average Service Time
ServiceTime = [85;75; 60]./1000; %s  

P = [
    0       1       0;
    0       0       1;
    0       0       0 
    ];

%Compute the Arrival Rate
l_IN = [10;0;5]; %job/s
l0=sum(l_IN);

%Compute The Arrival For each Station
l = inv(eye(3)-P')*l_IN;

% 1. The visits and the demands for the three stations
Visits=l/l0;
fprintf(1,"1. Visit of the Stations:\n\t WebS: %f \t DBS: %f \t StrS: %f \n\n",Visits);
Demands= Visits.*ServiceTime;
fprintf(1,"2. Demand of the Stations:\n\t WebS: %f \t DBS: %f \t StrS: %f \n\n",Demands);

% 3. The throughput of the system
%Supposing that the system is stable we can assume X=l0
SystemThroughput = l0;
fprintf(1,"3. The throughput of the system is: %f\n\n",SystemThroughput);

% 2. The utilization of the three stations
StationUtilization = SystemThroughput.*Demands;
fprintf(1,"2. The Utilization of the Stations:\n\t WebS: %f \t DBS: %f \t StrS: %f \n\n",StationUtilization);

% 4. The average number of jobs in the three stations
Nk = StationUtilization./(1.-StationUtilization);
fprintf(1,"4. The average number of jobs in the 3 stations:\n\t WebS: %f \t DBS: %f \t StrS: %f \n\n",Nk);

% 5. The average system response time
Rk = Demands./(1.-StationUtilization);
AverageSystemResponseTime = sum(Rk);
fprintf(1,"5. The average system response time is: %f\n\n",AverageSystemResponseTime);


