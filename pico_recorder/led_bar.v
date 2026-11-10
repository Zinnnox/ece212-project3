module led_bar(
    input [3:0] in,
    output reg [7:0] led
);
    /*
    Displays a 4 bit value on the 8 LEDs as a position along the bar.
    The 16 possible values map onto the 8 LEDs as follows:
        -0 turns all LEDs off
        -An odd value lights one LED: 1 -> led[0], 3 -> led[1], ... 15 -> led[7]
        -An even value lights the two LEDs on either side of it, since it
         is in between them: 2 -> led[1:0], 4 -> led[2:1], ... 14 -> led[7:6]

        in   led
        0    00000000
        1    00000001
        2    00000011
        3    00000010
        4    00000110
        ...
        14   11000000
        15   10000000
    */
    //Do not modify above this line

    always @(*) begin
        case (in)
            4'd0: led = 8'b00000000;
            4'd1: led = 8'b00000001;
            4'd2: led = 8'b00000011;
            4'd3: led = 8'b00000010;
            4'd4: led = 8'b00000110;
            4'd5: led = 8'b00000100;
            4'd6: led = 8'b00001100;
            4'd7: led = 8'b00001000;
            4'd8: led = 8'b00011000;
            4'd9: led = 8'b00010000;
            4'd10: led = 8'b00110000;
            4'd11: led = 8'b00100000;
            4'd12: led = 8'b01100000;
            4'd13: led = 8'b01000000;
            4'd14: led = 8'b11000000;
            4'd15: led = 8'b10000000;
            default: led = 8'b00000000;
        endcase
    end

endmodule
