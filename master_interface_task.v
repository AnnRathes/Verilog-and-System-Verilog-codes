/*------------------------------------------------------------------------------
--
-- Design   : Master Interface
-- Project  : AXI Porject 
-- Author   : Zhuang Wu
-- Company  : University of Southern California 
-- Updated  : 04/10/2014; 04/22/2014

-- TASK     : Complete the Master Interface which connects Router and Slave Part
-------------------------------------------------------------------------------
--
-- File         : interface_master.v
-- Version      : 2.0
--
-------------------------------------------------------------------------------
--
-- Description : Master Interface connects Router and Slave Part
--						It helps deal with Transaction Write to Slave 
--						and also Transaction Read to slave
--						After completion of Write Transaction it helps deal
--						with Write Response to the corresponding Master
-- Updated by Yiheng Guo, 04/2015
-- Updated by Aeshaani Pahuja, 05/2019: removed latches.
------------------------------------------------------------------------------*/

module master_interface(
			ACLK, ARESETn, 										//Global signals
			AWID, AWADDR, AWVALID, AWREADY,		//Write address signals
			WID, WDATA, WVALID, WREADY, 			//Write data signals
			BID, BRESP, BVALID, BREADY,				//Write response signals
			ARID, ARADDR, ARVALID, ARREADY,		//Read address signals
			RID, RDATA, RVALID, RREADY,				//Read data signals
			R2S_data_in, S2R_data_out,
			router_valid, IF_ready,
			router_ready, IF_valid
			);

	
parameter SLAVEID = 3'b110;		
		
input 					ACLK, ARESETn;
output 	[2:0] 	AWID;
output 	[31:0] 	AWADDR;
output 					AWVALID;
input 					AWREADY;

output 	[2:0]		WID;
output 	[127:0] WDATA;
output 					WVALID;
input 					WREADY;

input 	[2:0] 	BID;
input 	[1:0]		BRESP;
input 					BVALID;
output 					BREADY;

output 	[2:0] 	ARID;
output 	[31:0] 	ARADDR;
output 					ARVALID;
input 					ARREADY;

input 	[2:0] 	RID;
input 	[127:0]	RDATA;
input 					RVALID;
output 					RREADY;

input 	[159:0] R2S_data_in;
output	[159:0] S2R_data_out;

input 					router_valid;
output 					IF_ready;
input 					router_ready;
output 					IF_valid;

reg 		[2:0] 	AWID;
reg 		[31:0] 	AWADDR;
reg 						AWVALID;
reg 		[2:0] 	WID;
reg			[127:0] WDATA;
reg 						WVALID;
reg 		[2:0] 	ARID;
reg 		[31:0] 	ARADDR;
reg             ARVALID;

/***above are the inport and export signals***/

// Type_ID parameter
localparam WRITEADDRESS 	= 3'b000;
localparam WRITEDATA 			= 3'b001;
localparam WRITERESPONSE 	= 3'b011;
localparam READADDRESS 		= 3'b010;
localparam READDATA			 	= 3'b100;

wire 	[2:0] 	Trans_ID;
wire	[2:0] 	CTR;
wire	[2:0] 	MID;
wire	[2:0] 	SID;
wire	[2:0] 	Type_ID;
wire 					Valid;
wire	[127:0] Transaction;

// 4 tables for write_addr and write_date re-order
reg [164:0] table0[7:0];
reg [164:0] table1[7:0];
reg [164:0] table2[7:0];
reg [164:0] table3[7:0];

// read address fifo signals
wire read_addr_put, read_addr_empty, read_addr_full;
wire  read_addr_get;
wire [40:0] read_addr_data_in, read_addr_data_out;

// there are clock latencies for slave memory writing data
// when slave is writing data, resev=1; when writing is finished, resev=0
// this resev signal indicate if we can update grant signal, etc.
// that is, when memory is writing, we should reserve write_reorder buffer
reg resev; 

// R2S fifo signals
wire 					S_get; // slave get data from R2S fifo
wire					S_put;
wire 					RTS_full;
wire 					RTS_empty;
wire 	[159:0] RTS_data_out;

