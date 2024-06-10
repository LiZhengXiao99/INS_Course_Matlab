% -------------------------------------------------------------------------
%                            《纯惯导递推》                          
% 利用陀螺和加速度计的输出利用机械编排算法推算载体的位置、速度、姿态 
% 
% - 图省事没有用四元数，表示姿态和旋转大都直接用方向余弦阵
% - 以单子样 + 前一周期的算法补偿了陀螺仪和加速度计的不可交换误差 
% - 计算全部的一个多小时数据相当费时，可以配置 is_only_100s 只计算 100 秒 
% 
% 作者|创建日期|修改日期：     李郑骁 | 6/6/2024 | 6/8/2024          
% -------------------------------------------------------------------------

%% ------------------------- 程序初始化 ------------------------- %%
clear; close all; clc; warning off;                    % 清空工作区、命令窗
addpath('data'); addpath('utils'); addpath('base');    % 添加数据文件目录

%% -------------------------- 配置选项 -------------------------- %%
ts                          = 0.005;        % 采样间隔
t0                          = 91620.0;      % 初始时刻
is_cnscl                    = true;         % 是否进行不可交换误差补偿
is_calibrate_imu            = false;        % 是否校准 IMU 量测值（暂不支持）
is_only_100s                = false;        % 是否只计算前 100 秒数据

% 绘图设置
is_time_stamp_zero          = true;         % 是否将时间戳调整到从零开始
is_plot_raw_measurement     = true;         % 是否绘制原始 IMU 量测
is_plot_ref_pva             = false;        % 是否绘制 PVA 参考数据
is_plot_result_pva          = false;        % 是否绘制 PVA 结果数据
is_compare_with_psins       = true;         % 是否与 PSINS 解算结果比较

% PVA 初值
p0  = [23.1373950708; 113.3713651222; 2.175];                       % 初始位置（BLH）            【deg,deg,m】
v0  = [0.0; 0.0; 0.0];                                              % 初始速度（NED）            【m/s】
a0  = [0.0107951084511778; -2.14251290749072; -75.7498049314083 ];  % 初始姿态（Roll,Pitch,Yall）【deg】
p0(1:2) = p0(1:2) / 180 * pi; a0 = a0 / 180 * pi;                   % 初始角度转弧度 

%% ------------------------ 导入数据文件 ------------------------ %%
raw_imu = binfile('Data1.bin', 7);                                      % IMU 量测数据【t(1)|gyr(3)|acc(3)】
pva_ref = binfile('Data1_PureINS.bin', 10);                             % PVA 参考    【t(1)|pos(3)|vel(3)|att(3)】
if is_compare_with_psins, load('pva_psins.mat'); end                    % PSINS 结果
            
if is_only_100s                                                         % 裁剪出前 100 秒的数据
    raw_imu = raw_imu(1:20000,:); pva_ref = pva_ref(1:20000,:); 
    if is_compare_with_psins, pva_psins = pva_psins(1:5000,:); end
end

if is_time_stamp_zero,      raw_imu(:,1) = raw_imu(:,1) - raw_imu(1,1); end  % 调整原始数据下标从零开始
if is_time_stamp_zero,      pva_ref(:,1) = pva_ref(:,1) - pva_ref(1,1); end  % 调整参考结果下标从零开始
if is_plot_raw_measurement, plot_imu(raw_imu,'原始IMU量测');            end  % 绘制 IMU 原始量测数据
if is_plot_ref_pva,         plot_pva(pva_ref,'PVA 参考结果');           end  % 绘制 PVA 参考结果

%% ----------------------- 惯导解算初始化 ----------------------- %% 
last_imu = raw_imu(1,:); cur_imu = raw_imu(1,:);    
last_pos = p0; last_vel = v0; last_att = a0;
pva_sins = zeros(length(raw_imu),10);
timebar(1, length(raw_imu), '纯惯导递推解算');

%% ----------------------- 逐历元惯导递推 ----------------------- %% 
for i = 1 : length(raw_imu)
    %% 取 IMU 量测值、校准
    last_imu = cur_imu; cur_imu = raw_imu(i,:);
    if is_calibrate_imu, cur_imu = calibrate_imu(imu, Ba, Bg, Mg, Ma); end      

    %% 不可交换误差补偿，得到补偿后的角增量 d_theta、比力增量 d_vfb
    if is_cnscl
        d_vfb = cur_imu(5:7)' + ...
            + cross(cur_imu(2:4)' , cur_imu(5:7)') / 2 ...
            + cross(last_imu(2:4)', cur_imu(5:7)') / 12 ...
            + cross(last_imu(5:7)', cur_imu(2:4)') / 12;
        d_theta = cur_imu(2:4)' + cross(last_imu(2:4)',cur_imu(2:4)') / 12;
    else
        d_vfb = cur_imu(5:7)'; d_theta = cur_imu(2:4)'
    end

    %% 地球相关参数计算
    w_nen = earth.wnen(last_pos, last_vel);             % 牵连角速度引起的 n 系旋转
    w_nie = earth.wnie(last_pos(1));                    % 地球自转引起的 n 系旋转
    w_nin = w_nen + w_nie;                              % n 相对 i 的旋转角速度
    g = earth.g(last_pos);                              % 重力加速度
    gn = earth.gn(g);                                   % 重力加速度在 n 系投影
    gcc = gn - cross(w_nin + w_nie, last_vel);          % 有害加速度
    
    %%  当前速度 = 上一时刻速度 + n 系比力积分项 + 有害加速度积分项 
    d_nin = w_nin * ts;                                 % n 系相对 i 系的旋转角度
    cnn = eye(3) - attitude.skew_symmetric(d_nin / 2);  % n 系相对于 i 系的旋转矩阵
    cbn =  attitude.a2m(last_att);                      % 上一时刻姿态阵
    d_vfn = cnn * cbn * d_vfb;                          % 把加速度计输出的 b 系比力增量转为 n 系比力积分项
    d_vgn = gcc * ts;                                   % 有害加速度积分项
    cur_vel = last_vel + d_vfn + d_vgn; 

    %% 当前位置 = 上一时刻位置 + 位置更新矩阵 * 两时刻平均速度
    cur_pos = last_pos + earth.mpv(last_pos) * (last_vel + cur_vel) * ts / 2;

    %% 当前姿态 = 两时刻 n 系的旋转矩阵 * 上一时刻姿态阵 * 两时刻 b 系旋转矩阵
    cbb = attitude.rv2m(d_theta);   % 两时刻 b 系旋转矩阵
    cnn = attitude.rv2m(-d_nin);    % 两时刻 n 系旋转矩阵
    cbn = cnn * cbn * cbb;          % 当前时刻姿态阵
    cur_att = attitude.m2a(cbn);    % 当前时刻欧拉角

    %% 存储导航结果 PVA
    timebar;
    pva_sins(i,:) = [cur_imu(1), cur_pos', cur_vel', cur_att'];
    last_pos = cur_pos; last_vel = cur_vel; last_att = cur_att; 
end

%% ----------------------- 结果绘图与分析 ----------------------- %% 
pva_sins(:,2:3) = pva_sins(:,2:3) * 180 / pi;
pva_sins(:,8:10) = pva_sins(:,8:10) * 180 / pi;
save data/pva_sins pva_sins;
if is_plot_result_pva, plot_pva(pva_sins,'纯惯导递推 PVA 结果'); end
if is_compare_with_psins
    polt_pva_compare3(pva_sins,pva_psins,pva_ref,"课设程序结果","PSINS结果","参考结果");
else
    polt_pva_compare(pva_sins,pva_ref,"课程程序结果","参考结果"); 
end



