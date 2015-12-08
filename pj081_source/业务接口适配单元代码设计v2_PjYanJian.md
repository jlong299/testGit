# 业务接口适配单元代码设计v2_PjYanJian
@(Work Record)[工作|技术|数据链路层|复分接|业务接口适配]

此版本为version 2改进版

[toc]

## 发送端
### 接口信号
Input :   Data[7:0]   / wren  / wrclk （不需要sop eop）
Output :   Data[0:0] / ena / clkout

### Global Enable Signal 
控制发送端最终输出信号占空比，占空比为定值
方案为了保证严格匹配占空比，在两帧信号之间填充cnst_padding

### 输入FIFO
Input :  Data[7:0]   / wren  / wrclk 
输入数据速率比较快

Output :  Data[7:0] / valid
输出控制:   ena_glb / rden 

> 全局使能信号**ena_glb控制全局占空比**，例如FIFO的rden等
> FIFO深度要求**比较深**，防止突发业务写爆FIFO，因为写入速度快

#### FIFO读取策略
- state 0
如果FIFO余量不小于cnst_len时，进入state 1 ， 记录rd_len = cnst_len
如果FIFO余量小于cnst_len时，非empty时，进入state 1 ， 记录rd_len = 实际余量
empty时，留在state 0
- state 1
读取rd_len个Data[7:0]，并且加入帧头cnst_head，长度rd_len， 后面紧接着rd_len个数据，最后进入state 0

#### 帧结构
帧结构为 Head + Len + Payload
其中Head为32bit帧头: 1ACFFCED
Len为rd_len，16比特。rd_len 小于等于 cnst_len, cnst_len=2048 
Payload ：业务数据

> 写入FIFO时，一定要先确认full为0，或者wrusedw 小于阈值
> 根据fifo数据手册，应该是full变为1的同一个周期wrreq为0，所以使用full作为reset？

编写代码时需要注意：
> FIFO的读使能rden(或者rdreq)在全局占空比使能ena_glb作用下，其产生方式需要重点关注，注意在ena_glb=0时也要保证rdreq=0

### 加入填充
在FIFO输出的两段有效数据之间加入填充cnst_padding : 74

### 并串转换8转1
通过FIFO转为1bit数据给调制器
FIFO的读写使能都是ena_glb的占空比，但是时钟是8倍关系
> 保证FIFO不溢出，需要思考FIFO的深度 

## 接收端
### 帧头锁定
长度为略大于32的1比特移位寄存器，输入为解调数据。当其与帧头cnst_head完全匹配时，置hit_head=1。

### 拆包模块
实现去除padding、帧头cnst_head、和长度域rd_len功能
- state 0
接收到帧头锁定信号hit_head后，进入 state 1
- state 1
读出rd_len字段，按照该长度读出接下来的数据，结束后转为state 0

拆包模块输出符合要求


## 补充：代码文件名称
文件夹 pj081_source 下
**data2flow_pj081.vhd**    (TX)
**flow2data_pj081.vhd**    (RX)
ff_tx_pj081.vhd
ff_8to1_pj081.vhd
ff_1to8_pj081.vhd
**ena_global_pj081.vhd**   (Global enable for TX)