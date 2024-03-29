load('variety1.mat')
data = variety1;
days = 7; %向后预测天数
S = 12; %周期
max_ar = 3;
max_ma = 3;
max_sar = 3;
max_sma = 3;
figflag = 'on';
[forData,lower,upper,res] = Fun_SARIMA_Forecast(data,days,max_ar,max_ma,max_sar,max_sma,S,figflag,'aic');
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