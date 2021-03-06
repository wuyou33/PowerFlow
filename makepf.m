% Author: Kang-S
%% TEMP TEST: 临时调试代码
clc
clear
close all
%% 公式形式
    % ┌ ΔP ┐  _   ┌ H N ┐ ┌  Δδ  ┐
    % └ ΔQ ┘  ─   └ K L ┘ └ ΔU/U ┘ 
%% 环境初始化
% casedata = case2383wp;
casedata = runpf('case14');
RUN = runpf(casedata);clc; % 用于误差比较
addpath ('./BSP', './Index', './Reference','./Recorde'); % 函数链接，退出程序后自动清除目录
run BSP_Initial.m
print_title(PRINT_LENGTH, 1, '正在运行 IEEE %d',NUM.Bus);

%% Time
tic
%% 导纳矩阵生成
[Y, G, B,k] = BSP_MakeY(Input);  % 形成导纳矩阵 .......2383wp 0.005s
if UNDISPLAY  % 导纳矩阵显示
    print_title(PRINT_LENGTH,6,'导纳矩阵');
    disp(Y);
end
% ERR_MAX = max(max(abs( Y - makeYbus(baseMVA, bus, branch) )));
%% 判断导纳矩阵误差值
if DISPLAY  % 导纳矩阵误差值计算和显示
    ERR_MAX = max(max(abs( Y - makeYbus(baseMVA, bus, branch) )));  % 误差值
    print_title(PRINT_LENGTH,5,'Y误差：%e', full(ERR_MAX));
end
if UNFIGURE  % 显示误差图像
    answ = Y - makeYbus(baseMVA, bus, branch);
    image(abs(answ)*3*1e15);
    colorbar;
    title(['Different_{max} = ', num2str(ERR_MAX),'（图像3^{15}倍放大）']);
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
if UNFIGURE   % 记录fx数据
    draw = max(abs(NL.fx)); 
end

%% 大循环
for PF_N_IT = 1:PF_MAX_IT % 最大迭代次数 
  
    %% 雅可比矩阵
