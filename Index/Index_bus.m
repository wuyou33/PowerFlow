function [BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, BASE_KV, ...
    ZONE, VMAX, VMIN] = Index_bus
%% define the indices
BUS_I       = 1;    %% 母线编号  (1 to 29997)
BUS_TYPE    = 2;    %% 节点类型  (1 - PQ bus, 2 - PV bus, 3 - reference bus, 4 - isolated bus)
PD          = 3;    %% 注入负荷的有功 (MW)
QD          = 4;    %% 注入负荷的无功 (MVAr)
GS          = 5;    %% 与母线并联的电导 (MW at V = 1.0 p.u.)
BS          = 6;    %% 与母线并联的电纳 (MVAr at V = 1.0 p.u.)
BUS_AREA    = 7;    %% 电网断面号，一般设置为1, 1-100
VM          = 8;    %% 母线电压的幅值 (p.u.)
VA          = 9;    %% 母线电压的相角 (degrees)
BASE_KV     = 10;   %% 基准电压 (kV)
ZONE        = 11;   %% 损耗分区号，一般设置为1 (1-999)
VMAX        = 12;   %% 工作时，母线的最高电压幅值 (p.u.) (not in PTI format)
VMIN        = 13;   %% 工作时，母线的最低电压幅值 (p.u.) (not in PTI format)