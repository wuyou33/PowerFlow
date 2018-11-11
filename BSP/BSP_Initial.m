format compact  
%% ������������
Accuracy = 1e-5;    % ��������
PF_MAX_IT = 5;      % ����������
%% ������Ʒ�
DISPLAY = 0;        % ��ʾ�м���Թ���
UNDISPLAY = 0;      % Ĭ�ϲ���ʾ�����ݣ����ɾ���
FIGURE  = 0;        % ��ʾͼ����Թ���
PRINT_LENGTH = 78;
ENABLE  = 1;        % gen��branch������״̬
DISABLE = 0;
%% ���ݵ��룺 IEEE��׼���ݸ�ʽ
% Input=runpf(casedata); clc; 
Input = casedata;   % ��Ҫ��makepf��ָ��casedata
Input_raw = Input;  % ��������ԭ���ϱ��ݣ�read��     
%% �ڵ����±��
% [is,pos]=ismember(B,A) pos��B��Ԫ�������A�г��֣����ֵ�λ�� (��logical)
nb = length(Input.bus(:,1));
busnum = Input.bus(:,1);                          Input.bus(:,1)=1:nb;
[~,temp] = ismember(Input.gen(:,1),busnum);       Input.gen(:,1)=temp;  
[~,temp] = ismember(Input.branch(:,1),busnum);    Input.branch(:,1)=temp;
[~,temp] = ismember(Input.branch(:,2),busnum);    Input.branch(:,2)=temp;
%% �ض������
baseMVA = Input.baseMVA;  % ��׼���� baseMVA
bus = Input.bus;          % BUSĸ�ߣ�         ���ɣ����ɣ���׼��ѹ
gen = Input.gen;          % Generator������� ���ʣ�������ѹ�����ʻ�׼ֵ
branch = Input.branch;    % Branch֧·��      ���裬�翹�������ɣ���λ
% gencost=gencost;

%% bus��generator��branch������ֵ
[BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, BASE_KV, ZONE, ...
    VMAX, VMIN] = Index_bus; %bus
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, TAP, SHIFT,...
    BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ANGMIN, ANGMAX, MU_ANGMIN,...
    MU_ANGMAX] = Index_branch; %branch
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    PC1, PC2, QC1MIN, QC1MAX, QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30,...
    RAMP_Q, APF] = Index_generator; %generator

%% �ڵ�����
Type.PQ_BUS = 1;  % BUS �ڵ����� BUS_TYPE
Type.PV_BUS = 2;
Type.BL_BUS = 3;
Type.IS_BUS = 4;

%% ϵͳ��Ϣ���ڵ��� ֧·�� ������� ��ѹֵ
NUM.Bus= size(bus,1);         % bus number
NUM.Branch = size(branch,1);  % branch number
NUM.Gen = size(gen,1);        % generator number

%% �ڵ���Ϣ��λ�� ����
% place ����ڵ��λ��, �ж�Ӧ�ڵ�Ϊ1��û��Ϊ0, ����Ϊlogical ��λ�õ������Ǿ����������
PLC.PQ = bus(:,BUS_TYPE) == Type.PQ_BUS; 
PLC.PV = bus(:,BUS_TYPE) == Type.PV_BUS;
PLC.BL = bus(:,BUS_TYPE) == Type.BL_BUS;
PLC.IS = bus(:,BUS_TYPE) == Type.IS_BUS;
% number ����ڵ������
NUM.PQ = sum(PLC.PQ~=0);             
NUM.PV = sum(PLC.PV~=0);
NUM.BL = sum(PLC.BL~=0);
NUM.IS = sum(PLC.IS~=0);
if NUM.PQ + NUM.PV + NUM.BL + NUM.IS ~= NUM.Bus
    error('���������쳣������ڵ����࣡��');
end
%% ��ʼ������
% �ڵ��ѹ
U = bus(:, VM);      % ĸ�ߵ�ѹ (p.u.)                            
delta = pi/180 * bus(:, VA);  % ĸ�ߵ�ѹ���(�����ƣ�MATLAB�����Ǻ���ʶ�𻡶���)
NL.xInit = [delta(logical(PLC.PQ + PLC.PV)); U(PLC.PQ)]; % ���Jacobian�����x

