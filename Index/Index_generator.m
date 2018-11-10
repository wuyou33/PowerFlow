function [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    PC1, PC2, QC1MIN, QC1MAX, QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30,...
    RAMP_Q, APF] = Index_generator
%% define the indices
GEN_BUS     = 1;    %% ���������ĸ�ߵı��
PG          = 2;    %% ���뷢������й����� (MW)
QG          = 3;    %% ���뷢������޹����� (MVAr)
QMAX        = 4;    %% ��������������޹����� (MVAr)
QMIN        = 5;    %% ���������С����޹����� (MVAr)
VG          = 6;    %% ������Ĺ�����ѹ��ֵ (p.u.)
MBASE       = 7;    %% ������Ĺ��ʻ�׼ֵ��Ĭ��ΪbaseMVA
GEN_STATUS  = 8;    %% ״̬, 1 - machine in service, 0 - machine out of service
PMAX        = 9;    %% ��������������й����� (MW)
PMIN        = 10;   %% ���������С����й����� (MW)
PC1         = 11;   %% Pc1, lower real power output of PQ capability curve (MW)
PC2         = 12;   %% Pc2, upper real power output of PQ capability curve (MW)
QC1MIN      = 13;   %% Qc1min, minimum reactive power output at Pc1 (MVAr)
QC1MAX      = 14;   %% Qc1max, maximum reactive power output at Pc1 (MVAr)
QC2MIN      = 15;   %% Qc2min, minimum reactive power output at Pc2 (MVAr)
QC2MAX      = 16;   %% Qc2max, maximum reactive power output at Pc2 (MVAr)
RAMP_AGC    = 17;   %% ramp rate for load following/AGC (MW/min)
RAMP_10     = 18;   %% ramp rate for 10 minute reserves (MW)
RAMP_30     = 19;   %% ramp rate for 30 minute reserves (MW)
RAMP_Q      = 20;   %% ramp rate for reactive power (2 sec timescale) (MVAr/min)
APF         = 21;   %% area participation factor