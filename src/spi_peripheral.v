`default_nettype none

module spi_peripheral (



input  wire       clk,      // clock
input  wire       rst_n,     // reset_n - low to reset

//these are the three wire signals it is reading from the SPI bus

input wire SCLK, // SPI clock
input wire COPI, // SPI data in
input wire nCS,  // SPI chip select

//reverse of PWM think of the flow of ddata SPPI pin -> SPI -> 5 reg bytres -> PWM -> 16 pin output

output reg [7:0] en_reg_out_7_0,
output reg [7:0] en_reg_out_15_8,
output reg [7:0] en_reg_pwm_7_0,
output reg [7:0] en_reg_pwm_15_8,
output reg [7:0] pwm_duty_cycle





);

// Synchronizer chains makes the SPI pins safe to use
reg sclk_ff1; //sync 1
reg sclk_ff2; //sync 2
reg sclk_ff3; //sync 3

reg ncs_ff1; //sync 1
reg ncs_ff2; //sync 2
reg ncs_ff3; //sync 3

reg copi_ff1; //sync 1
reg copi_ff2; //sync 2
//reg copi_ff3; //sync 3
//sclk_rising — "did SCLK just go from low to high?"
//ncs_falling — "did a transaction just start?
//ncs_rising — "did a transaction just end?"

wire sclk_rising = sclk_ff2 & ~sclk_ff3;
wire ncs_falling = ~ncs_ff2 & ncs_ff3;
wire ncs_rising  = ncs_ff2 & ~ncs_ff3;

reg [15:0] shift_reg;//holding 16 bits of data
reg [4:0] bit_counter;//needs to count up to 16 in NUMERICAL value
//making the 000000000 or wtv out put copying format form pwm peripheral.v

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sclk_ff1 <= 1'b0;
        sclk_ff2 <= 1'b0;
        sclk_ff3 <= 1'b0;

        ncs_ff1 <= 1'b1;
        ncs_ff2 <= 1'b1;
        ncs_ff3 <= 1'b1;

        copi_ff1 <= 1'b0;
        copi_ff2 <= 1'b0;

        en_reg_out_7_0 <= 8'h00;
        en_reg_out_15_8 <= 8'h00;
        en_reg_pwm_7_0 <= 8'h00;
        en_reg_pwm_15_8 <= 8'h00;
        pwm_duty_cycle <= 8'h00;

        shift_reg <= 16'h0000;
        bit_counter <= 5'd0;
        
    end else begin
        sclk_ff1 <= SCLK;
        sclk_ff2 <= sclk_ff1;
        sclk_ff3 <= sclk_ff2;

        ncs_ff1 <= nCS;
        ncs_ff2 <= ncs_ff1;
        ncs_ff3 <= ncs_ff2;

        copi_ff1 <= COPI;
        copi_ff2 <= copi_ff1;


         en_reg_out_7_0 <= 8'h00;
        en_reg_out_15_8 <= 8'h00;
        en_reg_pwm_7_0 <= 8'h00;
        en_reg_pwm_15_8 <= 8'h00;
        pwm_duty_cycle <= 8'h00;

        if (ncs_falling) begin
            bit_counter <= 5'd0;
        end 

        else if (sclk_rising && !ncs_ff2) begin
            shift_reg <= {shift_reg[14:0], copi_ff2};
            bit_counter <= bit_counter + 1;
        end
        
    end

end



endmodule