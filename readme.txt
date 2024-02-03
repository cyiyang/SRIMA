一、代码运行环境：
MATLAB2019 / MATLAB2018 / MATLAB2017

二、文件说明
1.文件夹funs
funs文件夹中为ARMA相关的函数文件，该文件夹中的文件无法直接运行，需要在其他文件或命令行窗口中对入口参数赋值并调用。
1.1. SARMA_Order_Select.m
通过AIC，BIC等准则暴力选定阶数。
1.2. Fun_SARIMA_Forecast.m
封装好的预测程序，可以通过输入原始数据、预测步数等直接获得预测结果。使用SARIMA进行预测的函数，可以直接调用，非季节差分阶数自动确定。p，q，P，Q自动确定。
1.3. creatSARIMA.m
根据参数创建SARIMA模型，在其他文件中调用
2.文件夹demos
demo中为一些demo文件，用于测试funs中的函数。
2.1. Demo_SARIMA.m
调用Fun_SARIMA_Forecast 进行多步预测的demo。
3.文件夹scripts
3.1. SARMA_Forecast.m
知乎专栏（https://zhuanlan.zhihu.com/p/117595003）中的多步预测代码。为脚本文件，可以直接运行。其中调用了Fun_SARIMA_Forecast.。

三、使用说明
1. 使用前建议先执行安装，安装方法为
（1）右键点击“install_funs.m”，再点运行。
 
（2）当在命令行窗口出现下图提示时说明安装完成
 
四、常见问题：
暂无
