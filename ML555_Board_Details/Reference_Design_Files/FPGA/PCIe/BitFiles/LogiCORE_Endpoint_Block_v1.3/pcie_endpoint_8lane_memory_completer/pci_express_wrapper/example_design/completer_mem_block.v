//------------------------------------------------------------------------------
//
// Copyright (C) 2006, Xilinx, Inc. All Rights Reserved.
//
// This file is owned and controlled by Xilinx and must be used solely
// for design, simulation, implementation and creation of design files
// limited to Xilinx devices or technologies. Use with non-Xilinx
// devices or technologies is expressly prohibited and immediately
// terminates your license.
//
// Xilinx products are not intended for use in life support
// appliances, devices, or systems. Use in such applications is
// expressly prohibited.
//
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor      : Xilinx
// \   \   \/     Version     : 1.2
//  \   \         Application : Example Completer design for PCI Express
//  /   /         Filename    : completer_mem_block.v
// /___/   /\     Module      : completer_mem_block
// \   \  /  \
//  \___\/\___\
//
//------------------------------------------------------------------------------
`timescale  1 ns / 10 ps

module completer_mem_block (
  write_clock,
  write_clock_en, // ignored for now
  read_clock,
  read_clock_en,  // ignored for now
  // RAM interface
  write_a,
  write_we,
  write_d,
  read_a,
  read_d);

  parameter G_RAM_READ_LATENCY = 1;
  parameter G_RAM_WRITE_LATENCY = 1;
  parameter G_RAM_DEPTH = 1; // How many BRAMs deep?  Only 1 or 2 are allowed.
  parameter G_RAM_SIZE = 16; // Based on completer state machine write address size

  input write_clock;
  input write_clock_en;
  input read_clock;
  input read_clock_en;

  // RAM interface
  input [G_RAM_SIZE-1:0] write_a;
  input [7:0] write_we;
  input [63:0] write_d;
  input [G_RAM_SIZE-1:0] read_a;
  output[63:0] read_d;
  
  // only 5 bits needed because of RAMB36 shifting write/read
  // address by 5, thereby cutting off the upper 5 bits of address
  // of G_RAM_SIZE, which now can select which stacked BRAM to enable.
  reg [4:0] read_a_reg [G_RAM_READ_LATENCY-1:0];
  integer i;
  
  // match read address to data ready to come out depending on latency 
  always @(posedge read_clock) begin
    read_a_reg[0] <= read_a[G_RAM_SIZE-1:11];
    
    for (i = 1; i < G_RAM_READ_LATENCY; i = i+1)
       read_a_reg[i] <= read_a_reg[i-1];
       
  end

    // LOWER DATA WORD SECTION
    // RAMB36 outputs
    wire [G_RAM_DEPTH-1:0] ldw_cascadeoutlata, ldw_cascadeoutrega;
    wire [G_RAM_DEPTH-1:0] ldw_cascadeoutlatb, ldw_cascadeoutregb;
    wire [(32*G_RAM_DEPTH) - 1:0] ldw_doa;
    wire [(32*G_RAM_DEPTH) - 1:0] ldw_dob;
    wire [(4*G_RAM_DEPTH) - 1:0] ldw_dopa;
    wire [(4*G_RAM_DEPTH) - 1:0] ldw_dopb;
    
    // RAMB36 inputs
    wire [G_RAM_DEPTH-1:0] ldw_ena, ldw_enb; 
    wire [G_RAM_DEPTH-1:0] ldw_regcea, ldw_cascadeinlata, ldw_cascadeinrega;
    wire [G_RAM_DEPTH-1:0] ldw_cascadeinlatb, ldw_cascadeinregb, ldw_regceb;
    wire [15:0] ldw_addra;
    wire [15:0] ldw_addrb;
    wire [31:0] ldw_dia;
    wire [31:0] ldw_dib;
    wire [3:0] ldw_dipa;
    wire [3:0] ldw_dipb;
    wire [3:0] ldw_wea;
    wire [3:0] ldw_web;

    // Write Ports (common to lower DW)
    assign ldw_dia = write_d[31:0];
    assign ldw_dipa = 4'h0;
    assign ldw_addra = {write_a[10:0], 5'b00000};
    assign ldw_wea = write_we[3:0];
    // This encoding can accomodate larger stacks of BRAMs, but for performance
    // and easy coding, the stack has been limited to 2, so write_a[15:11]
    // values of 3 or more will be ignored.  Shifting causes 1-hot on ENA.
    assign ldw_ena[G_RAM_DEPTH-1:0] = (1 << write_a[G_RAM_SIZE-1:11]); 
    
    
    // Read Ports (common to lower DW)
    assign ldw_dib = 32'h0;
    assign ldw_dipb = 32'h0;
    assign ldw_addrb = {read_a[10:0], 5'b00000};
    assign ldw_web = 4'h0;
    // This encoding can accomodate larger stacks of BRAMs, but for performance
    // and easy coding, the stack has been limited to 2, so write_a[15:11]
    // values of 3 or more will be ignored.  Shifting causes 1-hot on ENA.
    assign ldw_enb[G_RAM_DEPTH-1:0] = (1 << read_a[G_RAM_SIZE-1:11]); // shifting causes 1-hot on ENA
      

  genvar ldword_num;
  generate
    // for the lower DW, bits [31:0]
    for (ldword_num = 0; ldword_num < G_RAM_DEPTH; ldword_num=ldword_num+1) begin: gen_ldword
 
      assign ldw_regcea[ldword_num] = 1'b1;
      assign ldw_regceb[ldword_num] = 1'b1;
      assign ldw_cascadeinlata[ldword_num] = 1'b0;
      assign ldw_cascadeinlatb[ldword_num] = 1'b0;
      assign ldw_cascadeinrega[ldword_num] = 1'b0;
      assign ldw_cascadeinregb[ldword_num] = 1'b0;
      
       // Port A is Write Port, Port B is Read Port
       RAMB36 
       # (
         .DOB_REG               (G_RAM_READ_LATENCY-1),
         .DOA_REG               (0),
         .WRITE_MODE_A          ("READ_FIRST"),
         .WRITE_MODE_B          ("READ_FIRST"),
         .READ_WIDTH_A          (36),
         .READ_WIDTH_B          (36),
         .WRITE_WIDTH_A         (36),
         .WRITE_WIDTH_B         (36))
       ldword (
         .CASCADEOUTLATA        (ldw_cascadeoutlata[ldword_num]), 
         .CASCADEOUTLATB        (ldw_cascadeoutlatb[ldword_num]), 
         .CASCADEOUTREGA        (ldw_cascadeoutrega[ldword_num]), 
         .CASCADEOUTREGB        (ldw_cascadeoutregb[ldword_num]), 
         .DOA                   (ldw_doa[(32*ldword_num) + 31:32*ldword_num]), 
         .DOB                   (ldw_dob[(32*ldword_num) + 31:32*ldword_num]), 
         .DOPA                  (ldw_dopa[(4*ldword_num) + 3:4*ldword_num]), 
         .DOPB                  (ldw_dopb[(4*ldword_num) + 3:4*ldword_num]),
         .ADDRA                 (ldw_addra), 
         .ADDRB                 (ldw_addrb), 
         .CASCADEINLATA         (ldw_cascadeinlata[ldword_num]), 
         .CASCADEINLATB         (ldw_cascadeinlatb[ldword_num]), 
         .CASCADEINREGA         (ldw_cascadeinrega[ldword_num]), 
         .CASCADEINREGB         (ldw_cascadeinregb[ldword_num]), 
         .CLKA                  (write_clock), 
         .CLKB                  (read_clock), 
         .DIA                   (ldw_dia), 
         .DIB                   (ldw_dib), 
         .DIPA                  (ldw_dipa), 
         .DIPB                  (ldw_dipb), 
         .ENA                   (ldw_ena[ldword_num]), 
         .ENB                   (ldw_enb[ldword_num]), 
         .REGCEA                (ldw_regcea[ldword_num]), 
         .REGCEB                (ldw_regceb[ldword_num]), 
         .SSRA                  (1'b0), 
         .SSRB                  (1'b0), 
         .WEA                   (ldw_wea), 
         .WEB                   (ldw_web)
         );
    end
  endgenerate


    // UPPER DATA WORD SECTION
    
    // RAMB36 outputs
    wire [G_RAM_DEPTH-1:0] hdw_cascadeoutlata, hdw_cascadeoutrega;
    wire [G_RAM_DEPTH-1:0] hdw_cascadeoutlatb, hdw_cascadeoutregb;
    wire [(32*G_RAM_DEPTH) - 1:0] hdw_doa;
    wire [(32*G_RAM_DEPTH) - 1:0] hdw_dob;
    wire [(4*G_RAM_DEPTH) - 1:0] hdw_dopa;
    wire [(4*G_RAM_DEPTH) - 1:0] hdw_dopb;
    
    // ramb36 inputs
    //wire hdw_clka, hdw_clkb, hdw_ssra, hdw_ssrb; 
    wire [G_RAM_DEPTH-1:0] hdw_ena, hdw_enb;
    wire [G_RAM_DEPTH-1:0] hdw_regcea, hdw_cascadeinlata, hdw_cascadeinrega;
    wire [G_RAM_DEPTH-1:0] hdw_cascadeinlatb, hdw_cascadeinregb, hdw_regceb;
    wire [15:0] hdw_addra;
    wire [15:0] hdw_addrb;
    wire [31:0] hdw_dia;
    wire [31:0] hdw_dib;
    wire [3:0] hdw_dipa;
    wire [3:0] hdw_dipb;
    wire [3:0] hdw_wea;
    wire [3:0] hdw_web;

    // Write Ports (common to high DW)
    assign hdw_dia = write_d[63:32];
    assign hdw_dipa = 4'h0;
    assign hdw_addra = {write_a[10:0], 5'b00000};
    assign hdw_wea = write_we[7:4];
    // This encoding can accomodate larger stacks of BRAMs, but for performance
    // and easy coding, the stack has been limited to 2, so write_a[15:11]
    // values of 3 or more will be ignored.  Shifting causes 1-hot on ENA.
    assign hdw_ena[G_RAM_DEPTH-1:0] = (1 << write_a[G_RAM_SIZE-1:11]); // shifting causes 1-hot on ENA
    
    // Read Ports (common to high DW)
    assign hdw_dib = 32'h0;
    assign hdw_dipb = 32'h0;
    assign hdw_addrb = {read_a[10:0], 5'b00000};
    assign hdw_web = 4'h0;
    // This encoding can accomodate larger stacks of BRAMs, but for performance
    // and easy coding, the stack has been limited to 2, so write_a[15:11]
    // values of 3 or more will be ignored.  Shifting causes 1-hot on ENA.
    assign hdw_enb[G_RAM_DEPTH-1:0] = (1 << read_a[G_RAM_SIZE-1:11]); // shifting causes 1-hot on ENA
      

  genvar hdword_num;
  generate
    // for the high DW, bits [63:32]
    for (hdword_num = 0; hdword_num < G_RAM_DEPTH; hdword_num=hdword_num+1) begin: gen_hdword
 
      assign hdw_regcea[hdword_num] = 1'b1;
      assign hdw_regceb[hdword_num] = 1'b1;
      assign hdw_cascadeinlata[hdword_num] = 1'b0;
      assign hdw_cascadeinlatb[hdword_num] = 1'b0;
      assign hdw_cascadeinrega[hdword_num] = 1'b0;
      assign hdw_cascadeinregb[hdword_num] = 1'b0;

      
       // Port A is Write Port, Port B is Read Port
       RAMB36 
       # (
         .DOB_REG               (G_RAM_READ_LATENCY-1),
         .DOA_REG               (0),
         .WRITE_MODE_A          ("READ_FIRST"),
         .WRITE_MODE_B          ("READ_FIRST"),
         .READ_WIDTH_A          (36),
         .READ_WIDTH_B          (36),
         .WRITE_WIDTH_A         (36),
         .WRITE_WIDTH_B         (36))
       hdword (
         .CASCADEOUTLATA        (hdw_cascadeoutlata[hdword_num]), 
         .CASCADEOUTLATB        (hdw_cascadeoutlatb[hdword_num]), 
         .CASCADEOUTREGA        (hdw_cascadeoutrega[hdword_num]), 
         .CASCADEOUTREGB        (hdw_cascadeoutregb[hdword_num]), 
         .DOA                   (hdw_doa[(32*hdword_num) + 31:32*hdword_num]), 
         .DOB                   (hdw_dob[(32*hdword_num) + 31:32*hdword_num]), 
         .DOPA                  (hdw_dopa[(4*hdword_num) + 3:4*hdword_num]), 
         .DOPB                  (hdw_dopb[(4*hdword_num) + 3:4*hdword_num]),
         .ADDRA                 (hdw_addra), 
         .ADDRB                 (hdw_addrb), 
         .CASCADEINLATA         (hdw_cascadeinlata[hdword_num]), 
         .CASCADEINLATB         (hdw_cascadeinlatb[hdword_num]), 
         .CASCADEINREGA         (hdw_cascadeinrega[hdword_num]), 
         .CASCADEINREGB         (hdw_cascadeinregb[hdword_num]), 
         .CLKA                  (write_clock), 
         .CLKB                  (read_clock), 
         .DIA                   (hdw_dia), 
         .DIB                   (hdw_dib), 
         .DIPA                  (hdw_dipa), 
         .DIPB                  (hdw_dipb), 
         .ENA                   (hdw_ena[hdword_num]), 
         .ENB                   (hdw_enb[hdword_num]), 
         .REGCEA                (hdw_regcea[hdword_num]), 
         .REGCEB                (hdw_regceb[hdword_num]), 
         .SSRA                  (1'b0), 
         .SSRB                  (1'b0), 
         .WEA                   (hdw_wea), 
         .WEB                   (hdw_web)
         );
    end
  endgenerate

// This could probably be written better to accomodate larger stacks
// of BRAMs, but performance issues may prevent larger stacks.  Would
// need to be investigated further.
  generate
    if (G_RAM_DEPTH == 1) begin : depth1
       assign read_d = {hdw_dob[31:0], ldw_dob[31:0]};
    end
    else begin : depth2
       assign read_d = (read_a_reg[G_RAM_READ_LATENCY-1] == 5'h01) ? 
                            {hdw_dob[63:32], ldw_dob[63:32]} :
                            {hdw_dob[31:0], ldw_dob[31:0]};
    end
  endgenerate
  


endmodule

