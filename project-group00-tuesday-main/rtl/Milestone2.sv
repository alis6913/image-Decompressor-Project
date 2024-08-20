`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

// This is the top module (same as experiment4 from lab 5 - just module renamed to "project")
// It connects the UART, SRAM and VGA together.
// It gives access to the SRAM for UART and VGA
module M2 (
		/////// board clocks
		input logic clk,                  
        input logic reset,
        input logic M2_start,
        input logic [15:0] SRAM_read_data,

        output logic [17:0] M2_SRAM_Address,
        output logic [15:0] M2_SRAM_write_data,
        output logic M2_Status,
        output logic M2_SRAM_we_n
);

M2_state_type M2_state;

logic [6:0] address_a [2:0];
logic [6:0] address_b [2:0];

logic [31:0] write_data_b [2:0];
logic write_enable_b [2:0];
logic [31:0] read_data_a [2:0];
logic [31:0] read_data_b [2:0];


dual_port_RAM0 dual_port_RAM_inst0 (
	.address_a ( address_a[0] ),
	.address_b ( address_b[0] ),
	.clock ( clk ),
	.data_a ( 32'h00 ),
	.data_b ( write_data_b[0] ),
	.wren_a ( 1'b0 ),
	.wren_b ( write_enable_b[0] ),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
	);

dual_port_RAM1 dual_port_RAM_inst1 (
	.address_a ( address_a[1] ),
	.address_b ( address_b[1] ),
	.clock ( clk ),
	.data_a ( 32'h00 ),
	.data_b ( write_data_b[1] ),
	.wren_a ( 1'b0 ),
	.wren_b ( write_enable_b[1] ),
	.q_a ( read_data_a[1] ),
	.q_b ( read_data_b[1] )
	);

dual_port_RAM2 dual_port_RAM_inst2 (
	.address_a ( address_a[2] ),
	.address_b ( address_b[2] ),
	.clock ( clk ),
	.data_a ( 32'h00 ),
	.data_b ( write_data_b[2] ),
	.wren_a ( 1'b0 ),
	.wren_b ( write_enable_b[2] ),
	.q_a ( read_data_a[2] ),
	.q_b ( read_data_b[2] )
	);

logic [4:0] S_Address;
logic [5:0] LeadCounter, T_Counter, RCindex, RowTrack, ColTrack, S_P_Counter, TCC_write_counter;
logic [6:0] SC_Counter;

logic signed [31:0] Product[3:0];
logic signed [31:0] Op0[3:0];
logic signed [31:0] Op1[3:0];
logic signed [31:0] c[3:0]; // might not need

logic [127:0] SP_Register;
logic [27:0] T_Hold_Register;

logic [1:0] YUVflag;
logic [8:0] ColRegister;
logic [11:0] RowRegister;

logic [17:0] BaseAddress;

logic [15:0] LoadBuff;
logic TCCflag, TCCLoopFlag, TCC_op_flip,TCC_Write_flag;

always_comb begin

	//BaseAddress = 17'd76800;

	if (YUVflag == 2'd0) begin //Y read
		if (RCindex[2:0] == 3'b111) begin
			RowRegister = RowRegister + 320;
		end
		if (RCindex == 6'b111111) begin
			ColRegister = ColRegister + 8;
			RowRegister = 0;
			ColTrack = ColTrack + 1;
		end
		if (RCindex == 6'b111111 && RowTrack == 39) begin
			ColTrack = 0;
			BaseAddress = BaseAddress + 2560;
			RowTrack = RowTrack + 1;
			RowRegister = 0;
			ColRegister = 0
			if (RowTrack == 29) begin
				YUVflag = YUVflag + 1;
				BaseAddress = 153600;
			end
		end
	end 
	if (YUVflag == 2'd1) begin //U read
		if (RCindex[2:0] == 3'b111) begin
			RowRegister = RowRegister + 320;
		end
		if (RCindex == 6'b111111) begin
			ColRegister = ColRegister + 8;
			RowRegister = 0;
			ColTrack = ColTrack + 1;
		end
		if (RCindex == 6'b111111 && RowTrack == 19) begin
			ColTrack = 0;
			BaseAddress = BaseAddress + 1280;
			RowTrack = RowTrack + 1;
			RowRegister = 0;
			ColRegister = 0
			if (RowTrack == 29) begin
				YUVflag = YUVflag + 1;
				BaseAddress = 153760;
			end
		end
	end 
	if (YUVflag == 2'd2) begin //V read
		if (RCindex[2:0] == 3'b111) begin
			RowRegister = RowRegister + 320;
		end
		if (RCindex == 6'b111111) begin
			ColRegister = ColRegister + 8;
			RowRegister = 0;
			ColTrack = ColTrack + 1;
		end
		if (RCindex == 6'b111111 && RowTrack == 19) begin
			ColTrack = 0;
			BaseAddress = BaseAddress + 1280;
			RowTrack = RowTrack + 1;
			RowRegister = 0;
			ColRegister = 0
			if (RowTrack == 29) begin
				YUVflag = YUVflag + 1;
			end
		end
	end 
	if (YUVflag == 2'd3) begin // done all reads
		YUVflag = 0; //TEMP
	end 
end


always @(posedge clk or negedge reset) begin
	if (~reset)begin

		M2_state <= M2_S_IDLE;

		Op0[0] <= 32'd0;
        Op0[1] <= 32'd0;
        Op0[2] <= 32'd0;
        Op0[3] <= 32'd0;

        Op1[0] <= 32'd0;
        Op1[1] <= 32'd0;
        Op1[2] <= 32'd0;
        Op1[3] <= 32'd0;

		S_Address <= 5'd0;
		LeadCounter <= 6'd0;
		T_Counter <= 6'd0;
		SC_Counter <= 7'd0;
		TCCflag <= 1'b0;
        TCCLoopFlag <= 1'b0;
        TCC_op_flip <= 1'b0;
        TCC_Write_flag <= 1'b0;
        S_P_Counter <= 5'd0;

		SP_Register <= 127'd0;

		BaseAddress = 17'd76800;



	end else begin

            case(M2_state)

            M1_S_IDLE: begin

                M2_Status <= 1'b0;

                if(M2_start) begin

					M2_state <= M2_LI_0;

					Op0[0] <= 32'd0;
					Op0[1] <= 32'd0;
					Op0[2] <= 32'd0;
					Op0[3] <= 32'd0;

					Op1[0] <= 32'd0;
					Op1[1] <= 32'd0;
					Op1[2] <= 32'd0;
					Op1[3] <= 32'd0;

					S_Address <= 5'd0;
					LeadCounter <= 6'd0;
					T_Counter <= 6'd0;
					SC_Counter <= 7'd0;
					TCCflag <= 1'b0;
                    TCCLoopFlag <= 1'b0;
                    TCC_op_flip <= 1'b0;
                    TCC_Write_flag <= 1'b0;
                    S_P_Counter <= 5'd0;

					SP_Register <= 127'd0;

					BaseAddress = 17'd76800;
				end
			end

			M2_LI_0: begin
				M2_SRAM_Address <= BaseAddress + RCindex + ColRegister + RowRegister;
				RCindex <= RCindex + 1'b1;

				M2_state <= M2_LI_1;
			end

			M2_LI_1: begin
				M2_SRAM_Address <= BaseAddress + RCindex + ColRegister + RowRegister;
				RCindex <= RCindex + 1'b1;

				M2_state <= M2_LI_2;
			end

			M2_LI_2: begin
				M2_SRAM_Address <= BaseAddress + RCindex + ColRegister + RowRegister;
				RCindex <= RCindex + 1'b1;

				M2_state <= M2_LI_3;
			end

			M2_LI_3: begin
				if (LeadCounter < 60) begin
					M2_SRAM_Address <= BaseAddress + RCindex + ColRegister + RowRegister;
					RCindex <= RCindex + 1'b1;
				end
				LeadCounter <= LeadCounter + 1'b1;

				LoadBuff <= SRAM_read_data;
				write_enable_b[0] <= 1'b0;

				if(LeadCounter == 63) begin
					M2_state <= M2_T_CC_0;
				end else begin
					M2_state <= M2_LI_4;
				end
				
			end

			M2_LI_4: begin
				if (LeadCounter < 61) begin
					M2_SRAM_Address <= BaseAddress + RCindex + ColRegister + RowRegister;
					RCindex <= RCindex + 1'b1;
				end
				LeadCounter <= LeadCounter + 1'b1;

				write_enable_b[0] <= 1'b1;
				address_b[0] <= S_Address;
				write_data_b[0] <= {LoadBuff,SRAM_read_data};
				S_Address <= S_Address + 1'b1;

				M2_state <= M2_LI_3;

			end

			M2_T_CC_0: begin

                address_a[0] <= S_P_Counter;
                address_b[0] <= S_P_Counter + 1;
                S_P_Counter <= S_P_Counter + 2;

                M2_state <= M2_T_CC_1;

			end

			M2_T_CC_1: begin

                address_a[0] <= S_P_Counter;
                address_b[0] <= S_P_Counter + 1;
                S_P_Counter <= S_P_Counter + 2;

                M2_state <= M2_T_CC_2;
			end

			M2_T_CC_2: begin
                
                SP_Register[127:64] <= {read_data_a[0],read_data_b[0]};
                TCCLoopFlag <= 1'b0;
                TCC_op_flip <= 1'b0;

                M2_state <= M2_T_CC_3;

                if(SC_Counter == 7'b1111111)begin
                    M2_state <= M2_S_CC_0;
                end
			end

			M2_T_CC_3: begin

                SC_Counter <= SC_Counter + 1;

                if(TCCLoopFlag == 1'b1) begin
                    SP_Register[63:0] <= {read_data_a[0],read_data_b[0]};
                end

                if (TCC_op_flip == 0) begin
                    Op0[0] <= {16'd0, (SP_Register[127:112])};
                    Op0[1] <= {16'd0, (SP_Register[111:96])};
                    Op0[2] <= {16'd0, (SP_Register[95:80])};
                    Op0[3] <= {16'd0, (SP_Register[79:64])};

                    if(TCCflag == 1) begin
                        address_b[1 + TCC_Write_flag] <= TCC_write_counter[5:1];
                        TCC_write_counter <= TCC_write_counter +1;
                        write_enable_b[1 + TCC_Write_flag] <= 1'b1;
                        write_data_b[1 + TCC_Write_flag] <= ((T_Hold_Register + Product[0] + Product[1] + Product[2] + Product[3]) >>> 8)
                        TCC_Write_flag <= ~TCC_Write_flag;

                    end

                end else begin
                    Op0[0] <= {16'd0, (SP_Register[63:48])};
                    Op0[1] <= {16'd0, (SP_Register[47:32])};
                    Op0[2] <= {16'd0, (SP_Register[31:16])};
                    Op0[3] <= {16'd0, (SP_Register[15:0])};

                    T_Hold_Register <= (Product[0] + Product[1] + Product[2] + Product[3]) 

                end
                
                
                if (SC_Counter[3:0] == 4'b1100) begin
                    M2_state <= M2_T_CC_0;
                    TCCLoopFlag <= 1'b0;
                end else begin
                    M2_state <= M2_T_CC_3;
                    TCCLoopFlag <= 1'b1;
                    TCC_op_flip <= ~TCC_op_flip;
                end

                TCCflag <= 1'b1;

			end

			M2_S_CC_0: begin

				address_a[0] <= S_P_Counter;
                address_b[0] <= S_P_Counter + 1;
                S_P_Counter <= S_P_Counter + 2;

                M2_state <= M2_S_CC_1;
				
			end

			M2_S_CC_1: begin
                address_a[0] <= S_P_Counter;
                address_b[0] <= S_P_Counter + 1;
                S_P_Counter <= S_P_Counter + 2;

                M2_state <= M2_S_CC_2;
			end

			M2_S_CC_2: begin

                SP_Register[127:64] <= {read_data_a[0],read_data_b[0]};
                TCCLoopFlag <= 1'b0;
                TCC_op_flip <= 1'b0;

                M2_state <= M2_T_CC_3;

                if(SC_Counter == 7'b1111111)begin
                    M2_state <= M2_S_CC_0;
                end
				
			end

			M2_S_CC_3: begin
                SC_Counter <= SC_Counter + 1;

                if(TCCLoopFlag == 1'b1) begin
                    SP_Register[63:0] <= {read_data_a[0],read_data_b[0]};
                end

                if (TCC_op_flip == 0) begin
                    Op0[0] <= {16'd0, (SP_Register[127:112])};
                    Op0[1] <= {16'd0, (SP_Register[111:96])};
                    Op0[2] <= {16'd0, (SP_Register[95:80])};
                    Op0[3] <= {16'd0, (SP_Register[79:64])};

                    if(TCCflag == 1) begin
                        address_b[1 + TCC_Write_flag] <= TCC_write_counter[5:1];
                        TCC_write_counter <= TCC_write_counter +1;
                        write_enable_b[1 + TCC_Write_flag] <= 1'b1;
                        write_data_b[1 + TCC_Write_flag] <= ((T_Hold_Register + Product[0] + Product[1] + Product[2] + Product[3]) >>> 8)
                        TCC_Write_flag <= ~TCC_Write_flag;

                    end

                end else begin
                    Op0[0] <= {16'd0, (SP_Register[63:48])};
                    Op0[1] <= {16'd0, (SP_Register[47:32])};
                    Op0[2] <= {16'd0, (SP_Register[31:16])};
                    Op0[3] <= {16'd0, (SP_Register[15:0])};

                    T_Hold_Register <= (Product[0] + Product[1] + Product[2] + Product[3]) 

                end
                
                
                if (SC_Counter[3:0] == 4'b1100) begin
                    M2_state <= M2_T_CC_0;
                    TCCLoopFlag <= 1'b0;
                end else begin
                    M2_state <= M2_T_CC_3;
                    TCCLoopFlag <= 1'b1;
                    TCC_op_flip <= ~TCC_op_flip;
                end

                TCCflag <= 1'b1;	
			end

			endcase
	end
end

assign Product[0] = Op0[0] * Op1[0];
assign Product[1] = Op0[1] * Op1[1];
assign Product[2] = Op0[2] * Op1[2];
assign Product[3] = Op0[3] * Op1[3];

//C LUT for T_CC (ordered by collumn)
always_comb begin
	case(SC_Counter[3:0])
		4'b0000: begin 
			Op1[0] = 32'sd1448;  //C00
			Op1[1] = 32'sd2008;  //C10
			Op1[2] = 32'sd1892;  //C20
			Op1[3] = 32'sd1702;  //C30 
		end 
		4'b0001: begin  
			Op1[0] = 32'sd1448;   //C40
			Op1[1] = 32'sd1137;   //C50
			Op1[2] = 32'sd783;    //C60
			Op1[3] = 32'sd399;    //C70
		end
		4'b0010: begin 
			Op1[0] = 32'sd1448;   //C01
			Op1[1] = 32'sd1702;   //C11
			Op1[2] = 32'sd783;    //C21
			Op1[3] = -32'sd399;   //C31
		end  		
		4'b0011: begin
			Op1[0] = -32'sd1448;  //C41
			Op1[1] = -32'sd2008;  //C51
			Op1[2] = -32'sd1892;  //C61
			Op1[3] = -32'sd1137;  //C71
		end   
		4'b0100: begin
			Op1[0] = 32'sd1448;   //C02
			Op1[1] = 32'sd1137;   //C12
			Op1[2] = -32'sd783;   //C22
			Op1[3] = -32'sd2008;  //C32
		end      
		4'b0101: begin
			Op1[0] = -32'sd1448;  //C42
			Op1[1] = 32'sd399;    //C52
			Op1[2] = 32'sd1892;   //C62
			Op1[3] = 32'sd1702;   //C72
		end      
		4'b0110: begin
			Op1[0] = 32'sd1448;   //C03
			Op1[1] = 32'sd399;    //C13
			Op1[2] = -32'sd1892;  //C23
			Op1[3] = -32'sd1137;  //C33
		end      
		4'b0111: begin
			Op1[0] = 32'sd1448;   //C43
			Op1[1] = 32'sd1702;   //C53
			Op1[2] = -32'sd783;   //C63
			Op1[3] = -32'sd2008;  //C73
		end      
		4'b1000: begin
			Op1[0] = 32'sd1448;   //C04
			Op1[1] = -32'sd399;   //C14
			Op1[2] = -32'sd1892;  //C24
			Op1[3] = 32'sd1137;   //C34
		end      
		4'b1001: begin
			Op1[0] = 32'sd1448;   //C44
			Op1[1] = -32'sd1702;  //C54
			Op1[2] = -32'sd783;   //C64
			Op1[3] = 32'sd2008;   //C74
		end      
		4'b1010: begin
			Op1[0] = 32'sd1448;   //C05
			Op1[1] = -32'sd1137;  //C15
			Op1[2] = -32'sd783;   //C25
			Op1[3] = 32'sd2008;   //C35
		end     
		4'b1011: begin
			Op1[0] = -32'sd1448;  //C45
			Op1[1] = -32'sd399;   //C55
			Op1[2] = 32'sd1892;   //C65
			Op1[3] = -32'sd1702;  //C75
		end     
		4'b1100: begin
			Op1[0] = 32'sd1448;   //C06
			Op1[1] = -32'sd1702;  //C16
			Op1[2] = 32'sd783;    //C26
			Op1[3] = 32'sd399;    //C36
		end     
		4'b1101: begin
			Op1[0] = -32'sd1448;  //C46
			Op1[1] = 32'sd2008;   //C56
			Op1[2] = -32'sd1892;  //C66
			Op1[3] = 32'sd1137;   //C76
		end     
		4'b1110: begin
			Op1[0] = 32'sd1448;   //C07
			Op1[1] = -32'sd2008;  //C17
			Op1[2] = 32'sd1892;   //C27
			Op1[3] = -32'sd1702;  //C37
		end     
		4'b1111: begin
			Op1[0] = 32'sd1448;   //C47
			Op1[1] = -32'sd1137;  //C57
			Op1[2] = 32'sd783;    //C67
			Op1[3] = -32'sd399;   //C77
		end    
	endcase
end

endmodule