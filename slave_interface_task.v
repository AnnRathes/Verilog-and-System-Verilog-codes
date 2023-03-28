// ----------------------------------------------------------------------------------
// Slave interface(Master side) by Zeqian Li. Last update: 28/04/2014
// Description: Slave interface will packet transactions from Master Processor
//							and send packet to NoC. It has packet unit, Master to Router FIFO,
//							Router to Master FIFO, dePacket unit, Read Data reorder buffer and 
//							Write Response reorder buffer.
// Updated by Yiheng Guo, 04/2015
// Updated by Aeshaani Pahuja, 05/2019: removed latches.
// ----------------------------------------------------------------------------------

// naming style:
// VALID -> hold something valid, which wants to send
// READY -> buffer or fifo has empty locations, which can accept new transaction

module SI(	ACLK, ARESETn, 														//Global signals
						AWID, AWADDR, AWVALID, AWREADY,						//Write address channel signals
						WID, WDATA, WVALID, WREADY, 							//Write data channel signals
						BID, BRESP, BVALID, BREADY,								//Write response channnel signals
						ARID, ARADDR, ARVALID, ARREADY,						//Read address channel signals
						RID, RDATA, RVALID, RREADY,								//Read data channel signals
						M2R_data_out, IF_valid, IF_ready,									//signals to router
						R2M_data_input, router_ready, router_valid					//signals from router
			);	
			

parameter MASTERID = 3'b000;

input ACLK, ARESETn;

// signals which communicate with master processor 
input [2:0] 	AWID;
input [31:0] 	AWADDR;
input 				AWVALID;
output 				AWREADY;

input [2:0]	 	WID;
input [127:0] WDATA;
input 				WVALID;
output 				WREADY;

output [2:0] 	BID;
output [1:0]	BRESP;
output 				BVALID;
input 				BREADY;

input	[2:0] 	ARID;
input [31:0] 	ARADDR;
input 				ARVALID;
output 				ARREADY;

output [2:0] 		RID;
output [127:0] 	RDATA;
output 					RVALID;
input 					RREADY;

// signals which communicate with router
input 						router_ready;			//router is ready to take packet
input 						router_valid;			//router wants to write data packet to the R2M FIFO
output 						IF_valid;					//interface wants to write to router
output 						IF_ready;					//interface can read from router
input 	[159:0] 	R2M_data_input;					//From router to NoC-to-Master FIFO, input is a data packet
output 	[159:0] 	M2R_data_out;						//From Master-to-NoC FIFO to router

wire [2:0] 		AWID;
wire [31:0] 	AWADDR;
wire AWVALID, AWREADY;

wire [2:0] 		WID;
wire [127:0] 	WDATA;
wire WVALID, WREADY;

reg [2:0] 		BID;
reg [1:0] 		BRESP;
wire BVALID, BREADY;

wire [2:0] 		ARID;
wire [31:0] 	ARADDR;
wire ARVALID, ARREADY;

reg [2:0] 		RID;
reg [127:0] 	RDATA;
wire RVALID, RREADY;

wire 	router_ready, router_valid;
wire 	[159:0] R2M_data_input;
reg 	[159:0] w_packet;					//Packet from write address, write data and read address
reg 	[159:0] resp_packet;			//Packet from write response
reg 	[159:0] rd_packet;				//Packet from read data

wire 	IF_ready;	
wire 	IF_valid;

reg [2:0] SID;						//Slave ID register
reg [2:0] CTR;						//Counter register
reg [2:0] CTR0;						//Counter for slave 0, used in write
reg [2:0] CTR1;						//Counter for slave 1, used in write
reg [2:0] CTR2;						//Counter for slave 2, used in write
reg [2:0] CTR3;						//Counter for slave 3, used in write
reg [2:0] RdCTR;					//Counter used in read
reg unpacket_valid;

//////////M2R_FIFO////////////////
reg 	packet_valid;										//Packet unit is filled and wants to write to M2R fifo
wire 	M2R_fifo_write, M2R_fifo_read, M2R_fifo_full, M2R_fifo_empty, M2R_fifo_one;		//fifo1_one: M2R has only one empty location
wire 	[159:0] M2R_data_out;

//////////R2M_FIFO////////////////
wire R2M_fifo_write, R2M_fifo_read, R2M_fifo_full, R2M_fifo_empty; 
wire [159:0] R2M_fifo_out;

