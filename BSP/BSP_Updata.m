function [U,delta] = BSP_Updata( U,delta,NL_x, PLC,NUM )
%% NL��ʽ�еĵ�ѹ״̬������
U_a = NL_x( 1 : NUM.PQ + NUM.PV );                         % ��ѹ��� ����
U_m = NL_x( NUM.PQ + NUM.PV + 1 : 2 * NUM.PQ + NUM.PV  );  % ��ѹ��ֵ ��U/U

delta(PLC.PV) = delta(PLC.PV) + U_a(1:NUM.PV);
delta(PLC.PQ) = delta(PLC.PQ) + U_a(NUM.PV+1:end);

U(PLC.PQ) = U(PLC.PQ) + U_m .* U(PLC.PQ);  % U1 = U0 + ��U0/U0 * U0

%% �����ڵ�ĵ�ѹ״̬��
end