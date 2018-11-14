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
%% i!=j时 非对角元素
[j,i] = meshgrid(1:NUM.Bus);
H = - U(i).*U(j).*(G.*sin(delta(i)-delta(j))-B.*cos(delta(i)-delta(j)));
N = - U(i).*U(j).*(G.*cos(delta(i)-delta(j))+B.*sin(delta(i)-delta(j)));
K = + U(i).*U(j).*(G.*cos(delta(i)-delta(j))+B.*sin(delta(i)-delta(j)));
L = - U(i).*U(j).*(G.*sin(delta(i)-delta(j))-B.*cos(delta(i)-delta(j)));

%% i==j时 对角元素替代了原来的无效的非对角元素
i = 1 : NUM.Bus;
H(logical(eye(NUM.Bus))) =   U(i).^2 .* diag(B) + Qi(i);
N(logical(eye(NUM.Bus))) = - U(i).^2 .* diag(G) - Pi(i);
K(logical(eye(NUM.Bus))) =   U(i).^2 .* diag(G) - Pi(i);
L(logical(eye(NUM.Bus))) =   U(i).^2 .* diag(B) - Qi(i);

% -----------------------------------------至此，对每一个节点都算了其 H N K L
% 接下来，要根据各个节点的类型，顺序重排：PQ_BUS PV_BUS
%% HN KL 矩阵重新排序
H = [H( PLC.PV, : ); H( PLC.PQ, : )];
H = [H( :, PLC.PV ), H( :, PLC.PQ )];
N = [N( PLC.PV, PLC.PQ ); N( PLC.PQ, PLC.PQ )];
K = [K( PLC.PQ, PLC.PV ), K( PLC.PQ, PLC.PQ )];
L = L( PLC.PQ, PLC.PQ );

Jacobian = [H N
            K L];

end % main function: BSP_Jacobian


