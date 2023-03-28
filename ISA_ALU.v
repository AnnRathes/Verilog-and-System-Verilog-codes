//Verilog code for all arthimatic R-type instruction supported for Given ISA to implement Cardinal processor

module ISA_ALU (data_in_op_A, data_in_op_B, func_code, ww, data_out_alu);

input [0:63] data_in_op_A, data_in_op_B;
input [0:5] func_code; 
input [0:1] ww;
input [0:63] data_out_alu;

////////////////////////////////////////
parameter DATA_WIDTH = 64;
parameter TC = 1'b0; // 0: means operands are unsigned number, 1: signed number operands

//R-TYPE fuction list
 parameter VAND = 6'b000001;
 parameter VOR = 6'b000010;
 parameter VXOR = 6'b000011;
 parameter VNOT = 6'b000100;
 parameter VMOV = 6'b000101; // only carry di_A to output
 parameter VADD = 6'b000110;
 parameter VSUB = 6'b000111;
 parameter VMULEU = 6'b001000;
 parameter VMULOU = 6'b001001;
 parameter VSLL = 6'b001010;
 parameter VSRL = 6'b001011;
 parameter VSRA = 6'b001100;
 parameter VRTTH = 6'b001101;
 parameter VDIV = 6'b001110;
 parameter VMOD = 6'b001111; 
 parameter VSQEU = 6'b010000;
 parameter VSQOU = 6'b010001;
 parameter VSQRT = 6'b010010;
 
 //Participation field select mode
 parameter ww_b = 2'b00; // byte mode
 parameter ww_h = 2'b01; // half word mode
 parameter ww_w = 2'b10; // word mode
 parameter ww_d = 2'b11; // double word mode
 
 
 /////////////////////////////////////////////
 //Addition and Subtarction
 wire [0:7] cin, cout;
 wire add_or_sub; //0:add , 1:sub
 wire [0:63] add_or_sub_out;
 
 assign add_or_sub = (func_code == VADD)? 1'b0:1'b1;
  
  //WW=Byte 
 DW01_addsub #(.width(8)) addsub0
    (
        .A(data_in_op_A[0:7]),
        .B(data_in_op_B[0:7]),
        .CI(cin[0]),
        .CO(cout[0]),
        .ADD_SUB(add_or_sub),
        .SUM(add_or_sub_out[0:7])
    );
 DW01_addsub #(.width(8)) addsub1
    (
        .A(data_in_op_A[8:15]),
        .B(data_in_op_B[8:15]),
        .CI(cin[1]),
        .CO(cout[1]),
        .ADD_SUB(add_or_sub),
        .SUM(add_or_sub_out[8:15])
    );
 DW01_addsub #(.width(8)) addsub2
    (
        .A(data_in_op_A[16:23]),
        .B(data_in_op_B[16:23]),
        .CI(cin[2]),
        .CO(cout[2]),
        .ADD_SUB(add_or_sub),
        .SUM(add_or_sub_out[16:23])
    );
 DW01_addsub #(.width(8)) addsub3
    (
        .A(data_in_op_A[24:31]),
        .B(data_in_op_B[24:31]),
        .CI(cin[3]),
        .CO(cout[3]),
        .ADD_SUB(add_or_sub),
        .SUM(add_or_sub_out[24:31])
    );
 DW01_addsub #(.width(8)) addsub4
    (
        .A(data_in_op_A[32:39]),
        .B(data_in_op_B[32:39]),
        .CI(cin[4]),
        .CO(cout[4]),
        .ADD_SUB(add_or_sub),
        .SUM(add_or_sub_out[32:39])
    );
 DW01_addsub #(.width(8)) addsub5
    (
        .A(data_in_op_A[40:47]),
        .B(data_in_op_B[40:47]),
        .CI(cin[5]),
        .CO(cout[5]),
        .ADD_SUB(add_or_sub),
        .SUM(add_or_sub_out[40:47])
    );
 DW01_addsub #(.width(8)) addsub6
    (
        .A(data_in_op_A[48:55]),
        .B(data_in_op_B[48:55]),
        .CI(cin[6]),
        .CO(cout[6]),
        .ADD_SUB(add_or_sub),
        .SUM(add_or_sub_out[48:55])
    );
 DW01_addsub #(.width(8)) addsub7
    (
        .A(data_in_op_A[56:63]),
        .B(data_in_op_B[56:63]),
        .CI(cin[7]),
        .CO(cout[7]),
        .ADD_SUB(add_or_sub),
        .SUM(add_or_sub_out[56:63])
    );
	
	assign cin[0] = (ww == ww_b) ? 1'b0 : cout[1];
    assign cin[1] = ((ww == ww_b) || (ww == ww_h)) ? 1'b0 : cout[2];
    assign cin[2] = (ww == ww_b) ? 1'b0 : cout[3];
    assign cin[3] = ((ww == ww_b) || (ww == ww_h) || (ww == ww_w)) ? 1'b0 : cout[4];
    assign cin[4] = (ww == ww_b) ? 1'b0 : cout[5];
    assign cin[5] = ((ww == ww_b) || (ww == ww_h)) ? 1'b0 : cout[6];
    assign cin[6] = (ww == ww_b) ? 1'b0 : cout[7];
    assign cin[7] = 1'b0;
	
 
 /////////////////////////////////
 // Multiplication and squareroot
 
 reg [0:31] mul_A, mul_B;
 
	always @(*) begin
	
		mul_A = 32'bx;
		mul_B = 32'bx;
		
		case(func_code)
			VMULEU:
			VSQEU:
				begin
					case(ww)
						ww_b:
							begin
								mul_A = {data_in_op_A[0:7],data_in_op_A[16:23]data_in_op_A[32:39],data_in_op_A[48:55]};
								mul_B = {data_in_op_B[0:7],data_in_op_B[16:23]data_in_op_B[32:39],data_in_op_B[48:55]};
							end
						ww_h:
							begin
								mul_A = {data_in_op_A[0:15],data_in_op_A[32:47]};
								mul_B = {data_in_op_B[0:15],data_in_op_B[32:47]};
							end
						ww_w:
							begin
								mul_A = data_in_op_A[0:32];
								mul_B = data_in_op_B[0:32];
							end
					endcase
				end
				
			VMULOU:
			VSQOU:
				begin
					case(ww)
						ww_b:
							begin
								mul_A = {data_in_op_A[8:15],data_in_op_A[24:31]data_in_op_A[40:47],data_in_op_A[56:63]};
								mul_B = {data_in_op_B[8:15],data_in_op_B[24:31]data_in_op_B[40:47],data_in_op_B[56:63]};
							end
						ww_h:
							begin
								mul_A = {data_in_op_A[16:31],data_in_op_A[48:63]};
								mul_B = {data_in_op_B[16:31],data_in_op_B[48:63]};
							end
						ww_w:
							begin
								mul_A = data_in_op_A[32:63];
								mul_B = data_in_op_B[32:63];
							end
					endcase
				end
			
		endcase
		
	end
 
 //Multiplication module call
 wire [0:63] mul_b_out, mul_h_out, mul_w_out;
 
 //WW=Byte 
 DW02_mult #(.A_width(8), .B_width(8)) mul_b0
    (
        .A(mul_A[0:7]),
        .B(mul_B[0:7]),
        .TC(TC),
        .PRODUCT(mul_b_out[0:15])
    );
 DW02_mult #(.A_width(8), .B_width(8)) mul_b1
    (
        .A(mul_A[8:15]),
        .B(mul_B[8:15]),
        .TC(TC),
        .PRODUCT(mul_b_out[16:31])
    );
 DW02_mult #(.A_width(8), .B_width(8)) mul_b2
    (
        .A(mul_A[16:23]),
        .B(mul_B[16:23]),
        .TC(TC),
        .PRODUCT(mul_b_out[32:47])
    );
 DW02_mult #(.A_width(8), .B_width(8)) mul_b3
    (
        .A(mul_A[24:31]),
        .B(mul_B[24:31]),
        .TC(TC),
        .PRODUCT(mul_b_out[48:63])
    );
	
