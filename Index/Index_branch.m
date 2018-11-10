function [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, ...
    RATE_C, TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = Index_branch
% @ IDX_BRCH
%   columns 1-11 must be included in input matrix (in case file)
%    1  F_BUS       f, from bus number
%    2  T_BUS       t, to bus number
%    3  BR_R        r, resistance (p.u.)
%    4  BR_X        x, reactance (p.u.)
%    5  BR_B        b, total line charging susceptance (p.u.)
%    6  RATE_A      rateA, MVA rating A (long term rating)
%    7  RATE_B      rateB, MVA rating B (short term rating)
%    8  RATE_C      rateC, MVA rating C (emergency rating)
%    9  TAP         ratio, transformer off nominal turns ratio
%    10 SHIFT       angle, transformer phase shift angle (degrees)
%    11 BR_STATUS   initial branch status, 1 - in service, 0 - out of service
%    12 ANGMIN      minimum angle difference, angle(Vf) - angle(Vt) (degrees)
%    13 ANGMAX      maximum angle difference, angle(Vf) - angle(Vt) (degrees)
%                   (The voltage angle difference is taken to be unbounded below
%                    if ANGMIN < -360 and unbounded above if ANGMAX > 360.
%                    If both parameters are zero, it is unconstrained.)
%
%   columns 14-17 are added to matrix after power flow or OPF solution
%   they are typically not present in the input matrix
%    14 PF          real power injected into "from" end of branch (MW)
%    15 QF          reactive power injected into "from" end of branch (MVAr)
%    16 PT          real power injected into "to" end of branch (MW)
%    17 QT          reactive power injected into "to" end of branch (MVAr)
%
%   columns 18-21 are added to matrix after OPF solution
%   they are typically not present in the input matrix
%                   (assume OPF objective function has units, u)
%    18 MU_SF       Kuhn-Tucker multiplier on MVA limit at "from" bus (u/MVA)
%    19 MU_ST       Kuhn-Tucker multiplier on MVA limit at "to" bus (u/MVA)
%    20 MU_ANGMIN   Kuhn-Tucker multiplier lower angle difference limit (u/degree)
%    21 MU_ANGMAX   Kuhn-Tucker multiplier upper angle difference limit (u/degree)
%
%   See also DEFINE_CONSTANTS.
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