// tablex_get =1 or read_fifo_get =1 means tablex or read_addr fifo has empty locations
// tablex or read_addr fifo wants to read data from R2S fifo
reg		table0_get, table1_get, table2_get, table3_get, read_fifo_get;
reg 	[2:0] rd_ptr0, rd_ptr1, rd_ptr2, rd_ptr3;



// Depacket Unit helps getting 160 bits data from Router, 
// and according to the transaction type, send it to Read Process or Write Process
// [15:0] bits are routing info, no useness in interface here
assign 	Trans_ID 			= RTS_data_out[31:29];
assign	CTR 					= RTS_data_out[28:26];
assign	MID 					= RTS_data_out[25:23];
assign	SID 					= RTS_data_out[22:20];
assign	Type_ID  			= RTS_data_out[19:17];
assign 	Valid 				= RTS_data_out[16];
assign	Transaction 	= RTS_data_out[159:32];

// This signal is just for debugging
wire [31:0] adddr = Transaction[31:0];

/*********beginning of generating signals related to S_get, which wants to read from R2S_FIFO************/
always@(*)
begin
table0_get = 0;
table1_get = 0;
table2_get = 0;
table3_get = 0;
read_fifo_get = 0;
if(~RTS_empty)
	begin
	// if the transaction is Write_addr or Write_data
	// check to see if corresponding entry is empty or not
	if((Type_ID == WRITEADDRESS)||(Type_ID == WRITEDATA))
		begin
		case(MID)
			3'b000:
				begin
				if((table0[CTR][32] == 0)||(table0[CTR][161] == 0))
					table0_get = 1;
				end
			3'b001:
				begin
				if((table1[CTR][32] == 0)||(table1[CTR][161] == 0))
					table1_get = 1;
				end
			3'b010:
				begin
				if((table2[CTR][32] == 0)||(table2[CTR][161] == 0))
					table2_get = 1;
				end
			3'b011:
				begin
				if((table3[CTR][32] == 0)||(table3[CTR][161] == 0))
					table3_get = 1;
				end
			default:
				begin
				//just for debugging
				$display("ERROR!\n");
				$stop;
				end
		endcase
		end	
		
	// if the transaction is Read_addr
	// check to see if read_addr_fifo is full or not		
	if((Type_ID == READADDRESS)&&(!read_addr_full))
		begin
		read_fifo_get = 1;
		end
end
end//always

wire table_get;
// if table_get=1, tables can accept transaction from R2S_FIFO
assign table_get = table0_get || table1_get || table2_get || table3_get;

//-- Task 1: Generate S_get and S_put
//--		Hint: 1. write_reorder buffer and read_address fifo want to read data from R2S_FIFO
//--  				2. when packet from network is valid and R2S_FIFO is not full, we can put data into R2S_FIFO
assign S_get = 	!RTS_empty;
assign S_put = 	router_valid && !RTS_full;

/*********ending of generating signals related to S_get, which wants to read from R2S_FIFO************/

//Router to Interface FIFO
assign IF_ready = !RTS_full;
fifo #(.DEPTH(8), .DATA_WIDTH(160)) R2S_FIFO (
			.clk(ACLK), 
			.resetn(ARESETn), 
			.put(S_put), 
			.get(S_get), 
			.data_in(R2S_data_in), 
			.empty(RTS_empty),
			.full(RTS_full), 
			.data_out(RTS_data_out)
			);
	

