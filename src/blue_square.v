`default_nettype none

module tt_um_vga_blue_square(
    input wire [7:0] ui_in, // Dedizierte Eingänge
    output wire [7:0] uo_out, // Dedizierte Ausgänge
    input wire [7:0] uio_in, // IOs: Eingangs-Pfad
    output wire [7:0] uio_out, // IOs: Ausgangs-Pfad
    output wire [7:0] uio_oe, // IOs: Enable-Pfad (aktiv High: 0=Eingang, 1=Ausgang)
    input wire ena, // immer 1, solange das Design mit Strom versorgt ist - kann ignoriert werden
    input wire clk, // Takt
    input wire rst_n // reset_n - Low = Reset
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
    assign uio_oe = 0;

    // Suppress unused signals warning
    wire _unused_ok = &{ena, ui_in, uio_in};

    // VGA-Signalgenerator
    hvsync_generator hvsync_gen(
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(video_active),
        .hpos(pix_x),
        .vpos(pix_y)
    );

    // Definiere ein blaues Rechteck
    assign R = (pix_x >= 100 && pix_x < 200 && pix_y >= 100 && pix_y < 200) ? 2'b00 : 2'b00; // Kein Rot
    assign G = (pix_x >= 100 && pix_x < 200 && pix_y >= 100 && pix_y < 200) ? 2'b00 : 2'b00; // Kein Grün
    assign B = (pix_x >= 100 && pix_x < 200 && pix_y >= 100 && pix_y < 200) ? 2'b11 : 2'b00; // Voll Blau

endmodule
