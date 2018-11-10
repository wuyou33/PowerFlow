function [Y, G, B, y] = BSP_MakeY(Input)
% function [Y, G, B] = BSP_MakeY(Input)
%% BSP_MAKEY 计算导纳矩阵  
% OUTPUT: 
%        Y: 导纳矩阵 (unit: p.u.)
%        G: Y = G + jB
%        B: Y = G + jB
% INPUT: 
%        Input: IEEE标准格式输入矩阵（MATPOWER 'vision2.0'）
% TEMP TEST: 临时调试代码
% TIP: 如果有isolate bus， 就改一下导纳矩阵就好了，暂时不考虑
%% 变量转化
    baseMVA = Input.baseMVA;
    bus     = Input.bus;
    branch  = Input.branch;

%% 索引值（bus和branch）
[BUS_I, BUS_TYPE, PD, QD, GS, BS] = Index_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, TAP, SHIFT, ...
    BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ANGMIN, ANGMAX, MU_ANGMIN, ...
    MU_ANGMAX] = Index_branch;
ENABLE  = 1;
DISABLE = 0;

%% 节点数和支路数
NUM.Bus= size(bus,1);
NUM.Branch = size(branch,1);

%% 支路导纳预分配内存
Y = zeros(NUM.Bus);  % Y矩阵 预分配内存 
% y = zeros(NUM.Bus);  % 自导纳y0（对角线）和互导纳yij（非对角线），用于求线路功率
%% 变压器等效模型 （导纳矩阵形式）
%% ─────x───────[ij]───────x─────     from---k:1-|yt|----to
%%      |                  |
%%     [i]                [j]
%%      |                  |

%% 导纳矩阵生成
% branch_t = branch;         % 用branch_t代替branch计算, 函数中没有必要了，不会真正改变branch的值的
t = branch(:, TAP) == 0; % 变压器支路所 不在 的行数
branch(t, TAP) = 1;      % 非标准变比, 把0补1
k = branch(:, TAP);      % 非标准变比

for i = 1 : NUM.Bus         % BUS的自导纳
%     p = bus(i,1);           % 对应的节点编号（位置） ........ 节点重新编号之后应该是可以去掉的
    Y(i,i) = (bus(i,GS) + 1j * bus(i,BS)) / baseMVA;  
%     y(i,i) = Y(i,i);
end
y = Y;  % 只考虑到bus矩阵的值的时候，二者相同

for i = 1 : NUM.Branch       % Branch的自导纳
    if branch(i,BR_STATUS) == ENABLE   % 该母线正在投入运行中
        p1 = branch(i,F_BUS);  % 首节点
        p2 = branch(i,T_BUS);  % 末节点
        
        yt = 1 / ( branch(i, BR_R) + 1j * branch(i, BR_X));  % 串联初始导纳
        % 变压器模型
        yl = yt / k(i);
        yi = (1-k(i))/k(i)^2 * yt;
        yj = (k(i)-1)/k(i) * yt;
        % 导纳矩阵部分
        Y(p1,p1) = Y(p1,p1) + yl + 1j * branch(i,BR_B)/2 + yi;
        Y(p2,p2) = Y(p2,p2) + yl + 1j * branch(i,BR_B)/2 + yj;
        Y(p1,p2) = Y(p1,p2) - yl;
        Y(p2,p1) = Y(p1,p2);
        % 导纳部分
        y(p1,p1) = y(p1,p1) + 1j * branch(i,BR_B)/2 + yi; % might error *
        y(p2,p2) = y(p2,p2) + 1j * branch(i,BR_B)/2 + yj;
        y(p1,p2) = y(p1,p2) + yl;  % 若为0，则PF也为0
        y(p2,p1) = y(p1,p2);       % 若为0，则PT也为0
    end
end

%% 去掉无效节点(只保留有效的节点) （节点重新编号之后不需要）
% Y = Y(bus(:,BUS_I), bus(:,BUS_I));
%% 求G和B
G = real(Y);
B = imag(Y);

% Y = sparse(Y);
% G = sparse(G);
% B = sparse(B);
