% -------------------------------------------------------------------------
% 实现单组数据的静态粗对准，算法参考课程设计任务书（P6 - P8）
% 作者|创建日期|修改日期：     李郑骁 | 6/6/2024 | 6/9/2024          
% -------------------------------------------------------------------------
function att = aligns(p0,imu)
    sb = sin(p0(1)); cb = cos(p0(1)); tb = tan(p0(1));  % 经度的三角函数
    g = earth.g(p0); wie = earth.WGS84_WIE;             % 重力和地球自转角速率
    w_nie = earth.wnie(p0(1));                          % 地球自转角速度在 n 系投影
    gn = earth.gn(g);                                   % 重力加速度在 n 系的投影
%     fwv = inv([gn';w_nie';cross(gn',w_nie')]);
    
    fwv = [-tb/g  1/(wie*cb)  0                         % 惯导课设任务书 (18)
             0       0    -1/(g*wie*cb)
           -1/g      0        0];
       
    fb = imu(5:7); wnib = imu(2:4); vb = cross(fb,wnib);    % 惯导课设任务书 (16)
    cbn = fwv * [fb; wnib; vb];                             % 计算方向余弦阵，惯导课设任务书 (17)
    
%     cbn = attitude.norm_m(cbn);                             % 方向余弦阵单位化，惯导课设任务书 (19)
    att = attitude.m2a(cbn);                                % 方向余弦阵转欧拉角
end

