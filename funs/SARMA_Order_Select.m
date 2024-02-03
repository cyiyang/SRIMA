function [AR_Order,MA_Order,SAR_Order,SMA_Order] = SARMA_Order_Select(data,max_ar,max_ma,max_sar,max_sma,season,di,criterion)
% 通过AIC，BIC等准则暴力选定阶数，带有差分项
% 输入：
% data对象数据
% max_ar为AR模型搜寻的最大阶数   建议不大于3
% max_ma为MA模型搜寻的最大阶数   建议不大于3
% max_sar为SAR模型搜寻的最大阶数   建议不大于3
% max_sms为SMA模型搜寻的最大阶数   建议不大于3
% S为季节性周期
% 非季节di差分阶数
% criterion 为定阶准则，'aic'/'bic'/'aic+bic'三种选择，此变量可以不输入或者输入为[]，此时将使用默认'aic+bic'准则
% 输出：
% AR_Order为AR模型输出阶数
% MA_Order为MA模型输出阶数
% SAR_Order为SAR模型输出阶数
% SMA_Order为SMA模型输出阶数

%  Copyright (c) 2019 Mr.括号 All rights reserved.
%  原文链接 https://zhuanlan.zhihu.com/p/69630638
if ~exist('criterion')||isempty(criterion)  %未指定准则
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
                    [aic,bic] = aicbic(LogL,(ar+ma+sar+sma+2),T); %除了ar与ma外，还有常数和方差，故+2
                    switch criterion
                        case 'aic'
                            infoC_Sum(ar+1,ma+1,sar+1,sma+1) = aic;  %以AIC之为标准进行选取
                        case 'bic'
                            infoC_Sum(ar+1,ma+1,sar+1,sma+1) = bic;  %以BIC为标准进行选取
                        case 'aic+bic'
                            infoC_Sum(ar+1,ma+1,sar+1,sma+1) = bic+aic;  %以BIC和AIC之和为标准进行选取
                    end
                    
                catch ME %捕捉错误信息
                    msgtext = ME.message;
                    if (strcmp(ME.identifier,'econ:arima:estimate:InvalidVarianceModel'))
                         infoC_Sum(ar+1,ma+1,sar+1,sma+1) = NaN; %无法估计参数，直接置nan
                        %msgtext = [msgtext,'  ','无法进行arima模型估计，这可能是由于用于训练的数据长度较小，而要进行拟合的阶数较高导致的，请尝试减小max_ar和max_ma的值']
                    else
                        infoC_Sum(ar+1,ma+1,sar+1,sma+1) = NaN; %无法估计参数，直接置nan
                        %msgbox(msgtext, '错误')
                    end
                end
            end
        end
    end
end
ind = find(infoC_Sum==min(min(min(min(infoC_Sum)))));  %找到最小值的索引
[I1,I2,I3,I4] = ind2sub([max_ar+1,max_ma+1,max_sar+1,max_sma+1],ind);                 %将索引转换为下标
AR_Order  = I1 - 1;
MA_Order  = I2 - 1;
SAR_Order = I3 - 1;
SMA_Order = I4 - 1;
end