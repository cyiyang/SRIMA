function [AR_Order,MA_Order,SAR_Order,SMA_Order] = SARMA_Order_Select(data,max_ar,max_ma,max_sar,max_sma,season,di,criterion)
% ͨ��AIC��BIC��׼����ѡ�����������в����
% ���룺
% data��������
% max_arΪARģ����Ѱ��������   ���鲻����3
% max_maΪMAģ����Ѱ��������   ���鲻����3
% max_sarΪSARģ����Ѱ��������   ���鲻����3
% max_smsΪSMAģ����Ѱ��������   ���鲻����3
% SΪ����������
% �Ǽ���di��ֽ���
% criterion Ϊ����׼��'aic'/'bic'/'aic+bic'����ѡ�񣬴˱������Բ������������Ϊ[]����ʱ��ʹ��Ĭ��'aic+bic'׼��
% �����
% AR_OrderΪARģ���������
% MA_OrderΪMAģ���������
% SAR_OrderΪSARģ���������
% SMA_OrderΪSMAģ���������

%  Copyright (c) 2019 Mr.���� All rights reserved.
%  ԭ������ https://zhuanlan.zhihu.com/p/69630638
if ~exist('criterion')||isempty(criterion)  %δָ��׼��
    criterion = 'aic+bic';
end
T = length(data);

for ar = 0:max_ar
    for ma = 0:max_ma
        for sar = 0:max_sar
            for sma = 0:max_sma
                if ar==0&&ma==0
                    infoC_Sum(ar+1,ma+1,sar+1,sma+1) = NaN;
                    continue
                end
                if sar==0&&sma == 0
                    infoC_Sum(ar+1,ma+1,sar+1,sma+1) = NaN;
                    continue
                end
                try
                    Mdl = creatSARIMA(ar,ma,sar,sma,season,di);
                    [~, ~, LogL] = estimate(Mdl, data, 'Display', 'off');
                    [aic,bic] = aicbic(LogL,(ar+ma+sar+sma+2),T); %����ar��ma�⣬���г����ͷ����+2
                    switch criterion
                        case 'aic'
                            infoC_Sum(ar+1,ma+1,sar+1,sma+1) = aic;  %��AIC֮Ϊ��׼����ѡȡ
                        case 'bic'
                            infoC_Sum(ar+1,ma+1,sar+1,sma+1) = bic;  %��BICΪ��׼����ѡȡ
                        case 'aic+bic'
                            infoC_Sum(ar+1,ma+1,sar+1,sma+1) = bic+aic;  %��BIC��AIC֮��Ϊ��׼����ѡȡ
                    end
                    
                catch ME %��׽������Ϣ
                    msgtext = ME.message;
                    if (strcmp(ME.identifier,'econ:arima:estimate:InvalidVarianceModel'))
                         infoC_Sum(ar+1,ma+1,sar+1,sma+1) = NaN; %�޷����Ʋ�����ֱ����nan
                        %msgtext = [msgtext,'  ','�޷�����arimaģ�͹��ƣ����������������ѵ�������ݳ��Ƚ�С����Ҫ������ϵĽ����ϸߵ��µģ��볢�Լ�Сmax_ar��max_ma��ֵ']
                    else
                        infoC_Sum(ar+1,ma+1,sar+1,sma+1) = NaN; %�޷����Ʋ�����ֱ����nan
                        %msgbox(msgtext, '����')
                    end
                end
            end
        end
    end
end
ind = find(infoC_Sum==min(min(min(min(infoC_Sum)))));  %�ҵ���Сֵ������
[I1,I2,I3,I4] = ind2sub([max_ar+1,max_ma+1,max_sar+1,max_sma+1],ind);                 %������ת��Ϊ�±�
AR_Order  = I1 - 1;
MA_Order  = I2 - 1;
SAR_Order = I3 - 1;
SMA_Order = I4 - 1;
end