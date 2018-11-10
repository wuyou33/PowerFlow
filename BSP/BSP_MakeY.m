function [Y, G, B, y] = BSP_MakeY(Input)
% function [Y, G, B] = BSP_MakeY(Input)
%% BSP_MAKEY ���㵼�ɾ���  
% OUTPUT: 
%        Y: ���ɾ��� (unit: p.u.)
%        G: Y = G + jB
%        B: Y = G + jB
% INPUT: 
%        Input: IEEE��׼��ʽ�������MATPOWER 'vision2.0'��
% TEMP TEST: ��ʱ���Դ���
% TIP: �����isolate bus�� �͸�һ�µ��ɾ���ͺ��ˣ���ʱ������
%% ����ת��
    baseMVA = Input.baseMVA;
    bus     = Input.bus;
    branch  = Input.branch;

%% ����ֵ��bus��branch��
[BUS_I, BUS_TYPE, PD, QD, GS, BS] = Index_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, TAP, SHIFT, ...
    BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ANGMIN, ANGMAX, MU_ANGMIN, ...
    MU_ANGMAX] = Index_branch;
ENABLE  = 1;
DISABLE = 0;

%% �ڵ�����֧·��
NUM.Bus= size(bus,1);
NUM.Branch = size(branch,1);

%% ֧·����Ԥ�����ڴ�
Y = zeros(NUM.Bus);  % Y���� Ԥ�����ڴ� 
% y = zeros(NUM.Bus);  % �Ե���y0���Խ��ߣ��ͻ�����yij���ǶԽ��ߣ�����������·����
%% ��ѹ����Чģ�� �����ɾ�����ʽ��
%% ����������x��������������[ij]��������������x����������     from---k:1-|yt|----to
%%      |                  |
%%     [i]                [j]
%%      |                  |

%% ���ɾ�������
% branch_t = branch;         % ��branch_t����branch����, ������û�б�Ҫ�ˣ����������ı�branch��ֵ��
t = branch(:, TAP) == 0; % ��ѹ��֧·�� ���� ������
branch(t, TAP) = 1;      % �Ǳ�׼���, ��0��1
k = branch(:, TAP);      % �Ǳ�׼���

for i = 1 : NUM.Bus         % BUS���Ե���
%     p = bus(i,1);           % ��Ӧ�Ľڵ��ţ�λ�ã� ........ �ڵ����±��֮��Ӧ���ǿ���ȥ����
    Y(i,i) = (bus(i,GS) + 1j * bus(i,BS)) / baseMVA;  
%     y(i,i) = Y(i,i);
end
y = Y;  % ֻ���ǵ�bus�����ֵ��ʱ�򣬶�����ͬ

for i = 1 : NUM.Branch       % Branch���Ե���
    if branch(i,BR_STATUS) == ENABLE   % ��ĸ������Ͷ��������
        p1 = branch(i,F_BUS);  % �׽ڵ�
        p2 = branch(i,T_BUS);  % ĩ�ڵ�
        
        yt = 1 / ( branch(i, BR_R) + 1j * branch(i, BR_X));  % ������ʼ����
        % ��ѹ��ģ��
        yl = yt / k(i);
        yi = (1-k(i))/k(i)^2 * yt;
        yj = (k(i)-1)/k(i) * yt;
        % ���ɾ��󲿷�
        Y(p1,p1) = Y(p1,p1) + yl + 1j * branch(i,BR_B)/2 + yi;
        Y(p2,p2) = Y(p2,p2) + yl + 1j * branch(i,BR_B)/2 + yj;
        Y(p1,p2) = Y(p1,p2) - yl;
        Y(p2,p1) = Y(p1,p2);
        % ���ɲ���
        y(p1,p1) = y(p1,p1) + 1j * branch(i,BR_B)/2 + yi; % might error *
        y(p2,p2) = y(p2,p2) + 1j * branch(i,BR_B)/2 + yj;
        y(p1,p2) = y(p1,p2) + yl;  % ��Ϊ0����PFҲΪ0
        y(p2,p1) = y(p1,p2);       % ��Ϊ0����PTҲΪ0
    end
end

%% ȥ����Ч�ڵ�(ֻ������Ч�Ľڵ�) ���ڵ����±��֮����Ҫ��
% Y = Y(bus(:,BUS_I), bus(:,BUS_I));
%% ��G��B
G = real(Y);
B = imag(Y);

% Y = sparse(Y);
% G = sparse(G);
% B = sparse(B);
