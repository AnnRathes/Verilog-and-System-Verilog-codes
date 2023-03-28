
`timescale 1ns/1ps

`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW01_addsub.v"
`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW02_mult.v"
`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_div.v"
`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_sqrt.v"
`include "/usr/local/synopsys/Design_Compiler/K-2015.06-SP5-5/dw/sim_ver/DW_shifter.v"


module tb;


reg  [0:63] data_in_op_A, data_in_op_B;
reg  [0:5] func_code; 
reg  [0:1] ww;
wire [0:63] data_out_alu;

//R-TYPE fuction list
 parameter VAND = 6'b000001;
 parameter VOR = 6'b000010;
 parameter VXOR = 6'b000011;
 parameter VNOT = 6'b000100;
 parameter VMOV = 6'b000101; 
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
 
 // select mode
 parameter ww_b = 2'b00; // byte
 parameter ww_h = 2'b01; // half word
 parameter ww_w = 2'b10; // word
 parameter ww_d = 2'b11; // double word
 
 
 ISA_ALU ISA_ALU_inst(.data_in_op_A(data_in_op_A), .data_in_op_B(data_in_op_B), .func_code(func_code), .ww(ww), .data_out_alu(data_out_alu));
 
 integer out_file;
 
  initial 
    begin
        out_file = $fopen("ALU_ISA.res", "w");
		#10
		
