% -------------------------------------------------------------------------
% ������ز�������
% ����|��������|�޸����ڣ�     ��֣�� | 6/6/2024 | 6/7/2024          
% -------------------------------------------------------------------------
classdef earth
    properties ( Constant, Access = public)
        WGS84_WIE = 7.2921151467E-5;        % ������ת���ٶ�
        WGS84_F   = 0.0033528106647474805;  % ����
        WGS84_RA  = 6378137.0000000000;     % ���򳤰���
        WGS84_RB  = 6356752.3142451793;     % ����̰���
        WGS84_GM0 = 398600441800000.00;     % ������������
        WGS84_E1  = 0.0066943799901413156;  % ��һƫ����ƽ��
        WGS84_E2  = 0.0067394967422764341;  % �ڶ�ƫ����ƽ��
        
        beta  = 5.27094E-3;
        beta1 = 2.32718E-5;
        beta2 = 3.086E-6;
        beta3 = 8.08E-9;
        g0    = 9.7803267714;
    end

    methods(Static, Access = 'public')
        
        function g = g(blh)
            % �������ٶȼ���
            sb2 = sin(blh(1)) * sin(blh(1)); 
            g = earth.g0 * (1.0 + earth.beta * sb2 + earth.beta1 * sb2 * sb2)... 
                - earth.beta2 * blh(2);
        end
        
        function gn = gn(g)
            % �������ٶ���nϵͶӰ
            gn = [0,0,g]';
        end
        
        function wnie = weie()
            % ������ת����ĵ���ϵ��ת
            wnie = [0, 0, earth.WGS84_WIE]';
        end

        function wnie = wnie(b)
            % ������ת����ĵ���ϵ��ת
            wnie = [earth.WGS84_WIE * cos(b), 0, -earth.WGS84_WIE * sin(b)]';
        end
        
        function wnen = wnen(blh,vel)
            % ǣ�����ٶ�����ĵ���ϵ��ת
            rn = earth.rn(blh(1));
            rm = earth.rm(blh(1));
            wnen = [vel(2) / (rn + blh(3))
                   -vel(1) / (rm + blh(3))
                   -vel(2) * tan(blh(1)) / (rn + blh(3))];
        end

        function rn = rn(b)
            % ����î��Ȧ���ʰ뾶 RN
            sb2 = sin(b) * sin(b);
            rn = earth.WGS84_RA / (1 - earth.WGS84_E2 * sb2);
        end
        
        function rm = rm(b)
            % ��������Ȧ���ʰ뾶 RM
            sb2 = sin(b) * sin(b);
            rm = earth.WGS84_RA * (1 - earth.WGS84_E1) /...
                ((1 - earth.WGS84_E2 * sb2) * sqrt(1 - earth.WGS84_E2 * sb2));
        end

        function mpv = mpv(blh)
            % λ�ø��¾��������� NED ����ת��Ϊ BLH ����
            mpv(1,1) = 1 / (earth.rm(blh(1)) + blh(3));
            mpv(2,2) = 1 / (earth.rn(blh(1)) + blh(3)) * cos(blh(1));
            mpv(3,3) = -1;
        end
        
    end
end