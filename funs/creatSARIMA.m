function Mdl = creatSARIMA(ar,ma,sar,sma,season,di)
% Copyright (c) 2019 Mr.括号 All rights reserved.
% 根据参数创建SARIMA模型，常数项都设为了0
% 输入：
% ar 为AR模型阶数
% ma 为MA模型阶数
% sar 为SAR模型阶数   
% sma 为SMA模型阶数   
% season 为季节性周期
% di为差分阶次
% 输出：
% Mdl 构建的SARIMA模型

%  Copyright (c) 2020 Mr.括号 All rights reserved.
%  本代码为淘宝买家专用，不开源，请勿公开分享~
    if ar==0&&ma~=0&&sar==0&&sma~=0
        Mdl = arima('Constant',0,'D',di,...
    'Seasonality',season,'MALags',1:ma,'SMALags',(1:sma)*season);
    elseif  ar~=0&&ma==0&&sar==0&&sma~=0
        Mdl = arima('Constant',0,'ARLags',1:ar,'D',di,...
    'Seasonality',season,'SMALags',(1:sma)*season);
    elseif  ar==0&&ma~=0&&sar~=0&&sma==0
        Mdl = arima('Constant',0,'SARLags',(1:sar)*season,'D',di,...
    'Seasonality',season,'MALags',1:ma);
    elseif  ar~=0&&ma==0&&sar~=0&&sma==0
        Mdl = arima('Constant',0,'ARLags',1:ar,'SARLags',(1:sar)*season,'D',di,...
    'Seasonality',season);
    elseif  ar~=0&&ma~=0&&sar~=0&&sma==0
        Mdl = arima('Constant',0,'ARLags',1:ar,'SARLags',(1:sar)*season,'D',di,...
    'Seasonality',season,'MALags',1:ma);
    elseif  ar~=0&&ma~=0&&sar==0&&sma~=0
        Mdl = arima('Constant',0,'ARLags',1:ar,'D',di,...
    'Seasonality',season,'MALags',1:ma,'SMALags',(1:sma)*season);
    elseif  ar~=0&&ma==0&&sar~=0&&sma~=0
        Mdl = arima('Constant',0,'ARLags',1:ar,'SARLags',(1:sar)*season,'D',di,...
    'Seasonality',season,'SMALags',(1:sma)*season);
    elseif  ar==0&&ma~=0&&sar~=0&&sma~=0
        Mdl = arima('Constant',0,'SARLags',(1:sar)*season,'D',di,...
    'Seasonality',season,'MALags',1:ma,'SMALags',(1:sma)*season);
    elseif  ar~=0&&ma~=0&&sar~=0&&sma~=0
        Mdl = arima('Constant',0,'ARLags',1:ar,'SARLags',(1:sar)*season,'D',di,...
    'Seasonality',season,'MALags',1:ma,'SMALags',(1:sma)*season);
    end
    arima
end