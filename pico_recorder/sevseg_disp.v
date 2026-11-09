module sevseg_disp(
    input [3:0] in,
    input dp,
    output reg [7:0] segs
);
    /*
    Takes in a 4 bit value and decimal point
    outputs signals for the 8 LEDs on the display
    Segments are assigned a=seg[0], b=seg[1], etc.
    seg[7] is the decimal point.
    Displays the hexadecimal value of the 4 bit input.
    Decimal point is controled by the dp input.
    */
    //Do not modify above this line

    // Bit#: 7  6  5  4  3  2  1  0
    // Seg : DP G  F  E  D  C  B  A

    always @(*) begin
        case (in)
            4'd0: segs = 8'b00111111;
            4'd1: segs = 8'b00000110;
            4'd2: segs = 8'b01011011;
            4'd3: segs = 8'b01001111;
            4'd4: segs = 8'b01100110;
            4'd5: segs = 8'b01101101;
            4'd6: segs = 8'b01111101;
            4'd7: segs = 8'b00000111;
            4'd8: segs = 8'b01111111;
            4'd9: segs = 8'b01101111;
            4'd10: segs = 8'b01110111;
            4'd11: segs = 8'b01111100;
            4'd12: segs = 8'b00111001;
            4'd13: segs = 8'b01011110;
            4'd14: segs = 8'b01111001;
            4'd15: segs = 8'b01110001;
        endcase
        if (dp) segs[7] = 1'b1;
        else segs[7] = 1'b0;
    end

endmodule