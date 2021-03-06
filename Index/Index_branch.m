function [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, ...
    RATE_C, TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = Index_branch

%% define the indices
F_BUS       = 1;    %% 起始母线编号
T_BUS       = 2;    %% 终止母线编号
BR_R        = 3;    %% 支路电阻 (p.u.)
BR_X        = 4;    %% 支路电抗 (p.u.)
BR_B        = 5;    %% 支路总充电电纳 (p.u.)
RATE_A      = 6;    %% 支路长期运行允许的功率 MVA 
RATE_B      = 7;    %% 支路短期运行允许的功率 MVA 
RATE_C      = 8;    %% 支路紧急运行允许的功率 MVA 
TAP         = 9;    %% 支路上变压器的变比，支路元件是导线，则该值为0，如果支路元件是变压器，则该变比为fbus侧基准电压与tbus侧基准电压之比,非标准变比所在的一侧称为 from 侧，阻抗所在一侧称为 to 侧
SHIFT       = 10;   %% 支路上变压器的转角，如果支路元件不是变压器，则该值为0 (degrees)
BR_STATUS   = 11;   %% 支路的初始工作状态，1表示投入运行，0表示退出运行 1 - in service, 0 - out of service
ANGMIN      = 12;   %% 支路最小相角差 angle(Vf) - angle(Vt) (degrees)
ANGMAX      = 13;   %% 支路最大相角差 angle(Vf) - angle(Vt) (degrees)
%% included in power flow solution, not necessarily in input
PF          = 14;   %% 支路功率的有功功率 at "from" bus end (MW)       (not in PTI format)
QF          = 15;   %% 支路功率的无功功率 at "from" bus end (MVAr) (not in PTI format)
PT          = 16;   %% 支路功率的有功功率 at "to" bus end (MW)         (not in PTI format)
QT          = 17;   %% 支路功率的无功功率 at "to" bus end (MVAr)   (not in PTI format)

%% included in opf solution, not necessarily in input
%% assume objective function has units, u
MU_SF       = 18;   %% Kuhn-Tucker multiplier on MVA limit at "from" bus (u/MVA)
MU_ST       = 19;   %% Kuhn-Tucker multiplier on MVA limit at "to" bus (u/MVA)
MU_ANGMIN   = 20;   %% Kuhn-Tucker multiplier lower angle difference limit (u/degree)
MU_ANGMAX   = 21;   %% Kuhn-Tucker multiplier upper angle difference limit (u/degree)
