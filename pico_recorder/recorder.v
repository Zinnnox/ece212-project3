module recorder(
    input clk,
    input tick,
    input rec,
    input play,
    input [1:0] bank,
    input [3:0] sample,
    output recording,
    output playing,
    output reg [3:0] out
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

    reg bank0_we, bank1_we, bank2_we, bank3_we;
    reg [3:0] bank0_out, bank1_out, bank2_out, bank3_out; 
    reg [7:0] bank0_last, bank1_last, bank2_last, bank3_last;
    reg [7:0] record_addr, play_addr;

    initial begin
        bank0_we = 0;
        bank1_we = 0;
        bank2_we = 0;
        bank3_we = 0;
        bank0_last = 0;
        bank1_last = 0;
        bank2_last = 0;
        bank3_last = 0;
        record_addr = 0;
        play_addr = 0;
    end

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
            // set playing and play address to 0 while recording
            playing <= 0;
            play_addr <= 0;

            // recording is high while rec is high and the bank is not full.
            if (record_addr < 8'd255) begin
                recording <= 1;
            end
            else begin
                recording <= 0;
            end

            // while rec, if tick and recording are high, write sample to current bank 
            // and set that bank's last register to the record address.
            if (tick && recording) begin
                if (bank == 2'd0) begin
                    bank0_we <= 1;
                    bank0_last <= record_addr;
                    out <= bank0_out;
                end
                if (bank == 2'd1) begin
                    bank1_we <= 1;
                    bank1_last <= record_addr;
                    out <= bank1_out;
                end
                if (bank == 2'd2) begin
                    bank2_we <= 1;
                    bank2_last <= record_addr;
                    out <= bank2_out;
                end
                if (bank == 2'd3) begin
                    bank3_we <= 1;
                    bank3_last <= record_addr;
                    out <= bank3_out;
                end
            end

            // while rec, if tick and recording are high, 
            //increase the record address by 1, unless it is 255.
            if (record_addr < 8'd255) begin
                record_addr <= record_addr + 1;
            end
            else begin
                recording <= 0;
            end
        end

        if (!rec) begin
            // set recording and record_addr to 0 while rec is low
            recording <= 0;
            record_addr <= 0;
             
            if (play) begin
                playing <= 1;
                
                // while playing, if tick is high, 
                // increase the play address by 1 or reset it to 0 if it 
                // is greater than or equal to the bank's last register.
                if (tick && playing) begin
                    if (play_addr < 8'd255) begin
                        play_addr <= play_addr + 1;
                    end
                    else begin
                        play_addr <= 0;
                    end
                end
            end
        end
    end

endmodule
