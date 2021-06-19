`timescale 1ns/100ps

// This module takes a reference clock and drives 6 7-segment displays to display
// the time in HH:MM:SS format. It also contains a toggle switch for a time set mode
// and 3 push buttons to set the time columns. The accuracy will be limited to the
// internal clock
// DE2-115 SOC board
// note: switches are default logic 0 when in "down position"
//       buttons are active low (logic high when not pressed)
module RTCDriver(
	input logic clock50MHz, //50 MHz clock
	input logic [2:0] push_button, //increase digit
	input logic reset_button, // master reset
	input logic man_switch, //manual clock set
	output logic [5:0] seven_seg[7:0] //6 displays, arranged in pin format
	// 10-9-1-2-4-6-7 | g-f-e-d-c-b-a.

	// total input|outputs = 6|48
);

logic resetn;

// Divide the frequency to 1Hz through a buffer and edge detection
parameter max_1kHz_cnt = 24999; //50E6/25E3 = 2000x ~/sec
parameter max_1Hz_cnt = 24999999; //50E6/25E6 = 2x ~/sec

logic [15:0] clock1kHz_div_count;
logic [24:0] clock1Hz_div_count;
logic clock1Hzbuf;
logic clock1Hz;
logic count_en; //20 ns pulse for counter

logic [3:0] sec_ctr_0; //1s column of seconds
logic [3:0] sec_ctr_1; //10s column of seconds
logic [3:0] min_ctr_0; //1s column of minutes
logic [3:0] min_ctr_1; //10s column of minutes
logic [3:0] hr_ctr_0; //1s column of hours
logic [3:0] hr_ctr_1; //10s column of hours

//seven segment register pinouts
//0 for 1s column, 1 for 10s column
logic [6:0] sevsegHH0, sevsegHH1, sevsegMM0, sevsegMM1, sevsegSS0, sevsegSS1;

assign resetn = reset_button;

/** clock divider */
// add counter to reset clock every 0.5s
always_ff @(posedge clock50MHz or negedge resetn) begin : clock_divider_1Hz
	if (resetn == 1'b0) begin
		clock1Hz_div_count <= 1'b0;
	end
	else begin
		if (clock1Hz_div_count < max_1Hz_cnt) begin
			clock1Hz_div_count <= clock1Hz_div_count + 16'd1;
		end
		else begin
			clock1Hz_div_count <= 16'd0;
		end
	end
end
// invert clock every 0.5s
always_ff @(posedge clock50MHz or negedge resetn) begin : clock_invert_1Hz
	if (resetn == 1'b0) begin
		clock1Hz <= 1'b0;
	end
	else begin
		if (clock1Hz_div_count <= 23'd0) begin
			clock1Hz <= ~clock1Hz;
		end
	end
end
// buffer the 1Hz clock for use as a 20ns "pulse"
always_ff @(posedge clock50MHz or negedge resetn) begin : clock_buf_1Hz
	if (resetn == 1'b0) begin
		clock1Hzbuf <= 1'b0;
	end
	else begin
		clock1Hzbuf <= clock1Hz;
	end
end
// generate the 20ns pulse for the counter
always_comb begin : counter_enable
	count_en = clock1Hz & ~clock1Hzbuf;
end

/** HH:MM:SS counters */
// seconds counter
always_ff @(posedge clock50MHz or negedge resetn) begin : seconds_counter
	if (resetn == 1'b0) begin
		sec_ctr_0 <= 4'd0;
        sec_ctr_1 <= 4'd0;
	end
	else begin
		if (man_switch && count_en) begin
            sec_ctr_0 <= sec_ctr_0 + 4'd1;
		end
	end
end


/**
// 1kHz clock divider (shift register button debouncing)
always_ff @(posedge clock50MHz or negedge resetn) begin : clock_divider_1kHz
	if (resetn == 1'b0) begin
		clock1kHz_div_count <= 16'd0
	end
end
*/

endmodule