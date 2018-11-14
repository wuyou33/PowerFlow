function [Y, G, B] = BSP_MakeY(Input)
% function [Y, G, B] = BSP_MakeY(Input)
%% BSP_MAKEY ���㵼�ɾ���  
% OUTPUT: 
%        Y: ���ɾ��� (unit: p.u.)
%        G: Y = G + jB
%        B: Y = G + jB
% INPUT: 
%        Input: IEEE��׼��ʽ�������MATPOWER 'vision2.0'��
% TEMP TEST: ��ʱ���Դ���
% TIP: �����isolate bus�� �͸�һ�µ��ɾ���ͺ��ˣ���ʱ������
%% ����ת��
    baseMVA = Input.baseMVA;
    bus     = Input.bus;
    branch  = Input.branch;

%% ����ֵ��bus��branch��
[BUS_I, BUS_TYPE, PD, QD, GS, BS] = Index_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, TAP, SHIFT, ...
    BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ANGMIN, ANGMAX, MU_ANGMIN, ...
    MU_ANGMAX] = Index_branch;
%% �ڵ�����֧·��
NUM.Bus= size(bus,1);
NUM.Branch = size(branch,1);


%% ��ѹ����Чģ�� �����ɾ�����ʽ��
%% ����������x��������������[ij]��������������x����������     from---k:1-|yt|----to
%%      |                  |
%%     [i]                [j]
%%      |                  |

%% bus����
bus_i = (1:NUM.Bus).'; % i,jȫ��������
bus_j = bus_i;
bus_v = (bus(:,GS) + 1j * bus(:,BS)) / baseMVA; % vȫ��������

%% branch ����
branch_i = branch(:,F_BUS);  % �׽ڵ�
branch_j = branch(:,T_BUS);  % ĩ�ڵ�

% ��ѹ��ģ��
yt = 1 ./ ( branch(:, BR_R) + 1j * branch(:, BR_X));    % ������ʼ����
t = branch(:, TAP) == 0;                                % ��ѹ��֧·�� ���� ������
branch(t, TAP) = 1;                                     % �Ǳ�׼���, ��0��1
k = branch(:, TAP);                                     % �Ǳ�׼���

yl = yt ./ k;
yi = (1-k) ./ (k.^2) .* yt;
yj = (k-1) ./ k .* yt;

branch_vii = yl + 1j * branch(:,BR_B)/2 + yi;
branch_vjj = yl + 1j * branch(:,BR_B)/2 + yj;
branch_vij = - yl;
branch_vji = branch_vij;

%% �ϳɵ��ɾ���
s_i = [bus_i; branch_i;   branch_j;   branch_i;   branch_j];
s_j = [bus_j; branch_i;   branch_j;   branch_j;   branch_i];
s_v = [bus_v; branch_vii; branch_vjj; branch_vij; branch_vji];
Y = sparse(s_i, s_j, s_v, NUM.Bus, NUM.Bus);

%% ��G��B
G = real(Y);
B = imag(Y);
