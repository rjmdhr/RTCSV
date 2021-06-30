`timescale 1ns/1ns

module sev_seg_dec_tb;

	logic [3:0] dec_val;
	logic [6:0] ss_val;
	
	sev_seg_dec uut0 (
		.dec_val(dec_val),
		.ss_val(ss_val)
	);

	initial begin
		dec_val = 4'dx;

		// 2^4 = 16 possible values for dec_val
		for (int unsigned x = 0; x < 16; x++) begin
			dec_val = x; #5; //5ns
			
		end
	end

endmodule