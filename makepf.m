% function makepf(casedata)
% %makepf 主程序：相当于MATPOWER的runpf
% if nargin < 1
%     clear
%     close all
%     casedata = case0;
% end
% % vision 2.0: 加入节点重新编号
%% TEMP TEST: 临时调试代码
clc
clear
close all
casedata = case300;

%% 环境初始化
addpath ('./BSP', './Index', './Reference','./Recorde'); % 函数链接
run BSP_Initial.m
print_title(PRINT_LENGTH, 1, '正在运行 IEEE %d',NUM.Bus)
tic

%% 导纳矩阵生成
% [Y, G, B] = BSP_MakeY(Input);
[Y, G, B, y] = BSP_MakeY(Input);  % 形成导纳矩阵
if UNDISPLAY  % 导纳矩阵显示
    print_title(PRINT_LENGTH,6,'导纳矩阵');
    disp(Y);
end

%% 判断导纳矩阵误差值
if DISPLAY  % 导纳矩阵误差值计算和显示
    ERR_MAX = max(max(abs( Y - full(makeYbus(baseMVA, bus, branch)) )));  % 误差值
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
%% 节点注入功率 Pre Value ---------------------每一个节点的Sis，和手算结果一致
% 节点重新编号后的版本，也就是母线的节点编号是连续的，比如1~300
Pis = -bus(:, PD);  % 负荷节点 消耗功率为负数 (MW, MVar)
Qis = -bus(:, QD);
for i = 1: NUM.Gen   % 每个节点加上发电机的 输入功率 (没有分节点的类型)
    Pis(gen(i, GEN_BUS)) = Pis(gen(i, GEN_BUS)) + gen(i, PG);
    Qis(gen(i, GEN_BUS)) = Qis(gen(i, GEN_BUS)) + gen(i, QG);
end

%% 功率不平衡量 Calculate Value
[ NL.fx,dP,dQ,Pi,Qi ] = BSP_Unbalanced( baseMVA,Pis,Qis,U,G,B,delta, PLC,NUM );
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
    [ NL.Jacobian ] = BSP_Jacobian( U,delta,G,B,Pi,Qi, PLC,NUM );
%     [NL.Jacobian] = dS_dV(Y, U, PLC);  % matpower求Jacobian矩阵的方法    
    %% 牛拉法 核心公式
    % ┌ ΔP ┐  _   ┌ H N ┐ ┌  Δδ  ┐
    % └ ΔQ ┘  ─   └ K L ┘ └ ΔU/U ┘    
    NL.x = -inv(NL.Jacobian) * NL.fx; % 牛拉法关键公式算出 dU，需要将其转换到原来的顺序    
    %% 电压状态更新
    [U,delta] = BSP_Updata( U,delta,NL.x,PLC,NUM );   
    %% 功率不平衡量
    [ NL.fx,dP,dQ,Pi,Qi ] = BSP_Unbalanced( baseMVA,Pis,Qis,U,G,B,delta, PLC,NUM );
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


%% 节点电压数据
bus(:,[VM, VA]) = [U,(delta*180/pi)];  % 把电压和相角更新到bus矩阵中

%% 节点功率数据 （只有平衡节点的PQ，PV节点的Q可以变化）
% BLC节点加上 ΔP 和 ΔQ
dS = -[dP,dQ]*baseMVA; % 注意有一个节点上接了两个发电机的情况(为什么是-号，我也不太清楚)
gen_BLC = gen(:,GEN_BUS) == bus(PLC.BL,BUS_I);  % 找到gen中BLC节点的位置（行数）
gen(gen_BLC,[PG, QG]) = gen(gen_BLC,[PG, QG]) + dS(PLC.BL); % 平衡节点的ΔP和ΔQ加上去 *
% PV节点加上 ΔQ
idx_dQ = abs(dS(:,2)) > 1e-5;  % 找到dS中ΔQ的位置（包括PV节点和BLC节点）
% [is,pos]=ismember(B,A) pos是B中元素如果在A中出现，出现的位置 (非logical)
[~,gen_PV] = ismember(bus(PLC.PV,BUS_I),gen(:,GEN_BUS)); % 找到gen中PV节点的位置（行数）
gen(gen_PV,QG) = gen(gen_PV,QG) + dS(PLC.PV, 2); % PV节点的ΔQ加上去

%% 将电压转化为复数的形式u = e + jf
u = U.*cos(delta) + 1j * U.*sin(delta);
%% 计算平衡节点的功率和线路功率 （前面直接把ΔP和ΔQ加上去结果似乎是对的）
% for j = 1:NUM.Bus
%     Sn_temp(j) = u(NUM.Bus)*conj(Y(NUM.Bus,j))*conj(u(j)); % conj函数用于求共轭
% end
% Sn = sum(Sn_temp);
% disp('*平衡节点功率 Sn');
% disp(Sn);

%% 线路功率
S = zeros(NUM.Bus); % 预分配内存
for i=1:NUM.Bus  % S_ij 和 S_ji不一定相同，也就是矩阵不一定对称
    for j=1:NUM.Bus
		S(i,j) = u(i)*(conj(u(i)) * conj(y(i,i)) + (conj(u(i)) - conj(u(j))) * conj(y(i,j)));
    end
end
S = - S * baseMVA;

%% 线路损耗
for i=1:NUM.Bus  % S_ij 和 S_ji不一定相同，也就是矩阵不一定对称
    for j=1:NUM.Bus
		dS(i,j) = S(i,j) + S(j,i);
    end
end
% dS = S + S';
%% 将 线路功率 和 损耗 封装起来
pf = branch(:,F_BUS);  % 起始母线
pt = branch(:,T_BUS);  % 中止母线
branch = [branch,zeros(NUM.Branch, 4)]; % 增加四列存放线路功率
loss = zeros(NUM.Branch, 1);
for i = 1 : NUM.Branch
    branch(i,PF) = real( S( pf(i), pt(i) ) );
    branch(i,QF) = imag( S( pf(i), pt(i) ) );
    branch(i,PT) = real( S( pt(i), pf(i) ) );
    branch(i,QT) = imag( S( pt(i), pf(i) ) );
    loss(i) = dS( pt(i), pf(i) );
end
%% --------------------------------------------------------至此，所有计算结束
%% 恢复节点编号
bus(:,BUS_I) = Input_raw.bus(:,BUS_I);
gen(:,GEN_BUS) = Input_raw.gen(:,GEN_BUS);
branch(:,[F_BUS,T_BUS]) = Input_raw.branch(:,[F_BUS,T_BUS]);
%% 判断收敛性，结果打印
BSP_print(bus,gen,branch,loss,NL,Type,NUM,PRINT_LENGTH,PF_N_IT,Accuracy); % 收敛性判断以及结果输出
%% 
toc
if FIGURE  % 误差变化曲线
    figure('Name','误差变化曲线');
    plot(draw);  % 绘制误差变化曲线
    xlabel('Time');
    ylabel('Per-unit value');
end
