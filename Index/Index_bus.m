function [BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, BASE_KV, ...
    ZONE, VMAX, VMIN] = Index_bus
%% define the indices
BUS_I       = 1;    %% ĸ�߱��  (1 to 29997)
BUS_TYPE    = 2;    %% �ڵ�����  (1 - PQ bus, 2 - PV bus, 3 - reference bus, 4 - isolated bus)
PD          = 3;    %% ע�븺�ɵ��й� (MW)
QD          = 4;    %% ע�븺�ɵ��޹� (MVAr)
GS          = 5;    %% ��ĸ�߲����ĵ絼 (MW at V = 1.0 p.u.)
BS          = 6;    %% ��ĸ�߲����ĵ��� (MVAr at V = 1.0 p.u.)
BUS_AREA    = 7;    %% ��������ţ�һ������Ϊ1, 1-100
VM          = 8;    %% ĸ�ߵ�ѹ�ķ�ֵ (p.u.)
VA          = 9;    %% ĸ�ߵ�ѹ����� (degrees)
BASE_KV     = 10;   %% ��׼��ѹ (kV)
ZONE        = 11;   %% ��ķ����ţ�һ������Ϊ1 (1-999)
VMAX        = 12;   %% ����ʱ��ĸ�ߵ���ߵ�ѹ��ֵ (p.u.) (not in PTI format)
VMIN        = 13;   %% ����ʱ��ĸ�ߵ���͵�ѹ��ֵ (p.u.) (not in PTI format)