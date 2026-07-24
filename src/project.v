/*
* Copyright (c) 2025, RPTU Kaiserslautern-Landau
* SPDX-License-Identifier: Apache-2.0
*/

`default_nettype none

module tt_um_vga_example (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // === Instantiate the adaptable module here ===
    /*tt_um_vga_blue_square vga_core (
        .ui_in   (ui_in),
        .uo_out  (uo_out),
        .uio_in  (uio_in),
        .uio_out (uio_out),
        .uio_oe  (uio_oe),
        .ena     (ena),
        .clk     (clk),
        .rst_n   (rst_n)
    );*/

     // === Instantiate the adaptable module here ===
    tt_um_vga_constant_moving_circle vga_core (
        .ui_in   (ui_in),
        .uo_out  (uo_out),
        .uio_in  (uio_in),
        .uio_out (uio_out),
        .uio_oe  (uio_oe),
        .ena     (ena),
        .clk     (clk),
        .rst_n   (rst_n)
    );

endmodule

module tt_um_vga_constant_moving_circle(
  input  wire [7:0] ui_in,    // Dedicated inputs for key input
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // Always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // Clock
  input  wire       rst_n     // Reset_n - low to reset
); 
    
// VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // Output configuration for TinyVGA PMOD
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, uio_in};

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  // Parameters for moving circle
  reg [9:0] circle_x = 320;
  reg [9:0] circle_y = 240;
  reg signed [1:0] x_dir = 1;
  reg signed [1:0] y_dir = 1;
  localparam [9:0] radius = 15;

  // Random direction on reset
  initial begin
    x_dir <= (ui_in[0] == 1) ? -1 : 1;
    y_dir <= (ui_in[1] == 1) ? -1 : 1;
  end

  reg [22:0] circle_move_counter = 0;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Reset position and direction of the circle
      circle_x <= 320;
      circle_y <= 240;
      x_dir <= (ui_in[0] == 1) ? -1 : 1;
      y_dir <= (ui_in[1] == 1) ? -1 : 1;
    end else begin
      circle_move_counter <= circle_move_counter + 1;
      if (circle_move_counter[22] == 1) begin // Constant speed for smoother motion
        // Boundary collision detection
        if (circle_x + radius >= 640 || circle_x - radius <= 0) x_dir <= -x_dir;
        if (circle_y + radius >= 480 || circle_y - radius <= 0) y_dir <= -y_dir;

        circle_x <= circle_x + x_dir;
        circle_y <= circle_y + y_dir;
      end
    end
  end

  // Rectangle parameters
  localparam [9:0] rect_width = 130;
  localparam [9:0] rect_height = 20;

  // Position adjustment for the first rectangle
  reg [9:0] rect1_x_offset = 160;
  wire left_pressed_1 = ui_in[0];
  wire right_pressed_1 = ui_in[1];
  
  // Position adjustment for the second rectangle
  reg [9:0] rect2_x_offset = 160;
  wire left_pressed_2 = ui_in[2];
  wire right_pressed_2 = ui_in[3];
  
  reg [17:0] move_counter;
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rect1_x_offset <= 160;
      rect2_x_offset <= 160;
      move_counter <= 0;
    end else begin
      move_counter <= move_counter + 1;
      if (move_counter == 0) begin
        // Move first rectangle
        if (left_pressed_1 && rect1_x_offset > 2) begin
          rect1_x_offset <= rect1_x_offset - 3;
        end
        if (right_pressed_1 && rect1_x_offset < (800 - rect_width - 3)) begin
          rect1_x_offset <= rect1_x_offset + 3;
        end
        // Move second rectangle
        if (left_pressed_2 && rect2_x_offset > 2) begin
          rect2_x_offset <= rect2_x_offset - 3;
        end
        if (right_pressed_2 && rect2_x_offset < (800 - rect_width - 3)) begin
          rect2_x_offset <= rect2_x_offset + 3;
        end
      end
    end
  end

  // Define first rectangle boundaries
  wire rect1_active = video_active &&
                      (pix_x >= rect1_x_offset) &&
                      (pix_x < (rect1_x_offset + rect_width)) &&
                      (pix_y >= 440 && pix_y < (440 + rect_height));

  // Define second rectangle boundaries
  wire rect2_active = video_active &&
                      (pix_x >= rect2_x_offset) &&
                      (pix_x < (rect2_x_offset + rect_width)) &&
                      (pix_y >= 40 && pix_y < (40 + rect_height));

  // Check if the current pixel is within the circle
  wire [19:0] dist_sq = (pix_x - circle_x) * (pix_x - circle_x) + (pix_y - circle_y) * (pix_y - circle_y);
  wire circle_active = video_active && (dist_sq <= radius * radius);

  // Set RGB values to display the circle and rectangles
  assign R = (circle_active) ? 2'b11 : 2'b00;
  assign G = (circle_active) ? 2'b10 : 2'b00;
  assign B = (rect1_active || rect2_active) ? 2'b11 : 2'b00;

endmodule
