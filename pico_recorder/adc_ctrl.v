module adc_ctrl(
    input clk,
    input start,
    input comp,
    input max,
    output reg inc,
    output reg clr,
    output reg load
);
    /*
    Control FSM for the ADC. It has four states, and starts in IDLE:

    IDLE:   Waiting for a conversion to start. All outputs are 0.
            If start is high, go to SETTLE. Otherwise stay in IDLE.
    SETTLE: Gives the DAC and comparator a clock cycle to settle on the
            new voltage. All outputs are 0.
            If comp is high or max is high, go to DONE. Otherwise go to INC.
    INC:    inc is high, so the datapath adds 1 to dac. Always go to SETTLE.
    DONE:   load and clr are high, so the datapath saves the result and
            sets dac back to 0. Always go to IDLE.

    This holds each DAC value for two clock cycles (SETTLE and then INC or
    DONE), and samples the comparator on the clock edge in between.

    comp is the comparator output. It is high when the DAC output voltage
    is higher than the analog input voltage.
    max is high when dac is 31, so the conversion stops instead of wrapping
    around to 0 if the input is higher than the DAC can go.
    */
    //Do not modify above this line

    localparam IDLE = 0, SETTLE = 1, INC = 2, DONE = 3;
    reg [1:0] state = 0;
    reg [1:0] next_state;

    always @(posedge clk) begin
        state <= next_state;
    end

    always @(*) begin
        case (state)
            IDLE: begin
                if (start) next_state = SETTLE;
                else next_state = IDLE;
                inc = 0;
                clr = 0;
                load = 0;
            end

            SETTLE: begin
                if (comp || max) next_state = DONE;
                else if (comp == 0 && max == 0) next_state = INC;
                inc = 0;
                clr = 0;
                load = 0;
            end 

            INC: begin
                next_state = SETTLE;
                inc = 1; 
            end 
            
            DONE: begin
                next_state = IDLE;
                inc = 0;
                clr = 1;
                load = 1;
            end
        endcase
    end


endmodule
