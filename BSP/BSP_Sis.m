function [Pis,Qis] = BSP_Sis(bus,gen,NUM)
%% BSP_Sis 计算节点注入功率  
% OUTPUT: 
%        Pis: 有功注入功率 ( MW )
%        Qis: 无功注入功率 (MVar)
% INPUT: 
%        bus: 母线矩阵
%        gen: 发电机矩阵
%        NUM: 数量（struct），@BSP_Initial.m
% Author: Kang-S

%% bus、generator和branch的索引值
[~, ~, PD, QD] = Index_bus; %bus
[GEN_BUS, PG, QG] = Index_generator; %generator

%% 注入功率

% 负荷  消耗功率为负数 (MW, MVar)
Sis_ib = (1 : NUM.Bus).';   % 位置 
Sis_jb = ones(NUM.Bus,1);   % Sis是单列的矩阵
Pis_vb = -bus(:, PD);       % 负数（消耗功率）
Qis_vb = -bus(:, QD);

% 发电机 产生功率为正数 (MW, MVar)
Sis_ig = gen(:, GEN_BUS);   % 位置 
Sis_jg = ones(NUM.Gen, 1);  % Sis是单列的矩阵
Pis_vg = gen(:, PG);
Qis_vg = gen(:, QG);

% 合成注入功率
Pis = sparse([Sis_ib; Sis_ig], [Sis_jb; Sis_jg], [Pis_vb; Pis_vg]);  
Qis = sparse([Sis_ib; Sis_ig], [Sis_jb; Sis_jg], [Qis_vb; Qis_vg]);
% Sis_i = [Sis_ib; Sis_ig];           Sis_j = [Sis_jb; Sis_jg];
% Pis_v = [Pis_vb; Pis_vg];           Qis_v = [Qis_vb; Qis_vg];
% Pis = sparse(Sis_i, Sis_j, Pis_v);  
% Qis = sparse(Sis_i, Sis_j, Qis_v);

