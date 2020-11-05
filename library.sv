`default_nettype none

/*------MULTIPLEXER------*/
module Multiplexer
    #(parameter WIDTH= 8)
    (input logic [WIDTH-1:0] I,
     input logic [$clog2(WIDTH)-1:0] S,
     output logic Y);

     assign Y= I[S];

endmodule : Multiplexer

/*------MUX2TO1------*/
module Mux2to1
    #(parameter WIDTH= 8)
    (input logic [WIDTH-1:0] I0, I1,
     input logic S,
     output logic [WIDTH-1:0] Y);

     assign Y= (S) ? I1 : I0;
endmodule : Mux2to1

/*------COMPARATOR------*/
module MagComp
    #(parameter WIDTH= 8)
    (input logic [WIDTH-1:0] A, B,
     output logic AgtB, AeqB, AltB);

    assign AgtB= (A > B);
    assign AeqB= (A == B);
    assign AltB= (A < B);
endmodule : MagComp

/*------DECODER------*/
module Decoder
    #(parameter WIDTH= 8)
    (input logic [$clog2(WIDTH)-1:0] I,
     input logic en,
     output logic [WIDTH-1:0] D);

    assign D= (en) ? (1 << I) : 0;
endmodule : Decoder

/*------ADDER------*/
module Adder
    #(parameter WIDTH= 16)
    (input logic [WIDTH-1:0] A, B,
     input logic Cin,
     output logic [WIDTH-1:0] S,
     output logic Cout);

    logic [WIDTH:0] tmp, tmp1;
    assign S= A + B;
    assign tmp = A + B + Cin;
    assign Cout= tmp[WIDTH];
endmodule : Adder

/*------REGISTER------*/
module Register
  #(parameter WIDTH=8)
  (input  logic [WIDTH-1:0] D,
   input  logic             en, clear, clock,
   output logic [WIDTH-1:0] Q);

  always_ff @(posedge clock)
    if (en)
      Q <= D;
    else if (clear)
      Q <= 0;

endmodule : Register

/*------SHIFT REGISTER------*/
module ShiftRegister
    #(parameter WIDTH=8)
    (input logic [WIDTH-1:0] D,
     input logic en, left, load, clk,
     output logic [WIDTH-1:0] Q);

    always_ff @(posedge clk) begin
        if(en) begin
            if(load)
                Q <= D;
            else
                Q <= left ? (Q << 1) : (Q >> 1);
        end
    end

endmodule : ShiftRegister

/*------COUNTER------*/
module Counter
    #(parameter WIDTH=8)
    (input logic [WIDTH-1:0] D,
     input logic en, clear, load, up, clock,
     output logic [WIDTH-1:0] Q);

    always_ff @(posedge clock) begin
        unique casez({en,clear,load})
            3'b11?: Q <= 'b0;
            3'b101: Q <= D;
            3'b100: Q <= up ? (Q+1) : (Q-1);
            3'b0??: Q <= Q;
        endcase
    end
endmodule : Counter

/*------BARRELSHIFTREGISTER------*/
module BarrelShiftRegister
    #(parameter WIDTH=8)
    (input logic [WIDTH-1:0] D,
     input logic [1:0] by,
     input logic en, load, clk,
     output logic [WIDTH-1:0] Q);

    always_ff @(posedge clk) begin
        if(en) begin
            if(load)
                Q <= D;
            else
                Q <= Q << by;
        end
    end

endmodule : BarrelShiftRegister

/*------MEMORY------*/
module Memory
    #(parameter DW=16,
                W=256,
                AW= $clog2(W))
    (input logic re, we, clk,
     input logic[AW-1:0] addr,
     inout tri [DW-1:0] Data);

    logic [DW-1:0] M[W];
    logic [DW-1:0] out;

    assign Data= re ? out : 'bz;

    always_ff @ (posedge clk)
        if(we)
            M[addr] <= Data;

    always_comb
        out= M[addr];

endmodule : Memory

