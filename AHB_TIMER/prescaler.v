
// Assignment 3 Adv Digital Timer 28-bit Prescaler Module
// Nikolaus Scherwitzel (H00298068)

module prescaler (
  input wire inCLK,
  input wire [27:0] prescale,

  output wire outCLK
);

reg [27:0]  rPRESCALE;
reg [27:0]  rCOUNTER;

always @(posedge inCLK) begin
  rPRESCALE <= prescale;
  rCOUNTER  <= rCOUNTER + 1'b1;

  // Reset counter if prescale value reached
  if (rCOUNTER == rPRESCALE)
    rCOUNTER <= 28'h0;
end

assign outCLK = (rCOUNTER == rPRESCALE);

endmodule