%     [ NL.Jacobian ] = BSP_Jacobian( U,delta,G,B,Pi,Qi, PLC,NUM ); % 2383 1.6s
    [ NL.Jacobian ] = BSP_FastJacobian(Y, u, PLC);  % 直接用复数的方法求Jacobian矩阵的方法 2383 0.006s  

    %% 牛拉法 核心公式 
    [NL.x] = BSP_solve(NL,NUM.Bus);
    
    %% 电压状态更新
    [u,U,delta] = BSP_Updata( U,delta,NL.x,PLC,NUM ); % 2383 0.0003s
    
    %% 功率不平衡量
    [ NL.fx,dP,dQ,Pi,Qi ] = BSP_Unbalanced( baseMVA,Pis,Qis,u,Y, PLC );

    %% 中间过程打印输出
    if UNFIGURE   % 误差数据记录
        draw = [draw,max(abs(NL.fx))];
    end
    if UNDISPLAY  % 显示雅可比矩阵
        print_title(PRINT_LENGTH,3,'牛拉法第%d次迭代', PF_N_IT);
        print_title(PRINT_LENGTH,6,'Jacobian 矩阵');
        disp(NL.Jacobian)
    end
    if UNDISPLAY  % 显示电压修正量
        print_title(PRINT_LENGTH,6,'x矩阵 (Δδ 和 ΔU/U)');
        disp(NL.x.');
    end
    if UNDISPLAY  % 显示电压修正结果
        print_title(PRINT_LENGTH,6,'电压修正结果');
        disp('* 电压幅值 U：');
        disp(U')
        disp('* 电压相角 δ：');
        disp(delta')
    end
    if UNDISPLAY  % 显示功率不平衡量
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
% BLC节点加上 ΔP 和 ΔQ
gen_BLC = gen(:,GEN_BUS) == bus(PLC.BL,BUS_I);  % 找到gen中BLC节点的位置（行数）
gen(gen_BLC,[PG, QG]) = gen(gen_BLC,[PG, QG]) + dS(PLC.BL); % 平衡节点的ΔP和ΔQ加上去 *
% PV节点加上 ΔQ
[~,gen_PV] = ismember(bus(PLC.PV,BUS_I),gen(:,GEN_BUS)); % 找到gen中PV节点的位置（行数） % [is,pos]=ismember(B,A) pos是B中元素如果在A中出现，出现的位置 (非logical)
gen(gen_PV,QG) = gen(gen_PV,QG) + dS(PLC.PV, 2); % PV节点的ΔQ加上去

%% 将电压转化为复数的形式u = e + jf
u = U.*cos(delta) + 1j * U.*sin(delta); % 已经验证正确

%% 平衡节点 功率  -- 此方法case5的运算结果和matpower不一样 
% Sn = u(PLC.BL) * sum(Y(PLC.BL,:)' .* conj(u) ) * baseMVA;
% gen_BLC = gen(:,GEN_BUS) == bus(PLC.BL,BUS_I);  % 找到gen中BLC节点的位置（行数）
% gen(gen_BLC,[PG, QG]) = [real(Sn), imag(Sn)];   % 平衡节点的ΔP和ΔQ加上去

%% 线路功率
pf = branch(:,F_BUS);  % 起始母线
pt = branch(:,T_BUS);  % 中止母线

idx_nz = sparse([pf;pt], [pt;pf], ones(2 * NUM.Branch,1), NUM.Bus, NUM.Bus);
delta_ij = delta.*idx_nz-delta'.*idx_nz;
PP = U.*idx_nz.*U' .* (G.*cos(delta_ij)+B.*sin(delta_ij));
QQ = U.*idx_nz.*U' .* (G.*sin(delta_ij)-B.*cos(delta_ij));
Bl = branch(:, BR_B) / 2;

tij = sparse([branch(:,F_BUS),branch(:,T_BUS)], [branch(:,T_BUS),branch(:,F_BUS)],[1./k,k], NUM.Bus,NUM.Bus);
bij0 = sparse([branch(:,F_BUS),branch(:,T_BUS)], [branch(:,T_BUS),branch(:,F_BUS)], [Bl, Bl] , NUM.Bus,NUM.Bus);

Pij = (PP - tij .* G .* (U.^2)) * baseMVA;
Qij = (QQ + (tij .* B - bij0) .* (U.^2)) * baseMVA;
Sij = Pij + 1j * Qij;

%% 线路损耗 (放在了下一节中运算loss)
%% 将 线路功率 和 损耗 封装起来
branch(:,PF) = Pij( (pt-1) * NUM.Bus + pf ); % 列优先方式索引
branch(:,QF) = Qij( (pt-1) * NUM.Bus + pf );
branch(:,PT) = Pij( (pf-1) * NUM.Bus + pt ); 
branch(:,QT) = Qij( (pf-1) * NUM.Bus + pt );

loss = Sij( (pt-1) * NUM.Bus + pf ) + Sij( (pf-1) * NUM.Bus + pt );
% loss = myget_losses(baseMVA, bus, branch);  % 用matpower的方法计算loss

%% --------------------------------------------------------至此，所有计算结束
%% 恢复节点编号
bus(:,BUS_I) = Input_raw.bus(:,BUS_I);
gen(:,GEN_BUS) = Input_raw.gen(:,GEN_BUS);
branch(:,[F_BUS,T_BUS]) = Input_raw.branch(:,[F_BUS,T_BUS]);

%% 判断收敛性，结果打印
BSP_print(bus,gen,branch,full(loss),NL,Type,NUM,PRINT_LENGTH,PF_N_IT,Accuracy)

%% 收敛过程
if UNFIGURE  % 误差变化曲线
    figure('Name','误差变化曲线');
    plot(draw);  % 绘制误差变化曲线
    xlabel('Time');
    ylabel('Per-unit value');
end
% 误差比较
fprintf('幅值误差: %.3e\t',max(max(abs(bus(:,VM)-RUN.bus(:,VM)))));
fprintf('相角误差: %.3e\n',max(max(abs(bus(:,VA)-RUN.bus(:,VA)))));
fprintf('有功误差: %.3e\t',max(max(abs(gen(:,PG)-RUN.gen(:,PG)))));
fprintf('无功误差: %.3e\n',max(max(abs(gen(:,QG)-RUN.gen(:,QG)))));

fprintf('PF误差: %.3e\t',max(max(abs(branch(:,PF)-RUN.branch(:,PF)))));
fprintf('QF误差: %.3e\n',max(max(abs(branch(:,QF)-RUN.branch(:,QF)))));
fprintf('PT误差: %.3e\t',max(max(abs(branch(:,PT)-RUN.branch(:,PT)))));
fprintf('QT误差: %.3e\n',max(max(abs(branch(:,QT)-RUN.branch(:,QT)))));
fprintf('程序耗时: %.3fs\n',time);
% fprintf('导纳矩阵误差: %.3e\n',full(ERR_MAX));