`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2026 11:24:16
// Design Name: 
// Module Name: riscv_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module riscv_tb ();

reg	 		 CLK_tb       ;
reg	 		 Reset_tb 	  ;
wire [31:0]	 Instr_tb	  ;
wire [31:0]	 ReadData_tb  ;
wire [31:0]	 PC_tb		  ;
wire [31:0]	 ALUResult_tb ;
wire         MemWrite_tb  ;
wire [31:0]	 WriteData_tb ;

parameter CLK_PERIOD = 1 ; // 1 GHz Clk

riscv_top RISCV_DUT (
	.i_CLK		 (CLK_tb)       ,
	.i_Reset	 (Reset_tb)     ,
	.i_Instr	 (Instr_tb)     ,
	.i_ReadData  (ReadData_tb)  ,
	.o_PC	     (PC_tb)        ,
	.o_ALUResult (ALUResult_tb) ,
	.o_MemWrite  (MemWrite_tb)  ,
	.o_WriteData (WriteData_tb)      
	);

instr_memory i_mem (
	.i_A  (PC_tb[9:2]) ,
	.o_RD (Instr_tb)
	);

data_memory d_mem (
	.i_CLK   (CLK_tb)            , 
	.i_Reset (Reset_tb)          , 
	.i_A     (ALUResult_tb[9:2]) ,
	.i_WE    (MemWrite_tb)       ,
	.i_WD    (WriteData_tb)      ,
	.o_RD    (ReadData_tb)
	);


//-----Clock Generation
initial 
	begin
        CLK_tb  = 1'b1 ;     
        forever      
        #(CLK_PERIOD*0.5) CLK_tb = ~CLK_tb ;  		
	end
	
	
task reset_pattern ();
    begin
        Reset_tb = 1'b0 ; 
        #1
        Reset_tb = 1'b1 ;
        #1
        Reset_tb = 1'b0 ;
    end
endtask


reg [31:0] rd_reg   ; // Destination Register

always @(negedge CLK_tb) 
	begin
		rd_reg = Instr_tb[11:7] ;

		case (Instr_tb[6:0])
		//-- R-instructions
		7'b0110011: //add,sub,and,or
			begin
				case (Instr_tb[14:12])
				3'b000:
					begin
						if ({Instr_tb[5] , Instr_tb[30]} == 2'b11)
							begin
								$display("PC=%h %s Instruction | expected x%0d=%0d, actual is %0d" ,
									 	  PC_tb , "SUB " , rd_reg , rd_value , RISCV_DUT.datapath.Result) ;
							end
						else 
							begin
								$display("PC=%h %s Instruction | expected x%0d=%0d, actual is %0d" ,
										  PC_tb , "ADD " , rd_reg , rd_value , RISCV_DUT.datapath.Result) ;
							end
					end
				3'b110:
					begin
						$display("PC=%h %s Instruction | expected x%0d=%0d, actual is %0d" , 
								  PC_tb , "OR  " , rd_reg , rd_value , RISCV_DUT.datapath.Result) ;
					end
				3'b111:
					begin
						$display("PC=%h %s Instruction | expected x%0d=%0d, actual is %0d" ,
								  PC_tb , "AND " , rd_reg , rd_value , RISCV_DUT.datapath.Result) ;
					end
				endcase
			end

		//-- I-instructions
		7'b0010011: //addi,andi,ori
			begin
				case (Instr_tb[14:12])
				3'b000:
					begin
						$display("PC=%h %s Instruction | expected x%0d=%0d, actual is %0d" , 
								  PC_tb , "ADDI" , rd_reg , rd_value , RISCV_DUT.datapath.Result) ;
					end
				3'b110:
					begin
						$display("PC=%h %s Instruction | expected x%0d=%0d, actual is %0d" , 
								  PC_tb , "ORI " , rd_reg , rd_value , RISCV_DUT.datapath.Result) ;
					end
				3'b111:
					begin
						$display("PC=%h %s Instruction | expected x%0d=%0d, actual is %0d" ,
							      PC_tb , "ANDI" , rd_reg , rd_value , RISCV_DUT.datapath.Result) ;
					end
				endcase
			end
		7'b0000011: //lw
			begin
				case (Instr_tb[14:12])
				3'b010:
					begin
						$display("PC=%h %s Instruction | expected x%0d=%0d, actual is %0d" ,
							      PC_tb , "LW  " , rd_reg , rd_value , RISCV_DUT.datapath.Result) ;
					end
				endcase
			end
		7'b1100111: //jalr
			begin
				case (Instr_tb[14:12])
				3'b000:
					begin
						$display("PC=%h %s Instruction | expected x%0d=%0d, actual is %0d" , 
								  PC_tb , "JALR" , rd_reg , rd_value , RISCV_DUT.datapath.Result) ;
					end
				endcase
			end

		//-- B-instructions
		7'b1100011: //beq,bne
			begin
				case (Instr_tb[14:12])
				3'b000:
					begin
						$display("PC=%h %s Instruction" , 
								  PC_tb , "BEQ ") ;
					end
				3'b001:
					begin
						$display("PC=%h %s Instruction" , 
								  PC_tb , "BNE ") ;
					end
				endcase
			end

		//-- J-instructions
		7'b1101111: //jal
			begin
				$display("PC=%h %s Instruction | expected x%0d=%0h, actual is %0h" , 
						  PC_tb , "JAL " , rd_reg , rd_value , RISCV_DUT.datapath.Result) ;
			end

		//-- S-instructions
		7'b0100011: //sw
			begin
				rd_reg = Instr_tb[24:20] ;

				case (Instr_tb[14:12])
				3'b010:
					begin
						$display("PC=%h %s Instruction | expected x%0d=%0d, actual is %0d" , 
								  PC_tb , "SW  " , rd_reg , rd_value , RISCV_DUT.datapath.RD2) ;
					end
				endcase			
			end
		endcase
	end
	
	
	
reg [31:0] rd_value ; // Destination Register Value

always @(*) 
	begin
		case (PC_tb)
		32'h00: // x2 = 5
			begin
				rd_value = 32'd5 ;
			end
		32'h04: //  x3 = 12
			begin
				rd_value = 32'd12 ;
			end
		32'h08: //  x7 = (12 - 9) = 3
			begin
				rd_value = 32'd3 ;
			end
		32'h0C: //  x4 = (3 OR 5) = 7
			begin
				rd_value = 32'd7 ;
			end
		32'h10: //  x5 = (12 AND 7) = 4
			begin
				rd_value = 32'd4 ;
			end
		32'h14: //  x5 = 4 + 7 = 11
			begin
				rd_value = 32'd11 ;
			end
		32'h18: //  beq x5, x7, end (NO)
			begin
				rd_value = rd_reg ;
			end
		32'h1C: //  beq x4, x0, around (NO)
			begin
				rd_value = rd_reg ;
			end
		32'h20: //  addi x5, x0, 0
			begin
				rd_value = 32'd0 ;
			end
		32'h24: //  add x7, x4, x5  <-around
			begin
				rd_value = 32'd7 ;
			end
		32'h28: //  sub x7, x7, x2 
			begin
				rd_value = 32'd2 ;
			end
		32'h2C: //  sw x7, 84(x3) 
			begin
				rd_value = 32'd2 ;
			end
		32'h30: //  lw x2, 96(x0)  
			begin
				rd_value = 32'd2 ;
			end
		32'h34: //  add x9, x2, x5
			begin
				rd_value = 32'd2 ;
			end
		32'h38: //  jal x3, end 
			begin
				rd_value = 32'h3C ;
			end
		32'h3C: //  addi x2, x0, 1 
			begin
				rd_value = 32'd1 ;
			end
		32'h40: //  add x2, x2, x9  <-end
			begin
				rd_value = 32'd4 ;
			end
		32'h44: //  sw x2, 0x20(x3)
			begin
				rd_value = 32'd4 ;
			end
		32'h48: //  beq x2, x2, done  <-done
			begin
				rd_value = rd_reg ;
			end
		endcase
	end
	

initial
	begin
        reset_pattern();

        wait (PC_tb == 32'h48)
            begin
            	#1
            	$display("================================Data Memory Results================================") ;
            	$display("%0d is stored successfully in data memory[96]" , RISCV_DUT.datapath.du1_regfile.register[7]) ;
            	$display("%0d is stored successfully in data memory[92]" , RISCV_DUT.datapath.du1_regfile.register[2]) ;
                $stop ;
            end
	end
endmodule
