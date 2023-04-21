
// Assignment 3 Adv Digital 12-bit DA2 Module
// Nikolaus Scherwitzel (H00298068)

module AHBDA2 (
  input wire HCLK,          // 50MHz
  input wire HRESETn,
  input wire [31:0] HADDR,
  input wire [31:0] HWDATA,
  input wire [1:0]  HTRANS,
  input wire HWRITE,
  input wire HSEL,
  input wire HREADY,
  
  output wire [31:0] HRDATA,
  output wire HREADYOUT,

  output wire da2_CS,
  output wire da2_DINA,
  output wire da2_DINB,
  output wire da2_SCLK
);

  `define SAMPLE_ADDR 32'h5500_0000

  // AHB-Lite registers
  reg         rHSEL;
  reg [31:0]  rHADDR;
  reg [31:0]  rHRDATA;
  reg         rHWRITE;
  reg         rHREADYOUT;

  // DA2 Registers
  reg [11:0]  rSAMPLE;      // Current sample being written
  reg [11:0]  rNEW_SAMPLE;  // New sample to be written
  reg [4:0]   rS_COUNTER;   // Counter for 16 SCLK serial write operation

  reg         rDA2_CS;      // Chip select (SYNC BAR in datasheet)
  reg         rDA2_DINA;
  reg         rDA2_DINB;

  wire CLK2;

  // Generate prescaled clk (HLCK/2) = 25MHz
  // DA2 module has max SCLK frequency of 30MHz
  prescaler_DA2 prescaler2 (
    .inCLK(HCLK),
    .outCLK(CLK2)
  );

  always @(posedge CLK2) begin
    // Check if we're at the end of 16 bit write cycle
    if ((!rDA2_CS) && rS_COUNTER[4]) begin
      rDA2_CS    <= 1'b1;
      rS_COUNTER <= 5'b0;
    end
    // Check if new sample has been written
    if (rDA2_CS && !(rSAMPLE == rNEW_SAMPLE)) begin
      rDA2_CS <= 1'b0;
      rSAMPLE <= rNEW_SAMPLE;
    end
    // If we're currently writing a sample:
    if (!rDA2_CS) begin
      if (rS_COUNTER <= 5'b00011)   // First 4 bits define ‘not-cares’ and operation mode
        rDA2_DINA <= 1'b0;
      else                          // Otherwise we're writing data sample bits
        rDA2_DINA <= rSAMPLE[16'd15 - rS_COUNTER];
      rS_COUNTER <= rS_COUNTER + 1'b1;
    end
    
  end
  
  always @(posedge HCLK) begin
    // Data Phase: Write only to DA2
    rHREADYOUT <= 1'b0;
    if (rHSEL && rHWRITE) begin
      rHREADYOUT <= 1'b1;
      case (rHADDR)
        `SAMPLE_ADDR : rNEW_SAMPLE <= HWDATA[11:0];
      endcase
    end
    // Address Phase: Sample bus
    if (HREADY) begin
      rHSEL   <= HSEL;
      rHADDR  <= HADDR;
      rHWRITE <= HWRITE;
    end
    
  end

  // AHB-Lite outputs
  assign HRDATA    = rHRDATA;
  assign HREADYOUT = rHREADYOUT;

  // DA2 outputs
  assign da2_CS   = rDA2_CS;
  assign da2_DINA = rDA2_DINA;
  assign da2_DINB = rDA2_DINB;
  assign da2_SCLK = CLK2;

endmodule