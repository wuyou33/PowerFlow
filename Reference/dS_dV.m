function [Jacobian] = dS_dV(Y, u, PLC)
%% matpower���ſɱȾ���ķ�������ϡ����󲿷֣�runpf -> newtonpf -> dSBus_dV����
% ���˹����￵
%% default input args

n = length(u);
I = Y * u;

diagV       = sparse(1:n, 1:n, u, n, n);  % ��u���ɵ�diag
diagI    = sparse(1:n, 1:n, I, n, n);     % ��I���ɵ�diag
diagVnorm   = sparse(1:n, 1:n, u./abs(u), n, n); % ��u�ĵ�λ�������ɵ�diag

dSbus_dVa = 1j * diagV * conj(diagI - Y * diagV);                     %% dSbus/dVa
dSbus_dVm = diagV * conj(Y * diagVnorm) + conj(diagI) * diagVnorm;    %% dSbus/dVm

H = real(dSbus_dVa( logical(PLC.PQ + PLC.PV), logical(PLC.PQ + PLC.PV) ));
N = real(dSbus_dVm( logical(PLC.PQ + PLC.PV), PLC.PQ ));
K = imag(dSbus_dVa( PLC.PQ, logical(PLC.PQ + PLC.PV) ));
L = imag(dSbus_dVm( PLC.PQ, PLC.PQ ));

Jacobian = [   H N;
               K L;    ];