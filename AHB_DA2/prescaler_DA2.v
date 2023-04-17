
// Insert header comments

module prescaler_DA2 (
  input wire inCLK,
  output wire outCLK
);

  reg rCOUNTER;

  always @(posedge inCLK)
    rCOUNTER <= rCOUNTER + 1'b1;

  assign outCLK = rCOUNTER;

endmodule