//WW=H
DW02_mult #(.A_width(16), .B_width(16)) mul_h0
    (
        .A(mul_A[0:15]),
        .B(mul_B[0:15]),
        .TC(TC),
        .PRODUCT(mul_h_out[0:31])
    );
 DW02_mult #(.A_width(16), .B_width(16)) mul_h1
    (
        .A(mul_A[16:31]),
        .B(mul_B[16:31]),
        .TC(TC),
        .PRODUCT(mul_h_out[32:63])
    );
	
//WW=WW
 DW02_mult #(.A_width(32), .B_width(32)) mul_w
    (
        .A(mul_A[0:31]),
        .B(mul_B[0:31]),
        .TC(TC),
        .PRODUCT(mul_w_out[0:63])
    );
 
 
 ///////////////////////////////////////////////
 //shift right/left logic
 //// The length of shift_value should be Log2(data_width) + 1
 //for ww=8b : log2(8)+1=4
 reg [0:3] shift_b0, shift_b1, shift_b2, shift_b3, shift_b4, shift_b5, shift_b6, shift_b7;
 //for ww=16h : log2(16)+1=5
 reg [0:4] shift_h0, shift_h1, shift_h2, shift_h3;
 //for ww=32w : log2(32)+1=6
 reg [0:5] shift_w0, shift_w1;
 //for ww=64d : log2(64)+1=7
 reg [0:6] shift_d;
 
	always @(*) begin
		shift_b0 = 4'bx;
		shift_b1 = 4'bx;
		shift_b2 = 4'bx;
		shift_b3 = 4'bx;
		shift_b4 = 4'bx;
		shift_b5 = 4'bx;
		shift_b6 = 4'bx;
		shift_b7 = 4'bx;
		
		shift_h0 = 5'bx;
		shift_h1 = 5'bx;
		shift_h2 = 5'bx;
		shift_h3 = 5'bx;
		
		shift_w0 = 6'bx;
		shift_w1 = 6'bx;
		
		shift_d  = 7'bx;
		
		if(func_code == VSLL) begin
			case(ww)
			ww_b:
				begin
						shift_b0 = {1'b0,data_in_op_B[5:7]};
						shift_b1 = {1'b0,data_in_op_B[13:15]};
						shift_b2 = {1'b0,data_in_op_B[21:23]};
						shift_b3 = {1'b0,data_in_op_B[29:31]};
						shift_b4 = {1'b0,data_in_op_B[37:39]};
						shift_b5 = {1'b0,data_in_op_B[45:47]};
						shift_b6 = {1'b0,data_in_op_B[53:55]};
						shift_b7 = {1'b0,data_in_op_B[61:63]};					
				end
			ww_h:
				begin
						shift_h0 = {1'b0, di_B[12:15]};
						shift_h0 = {1'b0, di_B[28:31]};
						shift_h0 = {1'b0, di_B[44:47]};
						shift_h0 = {1'b0, di_B[60:63]};
				end
			ww_w:
				begin
						shift_w0 = {1'b0, di_B[27:31]};
						shift_w1 = {1'b0, di_B[59:63]};
				end
			ww_d:		shift_d  = {1'b0, di_B[58:63]};
			endcase
		end
		
		else if(func_code == VSRL) begin
			case(ww)
			ww_b:
				begin
						shift_b0 = ({1'b0,data_in_op_B[5:7]}  ^ 4'b1111) + 1;
						shift_b1 = ({1'b0,data_in_op_B[13:15]}^ 4'b1111) + 1;
						shift_b2 = ({1'b0,data_in_op_B[21:23]}^ 4'b1111) + 1;
						shift_b3 = ({1'b0,data_in_op_B[29:31]}^ 4'b1111) + 1;
						shift_b4 = ({1'b0,data_in_op_B[37:39]}^ 4'b1111) + 1;
						shift_b5 = ({1'b0,data_in_op_B[45:47]}^ 4'b1111) + 1;
						shift_b6 = ({1'b0,data_in_op_B[53:55]}^ 4'b1111) + 1;
						shift_b7 = ({1'b0,data_in_op_B[61:63]}^ 4'b1111) + 1;					
				end
			ww_h:
				begin
						shift_h0 = ({1'b0, di_B[12:15]}^ 4'b1111) + 1;
						shift_h0 = ({1'b0, di_B[28:31]}^ 4'b1111) + 1;
						shift_h0 = ({1'b0, di_B[44:47]}^ 4'b1111) + 1;
						shift_h0 = ({1'b0, di_B[60:63]}^ 4'b1111) + 1;
				end
			ww_w:
				begin
						shift_w0 = ({1'b0, di_B[27:31]}^ 4'b1111) + 1;
						shift_w1 = ({1'b0, di_B[59:63]}^ 4'b1111) + 1;
				end                                   
			ww_d:		shift_d  = ({1'b0, di_B[58:63]}^ 4'b1111) + 1;
			endcase
		end
		
	end
 
 wire data_tc; 
 assign data_tc = (func_code == VSRA) ? 1'b1 : 1'b0;
 
 wire [0:63] shif_b_out, shif_h_out, shif_w_out, shif_d_out; // outputs

DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shift_b0
    (
        .data_in(data_in_op_A[0:7]),
        .data_tc(data_tc),
        .sh(shift_b0),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shif_b_out[0:7])
    );
DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shift_b1
    (
        .data_in(data_in_op_A[8:15]),
        .data_tc(data_tc),
        .sh(shift_b1),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shif_b_out[8:15])
    );
 DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shift_b2
    (
        .data_in(data_in_op_A[16:23]),
        .data_tc(data_tc),
        .sh(shift_b2),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shif_b_out[16:23])
    );
 DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shift_b3
    (
        .data_in(data_in_op_A[24:31]),
        .data_tc(data_tc),
        .sh(shift_b3),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shif_b_out[24:31])
    );
 DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shift_b4
    (
        .data_in(data_in_op_A[32:39]),
        .data_tc(data_tc),
        .sh(shift_b4),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shif_b_out[32:39])
    );
 DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shift_b5
    (
        .data_in(data_in_op_A[40:47]),
        .data_tc(data_tc),
        .sh(shift_b5),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shif_b_out[40:47])
    );
DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shift_b6
    (
        .data_in(data_in_op_A[48:55]),
        .data_tc(data_tc),
        .sh(shift_b6),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shif_b_out[48:55])
    );
DW_shifter #(
        .data_width(8),
        .sh_width(4), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shift_b7
    (
        .data_in(data_in_op_A[56:63]),
        .data_tc(data_tc),
        .sh(shift_b7),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shif_b_out[56:63])
    );
 
 //for ww=16h
 DW_shifter #(
        .data_width(16),
        .sh_width(5), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shift_h0
    (
        .data_in(data_in_op_A[0:15]),
        .data_tc(data_tc),
        .sh(shift_h0),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shif_h_out[0:15])
    );
DW_shifter #(
        .data_width(16),
        .sh_width(5), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shift_h1
    (
        .data_in(data_in_op_A[16:31]),
        .data_tc(data_tc),
        .sh(shift_h1),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shif_h_out[16:31])
    );
DW_shifter #(
        .data_width(16),
        .sh_width(5), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shift_h2
    (
        .data_in(data_in_op_A[32:47]),
        .data_tc(data_tc),
        .sh(shift_h2),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shif_h_out[32:47])
    );
DW_shifter #(
        .data_width(16),
        .sh_width(5), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shift_h3
    (
        .data_in(data_in_op_A[48:63]),
        .data_tc(data_tc),
        .sh(shift_h3),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shif_h_out[48:63])
    );
 
 
 // for ww=32w
  //    For word mode:
DW_shifter #(
        .data_width(32),
        .sh_width(6), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shift_w0
    (
        .data_in(data_in_op_A[0:31]),
        .data_tc(data_tc),
        .sh(shift_w0),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shif_w_out[0:31])
    );
DW_shifter #(
        .data_width(32),
        .sh_width(6), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shift_w1
    (
        .data_in(data_in_op_A[32:63]),
        .data_tc(data_tc),
        .sh(shift_w1),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shif_w_out[32:63])
    );
 
 //for ww=64d
DW_shifter #(
        .data_width(64),
        .sh_width(7), // Log2(data_width) + 1
        .inv_mode(0) // 0 = normal input, 0 padding in output
    )
    DW_shift_d
    (
        .data_in(data_in_op_A[0:63]),
        .data_tc(data_tc),
        .sh(shift_d),
        .sh_tc(1'b1), // 1 = signed sh
        .sh_mode(1'b1), // 1 = arithmetic shift mode
        .data_out(shif_d_out[0:63])
    ); 
 
////////////////////////////////////////////
//division and mode

wire [0:63] quotient_b, quotient_h, quotient_w, quotient_d, remainder_b, remainder_h, remainder_w, remainder_d;
wire [0:63] dividend, divisor;

assign  dividend = data_in_op_A;
assign  divisor = data_in_op_B;
 //    For byte mode:
    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b0
    (
        .a(dividend[0:7]),
        .b(divisor[0:7]),
        .quotient(quotient_b[0:7]),
        .remainder(remainder_b[0:7]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b1
    (
        .a(dividend[8:15]),
        .b(divisor[8:15]),
        .quotient(quotient_b[8:15]),
        .remainder(remainder_b[8:15]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b2
    (
        .a(dividend[16:23]),
        .b(divisor[16:23]),
        .quotient(quotient_b[16:23]),
        .remainder(remainder_b[16:23]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b3
    (
        .a(dividend[24:31]),
        .b(divisor[24:31]),
        .quotient(quotient_b[24:31]),
        .remainder(remainder_b[24:31]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b4
    (
        .a(dividend[32:39]),
        .b(divisor[32:39]),
        .quotient(quotient_b[32:39]),
        .remainder(remainder_b[32:39]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b5
    (
        .a(dividend[40:47]),
        .b(divisor[40:47]),
        .quotient(quotient_b[40:47]),
        .remainder(remainder_b[40:47]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b6
    (
        .a(dividend[48:55]),
        .b(divisor[48:55]),
        .quotient(quotient_b[48:55]),
        .remainder(remainder_b[48:55]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(8),
        .b_width(8),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_b7
    (
        .a(dividend[56:63]),
        .b(divisor[56:63]),
        .quotient(quotient_b[56:63]),
        .remainder(remainder_b[56:63]),
        .divide_by_0()
    );

    //    For half word mode:
    DW_div #(
        .a_width(16),
        .b_width(16),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_h0
    (
        .a(dividend[0:15]),
        .b(divisor[0:15]),
        .quotient(quotient_h[0:15]),
        .remainder(remainder_h[0:15]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(16),
        .b_width(16),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_h1
    (
        .a(dividend[16:31]),
        .b(divisor[16:31]),
        .quotient(quotient_h[16:31]),
        .remainder(remainder_h[16:31]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(16),
        .b_width(16),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_h2
    (
        .a(dividend[32:47]),
        .b(divisor[32:47]),
        .quotient(quotient_h[32:47]),
        .remainder(remainder_h[32:47]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(16),
        .b_width(16),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_h3
    (
        .a(dividend[48:63]),
        .b(divisor[48:63]),
        .quotient(quotient_h[48:63]),
        .remainder(remainder_h[48:63]),
        .divide_by_0()
    );

    //    For word mode:
    DW_div #(
        .a_width(32),
        .b_width(32),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_w0
    (
        .a(dividend[0:31]),
        .b(divisor[0:31]),
        .quotient(quotient_w[0:31]),
        .remainder(remainder_w[0:31]),
        .divide_by_0()
    );

    DW_div #(
        .a_width(32),
        .b_width(32),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_w1
    (
        .a(dividend[32:63]),
        .b(divisor[32:63]),
        .quotient(quotient_w[32:63]),
        .remainder(remainder_w[32:63]),
        .divide_by_0()
    );

    //    For double word mode:
    DW_div #(
        .a_width(64),
        .b_width(64),
        .tc_mode(TC),
        .rem_mode(0) // we want to do mod instaed of rem operation
    )
    DW_div_d
    (
        .a(dividend[0:63]),
        .b(divisor[0:63]),
        .quotient(quotient_d[0:63]),
        .remainder(remainder_d[0:63]),
        .divide_by_0()
    );
 
 ///////////////////////////////////////////////////
 //Square root
 wire [0:63] root_b, root_h, root_w, root_d; // root_b means square root for byte mode

    // Instantiation of square root array
    //    For byte mode:
    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b0
    (
        .a(data_in_op_A[0:7]),
        .root(root_b[4:7])
    );
    assign root_b[0:3] = 0;

    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b1
    (
        .a(data_in_op_A[8:15]),
        .root(root_b[12:15])
    );
    assign root_b[8:11] = 0;  

    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b2
    (
        .a(data_in_op_A[16:23]),
        .root(root_b[20:23])
    );
    assign root_b[16:19] = 0; 

    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b3
    (
        .a(data_in_op_A[24:31]),
        .root(root_b[28:31])
    );
    assign root_b[24:27] = 0; 

    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b4
    (
        .a(data_in_op_A[32:39]),
        .root(root_b[36:39])
    );
    assign root_b[32:35] = 0; 

    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b5
    (
        .a(data_in_op_A[40:47]),
        .root(root_b[44:47])
    );
    assign root_b[40:43] = 0; 

    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b6
    (
        .a(data_in_op_A[48:55]),
        .root(root_b[52:55])
    );
    assign root_b[48:51] = 0; 

    DW_sqrt #(
        .width(8),
        .tc_mode(TC)
    )
    DW_sqrt_b7
    (
        .a(data_in_op_A[56:63]),
        .root(root_b[60:63])
    );
    assign root_b[56:59] = 0; 

    //    For half word mode:
    DW_sqrt #(
        .width(16),
        .tc_mode(TC)
    )
    DW_sqrt_h0
    (
        .a(data_in_op_A[0:15]),
        .root(root_h[8:15])
    );
    assign root_h[0:7] = 0; 

    DW_sqrt #(
        .width(16),
        .tc_mode(TC)
    )
    DW_sqrt_h1
    (
        .a(data_in_op_A[16:31]),
        .root(root_h[24:31])
    );
    assign root_h[16:23] = 0; 

    DW_sqrt #(
        .width(16),
        .tc_mode(TC)
    )
    DW_sqrt_h2
    (
        .a(data_in_op_A[32:47]),
        .root(root_h[40:47])
    );
    assign root_h[32:39] = 0; 

    DW_sqrt #(
        .width(16),
        .tc_mode(TC)
    )
    DW_sqrt_h3
    (
        .a(data_in_op_A[48:63]),
        .root(root_h[56:63])
    );
    assign root_h[48:55] = 0; 

    //    For word mode:
    DW_sqrt #(
        .width(32),
        .tc_mode(TC)
    )
    DW_sqrt_w0
    (
        .a(data_in_op_A[0:31]),
        .root(root_w[16:31])
    );
    assign root_w[0:15] = 0; 

    DW_sqrt #(
        .width(32),
        .tc_mode(TC)
    )
    DW_sqrt_w1
    (
        .a(data_in_op_A[32:63]),
        .root(root_w[48:63])
    );
    assign root_w[32:47] = 0; 

    //    For double word mode:
    DW_sqrt #(
        .width(64),
        .tc_mode(TC)
    )
    DW_sqrt_d
    (
        .a(data_in_op_A[0:63]),
        .root(root_d[32:63])
    );
    assign root_d[0:31] = 0; 








 
 /////////////////////////////////
 //Case to select the func typ
 ////////////////////////////////
	always @(*) begin
		data_out_alu = {63{1'bx}};
		
		case(func_code)
			VAND:   data_out_alu = data_in_op_A & data_in_op_B;
			VOR:    data_out_alu = data_in_op_A | data_in_op_B;
			VXOR:   data_out_alu = data_in_op_A ^ data_in_op_B;
			VNOT:   data_out_alu = ~data_in_op_A;
			VMOV:   data_out_alu = data_in_op_A;
			VADD:   data_out_alu = add_or_sub_out;
			VSUB:   data_out_alu = add_or_sub_out;
			VMULEU: 
			VSQEU:
				begin
					case(ww)
					ww_b: data_out_alu = mul_b_out;
					ww_h: data_out_alu = mul_h_out;
					ww_w: data_out_alu = mul_w_out;
					endcase
				end
			VMULOU:
			VSQOU:
				begin
					case(ww)
					ww_b: data_out_alu = mul_b_out;
					ww_h: data_out_alu = mul_h_out;
					ww_w: data_out_alu = mul_w_out;
					endcase
				end
			VSLL:
			VSRL:
			VSRA:
				begin
					case(ww)
					ww_b: data_out_alu = shif_b_out;
					ww_h: data_out_alu = shif_h_out;
					ww_w: data_out_alu = shif_w_out;
					ww_d: data_out_alu = shif_d_out;
					endcase
				end
			VRTTH:
				case(ww)
                    ww_b :
                    begin
                        data_out_alu[0:7]   = {data_in_op_A[4:7],   data_in_op_A[0:3]};
                        data_out_alu[8:15]  = {data_in_op_A[12:15], data_in_op_A[8:11]};
                        data_out_alu[16:23] = {data_in_op_A[20:23], data_in_op_A[16:19]};
                        data_out_alu[24:31] = {data_in_op_A[28:31], data_in_op_A[24:27]};
                        data_out_alu[32:39] = {data_in_op_A[36:39], data_in_op_A[32:35]};
                        data_out_alu[40:47] = {data_in_op_A[44:47], data_in_op_A[40:43]};
                        data_out_alu[48:55] = {data_in_op_A[52:55], data_in_op_A[48:51]};
                        data_out_alu[56:63] = {data_in_op_A[60:63], data_in_op_A[56:59]};
                    end
                    ww_h :
                    begin
                        data_out_alu[0:15]  = {data_in_op_A[8:15],  data_in_op_A[0:7]};
                        data_out_alu[16:31] = {data_in_op_A[24:31], data_in_op_A[16:23]};
                        data_out_alu[32:47] = {data_in_op_A[40:47], data_in_op_A[32:39]};
                        data_out_alu[48:63] = {data_in_op_A[56:63], data_in_op_A[48:55]};
                    end
                    ww_w :
                    begin
                        data_out_alu[0:31]  = {data_in_op_A[16:31], data_in_op_A[0:15]};
                        data_out_alu[32:63] = {data_in_op_A[48:63], data_in_op_A[32:47]};
                    end
                    ww_d :
                        data_out_alu[0:63] = {data_in_op_A[32:63], data_in_op_A[0:31]};
                endcase
			VDIV:
				begin
					case(ww)
						ww_b: data_out_alu = quotient_b[0:63];
						ww_h: data_out_alu = quotient_h[0:63];
						ww_w: data_out_alu = quotient_w[0:63];
						ww_d: data_out_alu = quotient_d[0:63];
					endcase
				end
			VMOD:
				begin
					case(ww)
						ww_b: data_out_alu = remainder_b[0:63];
						ww_h: data_out_alu = remainder_h[0:63];
						ww_w: data_out_alu = remainder_w[0:63];
						ww_d: data_out_alu = remainder_d[0:63];
					endcase
				end
			VSQRT:
				begin
					case(ww)
						ww_b: data_out_alu = root_b[0:63];
						ww_h: data_out_alu = root_h[0:63];
						ww_w: data_out_alu = root_w[0:63];
						ww_d: data_out_alu = root_d[0:63];
					endcase
				end
		endcase
	end


endmodule



   
