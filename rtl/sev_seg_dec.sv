`timescale 1ns/100ps

module sev_seg_dec (
    input logic [3:0] dec_val, //decimal
    output logic [6:0] ss_val //10-9-1-2-4-6-7|g-f-e-d-c-b-a (common anode - active low)
);

always_comb begin
    case (dec_val)
        4'd0: ss_val = 7'b1000000;
        4'd1: ss_val = 7'b1111001;
        4'd2: ss_val = 7'b0100110;
        4'd3: ss_val = 7'b0110000;
        4'd4: ss_val = 7'b0011001;
        4'd5: ss_val = 7'b0010010;
        4'd6: ss_val = 7'b0000010;
        4'd7: ss_val = 7'b1111000;
        4'd8: ss_val = 7'b0000000;
        4'd9: ss_val = 7'b0011000;
        default: ss_val = 7'b1111111; //off
    endcase
end

endmodule 