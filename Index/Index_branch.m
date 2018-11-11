function [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, ...
    RATE_C, TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = Index_branch

%% define the indices
F_BUS       = 1;    %% ��ʼĸ�߱��
T_BUS       = 2;    %% ��ֹĸ�߱��
BR_R        = 3;    %% ֧·���� (p.u.)
BR_X        = 4;    %% ֧·�翹 (p.u.)
BR_B        = 5;    %% ֧·�ܳ����� (p.u.)
RATE_A      = 6;    %% ֧·������������Ĺ��� MVA 
RATE_B      = 7;    %% ֧·������������Ĺ��� MVA 
RATE_C      = 8;    %% ֧·������������Ĺ��� MVA 
TAP         = 9;    %% ֧·�ϱ�ѹ���ı�ȣ�֧·Ԫ���ǵ��ߣ����ֵΪ0�����֧·Ԫ���Ǳ�ѹ������ñ��Ϊfbus���׼��ѹ��tbus���׼��ѹ֮��,�Ǳ�׼������ڵ�һ���Ϊ from �࣬�迹����һ���Ϊ to ��
SHIFT       = 10;   %% ֧·�ϱ�ѹ����ת�ǣ����֧·Ԫ�����Ǳ�ѹ�������ֵΪ0 (degrees)
BR_STATUS   = 11;   %% ֧·�ĳ�ʼ����״̬��1��ʾͶ�����У�0��ʾ�˳����� 1 - in service, 0 - out of service
ANGMIN      = 12;   %% ֧·��С��ǲ� angle(Vf) - angle(Vt) (degrees)
ANGMAX      = 13;   %% ֧·�����ǲ� angle(Vf) - angle(Vt) (degrees)
%% included in power flow solution, not necessarily in input
PF          = 14;   %% real power injected at "from" bus end (MW)       (not in PTI format)
QF          = 15;   %% reactive power injected at "from" bus end (MVAr) (not in PTI format)
PT          = 16;   %% real power injected at "to" bus end (MW)         (not in PTI format)
QT          = 17;   %% react    ive power injected at "to" bus end (MVAr)   (not in PTI format)

%% included in opf solution, not necessarily in input
%% assume objective function has units, u
MU_SF       = 18;   %% Kuhn-Tucker multiplier on MVA limit at "from" bus (u/MVA)
MU_ST       = 19;   %% Kuhn-Tucker multiplier on MVA limit at "to" bus (u/MVA)
MU_ANGMIN   = 20;   %% Kuhn-Tucker multiplier lower angle difference limit (u/degree)
MU_ANGMAX   = 21;   %% Kuhn-Tucker multiplier upper angle difference limit (u/degree)
