

module TM_ALU (clk, reset, AvgTxLen, InstExed, CurTxLen, AvgTxLen_new, InstExed_new);

input clk, reset;
input [7:0] AvgTxLen, InstExed, CurTxLen;
output [7:0] AvgTxLen_new, InstExed_new;

wire [15:0] mult_out;
wire [16:0] add_out;
wire [7:0] div_out;
wire [7:0] add_InstExed;

reg [23:0] pr1Data;
reg [31:0] pr2Data;
reg [23:0] pr3Data;
reg [15:0] pr4Data;

always @(posedge clk or posedge reset) begin
  if(reset) begin
    pr1Data <= 0;
    pr2Data <= 0;
    pr3Data <= 0;
	pr4Data <= 0;
  end
  else begin
    pr1Data <= {AvgTxLen, InstExed, CurTxLen};
    pr2Data <= {mult_out, pr1Data[15:8], pr1Data[7:0]};
    pr3Data <= {add_out, add_InstExed};
	pr4Data <= {div_out, pr3Data[7:0]};
  end
end

assign mult_out = pr1Data[23:16] * pr1Data[15:8];
assign add_out = pr2Data[31:16] + pr2Data[7:0];
assign add_InstExed = pr2Data[15:8] + 1'b1;
assign div_out = pr3Data[23:8] / pr3Data[7:0];
assign AvgTxLen_new = pr4Data[15:8];
assign InstExed_new = pr4Data[7:0];

endmodule