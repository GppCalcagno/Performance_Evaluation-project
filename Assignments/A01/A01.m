clear all
%extract data from log
Table = readtable('apache1.log'); %just change the file to get the other values

%creatate a dateset
dataset = table;

%extract serviceT [s]
dataset.serviceT = Table.Var11/1000;

%extract ArrivalTime [s]
%i excluded data because it is equal for the entire dataset
for i=1:size(Table, 1)
    newStr = erase(string(Table{i,4}),'[15/Sep/2022:');
    date = split(newStr,':');
    dataset.ArrivalT(i) = str2num(date(1))*3600+str2num(date(2))*60+str2num(date(3));
end 

%assuming that jobs are served in the order of arrival, one at a time, and not interrupted
%i can compute the CompleteTime with the following formula
dataset.CompleteT(1)= dataset.ArrivalT(1) + dataset.serviceT(1);
for i=2:size(dataset, 1)
    dataset.CompleteT(i) = max(dataset.ArrivalT(i),dataset.CompleteT(i-1))+dataset.serviceT(i);
end  

%set the dataset to start at time 0
dataset.CompleteT = dataset.CompleteT - dataset.ArrivalT(1);
dataset.ArrivalT = dataset.ArrivalT - dataset.ArrivalT(1);

%retrive number of job in log
Num = size(dataset,1);
fprintf(1,"Number of Jobs: %g\n",Num);
%retrive the total time 

Time = dataset.CompleteT(Num);
fprintf(1,"Total Time: %g\n",Time);

%same number of arrival and completed work [job/s]
ArrivalRate = Num/Time;
throughput = Num/Time;
fprintf(1,"ArrivalRate and throughput: %g - %g \n",ArrivalRate, throughput);

%Average_Inter_Arrival (un po diversi) [job/s]
Delta_Arrival = dataset{2:end,2} - dataset{1:end-1,2};
Average_Inter_Arrival1 = sum(Delta_Arrival)/Num;
Average_Inter_Arrival2 = 1/ArrivalRate;
fprintf(1, "Average_Inter_Arrival: %g - %g\n", Average_Inter_Arrival1, Average_Inter_Arrival2);

%BusyTime [sec] & Utilization [] 
BusyTime = sum(dataset.serviceT);
Utilization = BusyTime/Time;
fprintf(1,"BusyTime: %g\n",BusyTime);
fprintf(1,"Utilization: %g\n",Utilization);

%W [job*s]
Rt = dataset.CompleteT - dataset.ArrivalT;
W = sum(Rt);
fprintf(1,"W: %g \n",W);

%Average Service Time [s]
ServiceTime = BusyTime/Num;
ServiceTime1 = sum(dataset.serviceT)/Num;
fprintf(1,"Service  Time: %g - %g\n",ServiceTime,ServiceTime1);

%Average Number of Jobs [job]
AverageNumJob = W/Time;
fprintf(1, "Average Number of jobs: %g\n", AverageNumJob);

%Average Response Time [s]
AverageResponseTime = W/Num; 
fprintf(1,"Average Response Time: %g\n",AverageResponseTime)

%Probability of having m jobs in the web server (with m = 0, 1, 2, 3)
ProbDataset = [dataset.ArrivalT,ones(Num,1);dataset.CompleteT,-ones(Num,1)];
ProbDataset= sortrows(ProbDataset,1);
ProbDataset(:,3)=cumsum(ProbDataset(:,2));
ProbDataset(1:end-1,4) = ProbDataset(2:end,1) - ProbDataset(1:end-1,1);
ProbDataset(end,4)=0;

y0 = sum(ProbDataset(:,4).*(ProbDataset(:,3)==0));
y1 = sum(ProbDataset(:,4).*(ProbDataset(:,3)==1));
y2 = sum(ProbDataset(:,4).*(ProbDataset(:,3)==2));
y3 = sum(ProbDataset(:,4).*(ProbDataset(:,3)==3));
BusyTime1 = Time-y0; %same result of above

py0= y0/Time;
py1= y1/Time;
py2= y2/Time;
py3= y3/Time;
fprintf(1,"Probability of having m jobs in the web server: " + ...
    "\n 0: %g \n 1: %g \n 2: %g \n 3: %g \n",py0,py1,py2,py3);

%Probability of having a response time less than t, (with t = 1 s, 5 s, 10 s
dataset.ResponseT = dataset.CompleteT-dataset.ArrivalT;
tau1 = sum((dataset.ResponseT<1));
tau5 = sum((dataset.ResponseT<5));
tau10 = sum((dataset.ResponseT<10));

Ptau1 = tau1/Num;
Ptau5 = tau5/Num;
Ptau10 = tau10/Num;

fprintf(1,"Prob of response time less than: \n 1: %g \n 5: %g \n 10: %g \n",Ptau1,Ptau5,Ptau10);

