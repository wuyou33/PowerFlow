function [ NL_fx,dP,dQ,Pi,Qi ] = BSP_Unbalanced( baseMVA,Pis,Qis,u,Y, PLC )
%% BSP_Unbalanced 计算功率不平衡量
% OUTPUT:均为 单列矩阵
%        NL_fx : 牛拉法公式中的fx，由dP和dQ组合而成
%        dP, dQ: 功率不平衡量 (每一个节点都算了，按照原来的顺序排列)
%        Pi, Qi: 功率计算量 （用于Jacobian矩阵的计算：二者公式有重复）
% INPUT:
%        baseMVA: 基准容量
%        Pis    : 节点的 真实 总输入功率:  Pis   ( MW )
%        Qis    : 节点的 真实 总输入功率:  Qis   (MVar)
%        u      : 母线电压(complex              (p.u.)
%        Y      : 导纳矩阵                      (p.u.)
%        PLC,NUM: 索引值 @BSP_Initial.m
% Author: Kang-S

%% 功率不平衡量
Si = u .* conj(Y * u);  % S = U*I^{*}
Pi = real(Si);
Qi = imag(Si);
dP = Pis / baseMVA - Pi;  % 计算ΔPi有功的不平衡量 (p.u.)
dQ = Qis / baseMVA - Qi;  % 计算ΔQi无功的不平衡量 (p.u.)

%% 算出 NL.fx 矩阵 （先全是ΔP，再全是ΔQ）
NL_fx = [dP(PLC.PV); dP(PLC.PQ) ; dQ(PLC.PQ)];  % 排列顺序是先PV节点，再PQ节点
% NL_fx = [dP(logical( PLC.PQ + PLC.PV)) ; dQ(PLC.PQ)];  % 排列顺序是原母线顺序下的ΔP ΔQ

end%func

