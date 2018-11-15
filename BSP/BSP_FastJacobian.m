function [Jacobian] = BSP_FastJacobian(Y, u, PLC)
%% matpower: runpf -> newtonpf -> dSBus_dV函数
% Author：Kang-S
%% default input args

n = length(u);
I = Y * u; % 导纳矩阵的解释式，I为节点的注入电流，Y*u是节点的流出电流

diagV       = sparse(1:n, 1:n, u, n, n);         % 以u构成的diag
diagI       = sparse(1:n, 1:n, I, n, n);         % 以I构成的diag
diagVnorm   = sparse(1:n, 1:n, u./abs(u), n, n); % 以u的单位向量构成的diag

dS_dVa = 1j * diagV * conj(diagI - Y * diagV);                     % dS/dVa
dS_dVm = diagV * conj(Y * diagVnorm) + conj(diagI) * diagVnorm;    % dS/dVm

% HN来源于ΔP为实部，KL来源于ΔQ为虚部
H = real([dS_dVa( PLC.PV, :); dS_dVa( PLC.PQ, :)]);
H = [H( :, PLC.PV), H( :, PLC.PQ)];
N = real([dS_dVm( PLC.PV, PLC.PQ ); dS_dVm( PLC.PQ, PLC.PQ )]);
K = imag([dS_dVa( PLC.PQ, PLC.PV ), dS_dVa( PLC.PQ, PLC.PQ)]);
L = imag(dS_dVm( PLC.PQ, PLC.PQ ));

Jacobian = [H N ; K L] * -1;