clear all
close all
clc

rng('default');

s = 1;
t = 0;

Tmax = 100000;
N_states = 4;
trace = [t, s];

Ts = zeros(N_states,1);
C = -1;

%probability of next State of CPU
prob = [0.5,0.2,0.3]; %return to: SENSOR, HEAT PUMP, AIR CONDITIONAR
Cumulative = cumsum(prob);

while t < Tmax
    switch s
        case 1 %Sensor
            C=C+1;
            ns = 2;
            dt = Erlang(3,0.1);
            Ts(s)= Ts(s)+dt;

        case 2 %CPU
            dt = Uniform(10,20);
            Ts(s) = Ts(s)+dt;

            r=rand();
            if r<Cumulative(1) %r < 0.5 -> sensor
                ns=1;
            elseif r<Cumulative(2) % r < 0.7 -> Heat Pump
                ns=3;
            else % r < 1 -> Air Conditionar
                ns=4;
            end

        case 3 % Heat Pump
            dt= ExpDistribution(0.03);
            Ts(s)= Ts(s)+dt;
            ns=1;

        case 4 % Air Conditionar
            dt= ExpDistribution(0.05);
            Ts(s)= Ts(s)+dt;
            ns=1;

    end %end switch

    s = ns;
	t = t + dt;
	
	trace(end + 1, :) = [t, s];
end


%% Computing the performance Index
ProbStates = Ts/t;
%Note: in this computation a +1 in the Completed job can be lost,
%but it can be trascured due to a +1 is
%irrelevant because of the magnitude of the number
X = C / t;

fprintf(1,"Throughput of the system: \t %f\n",X);
fprintf(1,"Prob of States: Sensor: %g  \tCPU: %g \tHP: %g\t AC: %g \n",ProbStates)
fprintf(1,"Total Prob: %g \n",sum(ProbStates));


%% function for Earlang Distibution
function out = Erlang(repetition,lambda) 
    arg=0;
    for i=1:repetition
        arg=arg + log(rand());
    end
    out= -arg/lambda;
end

%% function for Unifrom Distibution
function out = Uniform (a,b)
    out= rand()*(b-a)+a;    
end

%% function for Exponential Distibution
function out = ExpDistribution(lambda)
    out= -log(rand())/lambda;
end
