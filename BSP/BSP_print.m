function BSP_print(bus,gen,branch,loss,NL,Type,NUM,PRINT_LENGTH,PF_N_IT,Accuracy)
%          printpf(baseMVA, bus, gen, branch, f, success, et, fd, mpopt)
% BSP_print: ���ڴ�ӡ��������Ľ��
% OUTPUT: �ޣ�ͨ����ӡ�����û�����������
% INPUT��
%       bus��IEEE��ʽ�ڵ����
%       gen��IEEE��ʽ���������
%       NL�� ţ������ʽ�Ĳ�����fx��x��Jacobian��
%       Type�� �ڵ����ࣨ�ṹ�壺IEEE��׼���ֽڵ㣩
%       NUM�� ���ֽڵ��Լ�bus��gen�ȵ�����
%       PRINT_LENGTH�� ��ӡ����ĳ��ȣ���print_title.m��
%       PF_N: 
%       
%% bus��generator��branch������ֵ
[BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, BASE_KV, ZONE, ...
    VMAX, VMIN] = Index_bus; %bus
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, TAP, SHIFT,...
    BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ANGMIN, ANGMAX, MU_ANGMIN,...
    MU_ANGMAX] = Index_branch; %branch
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    PC1, PC2, QC1MIN, QC1MAX, QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30,...
    RAMP_Q, APF] = Index_generator; %generator

%% �������ж�
if (max(abs(NL.fx))<Accuracy )
    print_title(PRINT_LENGTH,1,'�������: ���� %d �ε���������', PF_N_IT);
else
    print_title(PRINT_LENGTH,1,'�������: ���㲻������δ�ﵽҪ�󾫶�');
end
%% bus data
print_title(PRINT_LENGTH,2,'Bus Data');
fprintf('ע�� * ��ʾ�˽ڵ�Ϊƽ��ڵ㣬x��ʾ�˽ڵ�Ϊ�����ڵ�\n');
fprintf(  '----- ----------------  ------------------  ------------------');
fprintf('\n Bus      Voltage          Generation             Load        ');
fprintf('\n  #   Mag(pu) Ang(deg)   P (MW)   Q (MVAr)   P (MW)   Q (MVAr)');
fprintf('\n----- ------- --------  --------  --------  --------  --------');
for i = 1:NUM.Bus
    % Bus Voltage data
    fprintf('\n%5d%7.3f%9.3f', bus(i, [BUS_I, VM, VA]));
    if bus(i, BUS_TYPE) == Type.BL_BUS
        fprintf('*');
    elseif bus(i, BUS_TYPE) == Type.IS_BUS
        fprintf('x');
    else
        fprintf(' ');
    end
    % Generation power data
    g  = find(gen(:, GEN_STATUS) > 0 & gen(:, GEN_BUS) == bus(i, BUS_I));  % �ҽڵ�����ͬ�ģ����һ���ڵ�������̨����������⣩
    if ~isempty(g)
        fprintf('%9.2f%10.2f', sum(gen(g, PG)), sum(gen(g, QG)));
    else  % ���������� P �� Q ���� 0
        fprintf('      -         -  ');
    end
    % Load power data
    if bus(i, PD)~=0 && bus(i, QD)~=0
            fprintf('%10.2f%10.2f ', [ bus(i,PD) bus(i,QD) ]);
    else  % ������ɵ� P �� Q ���� 0
        fprintf('       -         -   ');
    end
end
% �ܺ�ͳ��
fprintf('\n                        --------  --------  --------  --------');
fprintf('\n               Total: %9.2f %9.2f %9.2f %9.2f', ...
    sum(gen(1:NUM.Gen, PG)), sum(gen(1:NUM.Gen, QG)), ...
    sum(bus(1:NUM.Bus, PD)), sum(bus(1:NUM.Bus, QD)));
fprintf('\n--------------------------------------------------------------\n');

%% branch data
print_title(PRINT_LENGTH,2,'Branch Data');
fprintf(  '-----  ------------  ------------------  ------------------  ------------------');
fprintf('\nBrnch   From   To    From Bus Injection   To Bus Injection     Loss (I^2 * Z)  ');
fprintf('\n  #     Bus    Bus    P (MW)   Q (MVAr)   P (MW)   Q (MVAr)   P (MW)   Q (MVAr)');
fprintf('\n-----  -----  -----  --------  --------  --------  --------  --------  --------');
fprintf('\n%4d%7d%7d%10.2f%10.2f%10.2f%10.2f%10.3f%10.2f', ...
        [   (1:NUM.Branch)', branch(:, [F_BUS, T_BUS]), ...
            branch(:, [PF, QF]), branch(:, [PT, QT]), ...
            real(loss), imag(loss) ...
        ]');

fprintf('\n                                                             --------  --------');
fprintf('\n                                                    Total:%10.3f%10.2f', ...
        sum(real(loss)), sum(imag(loss)));
fprintf('\n');