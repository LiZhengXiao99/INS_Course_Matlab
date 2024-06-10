% -------------------------------------------------------------------------
%                           ��PSINS ���ߵ����ơ�                          
% �������ݣ����� PSINS ������� inspure ������������ο�����Ƚ�
% -------------------------------------------------------------------------
% ���д˽ű�ǰ��Ҫ���� PSINS �����䣺
%       1. �ڹ����������°����http://www.psins.org.cn/
%       2. ��ѹ�ļ���;
%       3. ���� psins240513/psinsinit.m �� PSINS �ļ�Ŀ¼��������·����
% -------------------------------------------------------------------------
%  avp = inspure(imu, avp0, href, isfig)
%  PSINS �Ĵ��ߵ�������Լ���ܶ�ģʽ����ѡ��
%  ���� f ģʽ����Լ�������ƣ�V �� H �Ƿֱ��ó�ֵԼ���̷߳�����ٶȺ�λ��
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
% ����|��������|�޸����ڣ�     ��֣�� | 6/8/2024 | 6/9/2024          
% -------------------------------------------------------------------------

%% ------------------------- �����ʼ�� ------------------------- %%
clear; close all; clc; warning off;                    % ��չ����������
addpath('data'); rmpath('base')                        % ��������ļ�Ŀ¼

%% -------------------------- ����ѡ�� -------------------------- %%
ts                          = 0.005;        % �������
t0                          = 91620.0;      % ��ʼʱ��
is_calibrate_imu            = false;        % �Ƿ�У׼ IMU ����ֵ
is_only_100s                = false;        % �Ƿ�ֻ����ǰ 100 ������

% ��ͼ����
is_time_stamp_zero          = true;         % �Ƿ�ʱ������������㿪ʼ
is_plot_raw_measurement     = true;         % �Ƿ����ԭʼ IMU ����
is_plot_ref_pva             = false;        % �Ƿ���� PVA �ο�����
is_plot_result_pva          = false;        % �Ƿ���� PVA �������
is_plot_compare_pva         = true;         % �Ƿ���� PVA �������Ա�ͼ

% PVA ��ֵ
p0  = [23.1373950708; 113.3713651222; 2.175];                       % ��ʼλ�ã�BLH��            ��deg,deg,m��
v0  = [0.0; 0.0; 0.0];                                              % ��ʼ�ٶȣ�NED��            ��m/s��
a0  = [0.0107951084511778; -2.14251290749072; -75.7498049314083 ];  % ��ʼ��̬��Roll,Pitch,Yall����deg��
p0(1:2) = p0(1:2) / 180 * pi; a0 = a0 / 180 * pi;                   % ��ʼ�Ƕ�ת���� 

%% ------------------------ ���������ļ� ------------------------ %%
raw_imu = binfile('Data1.bin', 7);                                      % IMU �������ݡ�t(1)|gyr(3)|acc(3)��
pva_ref = binfile('Data1_PureINS.bin', 10);                             % PVA �ο�    ��t(1)|pos(3)|vel(3)|att(3)��

if is_only_100s
    raw_imu = raw_imu(1:20000,:); 
    pva_ref = pva_ref(1:20000,:); 
end

if is_time_stamp_zero,      raw_imu(:,1) = raw_imu(:,1) - raw_imu(1,1); end  % ����ԭʼ�����±���㿪ʼ
if is_time_stamp_zero,      pva_ref(:,1) = pva_ref(:,1) - pva_ref(1,1); end  % �����ο�����±���㿪ʼ
if is_plot_raw_measurement, plot_imu(raw_imu,'ԭʼIMU����');            end  % ���� IMU ԭʼ��������
if is_plot_ref_pva,         plot_pva(pva_ref,'PVA �ο����');           end  % ���� PVA �ο����

%% ------------------------- PSINS ���� ------------------------ %% 
clear global glv; global glv; glv = glvf;

rfu_imu = [raw_imu(:,3),raw_imu(:,2),-raw_imu(:,4), ...
           raw_imu(:,6),raw_imu(:,5),-raw_imu(:,7),raw_imu(:,1)];

ned_avpr = [a0(2),a0(1),-a0(3), ...
            v0(2),v0(1),-v0(3), ...
            p0',raw_imu(1:1)];

% ���һ�������� f ģʽ����Լ�������ƣ�V �� H �Ƿֱ��ó�ֵԼ���̷߳�����ٶȺ�λ��
avp = inspure(rfu_imu, ned_avpr, 'H');         

pva_psins = [avp(:,10),avp(:,7) * 180 / pi,avp(:,8) * 180 / pi,avp(:,9), ...
                       avp(:,5),avp(:,4),-avp(:,6), ...
                       avp(:,2) * 180 / pi,avp(:,1) * 180 / pi,-avp(:,3) * 180 / pi];

if is_plot_compare_pva, polt_pva_compare(pva_psins,pva_ref,"PSINS���","�ο����"); end
save data/pva_psins pva_psins