/********beginning of putting transactions into 4 tables (4 write_reorder buffers)*********/
integer i;
always@(posedge ACLK, negedge ARESETn)
	begin : alwaysblock
	if(ARESETn == 0)
		begin
		for(i = 0; i <8; i = i+1)
			begin
			table0[i] <= 0;
			table1[i] <= 0;
			table2[i] <= 0;
			table3[i] <= 0;
			end
		end
	else	
		begin : Differentiate_Transaction
		if(table_get == 1)
		begin
			if(Type_ID == WRITEADDRESS)
				begin : WRITE_ADDRESS
				//according to the MID, it should be sent to corresponding table entry\\
				//-- Task 2: put data from packet(Transaction, Valid, Trans_ID) into write_reorder buffer\
				//--		Hint: check packet organization and write_reorder buffer structure
				case(MID)
					3'b000: 
						begin
						table0[CTR][31:0] <= RTS_data_out[63:32]	;
						table0[CTR][32] <= 	1'b1;
						table0[CTR][164:162] <=	Trans_ID;
						end
					3'b001:
						begin
						table1[CTR][31:0] <= RTS_data_out[63:32];
						table1[CTR][32] <= 	1'b1;
						table1[CTR][164:162] <= Trans_ID;
						end	
					3'b010:
						begin
						table2[CTR][31:0] <= RTS_data_out[63:32];
						table2[CTR][32] <= 1'b1;
						table2[CTR][164:162] <=	Trans_ID;
						end	
					3'b011:
						begin
						table3[CTR][31:0] <= RTS_data_out[63:32];
						table3[CTR][32] <= 	1'b1;
						table3[CTR][164:162] <=	Trans_ID;
						end
					default:
						begin
						//just for debugging
						$display("ERROR!\n");
						$stop;
						end						
				endcase
				end//Write_address
		
			if(Type_ID == WRITEDATA)
				begin : WRITE_DATA
				//according to the MID, it should be sent to corresponding table entry
				case(MID)
					3'b000: 
						begin
						table0[CTR][160:33] <=  Transaction;
						table0[CTR][161] <= 1'b1;					
						end
					3'b001:
						begin
						table1[CTR][160:33] <=	Transaction;
						table1[CTR][161] <= 1'b1;
						end	
					3'b010:
						begin
						table2[CTR][160:33] <= Transaction;
						table2[CTR][161] <= 1'b1;
						end	
					3'b011:
						begin
						table3[CTR][160:33] <= Transaction;
						table3[CTR][161] <= 1'b1;
						end	
					default:
						begin
						//just for debugging
						$display("ERROR!\n");
						$stop;
						end
					endcase
				end //Write Data
			end
		end
	end
