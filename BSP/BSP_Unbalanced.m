function [ NL_fx,dP,dQ,Pi,Qi ] = BSP_Unbalanced( baseMVA,Pis,Qis,U,G,B,delta, PLC,NUM )
%% BSP_Unbalanced ���㹦�ʲ�ƽ����
% OUTPUT:��Ϊ ���о���
%        NL_fx : ţ������ʽ�е�fx����dP��dQ��϶���
%        dP, dQ: ���ʲ�ƽ���� (ÿһ���ڵ㶼���ˣ�����ԭ����˳������)
%        Pi, Qi: ���ʼ����� ������Jacobian����ļ��㣺���߹�ʽ���ظ���
% INPUT:
%        baseMVA: ��׼����
%        Pis    : �ڵ�� ��ʵ �����빦��:  Pis   ( MW )
%        Qis    : �ڵ�� ��ʵ �����빦��:  Qis   (MVar)
%        U      : ĸ�ߵ�ѹ                      (p.u.)
%        G      : Y = G + jB                   (p.u.)
%        B      : Y = G + jB                   (p.u.)
%        delta  : ĸ�ߵ�ѹ���                  (rad )
%        PLC,NUM: ����ֵ ��� @BSP_Initial.m
% TEMP TEST: ��ʱ���Դ���

%% ���빦��
% �ڵ�� ���� �����빦�ʣ� Pi  Qi  (p.u.)
Pi = zeros(NUM.Bus,1); 
Pn = zeros(NUM.Bus,1); % ѭ����temp��
Qi = zeros(NUM.Bus,1); 
Qn = zeros(NUM.Bus,1); 
% �ڵ�� ��ʵ �����빦�ʣ� Pis  Qis  (MW MVar)
% Pis = -bus(:, PD);  % ���ɽڵ� ���Ĺ���
% Qis = -bus(:, QD);

%% ���㦤Pi�й��Ĳ�ƽ����
for i=1:NUM.Bus
    for j=1:NUM.Bus
        Pn(j)=U(i)*U(j)*(G(i,j)*cos(delta(i)-delta(j))+B(i,j)*sin(delta(i)-delta(j)));
    end
    Pi(i)=sum(Pn); % �й����ʷ��뷽��
end
dP = Pis / baseMVA - Pi;  % ÿ���ڵ㶼���� (p.u.)

%% ���㦤Qi�޹��Ĳ�ƽ����
for i = 1 : NUM.Bus
	for j = 1 : NUM.Bus
		Qn(j)=U(i)*U(j)*(G(i,j)*sin(delta(i)-delta(j))-B(i,j)*cos(delta(i)-delta(j)));
	end
	Qi(i)=sum(Qn); % �޹����ʷ��뷽��
end
dQ = Qis / baseMVA - Qi;  % ÿ���ڵ㶼���� (p.u.)

%% ��� NL.fx ����  input:PLC, NUM  ��ȫ�Ǧ�P����ȫ�Ǧ�Q
% NL_fx = [dP(logical( PLC.PQ + PLC.PV)) ; dQ(PLC.PQ)]; % ����˳����ԭ˳���µĦ�P ��Q
NL_fx = [dP(PLC.PV); dP(PLC.PQ) ; dQ(PLC.PQ)]; % ����˳����ԭ˳���µĦ�P ��Q
end%func

