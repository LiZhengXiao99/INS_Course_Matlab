% -------------------------------------------------------------------------
%                            《静态粗对准》                         
% 给定了一组导航级IMU的原始静态数据70秒，用静态粗对准方法计算其初始姿态角
%   1  整段静态数据平均后计算一次姿态角;
%   2. 每秒平均值计算姿态角，并画出“姿态角-时间”曲线;
%   3. 每历元计算姿态角，并画出“姿态角-时间”曲线;
% 
% - 算出来航向角在 0 度附近，±180 很接近，所以直接画航向角时间序列不太好看
% 
% 作者|创建日期|修改日期：     李郑骁 | 6/6/2024 | 6/6/2024
% -------------------------------------------------------------------------

%% ------------------------- 程序初始化 ------------------------- %%
clear; close all; clc; warning off;                    % 清空工作区、命令窗 
addpath('data'); addpath('utils'); addpath('base');    % 添加数据文件目录 

%% -------------------------- 配置选项 -------------------------- %%
ts                          = 0.005;                % 采样间隔
hz                          = 200;                  % 采样频率
is_time_stamp_zero          = true;                 % 是否将时间戳调整到从零开始
is_plot_raw_measurement     = true;                 % 是否绘制原始 IMU 量测
is_plot_mean_imu_sec        = true;                 % 是否绘秒平滑后的 IMU 量测
is_plot_align_result        = true;                 % 是否绘制粗对准结果
p0  = [51.2124539701, -114.0248136140, 1077.393]; 	% 初始位置（纬经高） 【deg,deg,m】

%% ------------------------ 导入数据文件 ------------------------ %%
raw_imu = load('staticdata.txt');                                           % 【t(1)|gyr(3)|acc(3)】 
if is_time_stamp_zero,      raw_imu(:,1) = raw_imu(:,1) - raw_imu(1,1); end % 调整下标从零开始 
if is_plot_raw_measurement, plot_imu(raw_imu,'原始IMU量测');            end % 绘制 IMU 原始量测数据 
p0(1:2) = p0(1:2) / 180 * pi;                                               % 初始经纬度转弧度 

%% --------------- 整段静态数据平均后计算一次姿态角 -------------- %% 
mean_imu = mean(raw_imu);           % 【t(1)|gyr(3)|acc(3)】
att_mean = aligns(p0, mean_imu);    %  调用 aligns() 进行静态粗对准 

att_mean_deg = att_mean * 180 / pi;
fprintf('整段静态数据平均后进行粗对准：%8.4f、%8.4f、%8.4f\n',...
        att_mean_deg(1),att_mean_deg(2),att_mean_deg(3));

%% -------------------- 每历元平均值计算姿态角 ------------------ %% 
att_epoch = zeros(length(raw_imu),3);
for i = 1 : length(raw_imu)
    att_epoch(i, :) = aligns(p0, raw_imu(i, :));
end

%% ----------------------- 每秒计算姿态角 ----------------------- %% 
mean_imu_sec = zeros(floor(length(raw_imu)/hz),7);
att_mean_sec = zeros(floor(length(raw_imu)/hz),3);
for i = 1 : length(mean_imu_sec)
    mean_imu_sec(i,:) = mean(raw_imu(( (i-1) * hz + 1): (i) * hz ,:));
end
if is_plot_mean_imu_sec, plot_imu(mean_imu_sec,'秒平均IMU量测'); end  

for i = 1 : length(mean_imu_sec)
    att_mean_sec(i, :) = aligns(p0, mean_imu_sec(i, :));
end

%% ----------------------- 绘制粗对准结果 ----------------------- %% 
if ~is_plot_align_result, return; end

myfigure('秒平均值计算姿态角');
subplot(3,1,1), hold on, title('横滚角 (deg)'); plot(mean_imu_sec(:,1),att_mean_sec(:,1) * 180 / pi); grid on; 
subplot(3,1,2), hold on, title('俯仰角 (deg)'); plot(mean_imu_sec(:,1),att_mean_sec(:,2) * 180 / pi); grid on; 
subplot(3,1,3), hold on, title('航向角 (deg)'); plot(mean_imu_sec(:,1),att_mean_sec(:,3) * 180 / pi); grid on; 

myfigure('每历元计算姿态角');
subplot(3,1,1), hold on, title('横滚角 (deg)'); plot(raw_imu(:,1),att_epoch(:,1) * 180 / pi); grid on; 
subplot(3,1,2), hold on, title('俯仰角 (deg)'); plot(raw_imu(:,1),att_epoch(:,2) * 180 / pi); grid on; 
subplot(3,1,3), hold on, title('航向角 (deg)'); plot(raw_imu(:,1),att_epoch(:,3) * 180 / pi); grid on; 


