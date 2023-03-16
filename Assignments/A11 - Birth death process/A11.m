clear all
close all
clc

N = 16;
N0 = 8;

b = 200;
d = 100;

pn = zeros(1, N+1);
pd = zeros(1, N+1);

%starting element
pn(1,1) = 0;
pd(1,1) = 0;


% due to the fact that vector start from 1 in matlab,i scale the "representation by 1",
% so element 1 represent the state with 0 element in the queue

for i=1:N %da 0 a 16 elementi (vettori partono da 1) 
	if i < 9 %less than 8 elements in the system
		brate = b;
	else
		brate = b * (N-(i-1))/ (N-N0);
    end
	drate=d;

    %here, as in the example, the formula to compute alpha has been
    %applied, but it it spiltted for stability reason
	pn(1, i+1) = pn(1,i) + log(brate);
	pd(1, i+1) = pd(1,i) + log(d);
end

%here, as in the example, the formula to compute alpha has been
%applied, but it it spiltted for stability reaso
p = exp(pn - pd);
p = p / sum(p);

fprintf(1,"check SUM of probabilities equal to 1 = %f\n",sum(p));

fprintf(1,"PROBABILITY OF EACH STATE:\n")
for i=0:N
    fprintf(1,"%d: %f\n",i,p(i+1));
end
fprintf(1,"\n");

plot([0:1:N],p , "+");
title('Probability to be in a State') 
xlabel('State = Number of packet in the system');
ylabel('Probabililty'); 
set(gca, 'XLim', [0,N], 'XTick', 0:1:N,'XTickLabel', 0:1:N);
set(gca, 'YLim', [-0.05,max(p)+0.1]);
