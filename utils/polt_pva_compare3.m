% -------------------------------------------------------------------------
% 绘制 PVA 导航结果
% 作者|创建日期|修改日期：     李郑骁 | 6/8/2024 | 6/8/2024
% -------------------------------------------------------------------------
function polt_pva_compare3(pva1,pva2,pva3,text1,text2,text3)

    myfigure('PVA 结果比较');
    legend_pva = [text1,text2,text3];
    subplot(3,3,1), hold on, grid on; title('Pos-B (Deg)');       plot(pva1(:,1),pva1(:,2) ,pva2(:,1),pva2(:,2) , pva3(:,1),pva3(:,2));  legend(legend_pva);
    subplot(3,3,2), hold on, grid on; title('Pos-L (Deg)');       plot(pva1(:,1),pva1(:,3), pva2(:,1),pva2(:,3) , pva3(:,1),pva3(:,3));  legend(legend_pva);
    subplot(3,3,3), hold on, grid on; title('Pos-H (m)');         plot(pva1(:,1),pva1(:,4), pva2(:,1),pva2(:,4) , pva3(:,1),pva3(:,4));  legend(legend_pva);
    subplot(3,3,4), hold on, grid on; title('Vcc-N (m/s)');       plot(pva1(:,1),pva1(:,5), pva2(:,1),pva2(:,5) , pva3(:,1),pva3(:,5));  legend(legend_pva);
    subplot(3,3,5), hold on, grid on; title('Vel-E (m/s)');       plot(pva1(:,1),pva1(:,6), pva2(:,1),pva2(:,6) , pva3(:,1),pva3(:,6));  legend(legend_pva);
    subplot(3,3,6), hold on, grid on; title('Vel-D (m/s)');       plot(pva1(:,1),pva1(:,7), pva2(:,1),pva2(:,7) , pva3(:,1),pva3(:,7));  legend(legend_pva);
    subplot(3,3,7), hold on, grid on; title('Att-Roll (Deg)');    plot(pva1(:,1),pva1(:,8), pva2(:,1),pva2(:,8) , pva3(:,1),pva3(:,8));  legend(legend_pva);
    subplot(3,3,8), hold on, grid on; title('Att-Pitch (Deg)');   plot(pva1(:,1),pva1(:,9), pva2(:,1),pva2(:,9) , pva3(:,1),pva3(:,9));  legend(legend_pva);
    subplot(3,3,9), hold on, grid on; title('Att-Yall (Deg)');    plot(pva1(:,1),pva1(:,10),pva2(:,1),pva2(:,10) ,pva3(:,1),pva3(:,10)); legend(legend_pva);
    
end