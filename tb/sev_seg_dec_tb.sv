`timescale 1ns/1ns

/** This module tests the seven segment decoder module (sev_seg_dec) by driving
 all possible values of dec_val to check if the pinouts are correct. It reads
 a test vector file line by line every positive edge of the clock. Although
 unecessary for an asynchronous circuit, these values are still set on a 
 positive edge in the rtc_driver module. */
module sev_seg_dec_tb;

	logic clk;
	logic [3:0] dec_val;
	logic [6:0] ss_val;

	// tb driver/check logic
	logic [10:0] test_vec [16:0]; //16x11 test vector
	logic [6:0] ss_val_exp; //expected output
	logic [31:0] test_num; //bookkeeping
	
	// instantiate unit under test
	sev_seg_dec UUT(
		.dec_val(dec_val),
		.ss_val(ss_val)
	);

	// 50MHz clock
	always begin
		#10
		clk = ~clk;
	end

	// read vector file
	initial begin
		$readmemb("sev_seg_tv.txt", test_vec);
		test_num = 0;
		clk = 1;
	end

	always @(posedge clk) begin
		{dec_val[3:0], ss_val_exp[6:0]} = test_vec[test_num];
		test_num++;
	end

	always @(negedge clk) begin
		if (test_vec[test_num] === 11'dx)
			$stop;
		else begin
			assert (ss_val === ss_val_exp)
			else $error ("Error at test %d:\n Input: %b, Expected: %b", test_num, dec_val, ss_val_exp);
		end
	end

endmodule