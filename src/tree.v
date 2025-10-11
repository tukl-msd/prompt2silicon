/*
* Copyright (c) 2025, RPTU Kaiserslautern-Landau
* SPDX-License-Identifier: Apache-2.0
*/

`default_nettype none

module tt_um_vga_tree(
    input  wire [7:0] ui_in,   // ungenutzt
    output wire [7:0] uo_out,  // TinyVGA PMOD
    input  wire [7:0] uio_in,  // ungenutzt
    output wire [7:0] uio_out, // 0
    output wire [7:0] uio_oe,  // 0
    input  wire       ena,     // ungenutzt
    input  wire       clk,     // Pixeltakt
    input  wire       rst_n    // aktives Low-Reset
);

    // VGA
    wire hsync, vsync, video_active;
    wire [9:0] pix_x, pix_y;
    reg  [1:0] R, G, B;

    // PMOD
    assign uo_out  = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Unused inputs squelch
    wire _unused_ok = &{ena, uio_in, ui_in};

    // Timing
    hvsync_generator hvsync_gen(
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(video_active),
        .hpos(pix_x),
        .vpos(pix_y)
    );

    // vsync → frame tick (sync to clk)
    reg vsync_q1, vsync_q2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vsync_q1 <= 1'b0;
            vsync_q2 <= 1'b0;
        end else begin
            vsync_q1 <= vsync;
            vsync_q2 <= vsync_q1;
        end
    end
    wire frame_tick = (vsync_q1 & ~vsync_q2);

    // Tree (static)
    wire tree_trunk  = (pix_x >= 10'd320 && pix_x <= 10'd330 && pix_y >= 10'd240 && pix_y <= 10'd480);
    wire tree_leaves = (pix_x >= 10'd300 && pix_x <= 10'd350 && pix_y >= 10'd200 && pix_y <  10'd240);

    // Falling leaves (5x5)
    localparam [9:0] LEAF_W  = 10'd5;
    localparam [9:0] TOP_Y   = 10'd200;
    localparam [9:0] BOT_Y   = 10'd480;
    localparam [9:0] RESET_Y = 10'd200;
    localparam [9:0] LEFT_X  = 10'd305;
    localparam [9:0] RIGHT_X = 10'd350;

    // 8 leaves
    reg [9:0] leaf_x [0:7];
    reg [9:0] leaf_y [0:7];

    integer i;

    // Init & motion
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Hard-coded starts to avoid width warnings
            leaf_x[0] <= LEFT_X + 10'd0;   leaf_y[0] <= TOP_Y + 10'd0;
            leaf_x[1] <= LEFT_X + 10'd5;   leaf_y[1] <= TOP_Y + 10'd2;
            leaf_x[2] <= LEFT_X + 10'd10;  leaf_y[2] <= TOP_Y + 10'd4;
            leaf_x[3] <= LEFT_X + 10'd15;  leaf_y[3] <= TOP_Y + 10'd6;
            leaf_x[4] <= LEFT_X + 10'd20;  leaf_y[4] <= TOP_Y + 10'd8;
            leaf_x[5] <= LEFT_X + 10'd25;  leaf_y[5] <= TOP_Y + 10'd10;
            leaf_x[6] <= LEFT_X + 10'd30;  leaf_y[6] <= TOP_Y + 10'd12;
            leaf_x[7] <= LEFT_X + 10'd35;  leaf_y[7] <= TOP_Y + 10'd14;
        end else if (frame_tick) begin
            for (i = 0; i < 8; i = i + 1) begin
                if (leaf_y[i] < BOT_Y) begin
                    leaf_y[i] <= leaf_y[i] + 10'd1;
                end else begin
                    leaf_y[i] <= RESET_Y;
                    // drift right by 7, wrap
                    if (leaf_x[i] <= (RIGHT_X - 10'd7))
                        leaf_x[i] <= leaf_x[i] + 10'd7;
                    else
                        leaf_x[i] <= LEFT_X;
                end
            end
        end
    end

    // Pixel color (pure combinational)
    reg leaf_here;
    integer j;

    always @* begin
        // defaults (assign on all paths to avoid latches)
        R = 2'b00; G = 2'b00; B = 2'b00;
        leaf_here = 1'b0;

        if (video_active) begin
            if (tree_trunk) begin
                R = 2'b10; G = 2'b01;               // brown-ish
            end else if (tree_leaves) begin
                G = 2'b11;                           // green
            end else begin
                for (j = 0; j < 8; j = j + 1) begin
                    if ( (pix_x >= leaf_x[j]) && (pix_x < (leaf_x[j] + LEAF_W)) &&
                         (pix_y >= leaf_y[j]) && (pix_y < (leaf_y[j] + LEAF_W)) ) begin
                        leaf_here = 1'b1;
                    end
                end
                if (leaf_here) begin
                    R = 2'b11; G = 2'b10;            // yellow-ish leaf
                end
            end
        end
    end

endmodule
