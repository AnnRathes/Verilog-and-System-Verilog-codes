

`timescale 1ns/1ps

module tb_TM_ALU;

  	reg clk, reset; // reset = active HIGH
  	reg [7:0] AvgTxLen, InstExed, CurTxLen;
  	wire [7:0] AvgTxLen_new, InstExed_new;
	integer z;
  	

  	initial
		clk = 1'b0;
  	always
		#2.5 clk = ~clk;
	initial begin
		z = $fopen("traffic_control.out","w");
		$fmonitor (z, "Time = %g ns, clk = %b, reset = %b, AvgTxLen = %b, InstExed = %b, CurTxLen = %b, AvgTxLen_new = %b, InstExed_new = %b ", $time, clk, reset, AvgTxLen, InstExed, CurTxLen, AvgTxLen_new, InstExed_new);
		reset = 1;
		#5; 
		reset = 0; AvgTxLen = 8'd32; InstExed = 8'd5; CurTxLen = 8'd64;
		#50;
		reset = 0; AvgTxLen = 8'd64; InstExed = 8'd25; CurTxLen = 8'd77;

		#50 
		$finish;
		$fclose(z);
	end

  	TM_ALU inst1(clk, reset, AvgTxLen, InstExed, CurTxLen, AvgTxLen_new, InstExed_new);

endmodule
