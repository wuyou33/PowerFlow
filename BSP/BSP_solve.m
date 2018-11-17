function [NL_x] = BSP_solve(NL,NUM_Bus)
%% BSP_FastJacobian: 快速计算雅可比矩阵runpf -> newtonpf -> dSBus_dV
% OUTPUT:
%        Jacobian: 雅可比矩阵        
% INPUT:
%        NL      : NR法公式的参数（struct）
%        NUM_Bus : 索引值NUM @BSP_Initial.m
% Author: Kang-S
%
% 用三角分解求解线性方程组 b = A * x
% x = NL.x
% A = - NL.Jacobian
% b = NL.fx
if NUM_Bus <= 20                            % 节点数少的时候直接运算即可
    NL_x  = - NL.Jacobian \ NL.fx;          % x = A\b
else
    q = amd(- NL.Jacobian);                 % 重组矩阵的顺序, 相当于提前做了lu的工作，但是速度更快
    [L, U, p] = lu(- NL.Jacobian(q,q), 'vector'); % 因为之前amd过了，现在的 p = 1:n, vector以向量形式返回
    NL_x = zeros(size(NL.Jacobian, 1), 1);  % 预分配NL_x的内存
    NL_x(q) = U \ ( L \ NL.fx( q(p)) );      % x = U\(L\b) 并 还原原来的顺序
    
%     q = amd(- NL.Jacobian);                 % 重组矩阵的顺序, 相当于提前做了lu的工作，但是速度更快
%     [L, U, p] = lu(- NL.Jacobian(q,q), 1.0, 'vector'); % 因为之前amd过了，现在的 p = 1:n
%     NL_x = zeros(size(NL.Jacobian, 1), 1);  % 预分配NL_x的内存
%     NL_x(q) = U \ ( L \ NL.fx( q(p)) );      % x = U\(L\b) 并 还原原来的顺序
end
%% amd
% P = amd(A) 为稀疏矩阵 C = A + A' 返回近似最小阶数置换向量。
% C(P,P) 或 A(P,P) 的 Cholesky 分解可能比 C 或 A 的 Cholesky 分解稀疏。
% amd 函数可能比 symamd 函数快，还可能比 symamd 返回更好的排序。
% 矩阵 A 必须是方阵。如果 A 为满矩阵，则 amd(A) 等效于 amd(sparse(A))。
%% lu
% [L,U,P] = lu(A,'vector') 在两个列向量 p 和 q 中返回置换信息。
% U是上三角矩阵、L是具有单位对角线的下三角矩阵  P是置换矩阵 
% Vector返回的向量(1:n)，而如果不加这个参数，那么将会返回eye(n) --- 括号中针对本情景