clc;
clear all;

%Average Service Time
ServiceTime = [40;100;120];

%Compute the probability of the "next State"
P = [
    0       0.3     0.2;
    1       0       0;
    0.2     0.8     0 
    ];

%Compute the Arrival Rate
l_IN = [10;0;0];
l0=sum(l_IN);

%Compute The Arrival For each Station
l = inv(eye(3)-P')*l_IN;

%1. The visits of the three stations
Visits=l/l0;
fprintf(1,"Visit of the Station:\n\t CPU: %f \t DISK: %f \t NET: %f \n ",Visits);

%2. The demand of the three station
Demand=Visits.*ServiceTime;
fprintf(1,"Demand of the Station:\n\t CPU: %f \t DISK: %f \t NET: %f \n ",Demand);

%3. The throughput of the three stations
SystemThroughput = l0;
StationThroughput= Visits*SystemThroughput;
fprintf(1,"Throughput of the Station:\n\t CPU: %f \t DISK: %f \t NET: %f \n ",StationThroughput);
