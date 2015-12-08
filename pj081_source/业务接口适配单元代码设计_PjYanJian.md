# 业务接口适配单元代码设计_PjYanJian
@(Work Record)[工作|技术|数据链路层|复分接|业务接口适配]

[toc]

## 发送端
### 接口信号
Input :   Data[7:0]   / wren / sop / eop / wrclk （不需要sop eop）
Output :   Data[0:0] / ena / clkout

### Global Enable Signal 


### 输入FIFO
Input :  Data[7:0]   / wren / sop / eop / wrclk （不需要sop eop）
输入数据速率比较快，用sop, eop 代表一帧的起始和结束位置

Output :  Data[7:0] / valid
输出控制:   ena_glb / rden / sop / eop （不需要sop eop）

> 全局使能信号**ena_glb控制全局占空比**，例如FIFO的rden等
> FIFO深度要求**比较深**，防止突发业务写爆FIFO，因为写入速度快

#### FIFO读取策略
- state 1 
如果FIFO余量不小于cnst_len时，进入state 2 ， 记录rd_len = cnst_len
如果FIFO余量小于cnst_len时，非empty时，进入state 2 ， 记录rd_len = 实际余量
empty时，留在state 1
- state 2
读取rd_len个Data[7:0]，并且加入帧头cnst_head，长度rd_len， 后面紧接着rd_len个数据，最后进入state 0
- state 0
等待若干保护间隔周期，计入state 1

> 写入FIFO时，一定要先确认full为0
> 根据fifo数据手册，应该是full变为1的同一个周期wrreq为0，所以使用full作为reset？

编写代码时需要注意：
> FIFO的读使能rden(或者rdreq)在全局占空比使能ena_glb作用下，其产生方式需要重点关注，注意在ena_glb=0时也要保证rdreq=0

### 加入填充
在FIFO输出的两段有效数据之间加入填充cnst_padding

### 并串转换8转1
通过FIFO转为1bit数据给调制器
FIFO的读写使能都是ena_glb的占空比，但是时钟是8倍关系
> 保证FIFO不溢出，需要思考FIFO的深度 

## 接收端
### 串并转换 1转8
通过FIFO转为8bit数据
### 8比特数据移位操作
根据后级的拆包模块提供的shift[2:0]选择移位比特数
### 拆包模块
实现去除padding、帧头cnst_head、和长度域rd_len功能
- state 0
接收到padding后，进入 state 1
计数器计数到thd_padding_lost时，如果仍没收到padding，则shift[2:0]加1
- state 1
读取到帧头cnst_head后，进入state 2 
判断padding 较多缺失时，转入state 0
- state 2
读出rd_len字段，按照该长度读出接下来的数据，结束后转为state 1

拆包模块输出符合要求
> 上面state1中的判断padding 较多缺失的逻辑，可以用计数器实现。padding匹配+1, 否则-1，超过阈值认为padding 较多缺失

## 缺陷
一个主要的缺陷是，当发送业务源为特定帧时（例如全部由帧头和填充组成的帧），并且业务量几乎达到上限时，拆包模块可能会出错。
简单的修改方法可以将帧头加长。
稍微复杂的方法可加扰码，并且扰码可变，帧头域含一个递增序列作为扰码初始相位。

## 补充：代码文件名称
文件夹 pj081_source 下
**data2flow_pj081.vhd**    (TX)
**flow2data_pj081.vhd**    (RX)
ff_tx_pj081.vhd
ff_8to1_pj081.vhd
ff_1to8_pj081.vhd
**ena_global_pj081.vhd**   (Global enable for TX)

## 改进版本2
