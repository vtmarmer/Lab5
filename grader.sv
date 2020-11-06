`default_nettype none

module Grader
  (input logic [2:0] guess0, guess1, guess2, guess3,
   input logic [2:0] pattern0, pattern1, pattern2, pattern3,
   output logic [2:0] red, white);

  logic red1, red2, red3, red0, white1, white2, white3, white0;
  logic m00, m01, m02, m03, m10, m11, m12, m13,
        m20, m21, m22, m23, m30, m31, m32, m33;
  CheckPeg peg0(.guess(guess0), .sel(2'd0), .red(red0), .white(white0),
                .match1(m00), .match2(m01), .match3(m02), .match4(m03), .*),
           peg1(.guess(guess1), .sel(2'd1), .red(red1), .white(white1),
                .match1(m10), .match2(m11), .match3(m12), .match4(m13), .*),
           peg2(.guess(guess2), .sel(2'd2), .red(red2), .white(white2),
                .match1(m20), .match2(m21), .match3(m22), .match4(m23), .*),
           peg3(.guess(guess3), .sel(2'd3), .red(red3), .white(white3),
                .match1(m30), .match2(m31), .match3(m32), .match4(m33), .*);

  Compile comp(.*);

endmodule: Grader

module CheckPeg
  (input logic [2:0] guess, pattern0, pattern1, pattern2, pattern3,
   input logic [1:0] sel,
   output logic red, white,
   output logic match1, match2, match3, match4);
  logic red_out;
  logic c0, c1, c2, c3;
  MagComp #(3) comparator0 (guess, pattern0, c0,,),
               comparator1 (guess, pattern1, c1,,),
               comparator2 (guess, pattern2, c2,,),
               comparator3 (guess, pattern3, c3,,);

  //assign red
  Multiplexer #(4) redMux ({c3, c2, c1, c0}, sel, red_out);

  assign white = (c0|c1|c2|c3) & ~red_out;

  assign red = red_out;

  assign {match1, match2, match3, match4} =
         {c0 & ~red_out, c1 & ~red_out, c2 & ~red_out, c3 & ~red_out};

endmodule: CheckPeg


module Compile
 (input logic red1, red2, red3, red0, white1, white2, white3, white0,
  input logic m00, m01, m02, m03, m10, m11, m12, m13,
              m20, m21, m22, m23, m30, m31, m32, m33,
  output logic [2:0] red, white);

  logic used0, used1, used2, used3;
  logic w1, w2, w3, w4;

  assign {used0, used1, used2, used3} = {red0, red1, red2, red3};
  assign red = red0 + red1 + red2 + red3;

  logic whiteCalc0, whiteCalc1, whiteCalc2, whiteCalc3;
  assign white = whiteCalc0 + whiteCalc1 + whiteCalc2 + whiteCalc3;

  logic w00, w01, w02, w03, w10, w11, w12, w13,
        w20, w21, w22, w23, w30, w31, w32, w33;

  assign whiteCalc0 = (w00 | w10 | w20 | w30) & ~used0;
  assign whiteCalc1 = (w01 | w11 | w21 | w31) & ~used1;
  assign whiteCalc2 = (w02 | w12 | w22 | w32) & ~used2;
  assign whiteCalc3 = (w03 | w13 | w23 | w33) & ~used3;

  //~w__ stops pegs from doubling up on one for a single white peg
  //~m__ stops one peg from yielding multiple white pegs

  assign w00 = m00;
  assign w01 = m01 & ~m00;
  assign w02 = m02 & ~(m00 | m01);
  assign w03 = m03 & ~(m00 | m01 | m02);

  assign w10 = m10 & ~w00;
  assign w11 = m11 & ~w10 & ~w01;
  assign w12 = m12 & ~(w10 | w11) & ~w02;
  assign w13 = m13 & ~(w10 | w11 | w12) & ~w03;

  assign w20 = m20 & ~(w00 | w10);
  assign w21 = m21 & ~w20 & ~(w01 | w11);
  assign w22 = m22 & ~(w20 | w21) & ~(w02 | w12);
  assign w23 = m23 & ~(w20 | w21 | w22) & ~(w03 | w13);

  assign w30 = m30 & ~(w00 | w10 | w20);
  assign w31 = m31 & ~w30 & ~(w01 | w11 | w21);
  assign w32 = m32 & ~(w30 | w31) & ~(w02 | w12 | w22);
  assign w33 = m33 & ~(w30 | w31 | w32) & ~(w03 | w13 | w23);

endmodule: Compile

module Grader_test;

  logic [2:0] guess0, guess1, guess2, guess3;
  logic [2:0] pattern0, pattern1, pattern2, pattern3;
  logic [2:0] red, white;

  Grader grade (.*);

  initial begin
    $monitor($time,,"pattern:%b, guess:%b, red, %b, white %b,",
                    {pattern3, pattern2, pattern1, pattern0},
                    {guess3, guess2, guess1, guess0}, red, white);

    {pattern3, pattern2, pattern1, pattern0} = 12'b000_000_001_000;
    {guess3, guess2, guess1, guess0} = 12'b001_000_001_000;
    #5;
    {pattern3, pattern2, pattern1, pattern0} = 12'b000_000_001_000;
    {guess3, guess2, guess1, guess0} = 12'b001_000_001_001;
    #5;
    {pattern3, pattern2, pattern1, pattern0} = 12'b000_000_001_000;
    {guess3, guess2, guess1, guess0} = 12'b001_001_000_001;
    #5;

    $finish;
  end

endmodule: Grader_test