reg 	RdDATA_in, Resp_in;										//Data type from router is Read Data ot Write Response
wire 	[2:0] R2M_fifo_out_type;							//Data type read from packet


////////////////////////Read Transaction Reorder Buffer////////////
reg [3:0] 	Rdbuff_rdptr;
reg [3:0] 	Rdbuff_wrptr;
reg [135:0] Rdbuff [0:7];

/////////////////////////////Write response reorder buffer//////////
reg [3:0] 	WRbuff_rdptr;
reg [3:0]		WRbuff_wrptr;
// [0] for write_response valid; [3:1] hold BID; [5:4] hold write_response; [37:6] hold write_response_addr
// [38] for write_addr valid; [41:39] hold SID; [44:42] hold CTR
// write_response finds the corresponding entry according to CTR and SID (CTR and SID as tags)
// Here write_response_addr is not necessary to be sent back by slave memory, just for verifying write_response is completed in order 
reg [44:0] 	WRbuff [0:7]; 
	
///////////if packet is valid, Write_addr and Write_date can be accepted when M2R fifo has 2 or more locations
///////////if packet is unvalid, Write_addr and Write_date can be accepted when M2R fifo is not full
///////////IMPORTANT: Considering packet unit can not hold date for more than 1 clock, what's in packet unit must be written to M2R fifo at next clock
assign AWREADY 	= 	(!((WRbuff_wrptr - WRbuff_rdptr) == 4'b1000)) && (packet_valid ? ((!M2R_fifo_one) && (!M2R_fifo_full)) : (!M2R_fifo_full));		
assign WREADY 	= 	(!((WRbuff_wrptr - WRbuff_rdptr) == 4'b1000)) && (packet_valid ? ((!M2R_fifo_one) && (!M2R_fifo_full)) : (!M2R_fifo_full));																																		
///////////Read address can be accepted if reorder buffer is not full && the same condition as WREADY and AWREADY.
assign ARREADY	= 	(!((Rdbuff_wrptr - Rdbuff_rdptr) == 4'b1000)) && (packet_valid  ? ((!M2R_fifo_one) && (!M2R_fifo_full)) : (!M2R_fifo_full));			

//-- Task  1: Generate BVALID and RVALID using signals from WRbuff and RDbuff
//--		Hint: WRbuff_wrptr[2:0] and Rdbuff_rdptr[2:0] can be used
assign BVALID = WRbuff[WRbuff_rdptr[2:0]][38] && WRbuff[WRbuff_rdptr[2:0]][0]; 	//Write_response is ready if both valid signals in current entry of the write reorder buffer are high.
assign RVALID = Rdbuff[Rdbuff_rdptr[2:0]][0] && Rdbuff[Rdbuff_rdptr[2:0]][7];		//Read data is ready if both valid signals in current entry of the read reorder buffer are high.


//Note: Observe how w_packet is used to packet the data that we receive from the master
//Our code works because the master processor writes in only one channel at a time and so 
//there is no danger of w_packet being overwritten by different channels. This is not according to the AXI spec. 
//To strictly follow the AXI spec the slave processor should be able to receive data in all the channels simultaneously. 
//To do this there should be a arbitration logic to select a packet from different channel to go into the slave_to_router FIFO. 

integer i;
always@(posedge ACLK) 
	begin
	if(ARESETn == 0) 
		begin
		w_packet <= 0;
		resp_packet <= 0;
		rd_packet <= 0;
		SID <= 4;
		CTR <= 0;
		CTR0 <= 0;
		CTR1 <= 0;
		CTR2 <= 0;
		CTR3 <= 0;
		RdCTR <= 0;
		
		packet_valid <= 0;
		Rdbuff_rdptr <= 0;
		Rdbuff_wrptr <= 0;
		WRbuff_rdptr <= 0;
		WRbuff_wrptr <= 0;
		
		for(i=0;i<8;i=i+1)
			begin
			Rdbuff[i][0] <= 0;
			WRbuff[i][0] <= 0;
			Rdbuff[i][7] <= 0;
			WRbuff[i][38] <= 0;
			end
		end
	else 
		begin
		packet_valid <= 0;
		//////////////////Write channel interface///////////////////////////////////////
		if(AWVALID && AWREADY) 
			begin		//write address request
			///reorder buffer
			WRbuff[WRbuff_wrptr[2:0]][38] <= 1;
			WRbuff_wrptr <= WRbuff_wrptr + 1;
			
			////////Packet write address//////////
			//-- Task 2: Write address packet generation, what's in the packet?
			//			Hint: search the word "w_packet" to make sure not skipping some packet generations 
			w_packet[159:64] <= 0;
			w_packet[63:32] <= 	AWADDR;								//write address
			w_packet[31:29] <= 	AWID;								//transaction ID
			
			case (AWADDR[5:4])									//Counter
				2'b00:	
					begin 										//Destination is slave 0
					w_packet[28:26] <= 	CTR0			;
					WRbuff[WRbuff_wrptr[2:0]][44:42] <= CTR0;
					CTR <= CTR0;
					CTR0 <= CTR0 + 1;
					end
				2'b01:	
					begin  										//Destination is slave 1
					w_packet[28:26] <= CTR1;
					WRbuff[WRbuff_wrptr[2:0]][44:42] <= CTR1;
					CTR <= CTR1;
					CTR1 <= CTR1 + 1;
					end
				2'b10:	
					begin  										//Destination is slave 2
					w_packet[28:26] <= CTR2;
					WRbuff[WRbuff_wrptr[2:0]][44:42] <= CTR2 ;
					CTR <= CTR2;
					CTR2 <= CTR2 + 1;
					end
				2'b11:	
					begin  										//Destination is slave 3
					w_packet[28:26] <= CTR3 ;
					WRbuff[WRbuff_wrptr[2:0]][44:42] <= CTR3;
					CTR <= CTR3;
					CTR3 <= CTR3 + 1;
					end
			endcase
			 
			w_packet[25:23] <= MASTERID;							//Master ID
			w_packet[22:20] <= {1'b1, AWADDR[5:4]};		//Slave ID
			WRbuff[WRbuff_wrptr[2:0]][41:39] <= {1'b1, AWADDR[5:4]};
			SID <= {1'b1, AWADDR[5:4]};
			w_packet[19:17] <= 3'b000;								//Type: write address
			w_packet[16] <= 1'b1;											//Valid bit
			////////////end of packeting//////////////	
			packet_valid <= 1;	
			end
		
		if(WVALID && WREADY) 
			begin		//write data request
			///////////packet write data///////////
			w_packet[159:32] <= WDATA;
			w_packet[31:29] <= WID;
			w_packet[28:26] <= CTR;
			w_packet[25:23] <= MASTERID;
			w_packet[22:20] <= SID;
			w_packet[19:17] <= 3'b001;								//Type: write data
			w_packet[16] <= 1'b1;
			///////////end of packeting////////////
			packet_valid <= 1;
			end

		///////////////////Read channel interface//////////////////////////////////////	
		if(ARVALID && ARREADY) 
			begin
			/////////////Reorder buffer///////////////
			//-- Task 3.1: When Read Address is packeted, what's info should be left in Read Reorder buffer?
			Rdbuff[Rdbuff_wrptr[2:0]][0] 	<= 1'b1;
			Rdbuff[Rdbuff_wrptr[2:0]][6:4] 	<= ARID;
			Rdbuff[Rdbuff_wrptr[2:0]][3:1] 	<= RdCTR ;
			
			RdCTR <= RdCTR + 1;
			Rdbuff_wrptr <= Rdbuff_wrptr + 1;
		
			/////////Packet unit///////////////
			w_packet[63:32] <= 	ARADDR;
			w_packet[31:29] <=	ARID;
			w_packet[28:26] <= 	RdCTR;
			w_packet[25:23] <= 	MASTERID;
			w_packet[22:20] <= 	{1'b1, ARADDR[5:4]}; 	//	SID
			w_packet[19:17] <= 	3'b010;								// 	Type
			w_packet[16] 		<= 	1'b1;
			////////end of packeting////////////////			
			packet_valid <= 1;
		end
		
		if(RdDATA_in && unpacket_valid) 
			begin				//Data comes back from slave and goes into reorder buffer
			
			//-- Task 3.2: When Read Data comes back, how to reorder? (according to which bits in rd_packet?)
			if(Rdbuff[0][3:1] == rd_packet[28:26]) 
				begin	//Compare the value of CTR
				Rdbuff[0][135:8] <= rd_packet[159:32];
				Rdbuff[0][7] <= 1;							//Assert the data valid bit
				end
			else if(Rdbuff[1][3:1] == rd_packet[28:26]) 
				begin
				Rdbuff[1][135:8] <= rd_packet[159:32];
				Rdbuff[1][7] <= 1;
				end
			else if(Rdbuff[2][3:1] == rd_packet[28:26]) 
				begin
				Rdbuff[2][135:8] <= rd_packet[159:32];
				Rdbuff[2][7] <= 1;
				end
			else if(Rdbuff[3][3:1] == rd_packet[28:26]) 
				begin
				Rdbuff[3][135:8] <= rd_packet[159:32];
				Rdbuff[3][7] <= 1;
				end
			else if(Rdbuff[4][3:1] == rd_packet[28:26]) 
				begin
				Rdbuff[4][135:8] <= rd_packet[159:32];
				Rdbuff[4][7] <= 1;
				end
			else if(Rdbuff[5][3:1] == rd_packet[28:26]) 
				begin
				Rdbuff[5][135:8] <= rd_packet[159:32];
				Rdbuff[5][7] <= 1;
				end
			else if(Rdbuff[6][3:1] == rd_packet[28:26]) 
				begin
				Rdbuff[6][135:8] <= rd_packet[159:32];
				Rdbuff[6][7] <= 1;
				end
			else if(Rdbuff[7][3:1] == rd_packet[28:26]) 
				begin
				Rdbuff[7][135:8] <= rd_packet[159:32];
				Rdbuff[7][7] <= 1;
				end
			end
		
		if(RREADY && RVALID) 
			begin					//Data from the first entry of reorder buffer is ready to commit
			//-- Task 3.3: When Read Data is committed, how to update Read Reorder buffer? 
			Rdbuff[Rdbuff_rdptr[2:0]][0] <= 1'b0;
			Rdbuff[Rdbuff_rdptr[2:0]][7] <= 1'b0;
			Rdbuff_rdptr <= Rdbuff_rdptr + 1'b1;
			end
		end
	
	/////////////////////Fill the write response reorder buffer////////////////////
		if(Resp_in && unpacket_valid) 
			begin //Data comes back from slave and goes into reorder buffer\
			
			//-- Task 4.1: how to reorder Write Response? (according to which parts in resp_packet?)
			if(WRbuff[0][44:39] == {resp_packet[28:26],resp_packet[22:20]}) 
				begin	
				WRbuff[0][37:1] <= {resp_packet[95:64], resp_packet[33:29]};	// resp_packet[95:64] --> write_response_addr; resp_packet[33:29] --> BRESP and BID
				WRbuff[0][0] <= 1;						//Assert the valid bit
				end
			else if(WRbuff[1][44:39]== {resp_packet[28:26],resp_packet[22:20]}) 
				begin
				WRbuff[1][37:1] <= {resp_packet[95:64], resp_packet[33:29]};
				WRbuff[1][0] <= 1;
				end
			else if(WRbuff[2][44:39] == {resp_packet[28:26],resp_packet[22:20]}) 
				begin
				WRbuff[2][37:1] <= {resp_packet[95:64], resp_packet[33:29]};
				WRbuff[2][0] <= 1;
				end
			else if(WRbuff[3][44:39] == {resp_packet[28:26],resp_packet[22:20]}) 
				begin
				WRbuff[3][37:1] <= {resp_packet[95:64], resp_packet[33:29]};
				WRbuff[3][0] <= 1;
				end
			else if(WRbuff[4][44:39] == {resp_packet[28:26],resp_packet[22:20]}) 
				begin
				WRbuff[4][37:1] <= {resp_packet[95:64], resp_packet[33:29]};
				WRbuff[4][0] <= 1;
				end
			else if(WRbuff[5][44:39] == {resp_packet[28:26],resp_packet[22:20]}) 
				begin
				WRbuff[5][37:1] <= {resp_packet[95:64], resp_packet[33:29]};
				WRbuff[5][0] <= 1;
				end
			else if(WRbuff[6][44:39] == {resp_packet[28:26],resp_packet[22:20]}) 
				begin
				WRbuff[6][37:1] <= {resp_packet[95:64], resp_packet[33:29]};
				WRbuff[6][0] <= 1;
				end
			else if(WRbuff[7][44:39] == {resp_packet[28:26],resp_packet[22:20]}) 
				begin
				WRbuff[7][37:1] <= {resp_packet[95:64], resp_packet[33:29]};
				WRbuff[7][0] <= 1;
				end			
			end

		if(BREADY && BVALID) 
			begin//Data from the first entry of reorder buffer is ready to commit
			//-- Task 4.1: Just like Read Reorder buffer, how to update Write Response reorder buffer when it is commmitted?
			WRbuff_rdptr <= WRbuff_rdptr + 1'b1;
			WRbuff[WRbuff_rdptr[2:0]][0] <= 1'b0;
			WRbuff[WRbuff_rdptr[2:0]][38] <= 1'b0;
			end
		end


/////////////Master to Router FIFO1//////////////////
assign IF_valid = !M2R_fifo_empty;

//-- Task 5: When to put/get packet into/from interface to router FIFO?
//write a valid packet when the fifo has enough space and there is a packet to be written
//read a packet when the router can accept a packet and the fifo has a packet to give
//assign M2R_fifo_write = ((ARVALID && AWREADY )==1) ? 1 : 0;
//assign M2R_fifo_read = ((RREADY && RVALID)==1)? 1: 0;
assign M2R_fifo_write = packet_valid && !M2R_fifo_full;
assign M2R_fifo_read = router_ready && !M2R_fifo_empty;

fifo #(.DEPTH(8), .DATA_WIDTH(160)) IF_to_router_FIFO (
		.clk(ACLK), 
		.resetn(ARESETn), 
		.put(M2R_fifo_write), 
		.get(M2R_fifo_read), 
		.data_in(w_packet), 
		.empty(M2R_fifo_empty), 
		.full(M2R_fifo_full), 
		.one_location(M2R_fifo_one), 
		.data_out(M2R_data_out)
		);


/////////////////Router to Master FIFO2///////////
assign R2M_fifo_write = (!R2M_fifo_full) && router_valid;
assign R2M_fifo_read = !R2M_fifo_empty;
assign R2M_fifo_out_type = R2M_fifo_out[19:17];
assign IF_ready = !R2M_fifo_full;

fifo #(.DEPTH(8), .DATA_WIDTH(160)) router_to_IF_FIFO (
		.clk(ACLK), 
		.resetn(ARESETn), 
		.put(R2M_fifo_write), 
		.get(R2M_fifo_read), 
		.data_in(R2M_data_input), 
		.empty(R2M_fifo_empty), 
		.full(R2M_fifo_full), 
		.data_out(R2M_fifo_out)
		);	

///////////////Unpacket////////////////
always@(posedge ACLK) 
	begin		
	if(ARESETn == 0) 
		begin
		Resp_in <= 0;
		RdDATA_in <= 0;
		unpacket_valid <= 0;
		end
	else 
		begin
		if(R2M_fifo_read) 
			begin
			if (R2M_fifo_out_type == 3'b100) 
				begin				//Packet type is read data
				rd_packet <= R2M_fifo_out;
				RdDATA_in <= 1;
				Resp_in <= 0;
				unpacket_valid <= 1;
				end
			else if(R2M_fifo_out_type == 3'b011) 
				begin			//Packet type is write response
				resp_packet <= R2M_fifo_out;
				Resp_in <= 1;
				RdDATA_in <= 0;
				unpacket_valid <= 1;
				end
			
			end
		else
			begin
			unpacket_valid <= 0;
			end
		end
	end

////////just for verifying write_response is completed in order//////
integer f_dump;
initial
	begin
		if(MASTERID==0) 
	begin
	f_dump = $fopen("./results/BRESP_addr0.dump", "w");
	end
if(MASTERID==1)
	begin
	f_dump = $fopen("./results/BRESP_addr1.dump", "w");
	end	
if(MASTERID==2)
	begin
	f_dump = $fopen("./results/BRESP_addr2.dump", "w");
	end	
if(MASTERID==3)
	begin
	f_dump = $fopen("./results/BRESP_addr3.dump", "w");		
	end	
end
	
	
/////////////Send data to master processor//////////////
always@(*)
begin
	if(RREADY && RVALID) 
		begin					//Data from the first entry of reorder buffer is ready to commit
		RDATA <= Rdbuff[Rdbuff_rdptr[2:0]][135:8];
		RID <= Rdbuff[Rdbuff_rdptr[2:0]][6:4];
		end
	else
		begin
		RDATA <= 128'd0;
		RID <= 3'd0;
		end	
	if(BREADY && BVALID) 
		begin
		BID <= WRbuff[WRbuff_rdptr[2:0]][3:1];
		BRESP <= WRbuff[WRbuff_rdptr[2:0]][5:4];
		$fwrite(f_dump, "%h\n", WRbuff[WRbuff_rdptr[2:0]][37:6]);
		end
	else
		begin
		BID <= 3'd0;
		BRESP <= 2'd0 ;
		end
end

endmodule

