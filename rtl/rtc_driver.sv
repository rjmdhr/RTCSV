`timescale 1ns/1ns

// This module takes a reference clock and drives 6 7-segment displays to display
// the time in HH:MM:SS format. It also contains a toggle switch for a time set mode
// and 3 push buttons to set the time columns. The accuracy will be limited to the
// internal clock
// note: switches are default logic 0 when in "down position"
//       buttons are active high (logic low when not pressed)
module rtc_driver (
	input logic clk, //50 MHz clock (20ns)
	input logic [2:0] push_but, //increase digit
	input logic rst, // master reset
	input logic man_sw, //manual clock set
	output logic [5:0] sev_seg[6:0] //6 displays, arranged in pin format;
	// 10-9-1-2-4-6-7 | g-f-e-d-c-b-a.
	// total input|outputs = 6|48
);

// divisors for 1Hz and 1kHz clock enables
parameter div1kHz = 24999; //50E6/25E3 = 2000x ~/sec
parameter div1Hz = 24999999; //50E6/25E6 = 2x ~/sec

logic [24:0] cnt1Hz;
logic cnten; //count enable
logic [15:0] cnt1kHz;
logic shiften; //shift reg enable

// counters (1 is 10s column, 0 is 1s column)
logic [3:0] sec0;
logic [2:0] sec1;
logic [3:0] min0;
logic [2:0] min1;
logic [3:0] hr0;
logic [1:0] hr1;

// shift register debouncers
logic [9:0] shiftreg [2:0];
logic pbstat [2:0];
logic pbstatbuf [2:0];
logic pben [2:0];

// seven segment output registers
// 0 for 1s column, 1 for 10s column
logic [6:0] ssH0, ssH1, ssM0, ssM1, ssS0, ssS1;

/** 1Hz clock enable for displays */
always_ff @(posedge clk or negedge rst) begin
	if (rst == 1'b0) begin
		cnt1Hz <= 25'd0;
		cnten <= 1'b0;
	end
	else begin
		if (cnt1Hz == div1Hz) begin
			cnten <= 1'b1;
			cnt1Hz <= 25'd0;
		end
		else begin
			cnten <= 1'b0;
			cnt1Hz <= cnt1Hz + 25'd1;
		end
	end
end

/** 1kHz clock enable for shift register debouncers */
always_ff @(posedge clk or negedge rst) begin
	if (rst == 1'b0) begin
		cnt1kHz <= 16'd0;
		shiften <= 1'b0;
	end
	else begin
		if (cnt1Hz == div1kHz) begin
			shiften <= 1'b1;
			cnt1kHz <= 16'd0;
		end
		else begin
			shiften <= 1'b0;
			cnt1kHz <= cnt1kHz + 16'd1;
		end
	end
end

/* Button debouncers */
always_ff @(posedge clk or negedge rst) begin
	if (rst == 1'b0) begin
		shiftreg[0] <= 10'd0;
		shiftreg[1] <= 10'd0;
		shiftreg[2] <= 10'd0;
	end
	else begin
		if (shiften) begin
			shiftreg[0] <= {shiftreg[0][8:0], ~push_but[0]};
			shiftreg[1] <= {shiftreg[1][8:0], ~push_but[1]};
			shiftreg[2] <= {shiftreg[2][8:0], ~push_but[2]};
		end
	end
end
// eliminate transients and buff the push button status
always_ff @(posedge clk or negedge rst) begin
	if (rst == 1'b0) begin
		pbstat <= {default:0};
		pbstatbuf <= {default:0};
	end
	else begin
		pbstat <= {|shiftreg[2],|shiftreg[1],|shiftreg[0]};
		pbstatbuf <= {pbstat[2],pbstat[1],pbstat[0]};
	end
end
// enable pulse for manual push buttons
always_comb begin
	pben[0] = pbstat[0]&&~pbstatbuf[0]; //seconds
	pben[1] = pbstat[1]&&~pbstatbuf[1]; //minutes
	pben[2] = pbstat[2]&&~pbstatbuf[2]; //hours
end

/** HH:MM:SS counters */
// seconds counter - increments and resets at 59
always_ff @(posedge clk or negedge rst) begin : seconds_counter
	if (rst == 1'b0) begin
		sec0 <= 4'd0;
		sec1 <= 3'd0;
	end
	else begin
		// auto
		if (~man_sw) begin
			if (cnten) begin
				if (sec0 < 4'd9) begin
					sec0 <= sec0 + 4'd1;
				end
				else begin
					if (sec1 == 3'd5) begin
						sec1 <= 3'd0;
						sec0 <= 4'd0;
					end
					else begin
						sec1 <= sec1 + 3'd1;
						sec0 <= 4'd0;
					end
				end
			end
		end
		// manual (increment behaviour is equivalent)
		else begin
			if (pben[0]) begin
				if (sec0 < 4'd9) begin
					sec0 <= sec0 + 4'd1;
				end
				else begin
					if (sec1 == 3'd5) begin
						sec1 <= 3'd0;
						sec0 <= 4'd0;
					end
					else begin
						sec1 <= sec1 + 3'd1;
						sec0 <= 4'd0;
					end
				end
			end
		end
	end
end
// minutes counter - increments every minute at the seconds reset
always_ff @(posedge clk or negedge rst) begin : minutes_counter
	if (rst == 1'b0) begin
		min0 <= 4'd0;
		min1 <= 3'd0;
	end
	else begin
		// auto
		if (~man_sw) begin
			if (cnten) begin
				if (sec1 == 3'd5 && sec0 == 4'd9) begin
					if (min0 < 4'd9) begin
						min0 <= min0 + 4'd1;
					end
					else begin
						if (min1 == 3'd5) begin
							min1 <= 3'd0;
							min0 <= 4'd0;
						end
						else begin
							min1 <= min1 + 3'd1;
							min0 <= 4'd0;
						end
					end
				end
			end
		end
		// manual (increments need not rely on seconds turnover ~ 59->0)
		else begin
			if (pben[1]) begin
				if (min0 < 4'd9) begin
					min0 <= min0 + 4'd1;
				end
				else begin
					if (min1 == 3'd5) begin
						min1 <= 3'd0;
						min0 <= 4'd0;
					end
					else begin
						min1 <= min1 + 3'd1;
						min0 <= 4'd0;
					end
				end
			end
		end
	end
end
// hours counter - increments every hour at the seconds reset (24 hour time)
always_ff @(posedge clk or negedge rst) begin : hours_counter
	if (rst == 1'b0) begin
		hr0 <= 4'd0;
		hr1 <= 2'd0;
	end
	else begin
		// auto
		if (~man_sw) begin
			if (cnten) begin
				if (sec1 == 3'd5 && sec0 == 4'd9) begin
					if (min1 == 3'd5 && min0 == 4'd9) begin
						if (hr1 == 2'd2 && hr0 == 4'd3) begin
							hr1 <= 2'd0;
							hr0 <= 4'd0;
						end
						else begin
							if (hr0 < 4'd9) begin
								hr0 <= hr0 + 4'd1;
							end
							else begin
								hr1 <= hr1 + 2'd1;
								hr0 <= 4'd0;
							end
						end
					end
				end
			end
		end
		// manual (increments need not rely on minutes & seconds turnover)
		else begin
			if (pben[2]) begin
				if (hr1 == 2'd2 && hr0 == 4'd3) begin
					hr1 <= 2'd0;
					hr0 <= 4'd0;
				end
				else begin
					if (hr0 < 4'd9) begin
						hr0 <= hr0 + 4'd1;
					end
					else begin
						hr1 <= hr1 + 2'd1;
						hr0 <= 4'd0;
					end
				end
			end
		end
	end
end

// seven segment decoder instantiations
sev_seg_dec second0 (
	.dec_val(sec0[3:0]),
	.ss_val(ssS0[6:0])
);

sev_seg_dec second1 (
	.dec_val(sec1[2:0]),
	.ss_val(ssS1[6:0])
);

sev_seg_dec minute0 (
	.dec_val(min0[3:0]),
	.ss_val(ssM0[6:0])
);

sev_seg_dec minute1 (
	.dec_val(min1[2:0]),
	.ss_val(ssM1[6:0])
);

sev_seg_dec hour0 (
	.dec_val(hr0[3:0]),
	.ss_val(ssH0[6:0])
);

sev_seg_dec hour1 (
	.dec_val(hr1[1:0]),
	.ss_val(ssH1[6:0])
);

// assign output logic
assign sev_seg[0] = ssH0;
assign sev_seg[1] = ssH1;
assign sev_seg[2] = ssM0;
assign sev_seg[3] = ssM1;
assign sev_seg[4] = ssH0;
assign sev_seg[5] = ssH1;

endmodule 