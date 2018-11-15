# Power Flow - Newton Rapson method
Author: Kang-S <https://github.com/Kang-S>

------
## What is this?
* 为了做好读研究生的前期工作，熟悉一下使用MATLAB利用NR法算潮流的方法，熟悉一下使用MATLAB矩阵化运算的特点

## Data Format
* 采用IEEE标准格式，可以用matpower的case直接进行测试

## Process
* 加入`导纳矩阵`，考虑到变压器（非标准变比）
* 加入`功率不平衡量`计算
* 加入`Jacobian矩阵`计算
* 加入`NR`法计算，`电压更新`，实现迭代收敛
* 收敛之后计算各`节点的电压，功率`
* 计算`支路功率`
* 将除了NR迭代大循环以外的for循环全部用`矩阵运算`代替，提高运行效率，目标是**case2383wp计算时间小于0.2s**
* 加入了`移相器`，全部`sparse化`，case2383wp收敛速度控制到了`0.02s`

## Point
* case5  最简化版本，bus的Meg=1，Ang=0，没有变压器
* case14 出现双回路和变压器，Ang不再为0
* case2383wp 出现移相器

## Contact
Email: sunkang.real@qq.com
Email: 1505020117@hhu.edu.cn