module main(
    input clk,
    input [3:0] btn,
    input [7:0] sw,
    input comp,
    output reg [4:0] dac,
    output strobe,
    output data,
    output shift_clk
);
    /*
    Top module. The following modules will be used in this:
        -debounce
        -tick
        -adc
        -recorder
        -led_bar
        -sevseg_disp (your module from Project 2)

    Inputs:
        -btn[0] is the record button and btn[1] is the play button. Both
         must be debounced before going into the recorder.
        -sw[1:0] selects the memory bank.
        -comp is the comparator output.

    Connections:
        -tick's output is the tick input to the recorder.
        -The adc's start input is high when tick is high and the recorder
         is not playing. The ADC runs all the time except during playback.
        -The adc's result is the sample input to the recorder.
        -The dac output comes from the adc, except during playback. During
         playback, it is the recorder's out with a 0 added as the LSB,
         {out, 1'b0}, since only the upper 4 bits are stored.

    Display:
        -The LEDs show the adc's result using the led_bar module. During
         playback, they show the recorder's out instead.
        -The seven-segment display shows the bank number, and the decimal
         point is on while recording. sevseg_in and sevseg_dp are already
         connected to the inputs of your sevseg_disp module, so you just
         need to assign them. The autograder checks sevseg_in and
         sevseg_dp, not the seven_seg output.

    You can change any of the wires declared below to regs.
    */
    wire [7:0] seven_seg;
    wire [7:0] led;
    wire [3:0] sevseg_in;
    wire sevseg_dp;
    shift_reg sreg(led, seven_seg, clk, strobe, data, shift_clk);
    sevseg_disp disp(sevseg_in, sevseg_dp, seven_seg);
    //Do not modify above this line

    // debounced record and play buttons
    wire db_rec, db_play;
    debounce db0(.clk(clk), .btn(btn[0]), .btn_db(db_rec));
    debounce db1(.clk(clk), .btn(btn[1]), .btn_db(db_play));

    // tick module
    wire tick;
    tick tick0(.clk(clk), .tick(tick));

    // adc module
    wire adc0_start;
    wire [4:0] adc0_dac;
    wire [3:0] adc0_result;
    assign adc0_start = tick && !db_play;
    adc adc0(
        .clk(clk),
        .start(adc0_start),
        .comp(comp),
        .dac(adc0_dac),
        .result(adc0_result)
    );

    // recorder module 
    wire rec0_recording, rec0_playing;
    wire [3:0] rec0_out;
    recorder rec0(
        .clk(clk),
        .tick(tick),
        .rec(db_rec),
        .play(db_play),
        .bank(sw[1:0]),
        .sample(adc0_result),
        .recording(rec0_recording),
        .playing(rec0_playing),
        .out(rec0_out)
    );

    // led bar will display the adc's result during recording,
    // and the recorder's out during playback.
    // dac already has the correct value to display, so we can just use that.
    reg [7:0] led_in;
    led_bar ledbar0(.in(led_in), .led(led));

    // determine dac and led output, if playing then output the recorder's out, 
    // otherwise output the adc's dac value.
    always @(*) begin
        if (rec0_playing) begin
            dac = {rec0_out, 1'b0};
            led_in = rec0_out;
        end
        else begin
            dac = adc0_dac;
            led_in = adc0_result;
        end
    end

    // sevseg_in is the bank number, and sevseg_dp is high when recording.
    assign sevseg_in = {2'b00, sw[1:0]};
    assign sevseg_dp = rec0_recording;

endmodule
