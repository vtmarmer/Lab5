`default_nettype none

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

    logic [4:0] redVal, whiteVal;
    calcFeedback feedback(.*);

    not n1(lost, won);

    /* Datapath */
    Counter #(4) roundCount(.Q(round_number), .D(4'd1), .clear(1'b0), .load(inc), .en(1'b1), .up(1'b1), .clock);
    MagComp #(4) cmp0(.AeqB(tenthRound), .A(4'd11), .B(round_number), .AltB(), .AgtB());
    MagComp #(3) cmp1(.AeqB(won), .A(3'd4), .B(red), .AltB(), .AgtB());
    Decoder #(5) redDecode(.D(redVal), .I(red), .en(1'b1)),
                 whiteDecode(.D(whiteVal), .I(white), .en(1'b1));
endmodule : Task2

module calcFeedback
    (input logic [11:0] guess,
     input logic [2:0] red, white,
     input logic [4:0] redVal, whiteVal,
     output logic [2:0] feedback0, feedback1, feedback2, feedback3);

    logic [12:0] tmp;
    always_comb begin
        case(redVal)
            5'b1_0000: begin
                case(whiteVal)
                    5'b1_0000: tmp= 12'b0;
                    5'b0_1000: tmp= 12'o1000;
                    5'b0_0100: tmp= 12'o1100;
                    5'b0_0010: tmp= 12'o1110;
                    5'b0_0001: tmp= 12'o1111;
                endcase
            end

            5'b0_1000: begin
                case(whiteVal)
                    5'b1_0000: tmp= 12'o7000;
                    5'b0_1000: tmp= 12'o7100;
                    5'b0_0100: tmp= 12'o7110;
                    5'b0_0010: tmp= 12'o7111;
                endcase
            end

            5'b0_0100: begin
                case(whiteVal)
                    5'b1_0000: tmp= 12'o7700;
                    5'b0_1000: tmp= 12'o7710;
                    5'b0_0100: tmp= 12'o7711;
                endcase
            end

            5'b0_0010: begin
                case(whiteVal)
                    5'b1_0000: tmp= 12'o7770;
                    5'b0_1000: tmp= 12'o7771;
                endcase
            end

            5'b0_0001: tmp= 12'o7777;
        endcase
        {feedback0, feedback1, feedback2, feedback3}= tmp;
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
            scoring: nextState= (tenthRound | won) ? roundOver : scoring;
            roundOver: nextState= start_game ? start : roundOver;
        endcase
    end

    /* Output Logic */
    always_comb begin
        case(currState)
            start: inc= ~grade_it;
            scoring: inc= (tenthRound | won) ? 1 : 0 ;
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

    assign red= 3'd2;
    assign white= 3'd2;
endmodule : Grader
