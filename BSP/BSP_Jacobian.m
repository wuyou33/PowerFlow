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
%% i!=jʱ �ǶԽ�Ԫ��
[j,i] = meshgrid(1:NUM.Bus);
H = - U(i).*U(j).*(G.*sin(delta(i)-delta(j))-B.*cos(delta(i)-delta(j)));
N = - U(i).*U(j).*(G.*cos(delta(i)-delta(j))+B.*sin(delta(i)-delta(j)));
K = + U(i).*U(j).*(G.*cos(delta(i)-delta(j))+B.*sin(delta(i)-delta(j)));
L = - U(i).*U(j).*(G.*sin(delta(i)-delta(j))-B.*cos(delta(i)-delta(j)));

%% i==jʱ �Խ�Ԫ�������ԭ������Ч�ķǶԽ�Ԫ��
i = 1 : NUM.Bus;
H(logical(eye(NUM.Bus))) =   U(i).^2 .* diag(B) + Qi(i);
N(logical(eye(NUM.Bus))) = - U(i).^2 .* diag(G) - Pi(i);
K(logical(eye(NUM.Bus))) =   U(i).^2 .* diag(G) - Pi(i);
L(logical(eye(NUM.Bus))) =   U(i).^2 .* diag(B) - Qi(i);

% -----------------------------------------���ˣ���ÿһ���ڵ㶼������ H N K L
% ��������Ҫ���ݸ����ڵ�����ͣ�˳�����ţ�PQ_BUS PV_BUS
%% HN KL ������������
H = [H( PLC.PV, : ); H( PLC.PQ, : )];
H = [H( :, PLC.PV ), H( :, PLC.PQ )];
N = [N( PLC.PV, PLC.PQ ); N( PLC.PQ, PLC.PQ )];
K = [K( PLC.PQ, PLC.PV ), K( PLC.PQ, PLC.PQ )];
L = L( PLC.PQ, PLC.PQ );

Jacobian = [H N
            K L];

end % main function: BSP_Jacobian


