%% TEMP TEST: ��ʱ���Դ���
clc
clear
close all
%% ��ʽ��ʽ
    % �� ��P ��  _   �� H N �� ��  ����  ��
    % �� ��Q ��  ��   �� K L �� �� ��U/U �� 
%% ������ʼ��
casedata = case300;
addpath ('./BSP', './Index', './Reference','./Recorde'); % ��������
run BSP_Initial.m
print_title(PRINT_LENGTH, 1, '�������� IEEE %d',NUM.Bus);

tic
%% ���ɾ�������
[Y, G, B] = BSP_MakeY(Input);  % �γɵ��ɾ��� .......2383wp 0.005s

if UNDISPLAY  % ���ɾ�����ʾ
    print_title(PRINT_LENGTH,6,'���ɾ���');
    disp(Y);
end
ERR_MAX = max(max(abs( Y - makeYbus(baseMVA, bus, branch) )));
%% �жϵ��ɾ������ֵ
if DISPLAY  % ���ɾ������ֵ�������ʾ
    ERR_MAX = max(max(abs( Y - makeYbus(baseMVA, bus, branch) )));  % ���ֵ
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

%% �ڵ�ע�빦�� Sis = Pis + j*Qis
[Pis,Qis] = BSP_Sis(bus,gen,NUM);

%% ���ʲ�ƽ���� Calculate Value
[ NL.fx,dP,dQ,Pi,Qi ] = BSP_Unbalanced( baseMVA,Pis,Qis,u,Y, PLC );  % ..2383wp 0.003s
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
%     tic
    [ NL.Jacobian ] = BSP_Jacobian( U,delta,G,B,Pi,Qi, PLC,NUM ); % 2383 1.6s
%     [ NL.Jacobian ] = dS_dV(Y, u, PLC);  % ֱ���ø����ķ�����Jacobian����ķ��� 2383 0.006s  
%     fprintf('Jacobian time %.4f\n',toc);
    %% ţ���� ���Ĺ�ʽ 
    NL.x = - NL.Jacobian \ NL.fx;  % 2383 0.01s

    %% ��ѹ״̬����
    [u,U,delta] = BSP_Updata( U,delta,NL.x,PLC,NUM ); % 2383 0.0003s
    
    %% ���ʲ�ƽ����
    [ NL.fx,dP,dQ,Pi,Qi ] = BSP_Unbalanced( baseMVA,Pis,Qis,u,Y, PLC );

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
time = toc;
%% �ڵ��ѹ����
bus(:,[VM, VA]) = [U,(delta*180/pi)];  % �ѵ�ѹ����Ǹ��µ�bus������
%% PV�ڵ� ���� ��ֻ�� ƽ��ڵ� �� P��Q��PV�ڵ� �� Q ���Ա仯��
dS = -[dP,dQ]*baseMVA; % ע����һ���ڵ��Ͻ�����������������
% PV�ڵ���� ��Q
[~,gen_PV] = ismember(bus(PLC.PV,BUS_I),gen(:,GEN_BUS)); % �ҵ�gen��PV�ڵ��λ�ã������� % [is,pos]=ismember(B,A) pos��B��Ԫ�������A�г��֣����ֵ�λ�� (��logical)
gen(gen_PV,QG) = gen(gen_PV,QG) + dS(PLC.PV, 2); % PV�ڵ�Ħ�Q����ȥ

%% ����ѹת��Ϊ��������ʽu = e + jf
u = U.*cos(delta) + 1j * U.*sin(delta); % �Ѿ���֤��ȷ

%% ƽ��ڵ� ����
Sn = sum( u(PLC.BL) .* Y(PLC.BL,:)' .* conj(u) ) * baseMVA;
gen_BLC = gen(:,GEN_BUS) == bus(PLC.BL,BUS_I);  % �ҵ�gen��BLC�ڵ��λ�ã�������
gen(gen_BLC,[PG, QG]) = [real(Sn), imag(Sn)];   % ƽ��ڵ�Ħ�P�ͦ�Q����ȥ

%% ��·����

% I1 = zeros(NUM.Bus);  % �����ǲ��ֵ���
% I2 = zeros(NUM.Bus);  % �����Ĳ��ֵ���
% S1 = zeros(NUM.Bus); 
% S2 = zeros(NUM.Bus);
% for i = 1:NUM.Bus
%     for j = 1:NUM.Bus
%         I1(i,j) = ( u(i) - u(j) ) * y(i,j);
%         I2(i,j) = u(i) * y(i,i);
%         S1(i,j) = u(i) * conj(I1(i,j)) * baseMVA; 
%         S2(i,j) = u(i) * conj(I2(i,j)) * baseMVA;
% %         dS(i,j) = I1(i,j)^2 / y(i,j)   * baseMVA;
%     end
% end
% S = S1 + S2;

%% ��·��� (��������һ��������loss)
%% �� ��·���� �� ��� ��װ����
% pf = branch(:,F_BUS);  % ��ʼĸ��
% pt = branch(:,T_BUS);  % ��ֹĸ��
% branch = [branch,zeros(NUM.Branch, 4)]; % �������д����·����
% loss = zeros(NUM.Branch, 1);
% for i = 1 : NUM.Branch
%     branch(i,PF) = real( S1( pf(i), pt(i) ) );
%     branch(i,QF) = imag( S1( pf(i), pt(i) ) );
%     branch(i,PT) = real( S1( pt(i), pf(i) ) );
%     branch(i,QT) = imag( S1( pt(i), pf(i) ) );
% %     loss(i) = dS( pt(i), pf(i) );
%     loss(i) = S1( pt(i), pf(i) ) + S1( pf(i), pt(i) ); % matpower�� loss �� P��Q Ӧ�ú� branch �� r��x �ǳ����ȵ�
% end
% loss = myget_losses(baseMVA, bus, branch);  % ��matpower�ķ�������loss

%% --------------------------------------------------------���ˣ����м������
%% �ָ��ڵ���
bus(:,BUS_I) = Input_raw.bus(:,BUS_I);
gen(:,GEN_BUS) = Input_raw.gen(:,GEN_BUS);
branch(:,[F_BUS,T_BUS]) = Input_raw.branch(:,[F_BUS,T_BUS]);

%% �ж������ԣ������ӡ
BSP_print(bus,gen,NL,Type,NUM,PRINT_LENGTH,PF_N_IT,Accuracy); % �������ж��Լ�������

%% 
if FIGURE  % ���仯����
    figure('Name','���仯����');
    plot(draw);  % �������仯����
    xlabel('Time');
    ylabel('Per-unit value');
end

% load('run.mat');
% RUN = runpf(casedata);clc;
% fprintf('��ֵ���: %.3e\n',max(max(abs(bus(:,8)-RUN.bus(:,8)))));
% fprintf('������: %.3e\n',max(max(abs(bus(:,9)-RUN.bus(:,9)))));
fprintf('���ɾ������: %.3e\n',full(ERR_MAX));
fprintf('�����ʱ: %.3fs\n',time);
