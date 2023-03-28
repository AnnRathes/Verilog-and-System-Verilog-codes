module traffic_control_binary (CLK, reset, ERR, PA, PB, L_A, L_B, RA, RB);
input CLK, reset, ERR, PA, PB;
output reg [2:0] L_A, L_B;
output reg RA, RB;

//OUTPUT
parameter	Flashing_Yellow	= 3'b000;	// Flashing_Yellow
parameter 	Flashing_Red = 3'b111;	// Flashing Red
parameter	Green_Arrow_Right = 3'b010;	// Green Arrow Right
parameter	Red = 3'b011;	// Red
parameter	Yellow = 3'b100;	// Yellow
parameter	Green_Arrow_Left = 3'b101;	// Green Arrow Left
parameter	Green = 3'b110;	// Green


		
//STATES
parameter STATE_0_PED_CROSSING = 3'b000;
parameter STATE_1 = 3'b001;
parameter STATE_2 = 3'b010;
parameter STATE_3 = 3'b011;
parameter STATE_4 = 3'b100;
parameter STATE_5 = 3'b101;
parameter STATE_6 = 3'b110;
parameter STATE_7_EXT_ERR = 3'b111;



reg [2:0] pres_state, next_state, count, temp_state, next_temp_state;

// ERR priority over reset
always @(posedge CLK) 
begin
	if(ERR) 
	begin
		pres_state <= STATE_7_EXT_ERR;
		count <= 0;
		temp_state <= STATE_1;
	end
	
	else if (reset) 
	begin
		pres_state <= STATE_7_EXT_ERR;
		count <= 0;
		temp_state <= STATE_1;
	end
	
	else 
	begin
		pres_state <= next_state;
		
		if(((pres_state == STATE_0_PED_CROSSING) && count < 5) || 
		((pres_state == STATE_1) && count < 7) || 
		((pres_state == STATE_2) && count < 2) || 
		((pres_state == STATE_3) && count < 2) || 
		((pres_state == STATE_4) && count < 7) || 
		((pres_state == STATE_5) && count < 2) ||
		((pres_state == STATE_6) && count < 2)) 
		begin
			count <= count + 1;
		end
		else 
			count <= 0;
	end
end

// RA and RB update
always @(posedge CLK) 
begin
	if(ERR) 
	begin
		RA <= 0;
		RB <= 0;
	end
	
	else if (reset) 
	begin
		RA <= 0;
		RB <= 0;
	end
	
	else 
	begin
		if(PA && !RA) 
			RA <= 1;
		if (PB && !RB) 
			RB <= 1;
				
		if((pres_state == STATE_0_PED_CROSSING) && (count == 5)) 
		begin
			RA <= 0;
			RB <= 0;
		end
		
		if(next_state == STATE_0_PED_CROSSING) 
		begin
			RA <= 1;
			RB <= 1;
		end
	end
end

// block for state transitions
always @(pres_state or count) 
begin
	case(pres_state)
		STATE_0_PED_CROSSING:
		begin
			L_A = Flashing_Red;
			L_B = Flashing_Red;
			if(count < 5)
			begin
				next_state = STATE_0_PED_CROSSING;
				next_temp_state = temp_state;
			end
			else 
			begin
				next_state = temp_state;
				next_temp_state = temp_state;
			end
		end
		STATE_1:
		begin
			L_A = Green;
			L_B = Red;
			if(count < 7)
			begin
				next_state = STATE_1;
				next_temp_state = temp_state;
			end
			else
			begin
				next_state = STATE_2;
				next_temp_state = temp_state;
			end
		end
		STATE_2:
		begin
			L_A = Green_Arrow_Left;
			L_B = Green_Arrow_Right;
			if(count < 2)
			begin
				next_state = STATE_2;
				next_temp_state = temp_state;
			end
			else
			begin
				next_state = STATE_3;
				next_temp_state = temp_state;
			end
		end
		STATE_3:
		begin
			L_A = Yellow;
			L_B = Green_Arrow_Right;
			if(count < 2)
			begin
				next_state = STATE_3;
				next_temp_state = temp_state;
			end
			else 
			begin
				if(RA || RB) 
				begin
					next_temp_state = STATE_4;
					next_state = STATE_0_PED_CROSSING;
				end
				else
				begin
					next_state = STATE_4;
					next_temp_state = STATE_1;
				end
			end
		end
		STATE_4:
		begin
			L_A = Red;
			L_B = Green;
			if(count < 7)
			begin
				next_state = STATE_4;
				next_temp_state = temp_state;
			end
			else
			begin
				next_state = STATE_5;
				next_temp_state = temp_state;
			end
		end
		STATE_5:
		begin
			L_A = Green_Arrow_Right;
			L_B = Green_Arrow_Left;
			if(count < 2)
			begin
				next_state = STATE_5;
				next_temp_state = temp_state;
			end
			else
			begin
				next_state = STATE_6;
				next_temp_state = temp_state;
			end
		end
		STATE_6:
		begin
			L_A = Green_Arrow_Right;
			L_B = Yellow;
			if(count < 2)
			begin
				next_state = STATE_6;
				next_temp_state = temp_state;
			end
			else 
			begin
				if(RA || RB) 
				begin
					next_temp_state = STATE_1;
					next_state = STATE_0_PED_CROSSING;
				end
				else
				begin
					next_state = STATE_1;
					next_temp_state = STATE_1;
				end
			end
		end
		STATE_7_EXT_ERR:
		begin
			next_state = STATE_0_PED_CROSSING;
			next_temp_state = STATE_1;	
			L_A = Flashing_Yellow;
			L_B = Flashing_Yellow;
		end
	endcase
end

endmodule
