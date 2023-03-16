% When ALL random timing follows an exponential distribution
% Race policy becomes identical to concurrency
% Assuming that the GC start only when a job is active and it is deactived when the job ends
rng('default');
clear all
close all
clc

%start from Scheduler
s = 1; 
t = 0;

Tmax = 100000;
N_states = 3;
C = -1; %to start the "simulation" with 0 job done

trace = [t, s];
Ts = zeros(N_states,1);

while t < Tmax
    switch s
        case 1 
            C=C+1; %when i enter this state i have completed a job
            dt = ExpDistribution(0.05);
            Ts(s)= Ts(s)+dt;
            ns=2;
        case 2
            ns1 = ExpDistribution(1); %job done at full speed
            ns3 = ExpDistribution(0.1); %start GC
            dt=min(ns1,ns3);

            Ts(s)= Ts(s)+dt;

            switch dt
                case ns1
                    ns=1;
                case ns3
                    ns=3;
            end

        case 3 
            ns2 = ExpDistribution(0.4); %end GC
            ns1 = ExpDistribution(0.3); %job done at slow speed
            
            dt=min(ns1,ns2);

            Ts(s)= Ts(s)+dt;
            
            switch dt
                case ns1
                    ns=1;
                case ns2
                    ns=2;
            end
    end %end switch
    
    t=t+dt;
    s=ns;
    trace(end + 1, :) = [t, s];
end

%% Computing Performance Index

ProbStates = Ts/t;
%Note: in this computation a +1 in the Completed job can be lost,
%(simulation end in state s2,s3) but it can be trascured due to a +1 is
%irrelevant because of the magnitude of the number
X = C / t;

fprintf(1,"Throughput of the system: \t %f\n",X);
fprintf(1,"Prob of States: NEWJob: %g  \tFSJ: %g \tSSJ: %g\n",ProbStates);
fprintf(1,"Total Prob: %g \n",sum(ProbStates));


%% function for Exponential Distibution
function out = ExpDistribution(lambda)
    out= -log(rand())/lambda;
end