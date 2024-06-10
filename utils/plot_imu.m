% -------------------------------------------------------------------------
% ���� IMU ԭʼ��������
% ����|��������|�޸����ڣ�     ��֣�� | 6/6/2024 | 6/6/2024
% -------------------------------------------------------------------------
function plot_imu(raw_imu,text)

    myfigure(text);
    
    subplot(2,1,1),  hold on, title('���������� (rad)'); 
    plot(raw_imu(:,1),raw_imu(:,2:4), 'LineWidth', 1); 
     grid on; legend('Gyr-X','Gyr-Y','Gyr-Z')
    
    subplot(2,1,2),  hold on, title('���ٶȼ����� (m/s)'); 
    plot(raw_imu(:,1),raw_imu(:,5:7), 'LineWidth', 1);
    grid on; legend('Acc-X','Acc-Y','ACC-Z')
end