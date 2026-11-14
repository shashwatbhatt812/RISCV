`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2026 11:34:02
// Design Name: 
// Module Name: reset_pattern
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


/*--------------- Reset Pattern ---------------*/
task reset_pattern ();
    begin
        Reset_tb = 1'b0 ; 
        #1
        Reset_tb = 1'b1 ;
        #1
        Reset_tb = 1'b0 ;
    end
endtask