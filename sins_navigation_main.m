% -------------------------------------------------------------------------
%                            �����ߵ����ơ�                          
% �������ݺͼ��ٶȼƵ�������û�е�����㷨���������λ�á��ٶȡ���̬ 
% 
% - ͼʡ��û������Ԫ������ʾ��̬����ת��ֱ���÷���������
% - �Ե����� + ǰһ���ڵ��㷨�����������Ǻͼ��ٶȼƵĲ��ɽ������ 
% - ����ȫ����һ����Сʱ�����൱��ʱ���������� is_only_100s ֻ���� 100 �� 
% 
% ����|��������|�޸����ڣ�     ��֣�� | 6/6/2024 | 6/8/2024          
% -------------------------------------------------------------------------

%% ------------------------- �����ʼ�� ------------------------- %%
clear; close all; clc; warning off;                    % ��չ����������
addpath('data'); addpath('utils'); addpath('base');    % ��������ļ�Ŀ¼

%% -------------------------- ����ѡ�� -------------------------- %%
ts                          = 0.005;        % �������
t0                          = 91620.0;      % ��ʼʱ��
is_cnscl                    = true;         % �Ƿ���в��ɽ�������
is_calibrate_imu            = false;        % �Ƿ�У׼ IMU ����ֵ���ݲ�֧�֣�
is_only_100s                = false;        % �Ƿ�ֻ����ǰ 100 ������

% ��ͼ����
is_time_stamp_zero          = true;         % �Ƿ�ʱ������������㿪ʼ
is_plot_raw_measurement     = true;         % �Ƿ����ԭʼ IMU ����
is_plot_ref_pva             = false;        % �Ƿ���� PVA �ο�����
is_plot_result_pva          = false;        % �Ƿ���� PVA �������
is_compare_with_psins       = true;         % �Ƿ��� PSINS �������Ƚ�

% PVA ��ֵ
p0  = [23.1373950708; 113.3713651222; 2.175];                       % ��ʼλ�ã�BLH��            ��deg,deg,m��
v0  = [0.0; 0.0; 0.0];                                              % ��ʼ�ٶȣ�NED��            ��m/s��
a0  = [0.0107951084511778; -2.14251290749072; -75.7498049314083 ];  % ��ʼ��̬��Roll,Pitch,Yall����deg��
p0(1:2) = p0(1:2) / 180 * pi; a0 = a0 / 180 * pi;                   % ��ʼ�Ƕ�ת���� 

%% ------------------------ ���������ļ� ------------------------ %%
raw_imu = binfile('Data1.bin', 7);                                      % IMU �������ݡ�t(1)|gyr(3)|acc(3)��
pva_ref = binfile('Data1_PureINS.bin', 10);                             % PVA �ο�    ��t(1)|pos(3)|vel(3)|att(3)��
if is_compare_with_psins, load('pva_psins.mat'); end                    % PSINS ���
            
if is_only_100s                                                         % �ü���ǰ 100 �������
    raw_imu = raw_imu(1:20000,:); pva_ref = pva_ref(1:20000,:); 
    if is_compare_with_psins, pva_psins = pva_psins(1:5000,:); end
end

if is_time_stamp_zero,      raw_imu(:,1) = raw_imu(:,1) - raw_imu(1,1); end  % ����ԭʼ�����±���㿪ʼ
if is_time_stamp_zero,      pva_ref(:,1) = pva_ref(:,1) - pva_ref(1,1); end  % �����ο�����±���㿪ʼ
if is_plot_raw_measurement, plot_imu(raw_imu,'ԭʼIMU����');            end  % ���� IMU ԭʼ��������
if is_plot_ref_pva,         plot_pva(pva_ref,'PVA �ο����');           end  % ���� PVA �ο����

%% ----------------------- �ߵ������ʼ�� ----------------------- %% 
last_imu = raw_imu(1,:); cur_imu = raw_imu(1,:);    
last_pos = p0; last_vel = v0; last_att = a0;
pva_sins = zeros(length(raw_imu),10);
timebar(1, length(raw_imu), '���ߵ����ƽ���');

