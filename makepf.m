%% TEMP TEST: 临时调试代码
clc
clear
close all
%% 公式形式
    % ┌ ΔP ┐  _   ┌ H N ┐ ┌  Δδ  ┐
    % └ ΔQ ┘  ─   └ K L ┘ └ ΔU/U ┘ 
%% 环境初始化
casedata = case300;
addpath ('./BSP', './Index', './Reference','./Recorde'); % 函数链接
run BSP_Initial.m
print_title(PRINT_LENGTH, 1, '正在运行 IEEE %d',NUM.Bus);

tic
%% 导纳矩阵生成
[Y, G, B] = BSP_MakeY(Input);  % 形成导纳矩阵 .......2383wp 0.005s

if UNDISPLAY  % 导纳矩阵显示
    print_title(PRINT_LENGTH,6,'导纳矩阵');
    disp(Y);
end
ERR_MAX = max(max(abs( Y - makeYbus(baseMVA, bus, branch) )));
%% 判断导纳矩阵误差值
if DISPLAY  % 导纳矩阵误差值计算和显示
    ERR_MAX = max(max(abs( Y - makeYbus(baseMVA, bus, branch) )));  % 误差值
    print_title(PRINT_LENGTH,5,'Y误差：%e', ERR_MAX)
%     fprintf("* 导纳矩阵最大误差值：%e\n\n", ERR_MAX);
    % 显示误差图像
    if FIGURE
        answ = Y - makeYbus(baseMVA, bus, branch);
        image(abs(answ)*3*1e15);
        colorbar;
        title(['Different_{max} = ', num2str(ERR_MAX),'（图像3^{15}倍放大）']);
    end
end

%% 节点注入功率 Sis = Pis + j*Qis
[Pis,Qis] = BSP_Sis(bus,gen,NUM);

%% 功率不平衡量 Calculate Value
[ NL.fx,dP,dQ,Pi,Qi ] = BSP_Unbalanced( baseMVA,Pis,Qis,u,Y, PLC );  % ..2383wp 0.003s
if DISPLAY  % 显示功率不平衡量
    print_title(PRINT_LENGTH,6,'功率不平衡量');
    disp(table(dP,dQ,Pi,Qi));
    print_title(PRINT_LENGTH,6,'fx矩阵')
    fprintf('   %.4f', NL.fx );
    fprintf('\n');
end
if FIGURE   % 记录fx数据
    draw = max(abs(NL.fx)); 
end

%% 大循环
for PF_N_IT = 1:PF_MAX_IT % 最大迭代次数 
  
    %% 雅可比矩阵
%     tic
    [ NL.Jacobian ] = BSP_Jacobian( U,delta,G,B,Pi,Qi, PLC,NUM ); % 2383 1.6s
