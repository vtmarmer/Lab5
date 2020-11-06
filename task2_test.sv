`default_nettype none

module task2_tb ();
    logic [11:0] guess;
    logic [2:0] feedback0, feedback1, feedback2, feedback3;
    logic [3:0] round_number;
    logic start_game, grade_it, won, lost, clock, reset;

    Task2 DUT(.*);

    initial begin
        $display("[start_game, grade_it]");
        $monitor($time,,
                 "%s [%b%b] guess=%o, feedback=%o, round_number=%h [%b%b] %b",
                 DUT.control.currState.name, start_game, grade_it, guess,
                 {feedback0, feedback1, feedback2, feedback3},
                 round_number, won, lost, DUT.tenthRound);
        clock= 0;
        forever #5 clock= ~clock;
    end

    initial begin
        start_game <= 1;
        reset= 1;
        grade_it= 0;
        @ (posedge clock);
        reset <= 0;

        guess <= 12'o7654;
        grade_it <= 1;
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);

        start_game <= 1;
        grade_it <= 0;
        @ (posedge clock);
        start_game <= 0;

        guess <= 12'o1154;
        grade_it <= 1;
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);

        $finish;
    end
endmodule : task2_tb
