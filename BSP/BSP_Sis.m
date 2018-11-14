function [Pis,Qis] = BSP_Sis(bus,gen,NUM)

%% bus��generator��branch������ֵ
[~, ~, PD, QD] = Index_bus; %bus

[GEN_BUS, PG, QG] = Index_generator; %generator
%% ע�빦��

% ����  ���Ĺ���Ϊ���� (MW, MVar)
Sis_ib = (1 : NUM.Bus).';           Sis_jb = ones(NUM.Bus,1);
Pis_vb = -bus(:, PD);               Qis_vb = -bus(:, QD);

% ����� ��������Ϊ���� (MW, MVar)
Sis_ig = gen(:, GEN_BUS);           Sis_jg = ones(NUM.Gen, 1);
Pis_vg = gen(:, PG);                Qis_vg = gen(:, QG);

% �ϳ�
Pis = sparse([Sis_ib; Sis_ig], [Sis_jb; Sis_jg], [Pis_vb; Pis_vg]);  
Qis = sparse([Sis_ib; Sis_ig], [Sis_jb; Sis_jg], [Qis_vb; Qis_vg]);
% Sis_i = [Sis_ib; Sis_ig];           Sis_j = [Sis_jb; Sis_jg];
% Pis_v = [Pis_vb; Pis_vg];           Qis_v = [Qis_vb; Qis_vg];
% Pis = sparse(Sis_i, Sis_j, Pis_v);  
% Qis = sparse(Sis_i, Sis_j, Qis_v);

