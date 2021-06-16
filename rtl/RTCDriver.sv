'timescale 1ms/1us

module RTCDriver(
	input logic clock36768Hz,
	output logic [5:0] seven_seg[7:0] 
);

logic resetn;

parameter clock1Hz_div = 18384;

end module 