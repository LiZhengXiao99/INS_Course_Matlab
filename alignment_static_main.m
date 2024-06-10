% -------------------------------------------------------------------------
%                            ����̬�ֶ�׼��                         
% ������һ�鵼����IMU��ԭʼ��̬����70�룬�þ�̬�ֶ�׼�����������ʼ��̬��
%   1  ���ξ�̬����ƽ�������һ����̬��;
%   2. ÿ��ƽ��ֵ������̬�ǣ�����������̬��-ʱ�䡱����;
%   3. ÿ��Ԫ������̬�ǣ�����������̬��-ʱ�䡱����;
% 
% - ������������ 0 �ȸ�������180 �ܽӽ�������ֱ�ӻ������ʱ�����в�̫�ÿ�
% 
% ����|��������|�޸����ڣ�     ��֣�� | 6/6/2024 | 6/6/2024
% -------------------------------------------------------------------------

%% ------------------------- �����ʼ�� ------------------------- %%
clear; close all; clc; warning off;                    % ��չ���������� 
addpath('data'); addpath('utils'); addpath('base');    % ��������ļ�Ŀ¼ 

%% -------------------------- ����ѡ�� -------------------------- %%
ts                          = 0.005;                % �������
hz                          = 200;                  % ����Ƶ��
is_time_stamp_zero          = true;                 % �Ƿ�ʱ������������㿪ʼ
is_plot_raw_measurement     = true;                 % �Ƿ����ԭʼ IMU ����
is_plot_mean_imu_sec        = true;                 % �Ƿ����ƽ����� IMU ����
is_plot_align_result        = true;                 % �Ƿ���ƴֶ�׼���
p0  = [51.2124539701, -114.0248136140, 1077.393]; 	% ��ʼλ�ã�γ���ߣ� ��deg,deg,m��

%% ------------------------ ���������ļ� ------------------------ %%
raw_imu = load('staticdata.txt');                                           % ��t(1)|gyr(3)|acc(3)�� 
if is_time_stamp_zero,      raw_imu(:,1) = raw_imu(:,1) - raw_imu(1,1); end % �����±���㿪ʼ 
if is_plot_raw_measurement, plot_imu(raw_imu,'ԭʼIMU����');            end % ���� IMU ԭʼ�������� 
p0(1:2) = p0(1:2) / 180 * pi;                                               % ��ʼ��γ��ת���� 

%% --------------- ���ξ�̬����ƽ�������һ����̬�� -------------- %% 
mean_imu = mean(raw_imu);           % ��t(1)|gyr(3)|acc(3)��
att_mean = aligns(p0, mean_imu);    %  ���� aligns() ���о�̬�ֶ�׼ 

att_mean_deg = att_mean * 180 / pi;
fprintf('���ξ�̬����ƽ������дֶ�׼��%8.4f��%8.4f��%8.4f\n',...
        att_mean_deg(1),att_mean_deg(2),att_mean_deg(3));

%% -------------------- ÿ��Ԫƽ��ֵ������̬�� ------------------ %% 
att_epoch = zeros(length(raw_imu),3);
for i = 1 : length(raw_imu)
    att_epoch(i, :) = aligns(p0, raw_imu(i, :));
end

%% ----------------------- ÿ�������̬�� ----------------------- %% 
mean_imu_sec = zeros(floor(length(raw_imu)/hz),7);
att_mean_sec = zeros(floor(length(raw_imu)/hz),3);
for i = 1 : length(mean_imu_sec)
    mean_imu_sec(i,:) = mean(raw_imu(( (i-1) * hz + 1): (i) * hz ,:));
end
if is_plot_mean_imu_sec, plot_imu(mean_imu_sec,'��ƽ��IMU����'); end  

for i = 1 : length(mean_imu_sec)
    att_mean_sec(i, :) = aligns(p0, mean_imu_sec(i, :));
end

%% ----------------------- ���ƴֶ�׼��� ----------------------- %% 
if ~is_plot_align_result, return; end

myfigure('��ƽ��ֵ������̬��');
subplot(3,1,1), hold on, title('����� (deg)'); plot(mean_imu_sec(:,1),att_mean_sec(:,1) * 180 / pi); grid on; 
subplot(3,1,2), hold on, title('������ (deg)'); plot(mean_imu_sec(:,1),att_mean_sec(:,2) * 180 / pi); grid on; 
subplot(3,1,3), hold on, title('����� (deg)'); plot(mean_imu_sec(:,1),att_mean_sec(:,3) * 180 / pi); grid on; 

myfigure('ÿ��Ԫ������̬��');
subplot(3,1,1), hold on, title('����� (deg)'); plot(raw_imu(:,1),att_epoch(:,1) * 180 / pi); grid on; 
subplot(3,1,2), hold on, title('������ (deg)'); plot(raw_imu(:,1),att_epoch(:,2) * 180 / pi); grid on; 
subplot(3,1,3), hold on, title('����� (deg)'); plot(raw_imu(:,1),att_epoch(:,3) * 180 / pi); grid on; 


