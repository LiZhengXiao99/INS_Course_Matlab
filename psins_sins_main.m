% -------------------------------------------------------------------------
%                           《PSINS 纯惯导递推》                          
% 导入数据，调用 PSINS 工具箱的 inspure 计算结果，再与参考结果比较
% -------------------------------------------------------------------------
% 运行此脚本前需要配置 PSINS 工具箱：
%       1. 在官网下载最新版程序：http://www.psins.org.cn/
%       2. 解压文件夹;
%       3. 运行 psins240513/psinsinit.m 将 PSINS 文件目录加入搜索路径。
% -------------------------------------------------------------------------
%  avp = inspure(imu, avp0, href, isfig)
%  PSINS 的纯惯导递推有约束很多模式可以选：
%  其中 f 模式是无约束纯递推，V 和 H 是分别用初值约束高程方向的速度和位置
%       'v' - velocity fix-damping, =vn0
%       'V' - vertical velocity fix-damping, =vn0(3)
%       'p' - position fix-damping, =pos0
%       'P' - position fix-damping, =pos0 & vertical velocity fix-damping, =vn0(3)
%       'H' - height fix-damping, =pos0(3)
%       'f' - height free.
%       'O' - open loop, vn=0.  Ref: my PhD thesis P41
%  If href is a 3or2-column vector and length(href)==length(imu)
%       'z' - fix vU & hgt, vU=href(:,1), hgt=href(:,2).
%       'Z' - fix hgt, hgt=href(:,1).
% -------------------------------------------------------------------------
% 作者|创建日期|修改日期：     李郑骁 | 6/8/2024 | 6/9/2024          
% -------------------------------------------------------------------------

%% ------------------------- 程序初始化 ------------------------- %%
clear; close all; clc; warning off;                    % 清空工作区、命令窗
addpath('data'); rmpath('base')                        % 添加数据文件目录

%% -------------------------- 配置选项 -------------------------- %%
ts                          = 0.005;        % 采样间隔
t0                          = 91620.0;      % 初始时刻
is_calibrate_imu            = false;        % 是否校准 IMU 量测值
is_only_100s                = false;        % 是否只计算前 100 秒数据

% 绘图设置
is_time_stamp_zero          = true;         % 是否将时间戳调整到从零开始
is_plot_raw_measurement     = true;         % 是否绘制原始 IMU 量测
is_plot_ref_pva             = false;        % 是否绘制 PVA 参考数据
is_plot_result_pva          = false;        % 是否绘制 PVA 结果数据
is_plot_compare_pva         = true;         % 是否绘制 PVA 解算结果对比图

% PVA 初值
p0  = [23.1373950708; 113.3713651222; 2.175];                       % 初始位置（BLH）            【deg,deg,m】
v0  = [0.0; 0.0; 0.0];                                              % 初始速度（NED）            【m/s】
a0  = [0.0107951084511778; -2.14251290749072; -75.7498049314083 ];  % 初始姿态（Roll,Pitch,Yall）【deg】
p0(1:2) = p0(1:2) / 180 * pi; a0 = a0 / 180 * pi;                   % 初始角度转弧度 

%% ------------------------ 导入数据文件 ------------------------ %%
raw_imu = binfile('Data1.bin', 7);                                      % IMU 量测数据【t(1)|gyr(3)|acc(3)】
pva_ref = binfile('Data1_PureINS.bin', 10);                             % PVA 参考    【t(1)|pos(3)|vel(3)|att(3)】

if is_only_100s
    raw_imu = raw_imu(1:20000,:); 
    pva_ref = pva_ref(1:20000,:); 
end

if is_time_stamp_zero,      raw_imu(:,1) = raw_imu(:,1) - raw_imu(1,1); end  % 调整原始数据下标从零开始
if is_time_stamp_zero,      pva_ref(:,1) = pva_ref(:,1) - pva_ref(1,1); end  % 调整参考结果下标从零开始
if is_plot_raw_measurement, plot_imu(raw_imu,'原始IMU量测');            end  % 绘制 IMU 原始量测数据
if is_plot_ref_pva,         plot_pva(pva_ref,'PVA 参考结果');           end  % 绘制 PVA 参考结果

%% ------------------------- PSINS 解算 ------------------------ %% 
clear global glv; global glv; glv = glvf;

rfu_imu = [raw_imu(:,3),raw_imu(:,2),-raw_imu(:,4), ...
           raw_imu(:,6),raw_imu(:,5),-raw_imu(:,7),raw_imu(:,1)];

ned_avpr = [a0(2),a0(1),-a0(3), ...
            v0(2),v0(1),-v0(3), ...
            p0',raw_imu(1:1)];

% 最后一个参数： f 模式是无约束纯递推，V 和 H 是分别用初值约束高程方向的速度和位置
avp = inspure(rfu_imu, ned_avpr, 'H');         

pva_psins = [avp(:,10),avp(:,7) * 180 / pi,avp(:,8) * 180 / pi,avp(:,9), ...
                       avp(:,5),avp(:,4),-avp(:,6), ...
                       avp(:,2) * 180 / pi,avp(:,1) * 180 / pi,-avp(:,3) * 180 / pi];

if is_plot_compare_pva, polt_pva_compare(pva_psins,pva_ref,"PSINS结果","参考结果"); end
save data/pva_psins pva_psins




