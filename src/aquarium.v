/*
* Copyright (c) 2025, RPTU Kaiserslautern-Landau
* SPDX-License-Identifier: Apache-2.0
*/

`default_nettype none

module tt_um_vga_aquarium (
    input wire [7:0] ui_in,   // Dedizierte Eingänge
    output wire [7:0] uo_out,  // Dedizierte Ausgänge
    input wire [7:0] uio_in,  // IOs: Eingangs-Pfad
    output wire [7:0] uio_out, // IOs: Ausgangs-Pfad
    output wire [7:0] uio_oe,  // IOs: Enable-Pfad (aktiv High: 0=Eingang, 1=Ausgang)
    input wire ena,           // Immer 1, so dass wir es ignorieren können
    input wire clk,           // Takt
    input wire rst_n          // Reset, aktiv Low
);

    // VGA-Signale
    wire hsync;
    wire vsync;
    wire video_active;
    wire [9:0] pix_x;
    wire [9:0] pix_y;
    reg [1:0] R;
    reg [1:0] G;
    reg [1:0] B;

    // TinyVGA PMOD
    assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

    // Ungenutzte Ausgänge auf 0 gesetzt
    assign uio_out = 0;
    assign uio_oe = 0;

    // Suppress unused signals warning
    wire _unused_ok = &{ena, ui_in, uio_in};

    // Instanziierung des hvsync_generators
    hvsync_generator hvsync_gen(
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(video_active),
        .hpos(pix_x),
        .vpos(pix_y)
    );

    // Koordinaten und Dimensionen des Schiffs
    localparam SHIP_X = 300;
    localparam SHIP_Y = 350;
    localparam SHIP_WIDTH = 80;
    localparam SHIP_HEIGHT = 20;
    localparam SAIL_HEIGHT = 40;

    // Fischvariablen
    reg [9:0] fish_x = 640;
    reg [9:0] fish_y;
    localparam FISH_WIDTH = 10;
    localparam FISH_HEIGHT = 5;
    localparam FISH_SPEED = 2;

    // LFSR für einfachen Zufall
    reg [15:0] lfsr = 16'hACE1; // Startwert des LFSR

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            fish_x <= 640; // Start ganz rechts
            lfsr <= 16'hACE1; // LFSR zurücksetzen
        end else begin
            fish_x <= fish_x > FISH_SPEED ? fish_x - FISH_SPEED : 640; // Fische von rechts nach links
            if (fish_x == 640) begin
                // LFSR basiertes, 'zufälliges' Element
                lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
                fish_y <= lfsr[9:0] % (480 - FISH_HEIGHT); // Neue Fischhöhe basierend auf LFSR
            end
        end
    end

    always @(*) begin
        if (video_active) begin
            // Rumpf des Schiffs
            if ((pix_x >= SHIP_X) && (pix_x < SHIP_X + SHIP_WIDTH) &&
                (pix_y >= SHIP_Y) && (pix_y < SHIP_Y + SHIP_HEIGHT)) begin
                R = 2'b01;  // Braun (Rumpf)
                G = 2'b00;
                B = 2'b00;
            end
            // Segel des Schiffs (Dreieck)
            else if (((pix_x >= SHIP_X + (SHIP_WIDTH / 4)) && (pix_x < SHIP_X + (3 * SHIP_WIDTH / 4))) &&
                     ((pix_y >= SHIP_Y - SAIL_HEIGHT) && (pix_y < SHIP_Y)) &&
                     ((pix_y - SHIP_Y + SAIL_HEIGHT) >= -(pix_x - (SHIP_X + SHIP_WIDTH / 2)) - 10) && 
                     ((pix_y - SHIP_Y + SAIL_HEIGHT) >= (pix_x - (SHIP_X + SHIP_WIDTH / 2)) - 10)) begin
                R = 2'b11;  // Weiß (Segel)
                G = 2'b11;
                B = 2'b11;
            end
            // Fisch darstellen
            else if ((pix_x >= fish_x) && (pix_x < fish_x + FISH_WIDTH) &&
                     (pix_y >= fish_y) && (pix_y < fish_y + FISH_HEIGHT)) begin
                R = 2'b11;  // Bunter Fisch
                G = 2'b01;
                B = 2'b11;
            end
            // Hintergrund
            else begin
                R = 2'b00;
                G = 2'b00;
                B = 2'b10;  // Blau (Wasser)
            end
        end else begin
            R = 2'b00;
            G = 2'b00;
            B = 2'b00;
        end
    end

endmodule
