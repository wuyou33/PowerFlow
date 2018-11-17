function [ NL_fx,dP,dQ,Pi,Qi ] = BSP_Unbalanced( baseMVA,Pis,Qis,u,Y, PLC )
%% BSP_Unbalanced ���㹦�ʲ�ƽ����
% OUTPUT:��Ϊ ���о���
%        NL_fx : ţ������ʽ�е�fx����dP��dQ��϶���
%        dP, dQ: ���ʲ�ƽ���� (ÿһ���ڵ㶼���ˣ�����ԭ����˳������)
%        Pi, Qi: ���ʼ����� ������Jacobian����ļ��㣺���߹�ʽ���ظ���
% INPUT:
%        baseMVA: ��׼����
%        Pis    : �ڵ�� ��ʵ �����빦��:  Pis   ( MW )
%        Qis    : �ڵ�� ��ʵ �����빦��:  Qis   (MVar)
%        u      : ĸ�ߵ�ѹ(complex              (p.u.)
%        Y      : ���ɾ���                      (p.u.)
%        PLC,NUM: ����ֵ @BSP_Initial.m
% Author: Kang-S

%% ���ʲ�ƽ����
Si = u .* conj(Y * u);  % S = U*I^{*}
Pi = real(Si);
Qi = imag(Si);
dP = Pis / baseMVA - Pi;  % ���㦤Pi�й��Ĳ�ƽ���� (p.u.)
dQ = Qis / baseMVA - Qi;  % ���㦤Qi�޹��Ĳ�ƽ���� (p.u.)

%% ��� NL.fx ���� ����ȫ�Ǧ�P����ȫ�Ǧ�Q��
NL_fx = [dP(PLC.PV); dP(PLC.PQ) ; dQ(PLC.PQ)];  % ����˳������PV�ڵ㣬��PQ�ڵ�
% NL_fx = [dP(logical( PLC.PQ + PLC.PV)) ; dQ(PLC.PQ)];  % ����˳����ԭĸ��˳���µĦ�P ��Q

end%func

