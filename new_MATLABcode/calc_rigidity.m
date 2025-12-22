function calc_rigidity
data = load('log_Ahq2_q.txt');

hold on
plot(data(:,1),data(:,2),'.');

middle_point = 40 ;
data1 = data(1:middle_point,:);
data2 = data(middle_point:size(data,1)-20,:);

b1 = (2*sum(data1(:,1))+sum(data1(:,2))) / size(data1,1);
b2 = (4*sum(data2(:,1))+sum(data2(:,2))) / size(data2,1);

tension = exp(-b1)
bend_k = exp(-b2) 

f1= polyval([-2 b1],data1(:,1));
f2= polyval([-4 b2],data2(:,1));

plot(data1(:,1),f1,'r')
plot(data2(:,1),f2,'r')