%% ----------------------- ����Ԫ�ߵ����� ----------------------- %% 
for i = 1 : length(raw_imu)
    %% ȡ IMU ����ֵ��У׼
    last_imu = cur_imu; cur_imu = raw_imu(i,:);
    if is_calibrate_imu, cur_imu = calibrate_imu(imu, Ba, Bg, Mg, Ma); end      

    %% ���ɽ����������õ�������Ľ����� d_theta���������� d_vfb
    if is_cnscl
        d_vfb = cur_imu(5:7)' + ...
            + cross(cur_imu(2:4)' , cur_imu(5:7)') / 2 ...
            + cross(last_imu(2:4)', cur_imu(5:7)') / 12 ...
            + cross(last_imu(5:7)', cur_imu(2:4)') / 12;
        d_theta = cur_imu(2:4)' + cross(last_imu(2:4)',cur_imu(2:4)') / 12;
    else
        d_vfb = cur_imu(5:7)'; d_theta = cur_imu(2:4)'
    end

    %% ������ز�������
    w_nen = earth.wnen(last_pos, last_vel);             % ǣ�����ٶ������ n ϵ��ת
    w_nie = earth.wnie(last_pos(1));                    % ������ת����� n ϵ��ת
    w_nin = w_nen + w_nie;                              % n ��� i ����ת���ٶ�
    g = earth.g(last_pos);                              % �������ٶ�
    gn = earth.gn(g);                                   % �������ٶ��� n ϵͶӰ
    gcc = gn - cross(w_nin + w_nie, last_vel);          % �к����ٶ�
    
    %%  ��ǰ�ٶ� = ��һʱ���ٶ� + n ϵ���������� + �к����ٶȻ����� 
    d_nin = w_nin * ts;                                 % n ϵ��� i ϵ����ת�Ƕ�
    cnn = eye(3) - attitude.skew_symmetric(d_nin / 2);  % n ϵ����� i ϵ����ת����
    cbn =  attitude.a2m(last_att);                      % ��һʱ����̬��
    d_vfn = cnn * cbn * d_vfb;                          % �Ѽ��ٶȼ������ b ϵ��������תΪ n ϵ����������
    d_vgn = gcc * ts;                                   % �к����ٶȻ�����
    cur_vel = last_vel + d_vfn + d_vgn; 

    %% ��ǰλ�� = ��һʱ��λ�� + λ�ø��¾��� * ��ʱ��ƽ���ٶ�
    cur_pos = last_pos + earth.mpv(last_pos) * (last_vel + cur_vel) * ts / 2;

    %% ��ǰ��̬ = ��ʱ�� n ϵ����ת���� * ��һʱ����̬�� * ��ʱ�� b ϵ��ת����
    cbb = attitude.rv2m(d_theta);   % ��ʱ�� b ϵ��ת����
    cnn = attitude.rv2m(-d_nin);    % ��ʱ�� n ϵ��ת����
    cbn = cnn * cbn * cbb;          % ��ǰʱ����̬��
    cur_att = attitude.m2a(cbn);    % ��ǰʱ��ŷ����

    %% �洢������� PVA
    timebar;
    pva_sins(i,:) = [cur_imu(1), cur_pos', cur_vel', cur_att'];
    last_pos = cur_pos; last_vel = cur_vel; last_att = cur_att; 
end

%% ----------------------- �����ͼ����� ----------------------- %% 
pva_sins(:,2:3) = pva_sins(:,2:3) * 180 / pi;
pva_sins(:,8:10) = pva_sins(:,8:10) * 180 / pi;
save data/pva_sins pva_sins;
if is_plot_result_pva, plot_pva(pva_sins,'���ߵ����� PVA ���'); end
if is_compare_with_psins
    polt_pva_compare3(pva_sins,pva_psins,pva_ref,"���������","PSINS���","�ο����");
else
    polt_pva_compare(pva_sins,pva_ref,"�γ̳�����","�ο����"); 
end



