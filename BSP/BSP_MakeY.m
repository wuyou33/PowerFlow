function [Y, G, B,Tap] = BSP_MakeY(Input)
%% BSP_MakeY 计算导纳矩阵  
% OUTPUT: 
%        Y: 导纳矩阵 (unit: p.u.)
%        G: Y = G + jB
%        B: Y = G + jB
%        Tap: 不考虑移相器的非标准变比，与branch矩阵顺序相同（仅做了补1的工作）
% INPUT: 
%        Input: IEEE标准格式输入矩阵（MATPOWER 'vision2.0'）
% Author: Kang-S

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
%%        K:1
%% i -----〇〇-----█████--------- j
%% 
%% 如果有移相器，那么[ij]和[ji]的值将不一样，导纳矩阵将会不对称，注意之后线路功率等的计算
%% i ─────●───────[ij]----[ji]───────●───── j    from---k:1-|yt|----to
%%        |                          |  
%%       [i]                        [j]
%%        |                          |

%% bus部分
bus_f = (1:NUM.Bus).'; % i,j全是纵向量
bus_t = bus_f;
bus_v = (bus(:,GS) + 1j * bus(:,BS)) / baseMVA; % v全是纵向量

%% branch 部分
branch_f = branch(:,F_BUS);  % 首节点
branch_t = branch(:,T_BUS);  % 末节点

% 变压器模型
stat = branch(:, BR_STATUS);                            % 母线的工作状态
Yl = stat ./ (branch(:, BR_R) + 1j * branch(:, BR_X));  % 串联部分branch
Bl = stat .* ( 1j * branch(:, BR_B) / 2 );              % 接地电容branch
Tap = ones(NUM.Branch, 1);                              % 默认变比，把0补1(0表示没有变压器，相当于变比为1)
idx = find(branch(:, TAP));                             % 找到有变压器的地方
Tap(idx) = branch(idx, TAP);                            % 非标准变比
k = Tap .* exp(1j*pi/180 * branch(:, SHIFT));           % 非标准变比（加上移相器）
% modified accoding to MATPOWER-manual
yff = ( 1-k ) ./ (k.*conj(k)) .* Yl + 1 ./ (k.*conj(k)) .* Bl;
yft = Yl ./ conj(k);
ytt = ( k-1 ) ./ k .* Yl + Bl;
ytf = Yl ./ k;

branch_vff = yft  + yff;
branch_vtt = ytf  + ytt;
branch_vft = - yft;
branch_vtf = - ytf;

% yft = Yl ./ conj(k);
% ytf = Yl ./ k;
% yff = ( 1-conj(k) ) ./ (k.*conj(k)) .* Yl;
% ytt = ( k-1 ) ./ k .* Yl;
% 
% branch_vff = yft + Bl + yff;
% branch_vtt = ytf + Bl + ytt;
% branch_vft = - yft;
% branch_vtf = - ytf;

%% 合成导纳矩阵
s_f = [bus_f; branch_f;   branch_t;   branch_f;   branch_t];
s_t = [bus_t; branch_f;   branch_t;   branch_t;   branch_f];
s_v = [bus_v; branch_vff; branch_vtt; branch_vft; branch_vtf];
Y = sparse(s_f, s_t, s_v, NUM.Bus, NUM.Bus);

%% 求G和B
G = real(Y);
B = imag(Y);
