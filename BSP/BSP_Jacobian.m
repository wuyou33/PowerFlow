function [ Jacobian ] = BSP_Jacobian( U,delta,G,B,Pi,Qi, PLC,NUM )  % n行m列
%% BSP_Jacobian 计算雅可比矩阵
% OUTPUT:
%        Jacobian: 雅可比矩阵        
% INPUT:
%        U     : 节点电压幅值（迭代量） (p.u.)
%        delta : 节点电压相角（迭代量） (rad )
%        G     : Y = G + jB           (p.u.)
%        B     : Y = G + jB           (p.u.)
%        Pi    : 功率计算量Pi          (p.u.)
%        Qi    : 功率计算量Qi          (p.u.)
%        bus   : IEEE标准格式的 bus 矩阵数据
% HELP:
%        分块,然后不同的节点分元胞数组各取所需                  
%                   ┌ H N ┐
%                   └ K L ┘            
% TEMP TEST: 临时调试代码
%% 初始化
% 预分配内存
J.H = zeros(NUM.Bus);
J.N = zeros(NUM.Bus);
J.K = zeros(NUM.Bus);
J.L = zeros(NUM.Bus);
%% i!=j时 非对角元素
for i = 1 : NUM.Bus
	for j = 1 : NUM.Bus
		J.H(i,j) = - U(i)*U(j)*(G(i,j)*sin(delta(i)-delta(j))-B(i,j)*cos(delta(i)-delta(j)));
	end
end
for i = 1 : NUM.Bus
	for j = 1 : NUM.Bus
		J.N(i,j) = - U(i)*U(j)*(G(i,j)*cos(delta(i)-delta(j))+B(i,j)*sin(delta(i)-delta(j)));
	end
end
for i = 1 : NUM.Bus
	for j = 1 : NUM.Bus
		J.K(i,j) = + U(i)*U(j)*(G(i,j)*cos(delta(i)-delta(j))+B(i,j)*sin(delta(i)-delta(j)));
	end
end
for i = 1 : NUM.Bus
	for j = 1 : NUM.Bus
		J.L(i,j) = - U(i)*U(j)*(G(i,j)*sin(delta(i)-delta(j))-B(i,j)*cos(delta(i)-delta(j)));
	end
end
%% i==j时 对角元素替代了原来的无效的非对角元素
i = 1 : NUM.Bus;
J.H(logical(eye(NUM.Bus))) =   U(i).^2 .* diag(B) + Qi(i);
J.N(logical(eye(NUM.Bus))) = - U(i).^2 .* diag(G) - Pi(i);
J.K(logical(eye(NUM.Bus))) =   U(i).^2 .* diag(G) - Pi(i);
J.L(logical(eye(NUM.Bus))) =   U(i).^2 .* diag(B) - Qi(i);

% -----------------------------------------至此，对每一个节点都算了其 H N K L
% 接下来，要根据各个节点的类型，顺序重排：PQ_BUS PV_BUS
%% HN KL 矩阵重新排序
[J] = sort_Jacobian(J,PLC);

Jacobian = [J.H J.N
            J.K J.L];

end % main function: BSP_Jacobian

%% sub function 1 雅可比矩阵 按照 节点类型 重排

function [J] = sort_Jacobian(J,PLC)
J.H = [J.H( PLC.PV, : ); J.H( PLC.PQ, : )];
J.H = [J.H( :, PLC.PV ), J.H( :, PLC.PQ )];

J.N = [J.N( PLC.PV, : ); J.N( PLC.PQ, : )];
J.N = J.N( :, PLC.PQ );

J.K = J.K( PLC.PQ, : );
J.K = [J.K( :, PLC.PV ), J.K( :, PLC.PQ )];

J.L = J.L( PLC.PQ, : );
J.L = J.L( :, PLC.PQ );
end

