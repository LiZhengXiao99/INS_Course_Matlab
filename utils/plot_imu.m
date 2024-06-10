% -------------------------------------------------------------------------
% 绘制 IMU 原始量测数据
% 作者|创建日期|修改日期：     李郑骁 | 6/6/2024 | 6/6/2024
% -------------------------------------------------------------------------
function plot_imu(raw_imu,text)

    myfigure(text);
    
    subplot(2,1,1),  hold on, title('陀螺仪量测 (rad)'); 
    plot(raw_imu(:,1),raw_imu(:,2:4), 'LineWidth', 1); 
     grid on; legend('Gyr-X','Gyr-Y','Gyr-Z')
    
    subplot(2,1,2),  hold on, title('加速度计量测 (m/s)'); 
    plot(raw_imu(:,1),raw_imu(:,5:7), 'LineWidth', 1);
    grid on; legend('Acc-X','Acc-Y','ACC-Z')
end