% function makepf(casedata)
% %makepf �������൱��MATPOWER��runpf
% if nargin < 1
%     clear
%     close all
%     casedata = case0;
% end
% % vision 2.0: ����ڵ����±��
%% TEMP TEST: ��ʱ���Դ���
clc
clear
close all
casedata = case300;

%% ������ʼ��
addpath ('./BSP', './Index', './Reference'); % ��������
run BSP_Initial.m
print_title(PRINT_LENGTH, 1, '�������� IEEE %d',NUM.Bus)
tic

%% ���ɾ�������
% [Y, G, B] = BSP_MakeY(Input);
[Y, G, B, y] = BSP_MakeY(Input);  % �γɵ��ɾ���
if UNDISPLAY  % ���ɾ�����ʾ
    print_title(PRINT_LENGTH,6,'���ɾ���');
    disp(Y);
end

%% �жϵ��ɾ������ֵ
if DISPLAY  % ���ɾ������ֵ�������ʾ
    ERR_MAX = max(max(abs( Y - full(makeYbus(baseMVA, bus, branch)) )));  % ���ֵ
    print_title(PRINT_LENGTH,5,'Y��%e', ERR_MAX)
%     fprintf("* ���ɾ���������ֵ��%e\n\n", ERR_MAX);
    % ��ʾ���ͼ��
    if FIGURE
        answ = Y - makeYbus(baseMVA, bus, branch);
        image(abs(answ)*3*1e15);
        colorbar;
        title(['Different_{max} = ', num2str(ERR_MAX),'��ͼ��3^{15}���Ŵ�']);
    end
end
%% �ڵ�ע�빦�� Pre Value ---------------------ÿһ���ڵ��Sis����������һ��
% �ڵ����±�ź�İ汾��Ҳ����ĸ�ߵĽڵ����������ģ�����1~300
Pis = -bus(:, PD);  % ���ɽڵ� ���Ĺ���Ϊ���� (MW, MVar)
Qis = -bus(:, QD);
for i = 1: NUM.Gen   % ÿ���ڵ���Ϸ������ ���빦�� (û�зֽڵ������)
    Pis(gen(i, GEN_BUS)) = Pis(gen(i, GEN_BUS)) + gen(i, PG);
    Qis(gen(i, GEN_BUS)) = Qis(gen(i, GEN_BUS)) + gen(i, QG);
end

%% ���ʲ�ƽ���� Calculate Value
[ NL.fx,dP,dQ,Pi,Qi ] = BSP_Unbalanced( baseMVA,Pis,Qis,U,G,B,delta, PLC,NUM );
if DISPLAY  % ��ʾ���ʲ�ƽ����
    print_title(PRINT_LENGTH,6,'���ʲ�ƽ����');
    disp(table(dP,dQ,Pi,Qi));
    print_title(PRINT_LENGTH,6,'fx����')
    fprintf('   %.4f', NL.fx );
    fprintf('\n');
end
if FIGURE   % ��¼fx����
    draw = max(abs(NL.fx)); 
end
%% ��ѭ��
for PF_N_IT = 1:PF_MAX_IT % ���������� 
    %% �ſɱȾ���
    [ NL.Jacobian ] = BSP_Jacobian( U,delta,G,B,Pi,Qi, PLC,NUM );
