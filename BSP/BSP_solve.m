function [NL_x] = BSP_solve(NL,NUM_Bus)
%% BSP_FastJacobian: ���ټ����ſɱȾ���runpf -> newtonpf -> dSBus_dV
% OUTPUT:
%        Jacobian: �ſɱȾ���        
% INPUT:
%        NL      : NR����ʽ�Ĳ�����struct��
%        NUM_Bus : ����ֵNUM @BSP_Initial.m
% Author: Kang-S
%
% �����Ƿֽ�������Է����� b = A * x
% x = NL.x
% A = - NL.Jacobian
% b = NL.fx
if NUM_Bus <= 20                            % �ڵ����ٵ�ʱ��ֱ�����㼴��
    NL_x  = - NL.Jacobian \ NL.fx;          % x = A\b
else
    q = amd(- NL.Jacobian);                 % ��������˳��, �൱����ǰ����lu�Ĺ����������ٶȸ���
    [L, U, p] = lu(- NL.Jacobian(q,q), 'vector'); % ��Ϊ֮ǰamd���ˣ����ڵ� p = 1:n, vector��������ʽ����
    NL_x = zeros(size(NL.Jacobian, 1), 1);  % Ԥ����NL_x���ڴ�
    NL_x(q) = U \ ( L \ NL.fx( q(p)) );      % x = U\(L\b) �� ��ԭԭ����˳��
    
%     q = amd(- NL.Jacobian);                 % ��������˳��, �൱����ǰ����lu�Ĺ����������ٶȸ���
%     [L, U, p] = lu(- NL.Jacobian(q,q), 1.0, 'vector'); % ��Ϊ֮ǰamd���ˣ����ڵ� p = 1:n
%     NL_x = zeros(size(NL.Jacobian, 1), 1);  % Ԥ����NL_x���ڴ�
%     NL_x(q) = U \ ( L \ NL.fx( q(p)) );      % x = U\(L\b) �� ��ԭԭ����˳��
end
%% amd
% P = amd(A) Ϊϡ����� C = A + A' ���ؽ�����С�����û�������
% C(P,P) �� A(P,P) �� Cholesky �ֽ���ܱ� C �� A �� Cholesky �ֽ�ϡ�衣
% amd �������ܱ� symamd �����죬�����ܱ� symamd ���ظ��õ�����
% ���� A �����Ƿ������ A Ϊ�������� amd(A) ��Ч�� amd(sparse(A))��
%% lu
% [L,U,P] = lu(A,'vector') ������������ p �� q �з����û���Ϣ��
% U�������Ǿ���L�Ǿ��е�λ�Խ��ߵ������Ǿ���  P���û����� 
% Vector���ص�����(1:n)����������������������ô���᷵��eye(n) --- ��������Ա��龰