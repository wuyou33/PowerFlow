function [Y, G, B] = BSP_MakeY(Input)
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
%% 节点数和支路数
NUM.Bus= size(bus,1);
NUM.Branch = size(branch,1);


%% 变压器等效模型 （导纳矩阵形式）
%% ─────x───────[ij]───────x─────     from---k:1-|yt|----to
%%      |                  |
%%     [i]                [j]
%%      |                  |

%% bus部分
bus_i = (1:NUM.Bus).'; % i,j全是纵向量
bus_j = bus_i;
bus_v = (bus(:,GS) + 1j * bus(:,BS)) / baseMVA; % v全是纵向量

%% branch 部分
branch_i = branch(:,F_BUS);  % 首节点
branch_j = branch(:,T_BUS);  % 末节点

% 变压器模型
yt = 1 ./ ( branch(:, BR_R) + 1j * branch(:, BR_X));    % 串联初始导纳
t = branch(:, TAP) == 0;                                % 变压器支路所 不在 的行数
branch(t, TAP) = 1;                                     % 非标准变比, 把0补1
k = branch(:, TAP);                                     % 非标准变比

yl = yt ./ k;
yi = (1-k) ./ (k.^2) .* yt;
yj = (k-1) ./ k .* yt;

branch_vii = yl + 1j * branch(:,BR_B)/2 + yi;
branch_vjj = yl + 1j * branch(:,BR_B)/2 + yj;
branch_vij = - yl;
branch_vji = branch_vij;

%% 合成导纳矩阵
s_i = [bus_i; branch_i;   branch_j;   branch_i;   branch_j];
s_j = [bus_j; branch_i;   branch_j;   branch_j;   branch_i];
s_v = [bus_v; branch_vii; branch_vjj; branch_vij; branch_vji];
Y = sparse(s_i, s_j, s_v, NUM.Bus, NUM.Bus);

%% 求G和B
G = real(Y);
B = imag(Y);