%     [NL.Jacobian] = dS_dV(Y, U, PLC);  % matpower��Jacobian����ķ���    
    %% ţ���� ���Ĺ�ʽ
    % �� ��P ��  _   �� H N �� ��  ����  ��
    % �� ��Q ��  ��   �� K L �� �� ��U/U ��    
    NL.x = -inv(NL.Jacobian) * NL.fx; % ţ�����ؼ���ʽ��� dU����Ҫ����ת����ԭ����˳��    
    %% ��ѹ״̬����
    [U,delta] = BSP_Updata( U,delta,NL.x,PLC,NUM );   
    %% ���ʲ�ƽ����
    [ NL.fx,dP,dQ,Pi,Qi ] = BSP_Unbalanced( baseMVA,Pis,Qis,U,G,B,delta, PLC,NUM );
    %% �м���̴�ӡ���
    if FIGURE   % ������ݼ�¼
        draw = [draw,max(abs(NL.fx))];
    end
    if DISPLAY  % ��ʾ�ſɱȾ���
        print_title(PRINT_LENGTH,3,'ţ������%d�ε���', PF_N_IT);
        print_title(PRINT_LENGTH,6,'Jacobian ����');
        disp(NL.Jacobian)
    end
    if DISPLAY  % ��ʾ��ѹ������
        print_title(PRINT_LENGTH,6,'x���� (���� �� ��U/U)');
        disp(NL.x.');
    end
    if DISPLAY  % ��ʾ��ѹ�������
        print_title(PRINT_LENGTH,6,'��ѹ�������');
        disp('* ��ѹ��ֵ U��');
        disp(U')
        disp('* ��ѹ��� �ģ�');
        disp(delta')
    end
    if DISPLAY  % ��ʾ���ʲ�ƽ����
        print_title(PRINT_LENGTH,6,'���ʲ�ƽ����');  
        disp(table(dP,dQ,Pi,Qi));
        print_title(PRINT_LENGTH,6,'���ʲ�ƽ���� fx����');
        fprintf('   %.4f', NL.fx );
        fprintf('\n');
    end
    %% ���ȿ��� �����Ʊ��������ʲ�ƽ������
    if ( max( abs(NL.fx) ) < Accuracy )
            break;
    end
end % NL ��ѭ��


%% �ڵ��ѹ����
bus(:,[VM, VA]) = [U,(delta*180/pi)];  % �ѵ�ѹ����Ǹ��µ�bus������

%% �ڵ㹦������ ��ֻ��ƽ��ڵ��PQ��PV�ڵ��Q���Ա仯��
% BLC�ڵ���� ��P �� ��Q
dS = -[dP,dQ]*baseMVA; % ע����һ���ڵ��Ͻ�����������������(Ϊʲô��-�ţ���Ҳ��̫���)
gen_BLC = gen(:,GEN_BUS) == bus(PLC.BL,BUS_I);  % �ҵ�gen��BLC�ڵ��λ�ã�������
gen(gen_BLC,[PG, QG]) = gen(gen_BLC,[PG, QG]) + dS(PLC.BL); % ƽ��ڵ�Ħ�P�ͦ�Q����ȥ *
% PV�ڵ���� ��Q
idx_dQ = abs(dS(:,2)) > 1e-5;  % �ҵ�dS�Ц�Q��λ�ã�����PV�ڵ��BLC�ڵ㣩
% [is,pos]=ismember(B,A) pos��B��Ԫ�������A�г��֣����ֵ�λ�� (��logical)
[~,gen_PV] = ismember(bus(PLC.PV,BUS_I),gen(:,GEN_BUS)); % �ҵ�gen��PV�ڵ��λ�ã�������
gen(gen_PV,QG) = gen(gen_PV,QG) + dS(PLC.PV, 2); % PV�ڵ�Ħ�Q����ȥ

%% ����ѹת��Ϊ��������ʽu = e + jf
u = U.*cos(delta) + 1j * U.*sin(delta);
%% ����ƽ��ڵ�Ĺ��ʺ���·���� ��ǰ��ֱ�ӰѦ�P�ͦ�Q����ȥ����ƺ��ǶԵģ�
% for j = 1:NUM.Bus
%     Sn_temp(j) = u(NUM.Bus)*conj(Y(NUM.Bus,j))*conj(u(j)); % conj������������
% end
% Sn = sum(Sn_temp);
% disp('*ƽ��ڵ㹦�� Sn');
% disp(Sn);

%% ��·����
S = zeros(NUM.Bus); % Ԥ�����ڴ�
for i=1:NUM.Bus  % S_ij �� S_ji��һ����ͬ��Ҳ���Ǿ���һ���Գ�
    for j=1:NUM.Bus
		S(i,j) = u(i)*(conj(u(i)) * conj(y(i,i)) + (conj(u(i)) - conj(u(j))) * conj(y(i,j)));
    end
end
S = - S * baseMVA;

%% ��·���
for i=1:NUM.Bus  % S_ij �� S_ji��һ����ͬ��Ҳ���Ǿ���һ���Գ�
    for j=1:NUM.Bus
		dS(i,j) = S(i,j) + S(j,i);
    end
end
% dS = S + S';
%% �� ��·���� �� ��� ��װ����
pf = branch(:,F_BUS);  % ��ʼĸ��
pt = branch(:,T_BUS);  % ��ֹĸ��
branch = [branch,zeros(NUM.Branch, 4)]; % �������д����·����
loss = zeros(NUM.Branch, 1);
for i = 1 : NUM.Branch
    branch(i,PF) = real( S( pf(i), pt(i) ) );
    branch(i,QF) = imag( S( pf(i), pt(i) ) );
    branch(i,PT) = real( S( pt(i), pf(i) ) );
    branch(i,QT) = imag( S( pt(i), pf(i) ) );
    loss(i) = dS( pt(i), pf(i) );
end
%% --------------------------------------------------------���ˣ����м������
%% �ָ��ڵ���
bus(:,BUS_I) = Input_raw.bus(:,BUS_I);
gen(:,GEN_BUS) = Input_raw.gen(:,GEN_BUS);
branch(:,[F_BUS,T_BUS]) = Input_raw.branch(:,[F_BUS,T_BUS]);
%% �ж������ԣ������ӡ
BSP_print(bus,gen,branch,loss,NL,Type,NUM,PRINT_LENGTH,PF_N_IT,Accuracy); % �������ж��Լ�������
%% 
toc
if FIGURE  % ���仯����
    figure('Name','���仯����');
    plot(draw);  % �������仯����
    xlabel('Time');
    ylabel('Per-unit value');
end