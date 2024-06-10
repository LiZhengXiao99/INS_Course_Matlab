% -------------------------------------------------------------------------
% 实现欧拉角 a、方向余弦阵 m、等效旋转矢量 rv 之间的转换 
% 坐标系：北东地-前右下、NED-FRU
% 作者|创建日期|修改日期：     李郑骁 | 6/6/2024 | 6/7/2024 
% -------------------------------------------------------------------------
classdef attitude
    
    methods(Static, Access = 'public')
        
        function s = skew_symmetric(v)
            % 计算三维向量的反对称阵
            s = [  0  -v(3)  v(2)
                  v(3)  0   -v(1)
                 -v(2) v(1)   0  ];
        end
        
        function m = a2m(a)
            % 欧拉角转方向余弦阵
            cf = cos(a(1)); sf = sin(a(1));
            cq = cos(a(2)); sq = sin(a(2));
            cj = cos(a(3)); sj = sin(a(3));
            
            m = [cq * cj, -cf * sj + sf * sq * cj,  sf * sj + cf * sq * cj
                 cq * sj,  cf * cj + sf * sq * sj, -sf * cj + cf * sq * sj
                   -sq  ,         sf * cq        ,         cf * cq        ];
        end
        
        function a = m2a(m)
            % 方向余弦阵转欧拉角
            a(1) = atan2(m(3,2),m(3,3));                                  % 俯仰角
            a(2) = atan2(-m(3,1),sqrt(m(3,2)*m(3,2) + m(3,3)*m(3,3)));    % 横滚角
            a(3) = atan2(m(2,1),m(1,1));                                  % 航向角
            a = a';
        end
        
        function m = rv2m(rv)
            % 等效旋转矢量转方向余弦阵
            rvx = attitude.skew_symmetric(rv);  % 等效旋转矢量的反对称阵
            rvn = norm(rv);                     % 等效旋转矢量的模
            m = eye(3) + sin(rvn) / rvn * rvx + ...
                   (1 - cos(rvn)) / rvn / rvn * rvx * rvx;
        end

        function norm_m = norm_m (m)
            % 方向余弦阵正交化
            for i = 1 : 5, m = (m + inv(m')) * 0.5; end     % 五次迭代
%             for i = 1 : 5, m = (m + m') * 0.5; end     % 五次迭代
            norm_m = m;
        end
        
    end
end