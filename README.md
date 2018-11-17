# Power Flow - Newton Rapson method
Author: Kang-S [Click to Follow](https://github.com/Kang-S "My Github")

------
## What is this?
* 为了做好读研究生的前期工作，熟悉一下使用MATLAB利用NR法算潮流的方法，熟悉一下使用MATLAB矩阵化运算的特点以及稀疏技术

## Prospectus
* **makepf.m** 程序主程序，在这个makepf的目录下运行
* **BSP**  程序的各个子函数
    - *MakeY : 形成导纳矩阵*
    - *Unbalanced: 功率不平衡量的计算*
    - *Sis: 计算节点注入功率Pis和Qis*
    - *Jacobian: 极坐标形成雅可比矩阵*
    - *FastJacobian: 利用复功率形成雅可比矩阵（极速）*
    - *solve: NR公式的计算*
    - *Updata: 节点电压更新*
    - **print_title: 输出标题的标准格式控制*
    - *print: 打印最后的结果*
* **Index**: 三个矩阵的内容索引（bus，branch，generator）
* **Recorde**: 非关键内容，调试中间过程记录，不属于程序内容
* **Reference**: 非关键内容,调试过程中和自己的程序进行比较，是一些比较好的算法的记录
* **README**: 项目的说明

## Data Format
* 采用IEEE标准格式，可以用`matpower`的`case`直接进行测试

## Point
* case5  最简化版本，bus的Meg=1，Ang=0，没有变压器
* case14 出现变压器，Ang不再为0
* case57 出现双回路，可能会对支路功率的计算产生影响(如果处理不好，可能也会影响导纳矩阵的计算)
* case2383wp 出现移相器（非标准变比变为复数）

## Process
* 加入`导纳矩阵`，考虑到变压器（非标准变比）
* 加入`功率不平衡量`计算
* 加入`Jacobian矩阵`计算
* 加入`NR`法计算，`电压更新`，实现迭代收敛
* 收敛之后计算各`节点的电压，功率`
* 计算`支路功率`，但是QF和QT有非常大的误差
* 将除了NR迭代大循环以外的for循环全部用`矩阵运算`代替，提高运行效率，目标是**case2383wp计算时间小于0.2s**
* 加入了`移相器`，全部`sparse化`，case2383wp收敛速度控制到了`0.02s`
* 发现了`matpower`中使用的`导纳矩阵模型`和我的不一样，根据matpower的形式进行了修改
    - 两边的对地导纳分别是： 
    $$Bl_{from} \quad 和 \quad (\frac{1} {kk^{*}} .* Bl)_{to} $$

* 加入了`支路功率`的计算，但是没有解决`双回路`的问题

## Contact
Email: sunkang.real@qq.com
Email: 1505020117@hhu.edu.cn
Email: sunnnnnnnk@gmail.com