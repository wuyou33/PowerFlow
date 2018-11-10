function [Jacobian] = dS_dV(Y, U, PLC)
%% matpower算雅可比矩阵的方法（非稀疏矩阵部分）runpf -> newtonpf -> dSBus_dV函数
% 搬运工：孙康
%% default input args

n = length(U);
Ibus = Y * U;

if issparse(Y)           %% sparse version (if Ybus is sparse)
    diagVnorm   = sparse(1:n, 1:n, U./abs(U), n, n);
else                        %% dense version
    diagV       = diag(U);
    diagIbus    = diag(Ibus);
    diagVnorm   = diag(U./abs(U));
end
    dSbus_dVa = 1j * diagV * conj(diagIbus - Y * diagV);                     %% dSbus/dVa
    dSbus_dVm = diagV * conj(Y * diagVnorm) + conj(diagIbus) * diagVnorm;    %% dSbus/dVm

j11 = real(dSbus_dVa( logical(PLC.PQ + PLC.PV), logical(PLC.PQ + PLC.PV) ));
j12 = real(dSbus_dVm(logical(PLC.PQ + PLC.PV), PLC.PQ));
j21 = imag(dSbus_dVa(PLC.PQ, logical(PLC.PQ + PLC.PV)));
j22 = imag(dSbus_dVm(PLC.PQ, PLC.PQ));

Jacobian = [   j11 j12;
               j21 j22;    ];