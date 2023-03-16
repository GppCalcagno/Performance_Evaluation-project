xclear all
close all
clc

Tmax= 500;

%% Computing the Q matrix according to the schema
%S1 = Idle
%S2 = CPU
%S3 = I/O Operation
%S4 = GPU

%note: value not specified are assumed equal to 0
q12 = 1/10; %Start Job

q21 = 1/50; %end Job
q23 = 1/10; %start I/O operation
q24 = 1/20; %start GPU operation

q32 = 1/5; %End I/O operation

q42 = 1/2; %End GPU operation

%Computing the diagonal Values
q11 = -q12;
q22 = -q21 -q23 -q24;
q33 = -q32;
q44 = -q42;

Q= [
    q11,    q12,    0,      0;
    q21,    q22,    q23,    q24;
    0,      q32,    q33,    0;
    0,      q42,    0,      q44;
    ];

fprintf(1,"Matrix Check: %f\n",sum(sum(Q)));

%% Solve the System
%The system starts in Idle state.
p0 = [1,0,0,0];

% In function of time 
[t, Sol]=ode45(@(t,x) Q'*x, [0 Tmax], p0');
plot(t, Sol, "-");
legend("S1: Idle","S2: CPU","S3: I/O","S4: GPU")
grid on

%steady state 
Q1=Q;
Q1(:,1)=ones(4,1);
pFinal=p0*inv(Q1);

fprintf(1,"Prob: \t 1: %g \t 2: %g \t 3: %g \t 4: %g\n",pFinal);

%% Utilization [time the system is not idle] {state reward}
% 0 when idle, 1 when computation is proceeding 
UtilizationReward = [0,1,1,1];

UtilizationTransientReward = StateReward(Sol,UtilizationReward);
UtilizationSteadyReward = StateReward(pFinal,UtilizationReward);
DrawMyFigure("Utilization", UtilizationTransientReward,UtilizationSteadyReward,t);

%% Average power consumption [measure in W] {state reward}
%depening on the component comsunption [W]
PowerReward= [0.1,2,0.5,10];

PowerTransientReward = StateReward(Sol,PowerReward);
PowerSteadyReward = StateReward(pFinal,PowerReward);
DrawMyFigure("Power Consumption", PowerTransientReward,PowerSteadyReward,t);

%% System throughput [when the system returns to the idle state] {transition reward}
% 1 when the system go from CPU to Idle (t21), otherwise 0
throughputReward = zeros(4);
throughputReward(2,1)=1;

throughputSteadtyReward=TransitionReward(pFinal,throughputReward,Q);
throughputTransientReward=TransitionReward(Sol,throughputReward,Q);
DrawMyFigure("Throughput", throughputTransientReward,throughputSteadtyReward,t);

%% GPU throughput [when a GPU task finishes and the control returns to the CPU]  {transition reward}
% 1 when the system go from GPU to CPU (t42), otherwise 0
GPUthroughputReward = zeros(4);
GPUthroughputReward(4,2)=1;

GPUthroughputSteadtyReward=TransitionReward(pFinal,GPUthroughputReward,Q);
GPUthroughputTransientReward=TransitionReward(Sol,GPUthroughputReward,Q);

DrawMyFigure("GPU Throughput", GPUthroughputTransientReward,GPUthroughputSteadtyReward,t);

%% I/O frequency [when a I/O task finishes and the control returns to the CPU] {transition reward}
% 1 when the system go from I/O to CPU (t32), otherwise 0
IOthroughputReward = zeros(4);
IOthroughputReward(3,2)=1;

IOthroughputSteadtyReward=TransitionReward(pFinal,IOthroughputReward,Q);
IOthroughputTransientReward=TransitionReward(Sol,IOthroughputReward,Q);

DrawMyFigure("I/O Throughput", IOthroughputTransientReward,IOthroughputSteadtyReward,t);

%% Draw a Figure with all the Reward
Rewards = [UtilizationTransientReward,PowerTransientReward,throughputTransientReward,GPUthroughputTransientReward,IOthroughputTransientReward];
figure("Name","Rewards")
plot(t, Rewards, "-");
hold on
legend("Utilization","Power Consumption","System Throughput","GPU Throughput","I/O Throughput")

%% Function to Compute State Reward
function out= StateReward(pi,Reward)
    %Transient or  Steady depend on the type of pi
    out=pi*Reward';
end

%% Function To Compute Transition Reward
function out= TransitionReward(pi,Reward,Q)
    %Transient or  Steady depend on the type of pi
    out = zeros(size(pi,1),1);

    for k=1:size(pi,1) %Transient or Steady
        partial=0;
        for i=1:size(pi,2) %for each state
            sum=0;
            for j=1:size(pi,2) %for each transaction 
                if(i~=j)
                    sum =sum+ Q(i,j)*Reward(i,j);
                end 
            end
        partial=partial+sum*pi(k,i);
        end
        out(k)=partial;
    end
end

%% Draw State Reward
function DrawMyFigure(name, TransientReward,SteadyReward,time)
    figure("Name",strcat(name," Reward"));
    plot(time, TransientReward, "-");
    title(sprintf("%s Steady Reward: %f",name,SteadyReward));
    legend(strcat(name," Transient Reward"),"Location",'southeast');
    grid on;
end
