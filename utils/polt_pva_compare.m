% -------------------------------------------------------------------------
% 绘制 PVA 导航结果
% 作者|创建日期|修改日期：     李郑骁 | 6/8/2024 | 6/8/2024
% -------------------------------------------------------------------------
function polt_pva_compare(pva,pva_ref,text1,text2)

    myfigure('PVA 结果比较');
    legend_pva = [text1,text2];
    subplot(3,3,1), hold on, grid on; title('Pos-B (Deg)');       plot(pva(:,1),pva(:,2) ,pva_ref(:,1),pva_ref(:,2));  legend(legend_pva);
    subplot(3,3,2), hold on, grid on; title('Pos-L (Deg)');       plot(pva(:,1),pva(:,3), pva_ref(:,1),pva_ref(:,3));  legend(legend_pva);
    subplot(3,3,3), hold on, grid on; title('Pos-H (m)');         plot(pva(:,1),pva(:,4), pva_ref(:,1),pva_ref(:,4));  legend(legend_pva);
    subplot(3,3,4), hold on, grid on; title('Vcc-N (m/s)');       plot(pva(:,1),pva(:,5), pva_ref(:,1),pva_ref(:,5));  legend(legend_pva);
    subplot(3,3,5), hold on, grid on; title('Vel-E (m/s)');       plot(pva(:,1),pva(:,6), pva_ref(:,1),pva_ref(:,6));  legend(legend_pva);
    subplot(3,3,6), hold on, grid on; title('Vel-D (m/s)');       plot(pva(:,1),pva(:,7), pva_ref(:,1),pva_ref(:,7));  legend(legend_pva);
    subplot(3,3,7), hold on, grid on; title('Att-Roll (Deg)');    plot(pva(:,1),pva(:,8), pva_ref(:,1),pva_ref(:,8));  legend(legend_pva);
    subplot(3,3,8), hold on, grid on; title('Att-Pitch (Deg)');   plot(pva(:,1),pva(:,9), pva_ref(:,1),pva_ref(:,9));  legend(legend_pva);
    subplot(3,3,9), hold on, grid on; title('Att-Yall (Deg)');    plot(pva(:,1),pva(:,10),pva_ref(:,1),pva_ref(:,10)); legend(legend_pva);
    
end