%     [ NL.Jacobian ] = dS_dV(Y, u, PLC);  % 直接用复数的方法求Jacobian矩阵的方法 2383 0.006s  
%     fprintf('Jacobian time %.4f\n',toc);
    %% 牛拉法 核心公式 
    NL.x = - NL.Jacobian \ NL.fx;  % 2383 0.01s

    %% 电压状态更新
    [u,U,delta] = BSP_Updata( U,delta,NL.x,PLC,NUM ); % 2383 0.0003s
    
    %% 功率不平衡量
    [ NL.fx,dP,dQ,Pi,Qi ] = BSP_Unbalanced( baseMVA,Pis,Qis,u,Y, PLC );

    %% 中间过程打印输出
    if FIGURE   % 误差数据记录
        draw = [draw,max(abs(NL.fx))];
    end
    if DISPLAY  % 显示雅可比矩阵
        print_title(PRINT_LENGTH,3,'牛拉法第%d次迭代', PF_N_IT);
        print_title(PRINT_LENGTH,6,'Jacobian 矩阵');
        disp(NL.Jacobian)
    end
    if DISPLAY  % 显示电压修正量
        print_title(PRINT_LENGTH,6,'x矩阵 (Δδ 和 ΔU/U)');
        disp(NL.x.');
    end
    if DISPLAY  % 显示电压修正结果
        print_title(PRINT_LENGTH,6,'电压修正结果');
        disp('* 电压幅值 U：');
        disp(U')
        disp('* 电压相角 δ：');
        disp(delta')
    end
    if DISPLAY  % 显示功率不平衡量
        print_title(PRINT_LENGTH,6,'功率不平衡量');  
        disp(table(dP,dQ,Pi,Qi));
        print_title(PRINT_LENGTH,6,'功率不平衡量 fx矩阵');
        fprintf('   %.4f', NL.fx );
        fprintf('\n');
    end
    %% 精度控制 （控制变量：功率不平衡量）
    if ( max( abs(NL.fx) ) < Accuracy )
            break;
    end
end % NL 大循环
time = toc;
%% 节点电压数据
bus(:,[VM, VA]) = [U,(delta*180/pi)];  % 把电压和相角更新到bus矩阵中
%% PV节点 功率 （只有 平衡节点 的 P和Q，PV节点 的 Q 可以变化）
dS = -[dP,dQ]*baseMVA; % 注意有一个节点上接了两个发电机的情况
% PV节点加上 ΔQ
[~,gen_PV] = ismember(bus(PLC.PV,BUS_I),gen(:,GEN_BUS)); % 找到gen中PV节点的位置（行数） % [is,pos]=ismember(B,A) pos是B中元素如果在A中出现，出现的位置 (非logical)
gen(gen_PV,QG) = gen(gen_PV,QG) + dS(PLC.PV, 2); % PV节点的ΔQ加上去

%% 将电压转化为复数的形式u = e + jf
u = U.*cos(delta) + 1j * U.*sin(delta); % 已经验证正确

%% 平衡节点 功率
Sn = sum( u(PLC.BL) .* Y(PLC.BL,:)' .* conj(u) ) * baseMVA;
gen_BLC = gen(:,GEN_BUS) == bus(PLC.BL,BUS_I);  % 找到gen中BLC节点的位置（行数）
gen(gen_BLC,[PG, QG]) = [real(Sn), imag(Sn)];   % 平衡节点的ΔP和ΔQ加上去

%% 线路功率

% I1 = zeros(NUM.Bus);  % 串联那部分电流
% I2 = zeros(NUM.Bus);  % 并联的部分电流
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

%% 线路损耗 (放在了下一节中运算loss)
%% 将 线路功率 和 损耗 封装起来
% pf = branch(:,F_BUS);  % 起始母线
% pt = branch(:,T_BUS);  % 中止母线
% branch = [branch,zeros(NUM.Branch, 4)]; % 增加四列存放线路功率
% loss = zeros(NUM.Branch, 1);
% for i = 1 : NUM.Branch
%     branch(i,PF) = real( S1( pf(i), pt(i) ) );
%     branch(i,QF) = imag( S1( pf(i), pt(i) ) );
%     branch(i,PT) = real( S1( pt(i), pf(i) ) );
%     branch(i,QT) = imag( S1( pt(i), pf(i) ) );
% %     loss(i) = dS( pt(i), pf(i) );
%     loss(i) = S1( pt(i), pf(i) ) + S1( pf(i), pt(i) ); % matpower中 loss 的 P、Q 应该和 branch 的 r，x 是成正比的
% end
% loss = myget_losses(baseMVA, bus, branch);  % 用matpower的方法计算loss

%% --------------------------------------------------------至此，所有计算结束
%% 恢复节点编号
bus(:,BUS_I) = Input_raw.bus(:,BUS_I);
gen(:,GEN_BUS) = Input_raw.gen(:,GEN_BUS);
branch(:,[F_BUS,T_BUS]) = Input_raw.branch(:,[F_BUS,T_BUS]);

%% 判断收敛性，结果打印
BSP_print(bus,gen,NL,Type,NUM,PRINT_LENGTH,PF_N_IT,Accuracy); % 收敛性判断以及结果输出

%% 
if FIGURE  % 误差变化曲线
    figure('Name','误差变化曲线');
    plot(draw);  % 绘制误差变化曲线
    xlabel('Time');
    ylabel('Per-unit value');
end

% load('run.mat');
% RUN = runpf(casedata);clc;
% fprintf('幅值误差: %.3e\n',max(max(abs(bus(:,8)-RUN.bus(:,8)))));
% fprintf('相角误差: %.3e\n',max(max(abs(bus(:,9)-RUN.bus(:,9)))));
fprintf('导纳矩阵误差: %.3e\n',full(ERR_MAX));
fprintf('程序耗时: %.3fs\n',time);
