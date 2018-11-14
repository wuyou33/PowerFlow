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
%        U      : 母线电压                      (p.u.)
%        G      : Y = G + jB                   (p.u.)
%        B      : Y = G + jB                   (p.u.)
%        delta  : 母线电压相角                  (rad )
%        PLC,NUM: 索引值 详见 @BSP_Initial.m
% TEMP TEST: 临时调试代码

% %% 将电压转化为复数的形式u = e + jf
% u = U.*cos(delta) + 1j * U.*sin(delta); 
%% 功率不平衡量
Si = u .* conj(Y * u);
Pi = real(Si);
Qi = imag(Si);
dP = Pis / baseMVA - Pi;  % 计算ΔPi有功的不平衡量 (p.u.)
dQ = Qis / baseMVA - Qi;  % 计算ΔQi无功的不平衡量 (p.u.)

%% 算出 NL.fx 矩阵  input:PLC, NUM  先全是ΔP，再全是ΔQ
% NL_fx = [dP(logical( PLC.PQ + PLC.PV)) ; dQ(PLC.PQ)]; % 排列顺序是原顺序下的ΔP ΔQ
NL_fx = [dP(PLC.PV); dP(PLC.PQ) ; dQ(PLC.PQ)]; % 排列顺序是原顺序下的ΔP ΔQ
end%func

