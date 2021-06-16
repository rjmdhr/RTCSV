'timescale 1ms/1us

module RTCDriver(
	input logic clock36768Hz, //crystal oscillator frequency
	output logic [5:0] seven_seg[7:0] //6 displays (2Hr,2Min,2Sec)
);

logic resetn;

// frequency division 
parameter clock1Hz_div_count = 18383;
logic [14:0] clock1Hz_div_count;
logic clock1Hzbuf;
logic clock1Hz;



end module 