
// Assignment 3 Adv Digital DA2 Prescaler Module
// Nikolaus Scherwitzel (H00298068)

// Divides HCLK by 2 (50Mhz/2) = 25MHz

module prescaler_DA2 (
  input wire inCLK,
  output wire outCLK
);

  reg rCOUNTER;

  always @(posedge inCLK)
    rCOUNTER <= rCOUNTER + 1'b1;

  assign outCLK = rCOUNTER;

endmodule
