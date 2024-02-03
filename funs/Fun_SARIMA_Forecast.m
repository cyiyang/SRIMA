function [forData,lower,upper,res] = Fun_SARIMA_Forecast(data,step,max_ar,max_ma,max_sar,max_sma,S,figflag,criterion)
% 使用SARIMA进行预测的函数，可以直接调用，非季节差分阶数自动确定。p，q，P，Q自动确定
% 输入：
% data为待预测数据，一维数据，使用SARIMA时，该数据长度至少为10+S，S为周期长度，但是达到10+S之后仍然可能会报错，可能是由数据的差分处理使得目标数据长度变短导致的。
% step为拟预测步数
% max_ar为AR模型搜寻的最大阶数   建议不大于3
% max_ma为MA模型搜寻的最大阶数   建议不大于3
% max_sar为SAR模型搜寻的最大阶数   建议不大于3
% max_sms为SMA模型搜寻的最大阶数   建议不大于3
% S为季节性周期
% figflag 为画图标志位，'on'为画图，'off'为不画
% criterion 为定阶准则，'aic'/'bic'/'aic+bic'三种选择，此变量可以不输入或者输入为[]，此时将使用默认'aic+bic'准则
% 输出：
% forData为预测结果，其长度等于step
% lower为预测结果的95%置信下限值
% upper为预测结果的95%置信上限值
% res：拟合残差值

%  Copyright (c) 2020 Mr.括号 All rights reserved.
%  本代码为淘宝买家专用，不开源，请勿公开分享~
if ~exist('criterion')
    criterion  = [];  %如果没有输入criterion参数，则指定为空
end
%% 1.载入数据
data = data(:);  %统一变为列向量
%% 2.确定季节性与非季节性差分数，D取默认值1，d从0至3循环，平稳后停止
for d = 0:3
    D1 = LagOp({1 -1},'Lags',[0,d]);     %非季节差分项的滞后算子
    D12 = LagOp({1 -1},'Lags',[0,1*S]);  %季节差分项的滞后算子
    D = D1*D12;          %相乘
    dY = filter(D,data); %对原数据进行差分运算
    if(getStatAdfKpss(dY)) %数据平稳
        disp(['非季节性差分数为',num2str(d),'，季节性差分数为1']);
        break;
    end
end
figure('Name','差分后数据','Visible',figflag,'color','w')
plot(dY);title('差分后数据')
%% 3.确定阶数ARlags,MALags,SARLags,SMALags
% 绘制ACF和PACF
figure('Name','平稳信号自相关图','Visible',figflag)
autocorr(dY)
figure('Name','平稳信号偏自相关图','Visible',figflag)
parcorr(dY)
% aicbic法确定阶数
try
    [AR_Order,MA_Order,SAR_Order,SMA_Order] = SARMA_Order_Select(dY,max_ar,max_ma,max_sar,max_sma,S,d,criterion); %自动定阶
catch ME %捕捉错误信息
    msgtext = ME.message;
    if (strcmp(ME.identifier,'econ:arima:estimate:InvalidVarianceModel'))
         msgtext = [msgtext,'  ','无法进行arima模型估计，这可能是由于用于训练的数据长度较小，而要进行拟合的阶数较高导致的，请尝试减小max_ar,max_ma,max_sar,max_sma的值'];
    end
    msgbox(msgtext, '错误')
end
disp(['ARlags=',num2str(AR_Order),',MALags=',num2str(MA_Order),',SARLags=',num2str(SAR_Order),',SMALags=',num2str(SMA_Order)]);
%% 4.残差检验
Mdl = creatSARIMA(AR_Order,MA_Order,SAR_Order,SMA_Order,S,d);  %创建SARIMA模型
try
    EstMdl = estimate(Mdl,data);
catch ME %捕捉错误信息
    msgtext = ME.message;
    if (strcmp(ME.identifier,'econ:arima:estimate:InvalidVarianceModel'))
         msgtext = [msgtext,'  ','无法进行arima模型估计，这可能是由于用于训练的数据长度较小，而要进行拟合的阶数较高导致的，请尝试减小max_ar和max_ma的值']
    end
    msgbox(msgtext, '错误')
    return
end
[res,~,logL] = infer(EstMdl,data);   %res即残差

stdr = res/sqrt(EstMdl.Variance);
figure('Name','残差检验','Visible',figflag)
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
% Durbin-Watson 统计是计量经济学分析中最常用的自相关度量
diffRes0 = diff(res);  
SSE0 = res'*res;
DW0 = (diffRes0'*diffRes0)/SSE0 % Durbin-Watson statistic，该值接近2，则可以认为序列不存在一阶相关性。
%% 5.预测
if ~isempty(strfind(version,'2018'))||~isempty(strfind(version,'2017'))||~isempty(strfind(version,'2016'))
    [forData,YMSE] = forecast(EstMdl,step,'Y0',data);   %matlab2018及以下版本写为Predict_Y = forecast(EstMdl,step,'Y0',Y);   matlab2019写为Predict_Y = forecast(EstMdl,step,Y);
elseif ~isempty(strfind(version,'2019'))||~isempty(strfind(version,'2020'))||~isempty(strfind(version,'2021'))||~isempty(strfind(version,'2022'))||~isempty(strfind(version,'2023'))
    [forData,YMSE] = forecast(EstMdl,step,data);   %matlab2018及以下版本写为Predict_Y = forecast(EstMdl,step,'Y0',Y);   matlab2019写为Predict_Y = forecast(EstMdl,step,Y);
else
    warndlg('仅支持MATLAB2016/2017/2018/2019/2020/2021/2022')
end
lower = forData - 1.96*sqrt(YMSE); %95置信区间下限
upper = forData + 1.96*sqrt(YMSE); %95置信区间上限

figure('Visible',figflag)
plot(data,'Color',[.7,.7,.7]);
hold on
h1 = plot(length(data):length(data)+step,[data(end);lower],'r:','LineWidth',2);
plot(length(data):length(data)+step,[data(end);upper],'r:','LineWidth',2)
h2 = plot(length(data):length(data)+step,[data(end);forData],'k','LineWidth',2);
legend([h1 h2],'95% 置信区间','预测值',...
	     'Location','NorthWest')
title('预测值')
hold off

end

function stat = getStatAdfKpss(data)
try 
    stat = adftest(data) && ~kpsstest(data);
catch ME
    msgtext = ME.message;
    if (strcmp(ME.identifier,'econ:adftest:EffectiveSampleSizeLessThanTabulatedValues'))
         msgtext = [msgtext,'  ','单位根检验无法进行，数据长度不足'];
    end
    msgbox(msgtext, '错误')
end
end