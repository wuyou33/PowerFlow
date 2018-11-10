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
% TEMP TEST: ��ʱ���Դ���
%% ��ʼ��
% Ԥ�����ڴ�
J.H = zeros(NUM.Bus);
J.N = zeros(NUM.Bus);
J.K = zeros(NUM.Bus);
J.L = zeros(NUM.Bus);
%% i!=jʱ �ǶԽ�Ԫ��
for i = 1 : NUM.Bus
	for j = 1 : NUM.Bus
		J.H(i,j) = - U(i)*U(j)*(G(i,j)*sin(delta(i)-delta(j))-B(i,j)*cos(delta(i)-delta(j)));
	end
end
for i = 1 : NUM.Bus
	for j = 1 : NUM.Bus
		J.N(i,j) = - U(i)*U(j)*(G(i,j)*cos(delta(i)-delta(j))+B(i,j)*sin(delta(i)-delta(j)));
	end
end
for i = 1 : NUM.Bus
	for j = 1 : NUM.Bus
		J.K(i,j) = + U(i)*U(j)*(G(i,j)*cos(delta(i)-delta(j))+B(i,j)*sin(delta(i)-delta(j)));
	end
end
for i = 1 : NUM.Bus
	for j = 1 : NUM.Bus
		J.L(i,j) = - U(i)*U(j)*(G(i,j)*sin(delta(i)-delta(j))-B(i,j)*cos(delta(i)-delta(j)));
	end
end
%% i==jʱ �Խ�Ԫ�������ԭ������Ч�ķǶԽ�Ԫ��

for i = 1 : NUM.Bus
	J.H(i,i) =   U(i).^2 * B(i,i) + Qi(i);
end
for i = 1 : NUM.Bus
	J.N(i,i) = - U(i).^2 * G(i,i) - Pi(i);
end
for i = 1 : NUM.Bus
	J.K(i,i) =   U(i).^2 * G(i,i) - Pi(i);
end
for i = 1 : NUM.Bus
	J.L(i,i) =   U(i).^2 * B(i,i) - Qi(i);
end
% -----------------------------------------���ˣ���ÿһ���ڵ㶼������ H N K L
% ��������Ҫ���ݸ����ڵ�����ͣ�˳�����ţ�PQ_BUS PV_BUS
%% HN KL ������������
[J] = sort_Jacobian(J,PLC);

Jacobian = [J.H J.N
            J.K J.L];

end % main function: BSP_Jacobian

%% sub function 1 �ſɱȾ��� ���� �ڵ����� ����
% function [J] = sort_Jacobian(J,PLC)
% J.H = J.H( logical(PLC.PQ + PLC.PV), : );
% J.H = J.H( :, logical(PLC.PQ + PLC.PV) );
% 
% J.N = J.N( logical(PLC.PQ + PLC.PV), : );
% J.N = J.N( :, PLC.PQ );
% 
% J.K = J.K( PLC.PQ, : );
% J.K = J.K( :, logical(PLC.PQ + PLC.PV) );
% 
% J.L = J.L( PLC.PQ, : );
% J.L = J.L( :, PLC.PQ );
% end
% ��������
function [J] = sort_Jacobian(J,PLC)
J.H = [J.H( PLC.PV, : ); J.H( PLC.PQ, : )];
J.H = [J.H( :, PLC.PV ), J.H( :, PLC.PQ )];

J.N = [J.N( PLC.PV, : ); J.N( PLC.PQ, : )];
J.N = J.N( :, PLC.PQ );

J.K = J.K( PLC.PQ, : );
J.K = [J.K( :, PLC.PV ), J.K( :, PLC.PQ )];

J.L = J.L( PLC.PQ, : );
J.L = J.L( :, PLC.PQ );
end
