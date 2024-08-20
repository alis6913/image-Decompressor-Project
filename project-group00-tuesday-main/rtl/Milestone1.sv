
`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

// This is the top module (same as experiment4 from lab 5 - just module renamed to "project")
// It connects the UART, SRAM and VGA together.
// It gives access to the SRAM for UART and VGA
module M1 (
		/////// board clocks
		input logic clk,                  
        input logic reset,
        input logic M1_start,
        input logic [15:0] SRAM_read_data,

        output logic [17:0] M1_SRAM_Address,
        output logic [15:0] M1_SRAM_write_data,
        output logic M1_Status,
        output logic M1_SRAM_we_n
);

M1_state_type M1_state;

logic signed [31:0] R_Initial[1:0];
logic signed [31:0] G_Initial[1:0];
logic signed [31:0] B_Initial[1:0];

logic [7:0] r[1:0];
logic [7:0] g[1:0];
logic [7:0] b[1:0];

logic signed [31:0] Y_Register[1:0];
logic signed [31:0] U_Register;
logic signed [31:0] V_Register[1:0];

logic [47:0] U_Shift_Register;
logic [47:0] V_Shift_Register;

logic [7:0] U_buff;
logic [7:0] V_buff;

logic [17:0] Y_Counter, X_counter, Y_Address, U_Address, V_Address, RGB_Address;

logic signed [31:0] Product[3:0];
logic signed [31:0] Op0[3:0];
logic signed [31:0] Op1[3:0];

logic eol;


always @(posedge clk or negedge reset) begin
    if (~reset)begin

        M1_state <= M1_S_IDLE;
        M1_SRAM_we_n <= 1'b1;
        M1_Status <= 1'b0;

        Y_Register[0] <= 16'd0;
        Y_Register[1] <= 16'd0;

        U_Register <= 16'd0;

        V_Register[0] <= 16'd0;
        V_Register[1] <= 16'd0;

        U_Shift_Register <= 48'd0;
        V_Shift_Register <= 48'd0;

        U_buff <= 8'd0;
        V_buff <= 8'd0;

        X_counter <= 18'd0;
        Y_Counter <= 18'd0;
        eol <= 1'b0;

        Op0[0] <= 32'd0;
        Op0[1] <= 32'd0;
        Op0[2] <= 32'd0;
        Op0[3] <= 32'd0;

        Op1[0] <= 32'd0;
        Op1[1] <= 32'd0;
        Op1[2] <= 32'd0;
        Op1[3] <= 32'd0;

        R_Initial[0] <= 32'd0;
        R_Initial[1] <= 32'd0;

        G_Initial[0] <= 32'd0;
        G_Initial[1] <= 32'd0;

        B_Initial[0] <= 32'd0;
        B_Initial[1] <= 32'd0;

        Y_Address <= Y_START_ADDRESS;
        U_Address <= U_START_ADDRESS;
        V_Address <= V_START_ADDRESS;
        RGB_Address <= RGB_START_ADDRESS;

        end else begin

            case(M1_state)

            M1_S_IDLE: begin

                M1_Status <= 1'b0;

                if(M1_start) begin

                    M1_state <= M1_LI_0;
                    M1_SRAM_we_n <= 1'b1;
						  M1_Status <= 1'b0;

						  Y_Register[0] <= 16'd0;
						  Y_Register[1] <= 16'd0;

						  U_Register <= 16'd0;

						  V_Register[0] <= 16'd0;
						  V_Register[1] <= 16'd0;

						  U_Shift_Register <= 48'd0;
						  V_Shift_Register <= 48'd0;

						  U_buff <= 8'd0;
						  V_buff <= 8'd0;
 
                            X_counter <= 18'd0;
                            Y_Counter <= 18'd0;
                            eol <= 1'b0;

                            Op0[0] <= 32'd0;
                            Op0[1] <= 32'd0;
                            Op0[2] <= 32'd0;
                            Op0[3] <= 32'd0;

                            Op1[0] <= 32'd0;
                            Op1[1] <= 32'd0;
                            Op1[2] <= 32'd0;
                            Op1[3] <= 32'd0;

                            R_Initial[0] <= 32'd0;
                            R_Initial[1] <= 32'd0;

                            G_Initial[0] <= 32'd0;
                            G_Initial[1] <= 32'd0;

                            B_Initial[0] <= 32'd0;
                            B_Initial[1] <= 32'd0;
						  
						  
						  Y_Address <= Y_START_ADDRESS;
						  U_Address <= U_START_ADDRESS;
						  V_Address <= V_START_ADDRESS;
						  RGB_Address <= RGB_START_ADDRESS;

                end
            end
        
        M1_LI_0: begin
            
            M1_SRAM_Address  <= Y_Address;
            Y_Address <= Y_Address + 1'b1;

            X_counter <= X_counter + 2'd2;
            Y_Counter <= Y_Counter + 1'd1;

            M1_state <= M1_LI_1;

        end

        M1_LI_1: begin

            M1_SRAM_Address  <= V_Address;
            V_Address <= V_Address + 1'b1;

            M1_state <= M1_LI_2;

        end

        M1_LI_2: begin

            M1_SRAM_Address  <= U_Address;
            U_Address <= U_Address + 1'b1;

            M1_state <= M1_LI_3;

        end

        M1_LI_3: begin

            M1_SRAM_Address  <= V_Address;
            V_Address <= V_Address + 1'b1;

            Op0[0] <= {24'd0, (SRAM_read_data[15:8] - 16)};
            Op1[0] <= 32'sd76284;

            Op0[1] <= {24'd0, (SRAM_read_data[7:0] - 16)};
            Op1[1] <= 32'sd76284;

            M1_state <= M1_LI_4;

        end

        M1_LI_4: begin

            M1_SRAM_Address  <= U_Address;
            U_Address <= U_Address + 1'b1;

            V_Shift_Register[47:40] <= SRAM_read_data[15:8]; //V0
            V_Shift_Register[39:32] <= SRAM_read_data[15:8]; //V0
            V_Shift_Register[31:24] <= SRAM_read_data[15:8]; //V0
            V_Shift_Register[23:16] <= SRAM_read_data[7:0];  //V1

            Y_Register[0] <= Product[0];
            Y_Register[1] <= Product[1];

            M1_state <= M1_LI_5;

        end

        M1_LI_5: begin

            U_Shift_Register[47:40] <= SRAM_read_data[15:8]; //U0
            U_Shift_Register[39:32] <= SRAM_read_data[15:8]; //U0
            U_Shift_Register[31:24] <= SRAM_read_data[15:8]; //U0
            U_Shift_Register[23:16] <= SRAM_read_data[7:0];  //U1

            Op0[0] <= {24'd0, V_Shift_Register[31:24] - 128};
            Op1[0] <= 32'sd104595;

            Op0[1] <= {24'd0, V_Shift_Register[31:24] - 128};
            Op1[1] <= -32'sd53281;

            Op0[2] <= {24'd0, V_Shift_Register[47:40]};
            Op1[2] <= 32'sd21;

            Op0[3] <= {24'd0, V_Shift_Register[39:32]};
            Op1[3] <= 32'sd52;

            X_counter <= X_counter + 2'd2;
           
            M1_state <= M1_LI_6;

        end

        M1_LI_6: begin


            V_Shift_Register[15:8] <= SRAM_read_data[15:8];
            V_Shift_Register[7:0] <= SRAM_read_data[7:0];
            
            Op0[0] <= {24'd0, U_Shift_Register[31:24] - 128};
            Op1[0] <= -32'sd25624;

            Op0[1] <= {24'd0, U_Shift_Register[31:24] - 128};
            Op1[1] <= 32'sd132251;

            Op0[2] <= {24'd0, U_Shift_Register[47:40]};
            Op1[2] <= 32'sd21;

            Op0[3] <= {24'd0, U_Shift_Register[39:32]};
            Op1[3] <= 32'sd52;

            R_Initial[0] <= Y_Register[0] + Product[0]; 

            V_Register[0] <= Product[1];
            V_Register[1] <= (Product[2] - Product[3]);

            M1_state <= M1_LI_7;

        end

        M1_LI_7: begin

            M1_SRAM_Address  <= Y_Address;
            Y_Address <= Y_Address + 1'b1;

            U_Shift_Register[15:8] <= SRAM_read_data[15:8] ;
            U_Shift_Register[7:0] <= SRAM_read_data[7:0];

            Op0[0] <= {24'd0, V_Shift_Register[31:24]};
            Op1[0] <= 32'sd159;

            Op0[1] <= {24'd0, V_Shift_Register[23:16]};
            Op1[1] <= 32'sd159;

            Op0[2] <= {24'd0, V_Shift_Register[15:8]};
            Op1[2] <= 32'sd52;

            Op0[3] <= {24'd0, V_Shift_Register[7:0]};
            Op1[3] <= 32'sd21;

            G_Initial[0] <= (Y_Register[0] + V_Register[0] + Product[0]);
            B_Initial[0] <= (Y_Register[0] + Product[1]);

            U_Register <= (Product[2] - Product[3]);

            M1_state <= M1_LI_8;

        end

        M1_LI_8: begin
            if (X_counter < 8'd162) begin
                M1_SRAM_Address  <= V_Address;
                V_Address <= V_Address + 1'b1;
            end

            Op0[0] <= {24'd0, U_Shift_Register[31:24]};
            Op1[0] <= 32'sd159;

            Op0[1] <= {24'd0, U_Shift_Register[23:16]};
            Op1[1] <= 32'sd159;

            Op0[2] <= {24'd0, U_Shift_Register[15:8]};
            Op1[2] <= 32'sd52;

            Op0[3] <= {24'd0, U_Shift_Register[7:0]};
            Op1[3] <= 32'sd21;

            V_Register[1] <= (((V_Register[1] + Product[0] + Product[1] - Product[2] + Product[3] + 8'd128) >>> 8) - 8'd128);

            M1_state <= M1_CC_0;

        end

        M1_CC_0: begin

            if (X_counter < 8'd160) begin
                if (eol == 1'b0) begin
                    M1_SRAM_Address  <= U_Address;
                    U_Address <= U_Address + 1'b1;
                end
            end

            Op0[0] <= {16'd0, (V_Register[1])};
            Op1[0] <= 32'sd104595;

            Op0[1] <= {16'd0, (V_Register[1])};
            Op1[1] <= -32'sd53281;

            U_Register <= (((U_Register + Product[0] + Product[1] - Product[2] + Product[3] + 8'd128) >>> 8) - 8'd128);

            V_Shift_Register <= V_Shift_Register << 8;
            U_Shift_Register <= U_Shift_Register << 8;

            M1_state <= M1_CC_1;
            
            if (Y_Counter > 240) begin
                M1_Status <= 1'b1;
            end

        end

        M1_CC_1: begin

            M1_SRAM_we_n <= 1'b0;

            M1_SRAM_Address  <= RGB_Address;
            RGB_Address <= RGB_Address + 1'b1;

            M1_SRAM_write_data <= {r[0], g[0]};

            Op0[0] <= {24'd0, (SRAM_read_data[15:8] - 16)};
            Op1[0] <= 32'sd76284;

            Op0[1] <= {24'd0, (SRAM_read_data[7:0] - 16)};
            Op1[1] <= 32'sd76284;

            Op0[2] <= {16'd0, (U_Register )};
            Op1[2] <= -32'sd25624;

            Op0[3] <= {16'd0, (U_Register )};
            Op1[3] <= 32'sd132251;

            R_Initial[1] <= Y_Register[1] + Product[0];
            G_Initial[1] <= Y_Register[1] + Product[1];

            if (eol == 1'b1) begin
                U_Shift_Register[7:0] <= U_buff;
                V_Shift_Register[7:0] <= V_buff;
            end
        
            M1_state <= M1_CC_2;

        end

        M1_CC_2: begin

            M1_SRAM_we_n <= 1'b0;

            M1_SRAM_Address  <= RGB_Address;
            RGB_Address <= RGB_Address + 1'b1;

            M1_SRAM_write_data <= {b[0], r[1]};

            Op0[0] <= {24'd0, V_Shift_Register[31:24]-128};
            Op1[0] <= 32'sd104595;

            Op0[1] <= {24'd0, V_Shift_Register[31:24]-128};
            Op1[1] <= -32'sd53281;

            Op0[2] <= {24'd0, V_Shift_Register[47:40]};
            Op1[2] <= 32'sd21;

            Op0[3] <= {24'd0, V_Shift_Register[39:32]};
            Op1[3] <= 32'sd52;

            G_Initial[1] <= G_Initial[1] + Product[2];
            B_Initial[1] <= Y_Register[1] + Product[3];
         
            Y_Register[0] <= Product[0];
            Y_Register[1] <= Product[1];

            if (eol == 1'b0) begin

                if (X_counter > 8'd159) begin
                    // might not need this
                    V_Shift_Register[7:0] <= V_Shift_Register[15:8];
                    V_buff <= V_Shift_Register[15:8];

                end else begin

                    V_Shift_Register[7:0] <= SRAM_read_data[15:8];
                    V_buff <= SRAM_read_data[7:0];   

                end
            end

            M1_state <= M1_CC_3;

        end

        M1_CC_3: begin

            M1_SRAM_we_n <= 1'b0;

            M1_SRAM_Address  <= RGB_Address;
            RGB_Address <= RGB_Address + 1'b1;

            M1_SRAM_write_data <= {g[1], b[1]};

            Op0[0] <= {24'd0, U_Shift_Register[31:24]-128};
            Op1[0] <= 32'sd132251;

            Op0[1] <= {24'd0, U_Shift_Register[31:24]-128};
            Op1[1] <= -32'sd25624;

            Op0[2] <= {24'd0, U_Shift_Register[47:40]};
            Op1[2] <= 32'sd21;

            Op0[3] <= {24'd0, U_Shift_Register[39:32]};
            Op1[3] <= 32'sd52;
            
            R_Initial[0] <= Y_Register[0] + Product[0]; 

            V_Register[0] <= Product[1];
            V_Register[1] <= (Product[2] - Product[3]);

            if (eol == 1'b0) begin

                if (X_counter > 8'd159) begin

                    U_Shift_Register[7:0] <= U_Shift_Register[15:8];
                    U_buff <= U_Shift_Register[15:8];

                end else begin

                    U_Shift_Register[7:0] <= SRAM_read_data[15:8];
                    U_buff <= SRAM_read_data[7:0];   

                end
            end

            M1_state <= M1_CC_4;

        end

        M1_CC_4: begin

            M1_SRAM_we_n <= 1'b1;

            if (X_counter < 8'd162) begin
                M1_SRAM_Address  <= Y_Address;
                Y_Address <= Y_Address + 1'b1;
            end
            eol <= ~eol;

            Op0[0] <= {24'd0, V_Shift_Register[31:24]};
            Op1[0] <= 32'sd159;

            Op0[1] <= {24'd0, V_Shift_Register[23:16]};
            Op1[1] <= 32'sd159;

            Op0[2] <= {24'd0, V_Shift_Register[15:8]};
            Op1[2] <= 32'sd52;

            Op0[3] <= {24'd0, V_Shift_Register[7:0]};
            Op1[3] <= 32'sd21;

            U_Register <= (Product[2] - Product[3]);

            G_Initial[0] <= (Y_Register[0] + V_Register[0] + Product[1]);
            B_Initial[0] <= (Y_Register[0] + Product[0]);

            X_counter <= X_counter + 1'd1;

            M1_state <= M1_CC_5;

        end

        M1_CC_5: begin

            M1_SRAM_we_n <= 1'b1;

            if (X_counter < 8'd160) begin
                if (eol == 1'b0) begin
                    M1_SRAM_Address  <= V_Address;
                    V_Address <= V_Address + 1'b1;
                end
            end

            Op0[0] <= {24'd0, U_Shift_Register[31:24]};
            Op1[0] <= 32'sd159;

            Op0[1] <= {24'd0, U_Shift_Register[23:16]};
            Op1[1] <= 32'sd159;

            Op0[2] <= {24'd0, U_Shift_Register[15:8]};
            Op1[2] <= 32'sd52;

            Op0[3] <= {24'd0, U_Shift_Register[7:0]};
            Op1[3] <= 32'sd21;

            V_Register[1] <= (((V_Register[1] + Product[0] + Product[1] - Product[2] + Product[3] + 8'd128) >>> 8) - 8'd128);

                if(X_counter > 163)begin
						  M1_SRAM_we_n <= 1'b1;
						  M1_Status <= 1'b0;

						  Y_Register[0] <= 16'd0;
						  Y_Register[1] <= 16'd0;

						  U_Register <= 16'd0;

						  V_Register[0] <= 16'd0;
						  V_Register[1] <= 16'd0;

						  U_Shift_Register <= 48'd0;
						  V_Shift_Register <= 48'd0;

						  U_buff <= 8'd0;
						  V_buff <= 8'd0;

						  X_counter <= 18'd0;
						  eol <= 1'b0;

                            Op0[0] <= 32'd0;
                            Op0[1] <= 32'd0;
                            Op0[2] <= 32'd0;
                            Op0[3] <= 32'd0;

                            Op1[0] <= 32'd0;
                            Op1[1] <= 32'd0;
                            Op1[2] <= 32'd0;
                            Op1[3] <= 32'd0;

                            R_Initial[0] <= 32'd0;
                            R_Initial[1] <= 32'd0;

                            G_Initial[0] <= 32'd0;
                            G_Initial[1] <= 32'd0;

                            B_Initial[0] <= 32'd0;
                            B_Initial[1] <= 32'd0;  

                    M1_state <= M1_LI_0;

                end else begin

                    M1_state <= M1_CC_0;

                end
        end
        
            endcase
        end       
end


assign Product[0] = Op0[0] * Op1[0];
assign Product[1] = Op0[1] * Op1[1];
assign Product[2] = Op0[2] * Op1[2];
assign Product[3] = Op0[3] * Op1[3];

assign r[0] = (R_Initial[0][31]) ? 8'd0 : (|R_Initial[0][30:24]) ? 8'd255 : R_Initial[0][23:16];
assign g[0] = (G_Initial[0][31]) ? 8'd0 : (|G_Initial[0][30:24]) ? 8'd255 : G_Initial[0][23:16];
assign b[0] = (B_Initial[0][31]) ? 8'd0 : (|B_Initial[0][30:24]) ? 8'd255 : B_Initial[0][23:16];

assign r[1] = (R_Initial[1][31]) ? 8'd0 : (|R_Initial[1][30:24]) ? 8'd255 : R_Initial[1][23:16];
assign g[1] = (G_Initial[1][31]) ? 8'd0 : (|G_Initial[1][30:24]) ? 8'd255 : G_Initial[1][23:16];
assign b[1] = (B_Initial[1][31]) ? 8'd0 : (|B_Initial[1][30:24]) ? 8'd255 : B_Initial[1][23:16];
endmodule