/********ending of putting transactions into 4 tables (4 write_reorder buffers)*********/
	
	// Read_Addr_FIFO and its signals
	assign read_addr_put = read_fifo_get;
	assign read_addr_data_in = {Trans_ID, CTR, MID, Transaction[31:0]} ;
	assign read_addr_get = ARREADY && ARVALID;
	fifo #(.DEPTH(64), .DATA_WIDTH(41)) Read_Addr_FIFO (
			.clk(ACLK), 
			.resetn(ARESETn), 
			.put(read_addr_put), 
			.get(read_addr_get), 
			.data_in(read_addr_data_in), 
			.empty(read_addr_empty), 
			.full(read_addr_full), 
			.data_out(read_addr_data_out)
			);
	
	
	/***************beginning of reading from write_reorder buffer and round robin for Write Transaction***************/
	localparam NONE = 4'b0000;
	localparam PORT0 = 4'b0001;
	localparam PORT1 = 4'b0010;
	localparam PORT2 = 4'b0100;
	localparam PORT3 = 4'b1000;
	
	reg [3:0] write_priority; 	
	wire table0_v, table1_v, table2_v, table3_v, table_v; 
	reg [3:0] grant;

	reg [2:0] 	temp_CTR;
	reg [2:0] 	temp_MID;
	reg [31:0]	temp_addr;
	
	// each entry is valid, only if both write_addr and write_data are valid
	assign table0_v = table0[rd_ptr0][32] && table0[rd_ptr0][161];
	assign table1_v = table1[rd_ptr1][32] && table1[rd_ptr1][161];
	assign table2_v = table2[rd_ptr2][32] && table2[rd_ptr2][161];
	assign table3_v = table3[rd_ptr3][32] && table3[rd_ptr3][161];
	assign table_v 	= table0_v || table1_v || table2_v || table3_v;
	
	always@(posedge ACLK)
		begin
		if(ARESETn == 0)
			begin
			write_priority <= 4'b0001;
			resev <=0;
			
			temp_CTR <= 0;
			temp_MID <= 0;
			temp_addr<= 0;
			
			rd_ptr0 <= 0;
			rd_ptr1 <= 0;
			rd_ptr2 <= 0;
			rd_ptr3 <= 0;
			
			grant 	<= NONE;
			end
		else
			begin
			
			// Read Address sent to Slave; CTR and MID are stored for ReadData sent back to master
			if(ARREADY && ARVALID)
				begin 
				temp_CTR <= read_addr_data_out[37:35];
				temp_MID <= read_addr_data_out[34: 32];
				end 
			
			// (WREADY) && (WVALID) means next clock, slave memory will finish writing data, below actions should be done:
			// -- 1. update round-robin arbiter
			// -- 2. reset "resev" signal, so we can grant another write transaction sent to slave memory
			// -- 3. store MID and CTR for write_response
			// -- 4. increase rd_ptr and invalid current entry
			
			//Note: The arbitration logic used here is not strictly LRU. 
			//We use a very simple arbitration method. 
			
			if((WREADY) && (WVALID))
				begin
				write_priority[0] 	<= write_priority[3];
				write_priority[3:1] <= write_priority[2:0];
				resev <=0;
				case(grant)
					4'b0001:
						begin
						temp_CTR <= rd_ptr0;
						temp_MID <= 0;
						temp_addr <= table0[rd_ptr0][31:0];
						rd_ptr0 <= rd_ptr0 + 1;
						table0[rd_ptr0][32] <= 0;
						table0[rd_ptr0][161] <= 0;
						end
					4'b0010: 
						begin
						temp_CTR <= rd_ptr1;
						temp_MID <= 1;
						temp_addr <= table1[rd_ptr1][31:0];
						rd_ptr1 <= rd_ptr1 + 1;
						table1[rd_ptr1][32] <= 0;
						table1[rd_ptr1][161] <= 0;
						end
					4'b0100:
						begin
						temp_CTR <= rd_ptr2;
						temp_MID <= 2;
						temp_addr <= table2[rd_ptr2][31:0];
						rd_ptr2 <= rd_ptr2 + 1;
						table2[rd_ptr2][32] <= 0;
						table2[rd_ptr2][161] <= 0;
						end
					4'b1000:
						begin
						temp_CTR <= rd_ptr3;
						temp_MID <= 3;
						temp_addr <= table3[rd_ptr3][31:0];
						rd_ptr3 <= rd_ptr3 + 1;
						table3[rd_ptr3][32] <= 0;
						table3[rd_ptr3][161] <= 0;
						end
				endcase
				end
			
			if(resev == 0)
				begin
				if(table_v) resev <=1;
				
				// case block for priority updating "grant" based on "write_priority"
				
				case (write_priority)
					PORT0:	
						begin
							if(table0_v)
								grant <= PORT0;
							else if(table1_v)
								grant <= PORT1;
							else if(table2_v)
								grant <= PORT2;
							else if(table3_v)
								grant <= PORT3;
							else
								grant <= NONE;
						end
					PORT1:
						begin
							if(table1_v)
								grant <= PORT1;
							else if(table2_v)
								grant <= PORT2;
							else if(table3_v)
								grant <= PORT3;
							else if(table0_v)
								grant <= PORT0;
							else
								grant <= NONE;
						end
					PORT2:
						begin
							if(table2_v)
								grant <= PORT2;
							else if(table3_v)
								grant <= PORT3;
							else if(table0_v)
								grant <= PORT0;
							else if(table1_v)
								grant <= PORT1;
							else
								grant <= NONE;
						end
					PORT3:
						begin
							if(table3_v)
								grant <= PORT3;
							else if(table0_v)
								grant <= PORT0;
							else if(table1_v)
								grant <= PORT1;
							else if(table2_v)
								grant <= PORT2;
							else
								grant <= NONE;
						end
					default:
						begin
						//just for debugging
						$display("ERROR!\n");
						$stop;
						end
			endcase // case block for priority updating "grant" based on "write_priority"
	
			end
		end
	end
 /***************ending of reading from write_reorder buffer and round robin for Write Transaction***************/

 /*********beginning of generating Write_addr, Write_data, Read_addr channel signals, which connected to slave memory***********/
