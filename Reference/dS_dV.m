function [Jacobian] = dS_dV(Y, u, PLC)
%% matpower算雅可比矩阵的方法（非稀疏矩阵部分）runpf -> newtonpf -> dSBus_dV函数
% 搬运：孙康
%% default input args

n = length(u);
I = Y * u;

diagV       = sparse(1:n, 1:n, u, n, n);         % 以u构成的diag
diagI       = sparse(1:n, 1:n, I, n, n);         % 以I构成的diag
diagVnorm   = sparse(1:n, 1:n, u./abs(u), n, n); % 以u的单位向量构成的diag

dS_dVa = 1j * diagV * conj(diagI - Y * diagV);                     % dS/dVa
dS_dVm = diagV * conj(Y * diagVnorm) + conj(diagI) * diagVnorm;    % dS/dVm

H = real([dS_dVa( PLC.PV, :); dS_dVa( PLC.PQ, :)]);
H = [H( :, PLC.PV), H( :, PLC.PQ)];
N = real([dS_dVm( PLC.PV, PLC.PQ ); dS_dVm( PLC.PQ, PLC.PQ )]);
K = imag([dS_dVa( PLC.PQ, PLC.PV ), dS_dVa( PLC.PQ, PLC.PQ)]);
L = imag(dS_dVm( PLC.PQ, PLC.PQ ));

Jacobian = [H N ; K L] * -1;