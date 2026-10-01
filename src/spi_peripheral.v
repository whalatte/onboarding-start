`default_nettype none

module spi_peripheral (input [7:0] ui_in,
input clk,
input rst_n,

output reg [7:0] en_reg_out_7_0,
output reg [7:0] en_reg_out_15_8,
output reg [7:0] en_reg_pwm_7_0,
output reg [7:0] en_reg_pwm_15_8,
output reg [7:0] pwm_duty_cycle);

reg f_sclk;
reg s_sclk;
reg f_ncs;
reg s_ncs;
reg f_copi;
reg s_copi;
reg prev_sclk;
reg prev_ncs;
reg [15:0] store;
reg [4:0] count; 


always @(posedge clk) 
    if(!rst_n) begin
        f_sclk <= 0;
        s_sclk <= 0;
        f_ncs  <= 1;
        s_ncs  <= 1;
        f_copi <= 0;
        s_copi <= 0;
        prev_sclk <= 0;
        prev_ncs <= 1;
        store <= 0;
        count <= 0;

        en_reg_out_7_0  <= 0;
        en_reg_out_15_8 <= 0;
        en_reg_pwm_7_0  <= 0;
        en_reg_pwm_15_8 <= 0;
        pwm_duty_cycle <= 0;
        

    end else begin

        f_sclk <= ui_in[0];
        s_sclk <= f_sclk;
        f_ncs <= ui_in[2];
        s_ncs <= f_ncs;
        f_copi <= ui_in[1];
        s_copi <= f_copi;
        prev_sclk <= s_sclk;  //because using f_sclk may become unstable
        prev_ncs <= s_ncs;


        if (prev_ncs && !s_ncs) begin //start fresh for a new transaction when falling edge detected
            store <= 0;
            count <= 0;
        end

        else if (!s_ncs && !prev_sclk && s_sclk && (count < 16)) begin// see if theres a rising edge for sclk. store bits while nCS is low

                store <= {store[14:0], s_copi};
                count <= count + 1'b1;
                
        end 
            
        else if ((count == 16) && !prev_ncs && s_ncs && store[15]) begin //nCS is high, transaction finished, update registers now.

                    case (store [14:8])
                default: begin end
                7'h00: en_reg_out_7_0  <= store[7:0];
                7'h01: en_reg_out_15_8 <= store[7:0];
                7'h02: en_reg_pwm_7_0  <= store[7:0];
                7'h03: en_reg_pwm_15_8 <= store[7:0];
                7'h04: pwm_duty_cycle <= store[7:0];

                    endcase

         end

        end 



endmodule