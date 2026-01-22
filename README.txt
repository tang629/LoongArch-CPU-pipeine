📝 项目说明：龙芯架构五级流水线处理器实现
🇨🇳 中文版
本项目实现了一个简化版的龙芯架构五级流水线处理器，支持基本的指令执行、数据通路控制、数据冒险与控制冒险处理。项目基于 Xilinx Vivado 平台开发，通过 IP 核加载指令存储器（ROM），可运行简单的汇编程序（如斐波那契计算、数据冒险测试等）。
1. 项目配置说明
开发环境：Xilinx Vivado
核心模块：
五级流水线：取指（IF）、译码（ID）、执行（EX）、访存（MEM）、写回（WB）
指令存储器：使用 dist_mem_gen_0 IP 核实现只读 ROM
ROM 配置：
名称：dist_mem_gen_0
类型：Single Port ROM
数据宽度：32 位
深度：128
初始化文件（.coe）：根据测试需求选择
2. COE 测试文件说明
项目提供多个 .coe 指令文件用于不同场景测试：
simpleDataHazardTest.coe	简单数据冒险测试，验证数据前递（Forwarding）机制	sp = 36, npc = 0
pipelineInitial.coe	流水线初始化测试，无数据冒险，用于验证控制流与流水线传递	sp 无所谓，npc=0
pipelinefib.coe	斐波那契递归计算程序，验证函数调用与栈操作	sp = 255, npc = 100
注意：r3 用作栈指针（sp），r1 用作返回地址（ra）。结果可通过内存查看，例如 fib 程序结果位于 sp - 20 地址处。
3. 仿真支持
使用test.v文件
4. 使用建议
在 Vivado 中创建新项目，添加所有 Verilog 源文件（所有.v但是不包括test.v)
生成 dist_mem_gen_0 IP 核，并加载对应 .coe 文件。
编译并生成比特流，或运行行为仿真。
若需扩展功能，可添加数据内存（RAM）支持、更多指令或异常处理机制。
5.下板子按键说明，sw_i[14]看运行的指令，按下sw_i[1]实现停止后，sw_i[13]看寄存器，sw_i[10:6]是要看的寄存器地址，sw_i[11]看内存，sw_i[10:3]是要看的内存地址，注意必须要播下开关sw_i[1]才能看寄存器和内存
以下是英文版
Here is the optimized English version of your project documentation, formatted for clarity and professionalism. It incorporates the updated details you provided regarding the testbench file and FPGA board switch controls.

📝 Project Description: Loongson-Architecture 5-Stage Pipelined Processor

This project implements a simplified 5-stage pipelined processor based on the Loongson architecture. It supports fundamental instruction execution, data path control, and hazard handling (data and control hazards). Designed for the Xilinx Vivado environment, the processor utilizes an IP-core based ROM to load instructions, enabling the execution of simple assembly programs such as Fibonacci calculations and data hazard tests.

1. Project Configuration

-   Development Environment: Xilinx Vivado
-   Core Modules:
    -   Pipeline Stages: Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), Write Back (WB).
    -   Instruction Memory: Implemented using a ROM IP core.
-   ROM IP Configuration:
    -   Name: dist_mem_gen_0
    -   Type: Single Port ROM
    -   Data Width: 32 bits
    -   Depth: 128
    -   Initialization: Load the .coe file according to the specific test case.

2. COE Test File Specifications

The project includes multiple .coe files for testing different scenarios:
File Name   Function / Description   Recommended Settings
simpleDataHazardTest.coe   Simple data hazard test to verify data forwarding (bypassing) mechanisms.   sp = 36, npc = 0

pipelineInitial.coe   Pipeline initialization test (no data hazards). Used to verify control flow and pipeline stage progression.   sp = Don't care, npc = 0

pipelinefib.coe   Recursive Fibonacci calculation program. Tests function calls, stack operations, and recursion.   sp = 255, npc = 100

Note: Register r3 is used as the stack pointer (sp), and r1 holds the return address (ra). Results can be verified in memory; for the Fibonacci program, check the memory location at sp - 20.

3. Simulation Setup

-   Testbench File: Use the provided test.v file to run behavioral simulations in Vivado or ModelSim.
-   Procedure: Compile the design with test.v as the top module to observe waveforms and verify functionality before FPGA implementation.

4. Implementation Guide

1.  Create a new project in Xilinx Vivado.
2.  Add all Verilog source files (.v files) to the project except test.v (exclude the testbench when generating the bitstream).
3.  Generate the dist_mem_gen_0 IP core and configure it to load the desired .coe file based on your test scenario.
4.  Run synthesis, implementation, and generate the bitstream for FPGA programming.
5. (Optional) Extend functionality by integrating data memory (RAM) support, additional instructions, or exception handling mechanisms.

5. FPGA Board Switch Controls (SW_I)

Once the design is programmed onto the FPGA, use the following switches to control and monitor the system. Note: To view registers or memory, you must first press SW_I[1] to stop the execution.
Switch Range   Function
SW_I[14]   View the currently executing instruction.

SW_I[1]   Press to stop (halt) the processor execution.

SW_I[13]   Enable viewing of registers.

SW_I[10:6]   Selects the register address (0-31) to display when SW_I[13] is active.

SW_I[11]   Enable viewing of memory contents.

SW_I[10:3]   Selects the memory address to display when SW_I[11] is active.

Important: You must toggle SW_I[1] (stop) to freeze the state before checking registers or memory values.