`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2026 11:32:36
// Design Name: 
// Module Name: instr_memory
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

module instr_memory (
	input    wire	[7:0]	i_A  ,
	output   wire	[31:0]	o_RD  
	);

reg [31:0] mem [255:0] ; //1KB word-addressable ROM

initial 
	begin
		$readmemh("InstructionMem.txt", mem);
	end

assign  o_RD = mem[i_A] ;

endmodule