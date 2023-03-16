clear all;
clc;

%col    =  stations
%row    =  classes

%station = servers = col: CRM(1),FS(2) [k]
%classes = row: employees(1) and providers(2) [c]

lambda = [5;10]; %req/s
Demands = [50,100;60,40]./1000; %s
%Since the CRM uses resources on the FS, requests need always to be handled by both servers.
%Because each requests need always to be handled by both servers i assume
%visist equal to 1  for each server for each type of class 
Visits = [1,1;1,1];

% 1. The utilization of the two servers
Uck = Demands .* [lambda,lambda];
Uk = sum(Uck);
fprintf(1,"1. The utilization of the two servers: CRM: %g \t FS: %g \n",Uk);

%since the system is stable X=lambda
Xc=lambda;
Xck = Visits.*[lambda, lambda];
Xk = sum(Xck);
X = sum(Xc);

%2. The residence time of the two servers
ResidenceTime_ck = Demands ./(1-[Uk;Uk]);
ResidenceTime_k= sum(Xc ./ [X; X] .* ResidenceTime_ck); 
fprintf(1,"2. The residence time of the two servers: CRM: %g \t FS: %g \n",ResidenceTime_k);

%3. The system response time
ResponseTime = sum(ResidenceTime_k);
fprintf(1,"3. The system response time: %g \n",ResponseTime);