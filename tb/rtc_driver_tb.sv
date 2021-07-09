`timescale 1ns/1ns

module rtc_driver_tb;

	logic clk;
	logic [2:0] push_but;
	logic rst;
	logic man_sw;
	logic [5:0] sev_seg[6:0];

	rtc_driver UUT(
		.clk(clk),
		.push_but(push_but),
		.rst(rst),
		.man_sw(man_sw),
		.sev_seg(sev_seg)
	);

	initial begin
		clk = 1;
		rst = 0; 
		man_sw = 1;
		#40
		rst = 1;
		man_sw = 0;

		// set UUT values close to edge cases
		UUT.cnt1Hz = UUT.div1Hz - 5;
		UUT.min1 = 5; UUT.min0 = 7;
		UUT.hr1 = 2; UUT.hr0 = 0;
		
		// test manual mode (after ~439290ns, time counters reset to 0)
		#439290
		man_sw = 1;
	end

	// 50MHz clock
	always begin
		#10
		clk = ~clk;
	end

	// force counter to count every other clock cycle
	always @(negedge UUT.cnten) begin
		UUT.cnt1Hz = UUT.div1Hz;
	end

	

endmodule