// simulation time - 0.5ms

/* This module simply tests the rtc_driver functionality under
"typical" conditions and edge cases. It is not meant to formally verify
the design, but to show the waveforms model that the blocks work as intended.
Also it is unreasonable to simulate and let the count enable reset 
after 1Hz (1E9 ns x 86400 s), so the counters were enabled every other 
clock cycle. The accuracy of 1Hz clock should rather be tested on an actual 
FPGA with a frequency counter.
*/
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
		#40;
		rst = 1;
		man_sw = 0;

		// set UUT (1Hz) values close to edge cases
		UUT.cnt1Hz = UUT.div1Hz - 5;
		UUT.min1 = 5; UUT.min0 = 7;
		UUT.hr1 = 2; UUT.hr0 = 0;

		// set UUT (1kHz) value for debouncers
		UUT.cnt1kHz = UUT.div1kHz - 5;

		// test manual push buttons while manual is off (active low)
		push_but = {default:0};
		#130;
		push_but = {default:1};

		// test manual mode (at 439320ns, time counters reset to 0)
		#439160; //439320-130-40
		man_sw = 1;
		#20;
		UUT.sec1 = 5; UUT.sec0 = 8;
		UUT.min1 = 5; UUT.min0 = 8;
		UUT.hr1 = 2; UUT.hr0 = 2;
		#30;
		repeat (20) begin
			UUT.setpben({default:1});
			#20;
			UUT.setpben({default:0});
			#20;
		end
	end

	// 50MHz clock
	always begin
		#10;
		clk = ~clk;
	end

	// force count/shift enables every other clock cycle
	always @(negedge UUT.cnten)
		UUT.cnt1Hz = UUT.div1Hz;

	always @(negedge UUT.shiften)
		UUT.cnt1kHz = UUT.div1kHz;

endmodule