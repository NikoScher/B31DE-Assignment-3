
// Insert header comments

module AHBDA2 (
  input wire HCLK,
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

  reg         rHSEL;
  reg [31:0]  rHADDR;
  reg [31:0]  rHRDATA;
  reg         rHWRITE;
  reg         rHREADYOUT;

  reg [11:0]  rSAMPLE;
  reg [11:0]  rNEW_SAMPLE;
  reg [4:0]   rS_COUNTER;

  reg         rDA2_CS;
  reg         rDA2_DINA;
  reg         rDA2_DINB;

  // Prescaled clk signals
  wire CLK4;

  // Generate prescaled clk ticks
  prescaler_DA2 prescaler4 (
    .inCLK(HCLK),
    .outCLK(CLK4)
  );

  always @(posedge CLK4) begin
    if ((!rDA2_CS) && rS_COUNTER[4]) begin
      rDA2_CS    <= 1'b1;
      rS_COUNTER <= 5'b0;
    end
    if (rDA2_CS && !(rSAMPLE == rNEW_SAMPLE)) begin
      rDA2_CS <= 1'b0;
      rSAMPLE <= rNEW_SAMPLE;
    end
    if (!rDA2_CS) begin
      if (rS_COUNTER <= 5'b00011)
        rDA2_DINA <= 1'b0;
      else
        rDA2_DINA <= rSAMPLE[16'd15 - rS_COUNTER];
      rS_COUNTER <= rS_COUNTER + 1'b1;
    end
  end
  
  always @(posedge HCLK) begin

    // Data Phase: Read/Write to bus
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

  assign HRDATA    = rHRDATA;
  assign HREADYOUT = rHREADYOUT;

  assign da2_CS   = rDA2_CS;
  assign da2_DINA = rDA2_DINA;
  assign da2_DINB = rDA2_DINB;
  assign da2_SCLK = CLK4;

endmodule