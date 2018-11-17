function [u,U,delta] = BSP_Updata( U,delta,NL_x, PLC,NUM )
%% BSP_Updata: 电压更新
% OUTPUT:
%        u       : 母线电压(complex              (p.u.)   
%        U       : u = U .* exp(1j*delta)
%        delta   : u = U .* exp(1j*delta)
% INPUT:
%        U       : u = U .* exp(1j*delta)
%        delta   : u = U .* exp(1j*delta)
%        NL_x    : NL NR法的参数（struct）
%        PLC,NUM : 索引值 @BSP_Initial.m
% Author: Kang-S

%% NL公式中的电压状态量更新
U_a = NL_x( 1 : NUM.PQ + NUM.PV );                         % 电压相角 Δδ
U_m = NL_x( NUM.PQ + NUM.PV + 1 : 2 * NUM.PQ + NUM.PV  );  % 电压幅值 ΔU/U

delta(PLC.PV) = delta(PLC.PV) + U_a(1:NUM.PV);
delta(PLC.PQ) = delta(PLC.PQ) + U_a(NUM.PV+1:end);

U(PLC.PQ) = U(PLC.PQ) + U_m .* U(PLC.PQ);  % U1 = U0 + ΔU0/U0 * U0

%% 将电压转化为复数的形式u = e + jf
u = U .* exp(1j*delta);
%% 各个节点的电压状态量
end