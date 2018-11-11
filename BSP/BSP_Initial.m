format compact  
%% 结束运算条件
Accuracy = 1e-5;    % 收敛精度
PF_MAX_IT = 5;      % 最大迭代次数
%% 输出控制符
DISPLAY = 0;        % 显示中间调试过程
UNDISPLAY = 0;      % 默认不显示的内容：导纳矩阵
FIGURE  = 0;        % 显示图像调试过程
PRINT_LENGTH = 78;
ENABLE  = 1;        % gen和branch的运行状态
DISABLE = 0;
%% 数据导入： IEEE标准数据格式
% Input=runpf(casedata); clc; 
Input = casedata;   % 需要在makepf中指定casedata
Input_raw = Input;  % 输入数据原材料备份（read）     
%% 节点重新编号
% [is,pos]=ismember(B,A) pos是B中元素如果在A中出现，出现的位置 (非logical)
nb = length(Input.bus(:,1));
busnum = Input.bus(:,1);                          Input.bus(:,1)=1:nb;
[~,temp] = ismember(Input.gen(:,1),busnum);       Input.gen(:,1)=temp;  
[~,temp] = ismember(Input.branch(:,1),busnum);    Input.branch(:,1)=temp;
[~,temp] = ismember(Input.branch(:,2),busnum);    Input.branch(:,2)=temp;
%% 重定义变量
baseMVA = Input.baseMVA;  % 基准容量 baseMVA
bus = Input.bus;          % BUS母线：         负荷，导纳，基准电压
gen = Input.gen;          % Generator发电机： 功率，工作电压，功率基准值
branch = Input.branch;    % Branch支路：      电阻，电抗，充电电纳，相位
% gencost=gencost;

%% bus、generator和branch的索引值
[BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, BASE_KV, ZONE, ...
    VMAX, VMIN] = Index_bus; %bus
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, TAP, SHIFT,...
    BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ANGMIN, ANGMAX, MU_ANGMIN,...
    MU_ANGMAX] = Index_branch; %branch
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    PC1, PC2, QC1MIN, QC1MAX, QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30,...
    RAMP_Q, APF] = Index_generator; %generator

%% 节点种类
Type.PQ_BUS = 1;  % BUS 节点种类 BUS_TYPE
Type.PV_BUS = 2;
Type.BL_BUS = 3;
Type.IS_BUS = 4;

%% 系统信息：节点数 支路数 发电机数 电压值
NUM.Bus= size(bus,1);         % bus number
NUM.Branch = size(branch,1);  % branch number
NUM.Gen = size(gen,1);        % generator number

%% 节点信息：位置 数量
% place 各类节点的位置, 有对应节点为1，没有为0, 类型为logical （位置的索引是矩阵的行数）
PLC.PQ = bus(:,BUS_TYPE) == Type.PQ_BUS; 
PLC.PV = bus(:,BUS_TYPE) == Type.PV_BUS;
PLC.BL = bus(:,BUS_TYPE) == Type.BL_BUS;
PLC.IS = bus(:,BUS_TYPE) == Type.IS_BUS;
% number 各类节点的总数
NUM.PQ = sum(PLC.PQ~=0);             
NUM.PV = sum(PLC.PV~=0);
NUM.BL = sum(PLC.BL~=0);
NUM.IS = sum(PLC.IS~=0);
if NUM.PQ + NUM.PV + NUM.BL + NUM.IS ~= NUM.Bus
    error('输入数据异常：请检查节点种类！！');
end
%% 初始计算量
% 节点电压
U = bus(:, VM);      % 母线电压 (p.u.)                            
delta = pi/180 * bus(:, VA);  % 母线电压相角(弧度制：MATLAB的三角函数识别弧度制)
NL.xInit = [delta(logical(PLC.PQ + PLC.PV)); U(PLC.PQ)]; % 组成Jacobian矩阵的x

