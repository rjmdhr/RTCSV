'timescale 1ns/100ps

// This module takes a reference clock and drives 6 7-segment displays to display
// the time in HH:MM:SS format. It also contains a toggle switch for a time set mode
// and 3 push buttons to set the time columns. The accuracy will be limited to the
// internal clock
module RTCDriver(
	input logic clock50MHz, //50 MHz clock
	input logic [3:0] push_button, //increase digit
	input logic switch, //manual mode
	output logic [5:0] seven_seg[7:0] //6 displays, arranged in pin format 
	// 10-9-1-2-4-6-7 | g-f-e-d-c-b-a.
);

logic resetn;

// Divide the frequency to 1Hz through a buffer and edge dete
parameter 1kHz_count = 24999; //50E6/25E3 = 2000 ~/sec
parameter 1Hz_count = 24999999; //50E6/25E6 = 2 ~/sec

logic [15:0] clock1kHz_div_count;
logic [24:0] clock1Hz_div_count;
logic clock1Hzbuf;
logic clock1Hz;

logic [5:0] sec_counter;
logic [5:0] min_counter;
logic [3:0] hour_counter;
logic count_en; //1ns pulse

logic [6:0] 7_seg_HH, 7_seg_MM, 7_seg_ss;

// divide the clock down to 1Hz
always_ff @(posedge clock50MHz or negedge resetn) begin : clock_divider
	if (resetn == 1'b0) begin
		clock1Hz_div_count <= 0;
	end
	else begin
		if (clock1Hz_div_count < 1Hz_count) begin
			clock1Hz_div_count <= clock1Hz_div_count + 16'd1;
		end
		else begin
			clock1Hz_div_count <= 16'd0;
			clock1Hz <= ~clock1Hz;
		end
	end
end


	


end module 