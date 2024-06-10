% -------------------------------------------------------------------------
%                           《PSINS 静态粗对准》                          
% 导入数据，调用 PSINS 工具箱的对准函数
% -------------------------------------------------------------------------
% 运行此脚本前需要配置 PSINS 工具箱：
%       1. 在官网下载最新版程序：http://www.psins.org.cn/
%       2. 解压文件夹;
%       3. 运行 psins240513/psinsinit.m 将 PSINS 文件目录加入搜索路径。
% -------------------------------------------------------------------------
% PSINS 提供了多种对准方法：
%       - alignsb：解析式对准，适用于静基座或微晃动环境(文献[1]7.1节)；
%       - aligni0：惯性凝固系初始对准（间接对准），抗角晃动干扰能力强(同上)；
%       - aligncmps：罗经法精对准(文献[11]2.3节)；
%       - alignfn/vn：以比力/速度误差为观测量的Kalman滤波精对准(文献[1]7.2节)；
%       - aligni0vn：基于数据复用技术，惯性系粗+速度量测Kalman滤波精对准；
% -------------------------------------------------------------------------
% 作者|创建日期|修改日期：     李郑骁 | 6/9/2024 | 6/9/2024          
% -------------------------------------------------------------------------

%% ------------------------- 程序初始化 ------------------------- %%
clear; close all; clc; warning off;                    % 清空工作区、命令窗 
addpath('data'); rmpath('base')                        % 添加数据文件目录

%% -------------------------- 配置选项 -------------------------- %%
ts                          = 0.005;                % 采样间隔
hz                          = 200;                  % 采样频率
is_time_stamp_zero          = true;                 % 是否将时间戳调整到从零开始
is_plot_raw_measurement     = true;                 % 是否绘制原始 IMU 量测W
p0  = [51.2124539701, -114.0248136140, 1077.393]; 	% 初始位置（纬经高） 【deg,deg,m】

%% ------------------------ 导入数据文件 ------------------------ %%
raw_imu = load('staticdata.txt');                                           % 【t(1)|gyr(3)|acc(3)】 
if is_time_stamp_zero,      raw_imu(:,1) = raw_imu(:,1) - raw_imu(1,1); end % 调整下标从零开始 
if is_plot_raw_measurement, plot_imu(raw_imu,'原始IMU量测');            end % 绘制 IMU 原始量测数据 
p0(1:2) = p0(1:2) / 180 * pi;                                               % 初始经纬度转弧度 

%% ------------------------- PSINS 解算 ------------------------ %% 
clear global glv; global glv; glv = glvf;

rfu_imu = [raw_imu(:,3),raw_imu(:,2),-raw_imu(:,4), ...
           raw_imu(:,6),raw_imu(:,5),-raw_imu(:,7),raw_imu(:,1)];

att = aligni0fitp(rfu_imu, p0, 1);
att_aligni0fitp = [att(2) * 180 / pi, att(1) * 180 / pi, -att(3) * 180 / pi];

att = alignsb(rfu_imu, p0);
att_alignsb = [att(2) * 180 / pi, att(1) * 180 / pi, -att(3) * 180 / pi];

att = aligni0(rfu_imu, p0, 1);
att_aligni0 = [att(2) * 180 / pi, att(1) * 180 / pi, -att(3) * 180 / pi];

fprintf('\n');
fprintf('        alignsb() 结果：%8.4f、%8.4f、%8.4f\n',...
    att_alignsb(1),att_alignsb(2),att_alignsb(3));
fprintf('        aligni0() 结果：%8.4f、%8.4f、%8.4f\n',...
    att_aligni0(1),att_aligni0(2),att_aligni0(3));
fprintf('att_aligni0fitp() 结果：%8.4f、%8.4f、%8.4f\n',...
    att_aligni0fitp(1),att_aligni0fitp(2),att_aligni0fitp(3));



