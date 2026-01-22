`timescale 1ps / 1ps

module tb_sccomp;

// DUT �ӿ�
reg clk;
reg rstn;
reg [15:0] sw_i;
wire [7:0] disp_seg_o;
wire [7:0] disp_an_o;

// ʱ������
always begin
    #1 clk = ~clk; // 100 MHz (10 ns period)
end

// �����Թ���
initial begin
    // ��ʼ��
    clk = 0;
    rstn = 0;
    sw_i = 16'h0100; // Ĭ�ϣ���ʾ ALU �������������ģ�?

    // ��λ
    #20 rstn = 1;

    // �� CPU ����һ��ʱ�䣨���� 1000 �����ڣ�
    repeat (200000) @(posedge clk);

    // ��ѡ���л���ʾģʽ�鿴�Ĵ���/�ڴ�


    $display("Simulation finished.");
    $finish;
end

// ʵ���� DUT
sccomp uut (
    .clk(clk),
    .rstn(rstn),
    .sw_i(sw_i),
    .disp_seg_o(disp_seg_o),
    .disp_an_o(disp_an_o)
);


endmodule