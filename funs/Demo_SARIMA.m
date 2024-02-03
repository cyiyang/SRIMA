clc
clear

load('variety1.mat')
load('variety2.mat')
load('variety3.mat')
load('variety4.mat')
load('variety5.mat')
load('variety6.mat') 
variety = [variety1 variety2 variety3 variety4 variety5 variety6];

forcost = [];
for i = 1:6
data = variety(:,1);
days = 7; %���Ԥ������
S = 12; %����
max_ar = 3;
max_ma = 3;
max_sar = 3;
max_sma = 3;
figflag = 'on';
%SARIMA��Ԥ��
[forData,lower,upper,res] = Fun_SARIMA_Forecast(data,days,max_ar,max_ma,max_sar,max_sma,S,figflag,'aic');
%��ͼ
figure(5)
plot(data,'k-',"LineWidth",2)
prectice = data + res-1;
hold on
plot(prectice,'g-',"LineWidth",1.5)
legend("��ʵֵ","Ԥ��ֵ")
hold off

forcost = [forcost forData];
end