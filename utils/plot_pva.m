% -------------------------------------------------------------------------
% 绘制 PVA 导航结果
% 作者|创建日期|修改日期：     李郑骁 | 6/6/2024 | 6/6/2024
% -------------------------------------------------------------------------
function plot_pva(pva,text)

    myfigure(text);
    subplot(3,3,1), hold on, grid on; title('Pos-B (Deg)');       plot(pva(:,1),pva(:,2)); 
    subplot(3,3,2), hold on, grid on; title('Pos-L (Deg)');       plot(pva(:,1),pva(:,3)); 
    subplot(3,3,3), hold on, grid on; title('Pos-H (m)');         plot(pva(:,1),pva(:,4)); 
    subplot(3,3,4), hold on, grid on; title('Vcc-N (m/s)');       plot(pva(:,1),pva(:,5)); 
    subplot(3,3,5), hold on, grid on; title('Vel-E (m/s)');       plot(pva(:,1),pva(:,6)); 
    subplot(3,3,6), hold on, grid on; title('Vel-D (m/s)');       plot(pva(:,1),pva(:,7)); 
    subplot(3,3,7), hold on, grid on; title('Att-Roll (Deg)');    plot(pva(:,1),pva(:,8)); 
    subplot(3,3,8), hold on, grid on; title('Att-Pitch (Deg)');   plot(pva(:,1),pva(:,9)); 
    subplot(3,3,9), hold on, grid on; title('Att-Yall (Deg)');    plot(pva(:,1),pva(:,10)); 
    
end
