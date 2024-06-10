% -------------------------------------------------------------------------
% ʵ��ŷ���� a������������ m����Ч��תʸ�� rv ֮���ת�� 
% ����ϵ��������-ǰ���¡�NED-FRU
% ����|��������|�޸����ڣ�     ��֣�� | 6/6/2024 | 6/7/2024 
% -------------------------------------------------------------------------
classdef attitude
    
    methods(Static, Access = 'public')
        
        function s = skew_symmetric(v)
            % ������ά�����ķ��Գ���
            s = [  0  -v(3)  v(2)
                  v(3)  0   -v(1)
                 -v(2) v(1)   0  ];
        end
        
        function m = a2m(a)
            % ŷ����ת����������
            cf = cos(a(1)); sf = sin(a(1));
            cq = cos(a(2)); sq = sin(a(2));
            cj = cos(a(3)); sj = sin(a(3));
            
            m = [cq * cj, -cf * sj + sf * sq * cj,  sf * sj + cf * sq * cj
                 cq * sj,  cf * cj + sf * sq * sj, -sf * cj + cf * sq * sj
                   -sq  ,         sf * cq        ,         cf * cq        ];
        end
        
        function a = m2a(m)
            % ����������תŷ����
            a(1) = atan2(m(3,2),m(3,3));                                  % ������
            a(2) = atan2(-m(3,1),sqrt(m(3,2)*m(3,2) + m(3,3)*m(3,3)));    % �����
            a(3) = atan2(m(2,1),m(1,1));                                  % �����
            a = a';
        end
        
        function m = rv2m(rv)
            % ��Ч��תʸ��ת����������
            rvx = attitude.skew_symmetric(rv);  % ��Ч��תʸ���ķ��Գ���
            rvn = norm(rv);                     % ��Ч��תʸ����ģ
            m = eye(3) + sin(rvn) / rvn * rvx + ...
                   (1 - cos(rvn)) / rvn / rvn * rvx * rvx;
        end

        function norm_m = norm_m (m)
            % ����������������
            for i = 1 : 5, m = (m + inv(m')) * 0.5; end     % ��ε���
%             for i = 1 : 5, m = (m + m') * 0.5; end     % ��ε���
            norm_m = m;
        end
        
    end
end