function [ Jacobian ] = BSP_Jacobian( U,delta,G,B,Pi,Qi, PLC,NUM )  % n��m��
%% BSP_Jacobian �����ſɱȾ���
% OUTPUT:
%        Jacobian: �ſɱȾ���        
% INPUT:
%        U     : �ڵ��ѹ��ֵ���������� (p.u.)
%        delta : �ڵ��ѹ��ǣ��������� (rad )
%        G     : Y = G + jB           (p.u.)
%        B     : Y = G + jB           (p.u.)
%        Pi    : ���ʼ�����Pi          (p.u.)
%        Qi    : ���ʼ�����Qi          (p.u.)
%        bus   : IEEE��׼��ʽ�� bus ��������
% HELP:
%        �ֿ�,Ȼ��ͬ�Ľڵ��Ԫ�������ȡ����                  
%                   �� H N ��
%                   �� K L ��            
%% i!=jʱ �ǶԽ�Ԫ�� 1.4s -> 0.24s
% tic
% vison ------------------------------------------------------------------1
% [j,i] = meshgrid(1:NUM.Bus);
% H = - U(i).*U(j).*(G.*sin(delta(i)-delta(j))-B.*cos(delta(i)-delta(j)));
% N = - U(i).*U(j).*(G.*cos(delta(i)-delta(j))+B.*sin(delta(i)-delta(j)));
% K = + U(i).*U(j).*(G.*cos(delta(i)-delta(j))+B.*sin(delta(i)-delta(j)));
% L = - U(i).*U(j).*(G.*sin(delta(i)-delta(j))-B.*cos(delta(i)-delta(j)));

% vison ------------------------------------------------------------------2
% idx_nz = (G + 1j*B) ~= 0; % no zero
% delta_ij = delta.*idx_nz-delta'.*idx_nz;
% H = - U.*idx_nz.*U' .* (G.*sin(delta_ij)-B.*cos(delta_ij));
% N = - U.*idx_nz.*U' .* (G.*cos(delta_ij)+B.*sin(delta_ij));
% K = + U.*idx_nz.*U' .* (G.*cos(delta_ij)+B.*sin(delta_ij));
% L = - U.*idx_nz.*U' .* (G.*sin(delta_ij)-B.*cos(delta_ij));

% vison ------------------------------------------------------------------3
idx_nz = (G + 1j*B) ~= 0; % no zero
delta_ij = delta.*idx_nz-delta'.*idx_nz;
H = - U.*idx_nz.*U' .* (G.*sin(delta_ij)-B.*cos(delta_ij));
N = - U.*idx_nz.*U' .* (G.*cos(delta_ij)+B.*sin(delta_ij));
K = -N;
L =  H;

% ------------------------------------------------------------------vison 4
% ---------------------------------------------------------------------fail
% Y = G + 1j*B;
% idx_nz = Y ~= 0; % no zero
% delta_ij = delta.*idx_nz-delta'.*idx_nz;
% % TA = - U.*idx_nz.*U';
% TB = conj(Y).*exp(1j*delta_ij)';
% H = - U.*idx_nz.*U' .* (imag(TB));
% N = - U.*idx_nz.*U' .* (real(TB));
% K = -N;
% L =  H;
% toc

% vison ------------------------------------------------------------------5
% ---------------------------------------------------------------------fail
% idx_nz = (G + 1j*B) ~= 0; % no zero
% delta_ij = delta.*idx_nz-delta'.*idx_nz;
% TA = G.*sin(delta_ij);
% TB = B.*cos(delta_ij);
% TC = - U.*idx_nz.*U';
% H = TC .* (TA - TB);
% N = TC .* (TA + TB);
% K = -N;
% L =  H;
%% i==jʱ �Խ�Ԫ�������ԭ������Ч�ķǶԽ�Ԫ�� 0.2s -> 0.01s��Index������sparse���ͣ�
% tic
idx = logical(sparse(1:NUM.Bus, 1:NUM.Bus, 1, NUM.Bus, NUM.Bus));
H(idx) =   U.^2 .* diag(B) + Qi;
N(idx) = - U.^2 .* diag(G) - Pi;
K(idx) =   U.^2 .* diag(G) - Pi;
L(idx) =   U.^2 .* diag(B) - Qi;
% toc
% -----------------------------------------���ˣ���ÿһ���ڵ㶼������ H N K L
% ��������Ҫ���ݸ����ڵ�����ͣ�˳�����ţ�PQ_BUS PV_BUS
%% HN KL ������������ 0.015s
H = [H( PLC.PV, : ); H( PLC.PQ, : )];
H = [H( :, PLC.PV ), H( :, PLC.PQ )];
N = [N( PLC.PV, PLC.PQ ); N( PLC.PQ, PLC.PQ )];
K = [K( PLC.PQ, PLC.PV ), K( PLC.PQ, PLC.PQ )];
L = L( PLC.PQ, PLC.PQ );

Jacobian = [H N
            K L];
end % main function: BSP_Jacobian