////////////////////////////////////////AND///////////////////////////////////////////////////////////////////////////////
		
		data_in_op_A = 64'h9999999999999999;
        data_in_op_B = 64'h6666666666666666;
        func_code = VAND;
        ww = ww_b;
		//result 64'h0000000000000000
        #4 
        $fdisplay(out_file, "VAND: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);

////////////////////////////////////////OR//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		data_in_op_A = 64'h9999999999999999;
        data_in_op_B = 64'h6666666666666666;
        func_code = VOR;
        ww = ww_b;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VOR: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
	

////////////////////////////////////////XOR//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		data_in_op_A = 64'h9999999999999999;
        data_in_op_B = 64'h6666666666666666;
        func_code = VXOR;
        ww = ww_b;
		//result 64'h0000000000000000
        #4 
        $fdisplay(out_file, "VXOR: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
	
////////////////////////////////////////NOT//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		data_in_op_A = 64'hffffffffffffffff;
        data_in_op_B = 64'h0000000000000000;
        func_code = VNOT;
        ww = ww_b;
		//result 64'h0000000000000000
        #4 
        $fdisplay(out_file, "VNOT: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
////////////////////////////////////////MOV//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		data_in_op_A = 64'hffffffffffffffff;
        data_in_op_B = 64'h0000000000000000;
        func_code = VMOV;
        ww = ww_d;
		//result 64'h0000000000000000
        #4 
        $fdisplay(out_file, "VMOV: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
////////////////////////////////////////ADD///////////////////////////////////////////////////////////////////////////////
		
		data_in_op_A = 64'hefffffffffffffff;
        data_in_op_B = 64'h1;
        func_code = VADD;
        ww = ww_b;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VADD: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'hefffffffffffffff;
        data_in_op_B = 64'h1;
        func_code = VADD;
        ww = ww_h;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VADD: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'hefffffffffffffff;
        data_in_op_B = 64'h1;
        func_code = VADD;
        ww = ww_w;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VADD: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'hefffffffffffffff;
        data_in_op_B = 64'h1;
        func_code = VADD;
        ww = ww_d;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VADD: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
////////////////////////////////////////SUB///////////////////////////////////////////////////////////////////////////////
		
		data_in_op_A = 64'h0000000000000000;
        data_in_op_B = 64'h0000000000000001;
        func_code = VSUB;
        ww = ww_b;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VSUB: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h0000000000000000;
        data_in_op_B = 64'h0000000000000001;
        func_code = VSUB;
        ww = ww_h;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VSUB: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h0000000000000000;
        data_in_op_B = 64'h0000000000000001;
        func_code = VSUB;
        ww = ww_w;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VSUB: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h0000000000000000;
        data_in_op_B = 64'h0000000000000001;
        func_code = VSUB;
        ww = ww_d;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VSUB: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
////////////////////////////////////////MUL///////////////////////////////////////////////////////////////////////////////
		
		data_in_op_A = 64'h0000000000000005;
        data_in_op_B = 64'h0000000000000002;
        func_code = VMULEU;
        ww = ww_b;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VMULEU: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h0000000000000500;
        data_in_op_B = 64'h0000000000000200;
        func_code = VMULEU;
        ww = ww_h;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VMULEU: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h0000000005000000;
        data_in_op_B = 64'h0000000002000000;
        func_code = VMULEU;
        ww = ww_w;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VMULEU: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);		


		data_in_op_A = 64'h0000000000000500;
        data_in_op_B = 64'h0000000000000200;
        func_code = VMULOU;
        ww = ww_b;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VMULOU: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h0000000005000000;
        data_in_op_B = 64'h0000000002000000;
        func_code = VMULOU;
        ww = ww_h;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VMULOU: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h0500000000000000;
        data_in_op_B = 64'h0200000000000000;
        func_code = VMULOU;
        ww = ww_w;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VMULOU: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);	

////////////////////////////////////////SQEU/SQOU///////////////////////////////////////////////////////////////////////////////U///////////////////////////////////////////////////////////////////////////////
		
		data_in_op_A = 64'h0000000000000009;
        data_in_op_B = 64'h0000000000000004;
        func_code = SQEU;
        ww = ww_b;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "SQEU: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h0000000000000009;
        data_in_op_B = 64'h0000000000000004;
        func_code = SQEU;
        ww = ww_h;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "SQEU: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h0000000000000009;
        data_in_op_B = 64'h0000000000000004;
        func_code = SQEU;
        ww = ww_w;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "SQEU: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);		


		data_in_op_A = 64'h0000000000000009;
        data_in_op_B = 64'h0000000000000004;
        func_code = SQOU;
        ww = ww_b;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "SQOU: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h0000000000000009;
        data_in_op_B = 64'h0000000000000004;
        func_code = SQOU;
        ww = ww_h;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "SQOU: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h0000000000000009;
        data_in_op_B = 64'h0000000000000004;
        func_code = SQOU;
        ww = ww_w;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "SQOU: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);	

////////////////////////////////////////DIV///////////////////////////////////////////////////////////////////////////////
		
		data_in_op_A = 64'h0000000000001234;
        data_in_op_B = 64'h0000000000000002;
        func_code = VDIV;
        ww = ww_b;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VDIV: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h123456789abcdef0;
        data_in_op_B = 64'h0000000000000005;
        func_code = VDIV;
        ww = ww_h;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VDIV: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h123456789abcdef0;
        data_in_op_B = 64'h0000000000000005;
        func_code = VDIV;
        ww = ww_w;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VDIV: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h123456789abcdef0;
        data_in_op_B = 64'h0000000000000005;
        func_code = VDIV;
        ww = ww_d;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VDIV: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
////////////////////////////////////////MOD///////////////////////////////////////////////////////////////////////////////
		
		data_in_op_A = 64'h0000000000001234;
        data_in_op_B = 64'h0000000000000005;
        func_code = VMOD;
        ww = ww_b;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VMOD: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h123456789abcdef0;
        data_in_op_B = 64'h0000000000000007;
        func_code = VMOD;
        ww = ww_h;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VMOD: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h123456789abcdef0;
        data_in_op_B = 64'h0000000000000008;
        func_code = VMOD;
        ww = ww_w;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VMOD: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
		
		data_in_op_A = 64'h123456789abcdef0;
        data_in_op_B = 64'h0000000000000005;
        func_code = VMOD;
        ww = ww_d;
		//result 64'hffffffffffffffff
        #4 
        $fdisplay(out_file, "VMOD: data_in_op_A = %h, data_in_op_B = %h, ww = %b, data_out_alu = %h", data_in_op_A, data_in_op_B, ww, data_out_alu);
				
		
		#10
        $fclose(out_file);
        $finish;
	end
endmodule