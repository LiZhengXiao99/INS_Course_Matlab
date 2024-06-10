% -------------------------------------------------------------------------
% 地球相关参数计算
% 作者|创建日期|修改日期：     李郑骁 | 6/6/2024 | 6/7/2024          
% -------------------------------------------------------------------------
classdef earth
    properties ( Constant, Access = public)
        WGS84_WIE = 7.2921151467E-5;        % 地球自转角速度
        WGS84_F   = 0.0033528106647474805;  % 扁率
        WGS84_RA  = 6378137.0000000000;     % 椭球长半轴
        WGS84_RB  = 6356752.3142451793;     % 椭球短半轴
        WGS84_GM0 = 398600441800000.00;     % 地球引力常数
        WGS84_E1  = 0.0066943799901413156;  % 第一偏心率平方
        WGS84_E2  = 0.0067394967422764341;  % 第二偏心率平方
        
        beta  = 5.27094E-3;
        beta1 = 2.32718E-5;
        beta2 = 3.086E-6;
        beta3 = 8.08E-9;
        g0    = 9.7803267714;
    end

    methods(Static, Access = 'public')
        
        function g = g(blh)
            % 重力加速度计算
            sb2 = sin(blh(1)) * sin(blh(1)); 
            g = earth.g0 * (1.0 + earth.beta * sb2 + earth.beta1 * sb2 * sb2)... 
                - earth.beta2 * blh(2);
        end
        
        function gn = gn(g)
            % 重力加速度在n系投影
            gn = [0,0,g]';
        end
        
        function wnie = weie()
            % 地球自转引起的地球系旋转
            wnie = [0, 0, earth.WGS84_WIE]';
        end

        function wnie = wnie(b)
            % 地球自转引起的导航系旋转
            wnie = [earth.WGS84_WIE * cos(b), 0, -earth.WGS84_WIE * sin(b)]';
        end
        
        function wnen = wnen(blh,vel)
            % 牵连角速度引起的导航系旋转
            rn = earth.rn(blh(1));
            rm = earth.rm(blh(1));
            wnen = [vel(2) / (rn + blh(3))
                   -vel(1) / (rm + blh(3))
                   -vel(2) * tan(blh(1)) / (rn + blh(3))];
        end

        function rn = rn(b)
            % 计算卯酉圈曲率半径 RN
            sb2 = sin(b) * sin(b);
            rn = earth.WGS84_RA / (1 - earth.WGS84_E2 * sb2);
        end
        
        function rm = rm(b)
            % 计算子午圈曲率半径 RM
            sb2 = sin(b) * sin(b);
            rm = earth.WGS84_RA * (1 - earth.WGS84_E1) /...
                ((1 - earth.WGS84_E2 * sb2) * sqrt(1 - earth.WGS84_E2 * sb2));
        end

        function mpv = mpv(blh)
            % 位置更新矩阵，用来把 NED 增量转换为 BLH 增量
            mpv(1,1) = 1 / (earth.rm(blh(1)) + blh(3));
            mpv(2,2) = 1 / (earth.rn(blh(1)) + blh(3)) * cos(blh(1));
            mpv(3,3) = -1;
        end
        
    end
end