
// Assignment 2 Adv Digital 32-bit Timer Module
// Nikolaus Scherwitzel (H00298068)

module AHBTIMER (
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

  output reg rTIMERIRQ
);

  `define LIMITV_ADDR   32'h5200_0000
  `define CURRENTV_ADDR 32'h5200_0004
  `define CONTROL_ADDR  32'h5200_0008

  reg         rHSEL;
  reg [31:0]  rHADDR;
  reg [31:0]  rHRDATA;
  reg         rHWRITE;
  reg         rHREADYOUT;

  reg [31:0]  rLIMITV;
  reg [31:0]  rCURRENTV;
  reg [31:0]  rCONTROL;

  // Prescaled clk signals
  wire CLKx;
  wire prescale;

  // Generate prescaled clk ticks
  prescaler prescalerx (
    .inCLK(HCLK),
    .outCLK(CLKx),
    .prescale(prescale)
  );
  
  always @(posedge HCLK) begin

    // Timer logic
    rTIMERIRQ <= 1'b0;
    // If timer is 'on'
    if (rCONTROL[0])
      // If using prescaler and prescaler clk high, or if not using prescaler
      if ((rCONTROL[3] && CLKx) || (!rCONTROL[3])) begin
        // If timer counting up
        if (rCONTROL[1]) begin
          rCURRENTV <= rCURRENTV + 1;
          if ((rCONTROL[2] && (rCURRENTV >= rLIMITV)) || ((!rCONTROL[2]) && (rCURRENTV >= 32'hffffffff))) begin
            rTIMERIRQ <= 1'b1;
            rCURRENTV <= 32'h00000000;
          end
        end
        // If timer counting down
        else begin
          rCURRENTV <= rCURRENTV - 1;
          if (rCURRENTV == 32'h0) begin
            rTIMERIRQ <= 1'b1;
            if (rCONTROL[2])
              rCURRENTV <= rLIMITV;
            else
              rCURRENTV <= 32'hffffffff;
          end
        end
      end

    // Data Phase: Push/Pull to/from bus
    rHREADYOUT <= 1'b0;
    if (rHSEL)
      // Writing
      if (rHWRITE) begin
        rHREADYOUT  <= 1'b1;
        rHRDATA     <= 32'h0;
        case (rHADDR)
          `LIMITV_ADDR  : rLIMITV   <= HWDATA;
          `CURRENTV_ADDR: rCURRENTV <= HWDATA;
          `CONTROL_ADDR : rCONTROL  <= HWDATA;
        endcase
      end
      // Reading
      else begin
        rHREADYOUT <= 1'b1;
        case (rHADDR)
          `LIMITV_ADDR  : rHRDATA <= rLIMITV;
          `CURRENTV_ADDR: rHRDATA <= rCURRENTV;
          `CONTROL_ADDR : rHRDATA <= rCONTROL;
        endcase
      end

    // Address Phase: Sample bus
    if (HREADY) begin
      rHSEL   <= HSEL;
      rHADDR	<= HADDR;
      rHWRITE <= HWRITE;
    end

  end

  assign prescale  = rCONTROL[31:4];
  assign HRDATA    = rHRDATA;
  assign HREADYOUT = rHREADYOUT;

endmodule