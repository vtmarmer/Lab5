module Task2
    (input logic start_game, grade_it,
    input logic [11:0] guess,
    output logic [2:0] feedback0, feedback1, feedback2, feedback3,
    output logic [3:0] round_number, //HEX
    output logic won, lost,
    input  logic clock, reset);

    logic [11:0] pattern;
    assign pattern = 12'b010_100_010_101; // or any other pattern you like

    logic tenthRound, inc;
    fsm control(.*);

    logic [2:0] red, white;
    Grader scoreThis(.guess0(guess[2:0]), .guess1(guess[5:3]), .guess2(guess[8:6]),
                     .guess3(guess[11:9]), .pattern0(pattern[2:0]), .done(), .clock(),
                     .pattern1(pattern[5:3]), .pattern2(pattern[8:6]),
                     .pattern3(pattern[11:9]), .reset(), .go(), .red, .white);

    logic rltw;
    calcFeedback feedback(.*);

    /* Datapath */
    Counter #(4) roundCount(.Q(round_number), .D(4'd1), .clear(1'b0), .load(inc), .en(1'b1), .up(1'b1), .clock);
    MagComp #(4) cmp0(.AeqB(tenthRound), .A(4'd11), .B(round_number), .AltB(), .AgtB());
    MagComp #(3) cmp1(.AeqB(won), .A(3'd4), .B(red), .AltB(), .AgtB());
    MagComp #(3) cmp2(.AltB(rltw), .A(red), .B(white), .AeqB(), .AgtB());
endmodule : Task2

module calcFeedback
    (input logic [11:0] guess,
     input logic [2:0] red, white,
     input logic rltw,
     output logic [2:0] feedback0, feedback1, feedback2, feedback3);

    /* Iterate through the 5x5 possibilites of outputs*/
    always_comb begin
        case(red)
            3'd4: {feedback0, feedback1, feedback2, feedback3}= 12'o7777;
            3'd3: {feedback0, feedback1, feedback2, feedback3}= (white == 3'd1) ? 12'o7771 : 12'o7770;

            /*
            3'd2: tmp= 12'o3300;
            3'd1: tmp= 12'o3000;
            3'd0: tmp= 12'o0000;
            ....*/
        endcase
    end
endmodule : calcFeedback

module fsm
    (input logic grade_it, start_game, tenthRound, won,
     output logic inc,
     input logic clock, reset);

    enum {start, scoring, roundOver} currState, nextState;

    /* Next State Logic */
    always_comb begin
        case(currState)
            start: nextState= (grade_it) ? scoring : start;
            scoring: nextState= (grade_it) ? ((tenthRound | won) ? roundOver : scoring) : start;
            roundOver: nextState= start_game ? start : roundOver;
        endcase
    end

    /* Output Logic */
    always_comb begin
        case(currState)
            start: inc= ~grade_it;
            scoring: inc= grade_it ? ((tenthRound | won) ? 0 : 1 ) : 1;
            roundOver: inc= 1;
        endcase
    end

    always_ff @ (posedge clock)
        if(reset)
            currState <= start;
        else
            currState <= nextState;

endmodule : fsm

module Grader
    (input logic [2:0] guess0, guess1, guess2, guess3,
     input logic [2:0] pattern0, pattern1, pattern2, pattern3,
     output logic [2:0] red, white,
     input logic clock, reset, go,
     output logic done);

    assign red= 3'd3;
    assign white= 3'd1;
endmodule : Grader