always@(*)
	begin
	ARVALID= !read_addr_empty;
	ARID 		= read_addr_data_out[40:38];
	ARADDR 	= read_addr_data_out[31:0];
	AWVALID = 0;
	WVALID 	= 0;	
	
	if (resev==1)
		begin
		AWVALID = 1;
		WVALID 	= 1;	
		end
	//-- Task 3: generate AWID, AWADDR, WID, WDATA
	//			Hint: 1. All these signals are from write_reorder buffer pointed by rd_ptrx, check table structure
	//						2. WID adn AWID should be same
	case(grant)
		4'b0001:
			begin
			AWID 	= table0[rd_ptr0][164:162] ;
			AWADDR 	= table0[rd_ptr0][31:0];
			WID 	= table0[rd_ptr0][164:162];
			WDATA 	= table0[rd_ptr0][160:33];
			end
		4'b0010: 
			begin
			AWID 	= table1[rd_ptr1][164:162] ;
			AWADDR 	= table1[rd_ptr1][31:0];
			WID		= table1[rd_ptr1][164:162];
			WDATA 	= table1[rd_ptr1][160:33];
			end
		4'b0100:
			begin
			AWID	= table2[rd_ptr2][164:162] ;
			AWADDR	= table2[rd_ptr2][31:0];
			WID 	= table2[rd_ptr2][164:162];
			WDATA 	= table2[rd_ptr2][160:33];
			end
		4'b1000:
			begin
			AWID 	= table3[rd_ptr3][164:162] ;
			AWADDR 	= table3[rd_ptr3][31:0];
			WID 	= table3[rd_ptr3][164:162];
			WDATA 	= table3[rd_ptr3][160:33];
			end
		endcase
	end	
 /*********ending of generating Write_addr, Write_data, Read_addr channel signals, which connected to slave memory***********/				


// S2R_FIFO and its signals
reg STRput; 
wire STRget;
wire router_ready;
reg [159:0] STRdata_in;
wire [159:0] S2R_data_out;
wire STRempty;
wire STRfull;

assign STRget = router_ready && (IF_valid);
assign IF_valid = !STRempty;
fifo #(.DEPTH(8), .DATA_WIDTH(160)) S2R_FIFO (
			.clk(ACLK), 
			.resetn(ARESETn), 
			.put(STRput), 
			.get(STRget), 
			.data_in(STRdata_in), 
			.empty(STRempty), 
			.full(STRfull), 
			.data_out(S2R_data_out)
			);

/***********begining of sending Write_response, Read_data to S2R_FIFO************/			
assign BREADY = !STRfull;
assign RREADY = !STRfull;
// indeed, [15:0] is not important in interface, router can generate routing info according to MID and SID

//Note: Notice the way temp_CTR, temp_MID and temp_addr is used. This works here because our
//slave memory can accept data/address from only one AXI channel at a time and it processes requests 
//in order. 
//This is not strictly according to the AXI specification. A real AXI interconnect should make no
//assumptions about the slave. 
//If AXI specification is strictly followed then a reorder mechanism should be used instead of the code below. 
always@(*)
	begin
		STRput = 0;
		STRdata_in = 160'd0;
		if((BVALID==1) && (BREADY == 1))
			begin
			STRput = 1;
			STRdata_in[31:29] 	= BID;
			STRdata_in[28:26] 	= temp_CTR;
			STRdata_in[25:23] 	= temp_MID;
			STRdata_in[22:20] 	= SLAVEID;
			
			STRdata_in[19:17] 	= WRITERESPONSE;
			STRdata_in[16] 			= 1;
			STRdata_in[33:32] 	= BRESP;
			STRdata_in[95:64]   = temp_addr;  // sent write_response_addr to master. indeed it is not necessary, just for verifying write_response is completed in order
			STRdata_in[63:34]		= 0;
			STRdata_in[15:0] 		= 0;
			end
		
		if( (RVALID == 1) && (RREADY == 1) )
			begin
			STRput = 1;
			STRdata_in[31:29] = RID;
			STRdata_in[28:26] = temp_CTR;
			STRdata_in[25:23] = temp_MID;
			STRdata_in[22:20] = SLAVEID;
			STRdata_in[19:17] = READDATA;
			STRdata_in[16] = 1;
			STRdata_in[159:32] = RDATA;
			STRdata_in[15:0] = 0;
			end
	end
/***********ending of sending Write_response, Read_data to S2R_FIFO************/			
endmodule


