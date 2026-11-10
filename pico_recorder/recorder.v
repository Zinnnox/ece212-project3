module recorder(
    input clk,
    input tick,
    input rec,
    input play,
    input [1:0] bank,
    input [3:0] sample,
    output recording,
    output playing,
    output [3:0] out
);
    /*
    Records ADC samples into one of 4 memory banks, and plays them back.

    Memory:
        -Instantiate 4 memory modules, one for each bank. Bank 0 is the
         first memory module, bank 1 is the second, and so on.
        -All of the memory modules share the same waddr (the record
         address), wdata (sample), and raddr (the play address).
        -Only the selected bank's memory module has its we input high.
        -out is the rdata output of the selected bank's memory module.
        -Each bank has an 8 bit "last" register that holds the address of
         the last sample recorded in that bank. These all start at 0.
        -bank selects which bank is recorded to or played from. If it
         changes, the new bank is used right away.

    Recording (rec is the debounced record button):
        -recording is high while rec is high and the bank is not full.
        -A record address register starts at 0. While rec is low, it is
         set to 0, so every press records from the start of the bank.
        -At each positive clock edge where recording and tick are both high:
            -sample is written to the current bank at the record address
            -that bank's last register is set to the record address
            -the record address increases by 1, unless it is 255. If it is
             255, the bank is full, and recording goes low until rec is
             released and pressed again.

    Playback (play is the debounced play button):
        -playing is high while play is high and rec is low. Recording
         takes priority over playback.
        -A play address register starts at 0. While playing is low, it is
         set to 0, so every press plays from the start of the bank.
        -At each positive clock edge where playing and tick are both high,
         the play address increases by 1. If the play address is greater
         than or equal to the bank's last register, it goes back to 0
         instead. This loops over the recording.
    */
    //Do not modify above this line

    // Registers for individual memory banks' write enable inputs,
    // read outputs, and last registers, and record and play address registers.
    wire bank0_we, bank1_we, bank2_we, bank3_we;
    reg [3:0] bank0_out, bank1_out, bank2_out, bank3_out; 
    reg [7:0] bank0_last, bank1_last, bank2_last, bank3_last;
    reg [7:0] record_addr, play_addr;
    reg [7:0] selected_last;
    reg [3:0] selected_out;

    initial begin
        bank0_last = 0;
        bank1_last = 0;
        bank2_last = 0;
        bank3_last = 0;
        record_addr = 0;
        play_addr = 0;
    end

    // continous assignments for status signals / outputs
    assign recording = rec && (record_addr < 8'd255);
    assign playing = play && !rec;
    assign out = selected_out;

    // Decode the selected bank into a one-clock write-enable pulse.
    // Only the selected memory receives a write when a recording tick occurs.
    assign bank0_we = tick && recording && (bank == 2'd0);
    assign bank1_we = tick && recording && (bank == 2'd1);
    assign bank2_we = tick && recording && (bank == 2'd2);
    assign bank3_we = tick && recording && (bank == 2'd3);

    // Select the last recorded address and memory output for the current bank.
    // This keeps the playback logic independent of which bank is selected.
    always @(*) begin
        case (bank)
            2'd0: begin
                selected_last = bank0_last;
                selected_out = bank0_out;
            end
            2'd1: begin
                selected_last = bank1_last;
                selected_out = bank1_out;
            end
            2'd2: begin
                selected_last = bank2_last;
                selected_out = bank2_out;
            end
            2'd3: begin
                selected_last = bank3_last;
                selected_out = bank3_out;
            end
            default: begin
                selected_last = 8'd0;
                selected_out = 4'd0;
            end
        endcase
    end

    // Instantiate memory banks with unique registers for inputs/outputs
    // Sharing the same record and play addresses, and sample data.
    memory mem0(
        .clk(clk),
        .we(bank0_we),
        .waddr(record_addr),
        .wdata(sample),
        .raddr(play_addr),
        .rdata(bank0_out) 
    );
    memory mem1(
        .clk(clk),
        .we(bank1_we),
        .waddr(record_addr),
        .wdata(sample),
        .raddr(play_addr),
        .rdata(bank1_out) 
    );
    memory mem2(
        .clk(clk),
        .we(bank2_we),
        .waddr(record_addr),
        .wdata(sample),
        .raddr(play_addr),
        .rdata(bank2_out) 
    );
    memory mem3(
        .clk(clk),
        .we(bank3_we),
        .waddr(record_addr),
        .wdata(sample),
        .raddr(play_addr),
        .rdata(bank3_out) 
    );

    always @(posedge clk) begin
        // recording takes priority over playback
        if (rec) begin
            // Reset playback while recording.
            play_addr <= 0;

            // Record the address of the newly written sample in the selected bank.
            if (tick && recording) begin
                case (bank)
                    2'd0: bank0_last <= record_addr;
                    2'd1: bank1_last <= record_addr;
                    2'd2: bank2_last <= record_addr;
                    2'd3: bank3_last <= record_addr;
                endcase

                // Advance to the next address only when a sample is written.
                // The write enable is also high only on this tick, so this
                // keeps recorded samples at consecutive memory addresses.
                if (record_addr < 8'd255) record_addr <= record_addr + 1;
            end
        end

        if (!rec) begin
            // Reset the recording address while not recording.
            record_addr <= 0;
             
            if (play) begin
                if (tick && playing) begin
                    // increment play address until it reaches last register
                    // of the current bank, then goes back to 0.
                    if (play_addr < selected_last) play_addr <= play_addr + 1;
                    else play_addr <= 0;
                end
            end
            else begin
                // Reset the play address while not playing.
                play_addr <= 0;
            end
        end
    end

endmodule
