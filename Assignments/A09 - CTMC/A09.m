clear all
close all
clc

Tmax= 300;

%NOTE
% i'm assuming that the reset is independent in the 2 type of connection 
% and in the simulation can occur just one event at time (no double reset\restore) 

%% Computing the Q matrix according to the schema
%S1 = connection both available
%S2 = only 4G connection not available
%S3 = only WIFI connection not available
%S4 = connection both Not available

q12 = 1/20 + 1/100; %Possibility to stop 4G due to interrupt of reset, with exponential property i sum the lambda
q13 = 1/3 +1/100; %Possibility to stop WIFI due to interrupt of reset, with exponential property i sum the lambda
q14 = 0;

q21 = 1/2; %Possibility to restore 4G
q24 = 1/3 + 1/100; %Possitibility to stop WIFI during 4G interruption
q23 = 0; 

q31 = 1/8; %Possitility to restore WIFI
q34 = 1/20 + 1/100; %Possitibility to stop 4G during WIFI interruption
q32 = 0; 


q42 = 1/8; %Possibility to restore WIFI
q43 = 1/2; %Possibility to restore 4G
q41 = 0;

    %Fill the matrix summing the row changing sign to the remaining element
q11 = -q12 -q13;
q22 = -q21 -q24;
q33 = -q31 -q34;
q44 = -q42 -q43;


Q= [
    q11,q12,q13,q14;
    q21,q22,q23,q24;
    q31,q32,q33,q34;
    q41,q42,q43,q44;
    ];

fprintf(1,"Matrix Check: %g\n",sum(sum(Q)));
%% Solve the System
%the system starts in a state where both channels are available:
p0 = [1,0,0,0];

[t, Sol]=ode45(@(t,x) Q'*x, [0 Tmax], p0');

plot(t, Sol, "-");
legend("S1: Both Av.","S2:Only 4G Not Av.","S3: Only WiFi Not Av.","Both Not Av.")