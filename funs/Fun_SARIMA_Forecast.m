function [forData,lower,upper,res] = Fun_SARIMA_Forecast(data,step,max_ar,max_ma,max_sar,max_sma,S,figflag,criterion)
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

%  Copyright (c) 2020 Mr.���� All rights reserved.
%  ������Ϊ�Ա����ר�ã�����Դ�����𹫿�����~
if ~exist('criterion')
    criterion  = [];  %���û������criterion��������ָ��Ϊ��
end
%% 1.��������
data = data(:);  %ͳһ��Ϊ������
%% 2.ȷ����������Ǽ����Բ������DȡĬ��ֵ1��d��0��3ѭ����ƽ�Ⱥ�ֹͣ
for d = 0:3
    D1 = LagOp({1 -1},'Lags',[0,d]);     %�Ǽ��ڲ������ͺ�����
    D12 = LagOp({1 -1},'Lags',[0,1*S]);  %���ڲ������ͺ�����
    D = D1*D12;          %���
    dY = filter(D,data); %��ԭ���ݽ��в������
    if(getStatAdfKpss(dY)) %����ƽ��
        disp(['�Ǽ����Բ����Ϊ',num2str(d),'�������Բ����Ϊ1']);
        break;
    end
end
figure('Name','��ֺ�����','Visible',figflag,'color','w')
plot(dY);title('��ֺ�����')
%% 3.ȷ������ARlags,MALags,SARLags,SMALags
% ����ACF��PACF
figure('Name','ƽ���ź������ͼ','Visible',figflag)
autocorr(dY)
figure('Name','ƽ���ź�ƫ�����ͼ','Visible',figflag)
parcorr(dY)
% aicbic��ȷ������
try
    [AR_Order,MA_Order,SAR_Order,SMA_Order] = SARMA_Order_Select(dY,max_ar,max_ma,max_sar,max_sma,S,d,criterion); %�Զ�����
catch ME %��׽������Ϣ
    msgtext = ME.message;
    if (strcmp(ME.identifier,'econ:arima:estimate:InvalidVarianceModel'))
         msgtext = [msgtext,'  ','�޷�����arimaģ�͹��ƣ����������������ѵ�������ݳ��Ƚ�С����Ҫ������ϵĽ����ϸߵ��µģ��볢�Լ�Сmax_ar,max_ma,max_sar,max_sma��ֵ'];
    end
    msgbox(msgtext, '����')
end
disp(['ARlags=',num2str(AR_Order),',MALags=',num2str(MA_Order),',SARLags=',num2str(SAR_Order),',SMALags=',num2str(SMA_Order)]);
%% 4.�в����
Mdl = creatSARIMA(AR_Order,MA_Order,SAR_Order,SMA_Order,S,d);  %����SARIMAģ��
try
    EstMdl = estimate(Mdl,data);
catch ME %��׽������Ϣ
    msgtext = ME.message;
    if (strcmp(ME.identifier,'econ:arima:estimate:InvalidVarianceModel'))
         msgtext = [msgtext,'  ','�޷�����arimaģ�͹��ƣ����������������ѵ�������ݳ��Ƚ�С����Ҫ������ϵĽ����ϸߵ��µģ��볢�Լ�Сmax_ar��max_ma��ֵ']
    end
    msgbox(msgtext, '����')
    return
end
[res,~,logL] = infer(EstMdl,data);   %res���в�

stdr = res/sqrt(EstMdl.Variance);
figure('Name','�в����','Visible',figflag)
subplot(2,3,1)
plot(stdr)
title('Standardized Residuals')
subplot(2,3,2)
histogram(stdr,10)
title('Standardized Residuals')
subplot(2,3,3)
autocorr(stdr)
subplot(2,3,4)
parcorr(stdr)
subplot(2,3,5)
qqplot(stdr)
% Durbin-Watson ͳ���Ǽ�������ѧ��������õ�����ض���
diffRes0 = diff(res);  
SSE0 = res'*res;
DW0 = (diffRes0'*diffRes0)/SSE0 % Durbin-Watson statistic����ֵ�ӽ�2���������Ϊ���в�����һ������ԡ�
%% 5.Ԥ��
if ~isempty(strfind(version,'2018'))||~isempty(strfind(version,'2017'))||~isempty(strfind(version,'2016'))
    [forData,YMSE] = forecast(EstMdl,step,'Y0',data);   %matlab2018�����°汾дΪPredict_Y = forecast(EstMdl,step,'Y0',Y);   matlab2019дΪPredict_Y = forecast(EstMdl,step,Y);
elseif ~isempty(strfind(version,'2019'))||~isempty(strfind(version,'2020'))||~isempty(strfind(version,'2021'))||~isempty(strfind(version,'2022'))||~isempty(strfind(version,'2023'))
    [forData,YMSE] = forecast(EstMdl,step,data);   %matlab2018�����°汾дΪPredict_Y = forecast(EstMdl,step,'Y0',Y);   matlab2019дΪPredict_Y = forecast(EstMdl,step,Y);
else
    warndlg('��֧��MATLAB2016/2017/2018/2019/2020/2021/2022')
end
lower = forData - 1.96*sqrt(YMSE); %95������������
upper = forData + 1.96*sqrt(YMSE); %95������������

figure('Visible',figflag)
plot(data,'Color',[.7,.7,.7]);
hold on
h1 = plot(length(data):length(data)+step,[data(end);lower],'r:','LineWidth',2);
plot(length(data):length(data)+step,[data(end);upper],'r:','LineWidth',2)
h2 = plot(length(data):length(data)+step,[data(end);forData],'k','LineWidth',2);
legend([h1 h2],'95% ��������','Ԥ��ֵ',...
	     'Location','NorthWest')
title('Ԥ��ֵ')
hold off

end

function stat = getStatAdfKpss(data)
try 
    stat = adftest(data) && ~kpsstest(data);
catch ME
    msgtext = ME.message;
    if (strcmp(ME.identifier,'econ:adftest:EffectiveSampleSizeLessThanTabulatedValues'))
         msgtext = [msgtext,'  ','��λ�������޷����У����ݳ��Ȳ���'];
    end
    msgbox(msgtext, '����')
end
end