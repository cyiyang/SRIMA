load('variety1.mat')
data = variety1;
days = 7; %���Ԥ������
S = 12; %����
max_ar = 3;
max_ma = 3;
max_sar = 3;
max_sma = 3;
figflag = 'on';
[forData,lower,upper,res] = Fun_SARIMA_Forecast(data,days,max_ar,max_ma,max_sar,max_sma,S,figflag,'aic');
% ʹ��SARIMA����Ԥ��ĺ���������ֱ�ӵ��ã��Ǽ��ڲ�ֽ����Զ�ȷ����p��q��P��Q�Զ�ȷ��
% ���룺
% dataΪ��Ԥ�����ݣ�һά���ݣ�ʹ��SARIMAʱ�������ݳ�������Ϊ10+S��SΪ���ڳ��ȣ����Ǵﵽ10+S֮����Ȼ���ܻᱨ�������������ݵĲ�ִ���ʹ��Ŀ�����ݳ��ȱ�̵��µġ�
% stepΪ��Ԥ�ⲽ��
% max_arΪARģ����Ѱ��������   ���鲻����3
% max_maΪMAģ����Ѱ��������   ���鲻����3
% max_sarΪSARģ����Ѱ��������   ���鲻����3
% max_smsΪSMAģ����Ѱ��������   ���鲻����3
% SΪ����������
% figflag Ϊ��ͼ��־λ��'on'Ϊ��ͼ��'off'Ϊ����
% criterion Ϊ����׼��'aic'/'bic'/'aic+bic'����ѡ�񣬴˱������Բ������������Ϊ[]����ʱ��ʹ��Ĭ��'aic+bic'׼��
% �����
% forDataΪԤ�������䳤�ȵ���step
% lowerΪԤ������95%��������ֵ
% upperΪԤ������95%��������ֵ
% res����ϲв�ֵ