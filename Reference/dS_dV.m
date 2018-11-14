function [Jacobian] = dS_dV(Y, u, PLC)
%% matpower算雅可比矩阵的方法（非稀疏矩阵部分）runpf -> newtonpf -> dSBus_dV函数
% 搬运工：孙康
%% default input args

n = length(u);
I = Y * u;

diagV       = sparse(1:n, 1:n, u, n, n);  % 以u构成的diag
diagI    = sparse(1:n, 1:n, I, n, n);     % 以I构成的diag
diagVnorm   = sparse(1:n, 1:n, u./abs(u), n, n); % 以u的单位向量构成的diag

dSbus_dVa = 1j * diagV * conj(diagI - Y * diagV);                     %% dSbus/dVa
dSbus_dVm = diagV * conj(Y * diagVnorm) + conj(diagI) * diagVnorm;    %% dSbus/dVm

H = real(dSbus_dVa( logical(PLC.PQ + PLC.PV), logical(PLC.PQ + PLC.PV) ));
N = real(dSbus_dVm( logical(PLC.PQ + PLC.PV), PLC.PQ ));
K = imag(dSbus_dVa( PLC.PQ, logical(PLC.PQ + PLC.PV) ));
L = imag(dSbus_dVm( PLC.PQ, PLC.PQ ));

Jacobian = [   H N;
               K L;    ];