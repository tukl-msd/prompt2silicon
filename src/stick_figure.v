/*
* Copyright (c) 2025, RPTU Kaiserslautern-Landau
* All rights reserved.
*
* Redistribution and use in source and binary form, with or without
* modification, are permitted provided that the following conditions are
* met:
*
* 1. Redistributions of source code must retain the above copyright notice,
*    this list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its
*    contributors may be used to endorse or promote products derived from
*    this software without specific prior written permission.
*
* THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
* TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
* PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
* OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

`default_nettype none

module tt_um_vga_stick_figure(
    input wire [7:0] ui_in, // Dedizierte Eingänge
    output wire [7:0] uo_out, // Dedizierte Ausgänge
    input wire [7:0] uio_in, // IOs: Eingangs-Pfad
    output wire [7:0] uio_out, // IOs: Ausgangs-Pfad
    output wire [7:0] uio_oe, // IOs: Enable-Pfad (aktiv High: 0=Eingang, 1=Ausgang)
    input wire ena, // Ignorieren - immer High
    input wire clk, // Takt
    input wire rst_n // Aktives Low-Reset
);

    // VGA-Signale
    wire hsync;
    wire vsync;
    wire [1:0] R;
    wire [1:0] G;
    wire [1:0] B;
    wire video_active;
    wire [9:0] pix_x;
    wire [9:0] pix_y;

    // TinyVGA PMOD
    assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

    // Ungenutzte Ausgänge auf 0 gesetzt
    assign uio_out = 0;
    assign uio_oe  = 0;

    // Unterdrücken von Warnungen für ungenutzte Signale
    wire _unused_ok = &{ena, uio_in};

    // VGA-Signal-Generator Instanziierung
    hvsync_generator hvsync_gen(
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(video_active),
        .hpos(pix_x),
        .vpos(pix_y)
    );

    // Parameter für den Kreis und die Striche
    parameter integer Y_CENTER = 200;
    parameter integer RADIUS = 20; // Noch kleinerer Kreisradius
    parameter integer STRAIGHT_LENGTH = 50; // Länge des senkrechten Strichs
    parameter integer HORIZONTAL_MID_Y = Y_CENTER + RADIUS + (STRAIGHT_LENGTH / 2);
    parameter integer CIRCLE_THICKNESS = 2; // Dicke des Kreisrandes

    // Register zur Speicherung der aktuellen X-Position des Kreises
    reg [9:0] x_center = 320;

    // Bedingung für den leeren Kreis (nur der Rand)
    wire in_circle_border = (pix_x - x_center) * (pix_x - x_center) +
                            (pix_y - Y_CENTER) * (pix_y - Y_CENTER) >= (RADIUS - CIRCLE_THICKNESS) * (RADIUS - CIRCLE_THICKNESS) &&
                            (pix_x - x_center) * (pix_x - x_center) +
                            (pix_y - Y_CENTER) * (pix_y - Y_CENTER) < RADIUS * RADIUS;

    // Bedingung für die Augen im Kreis
    wire in_left_eye = (pix_x >= x_center - 8) && (pix_x <= x_center - 4) &&
                       (pix_y >= Y_CENTER - 5) && (pix_y <= Y_CENTER - 3);

    wire in_right_eye = (pix_x >= x_center + 4) && (pix_x <= x_center + 8) &&
                        (pix_y >= Y_CENTER - 5) && (pix_y <= Y_CENTER - 3);

    // Bedingung für den Mund im Kreis
    wire in_mouth = (pix_x >= x_center - 4) && (pix_x <= x_center + 4) &&
                    (pix_y >= Y_CENTER + 4) && (pix_y <= Y_CENTER + 5);

    // Bedingungen für den senkrechten Strich
    wire in_straight_line = (pix_x == x_center) && 
                            (pix_y > Y_CENTER + RADIUS) && 
                            (pix_y <= Y_CENTER + RADIUS + STRAIGHT_LENGTH);

    // Bedingungen für den horizontalen Strich mittig am senkrechten Strich
    wire in_middle_horizontal_left = (pix_y == HORIZONTAL_MID_Y) &&
                                     (pix_x >= x_center - 20) && (pix_x < x_center);

    wire in_middle_horizontal_right = (pix_y == HORIZONTAL_MID_Y) &&
                                      (pix_x > x_center) && (pix_x <= x_center + 20);

    // Bedingungen für die schrägen 45-Grad-Striche
    wire in_left_angle = (pix_y > Y_CENTER + RADIUS + STRAIGHT_LENGTH) &&
                         (pix_y <= Y_CENTER + RADIUS + STRAIGHT_LENGTH + 20) &&
                         (pix_x == x_center - (pix_y - Y_CENTER - RADIUS - STRAIGHT_LENGTH));

    wire in_right_angle = (pix_y > Y_CENTER + RADIUS + STRAIGHT_LENGTH) &&
                          (pix_y <= Y_CENTER + RADIUS + STRAIGHT_LENGTH + 20) &&
                          (pix_x == x_center + (pix_y - Y_CENTER - RADIUS - STRAIGHT_LENGTH));

    // Farben definieren (Lila: Rot und Blau sind hoch, Grün ist niedrig)
    assign R = video_active && (in_circle_border || in_straight_line || in_left_angle || in_right_angle || in_middle_horizontal_left || in_middle_horizontal_right || in_left_eye || in_right_eye || in_mouth) ? 2'b11 : 2'b00;
    assign G = 2'b00; // no G
    assign B = video_active && (in_circle_border || in_straight_line || in_left_angle || in_right_angle || in_middle_horizontal_left || in_middle_horizontal_right || in_left_eye || in_right_eye || in_mouth) ? 2'b11 : 2'b00;

    // Bewegung der gesamten Figur basierend auf den Zuständen von Pin 1 (ui_in[1]) und Pin 2 (ui_in[2])
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            x_center <= 320; // Zurücksetzen der X-Position auf den Startwert
        end else begin
            if (ui_in[1]) begin
                // Bewege nach links, falls Pin 1 High ist
                x_center <= (x_center - 1 >= RADIUS) ? x_center - 1 : x_center;
            end else if (ui_in[2]) begin
                // Bewege nach rechts, falls Pin 2 High ist
                x_center <= (x_center + 1 <= 640 - RADIUS) ? x_center + 1 : x_center;
            end
        end
    end

endmodule
