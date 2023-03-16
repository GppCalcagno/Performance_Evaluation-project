clear all


lambda = 500;
mi1 = 1500;
mi2 = 1000;

%% M/G/1 System
fprintf(1,"<strong> M/G/1 System </strong>\n")

%Compute First and Second Moment
mi = 1/mi1 +1/mi2;
m2 = 2 * (1/mi1^2 + 1/(mi1*mi2) + 1/mi2^2); 
fprintf(1,"\tFirst Moment: %f\t SecondMoment: %f\n",mi,m2);

%averageServiceTime
D=mi;       

%Compute rho
rho=lambda*D;   

%Compute Utilization
Utilization=lambda*D;
fprintf(1,"\tUtilizationtilization :\t %f\n",Utilization);


%Compute (Exact) ResponseTime
ResponseTime = D + (lambda*m2)/(2*(1-rho));
fprintf(1,"\tResponseTime :\t %f\n",ResponseTime);

%The (exact) average number of jobs in the system
N = rho + (lambda^2 * m2)/(2*(1-rho));
fprintf(1,"\tNumberofJob:\t %f\n",N);


%% G/G/2 System
fprintf(1,"<strong> G/G/2 System </strong>\n")
k=4;
lambda_Erlang = 4000;

mean = k/lambda_Erlang;

lambda=1/mean;
T= mean;

ca = 1/sqrt(k);
cv = sqrt(mi1^2+mi2^2)/(mi1 + mi2);

rho = D/(2*T);

%Utilization
Utilization=lambda*D/2;
fprintf(1,"\tUtilizationtilization :\t %f\n",Utilization);

% Average Response Time 
AverageResponseTime = D + ((ca^2+cv^2)/2)*rho^2*D/(1-rho^2);
fprintf(1,"\tAverageResponseTime :\t %f\n",AverageResponseTime);

%The average number of jobs in the system
N = lambda*AverageResponseTime;
fprintf(1,"\tAverageNumberofJob:\t %f\n",N);





