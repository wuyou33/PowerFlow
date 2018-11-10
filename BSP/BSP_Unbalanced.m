function [ NL_fx,dP,dQ,Pi,Qi ] = BSP_Unbalanced( baseMVA,Pis,Qis,U,G,B,delta, PLC,NUM )
%% BSP_Unbalanced 计算功率不平衡量
% OUTPUT:均为 单列矩阵
%        NL_fx : 牛拉法公式中的fx，由dP和dQ组合而成
%        dP, dQ: 功率不平衡量 (每一个节点都算了，按照原来的顺序排列)
%        Pi, Qi: 功率计算量 （用于Jacobian矩阵的计算：二者公式有重复）
% INPUT:
%        baseMVA: 基准容量
%        Pis    : 节点的 真实 总输入功率:  Pis   ( MW )
%        Qis    : 节点的 真实 总输入功率:  Qis   (MVar)
%        U      : 母线电压                      (p.u.)
%        G      : Y = G + jB                   (p.u.)
%        B      : Y = G + jB                   (p.u.)
%        delta  : 母线电压相角                  (rad )
%        PLC,NUM: 索引值 详见 @BSP_Initial.m
% TEMP TEST: 临时调试代码

%% 输入功率
% 节点的 计算 总输入功率： Pi  Qi  (p.u.)
Pi = zeros(NUM.Bus,1); 
Pn = zeros(NUM.Bus,1); % 循环的temp量
Qi = zeros(NUM.Bus,1); 
Qn = zeros(NUM.Bus,1); 
% 节点的 真实 总输入功率： Pis  Qis  (MW MVar)
% Pis = -bus(:, PD);  % 负荷节点 消耗功率
% Qis = -bus(:, QD);

%% 计算ΔPi有功的不平衡量
for i=1:NUM.Bus
    for j=1:NUM.Bus
        Pn(j)=U(i)*U(j)*(G(i,j)*cos(delta(i)-delta(j))+B(i,j)*sin(delta(i)-delta(j)));
    end
    Pi(i)=sum(Pn); % 有功功率分离方程
end
dP = Pis / baseMVA - Pi;  % 每个节点都算了 (p.u.)

%% 计算ΔQi无功的不平衡量
for i = 1 : NUM.Bus
	for j = 1 : NUM.Bus
		Qn(j)=U(i)*U(j)*(G(i,j)*sin(delta(i)-delta(j))-B(i,j)*cos(delta(i)-delta(j)));
	end
	Qi(i)=sum(Qn); % 无功功率分离方程
end
dQ = Qis / baseMVA - Qi;  % 每个节点都算了 (p.u.)

%% 算出 NL.fx 矩阵  input:PLC, NUM  先全是ΔP，再全是ΔQ
% NL_fx = [dP(logical( PLC.PQ + PLC.PV)) ; dQ(PLC.PQ)]; % 排列顺序是原顺序下的ΔP ΔQ
NL_fx = [dP(PLC.PV); dP(PLC.PQ) ; dQ(PLC.PQ)]; % 排列顺序是原顺序下的ΔP ΔQ
end%func

