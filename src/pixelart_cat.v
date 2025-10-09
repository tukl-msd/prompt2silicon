`default_nettype none

module tt_um_vga_pixelart_cat(
    input wire [7:0] ui_in,    // Dedizierte Eingänge
    output wire [7:0] uo_out,  // Dedizierte Ausgänge
    input wire [7:0] uio_in,   // Allgemeine I/Os: Eingangs-Pfad
    output wire [7:0] uio_out, // Allgemeine I/Os: Ausgangs-Pfad
    output wire [7:0] uio_oe,  // Allgemeine I/Os: Enable-Pfad
    input wire ena,            // immer High, ignorierbar
    input wire clk,            // Takt
    input wire rst_n           // Aktives Low-Reset
);

    // VGA-Signale definieren
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

    // Ungenutzte Ausgänge auf 0 setzen
    assign uio_out = 0;
    assign uio_oe  = 0;

    // VGA-Signalgenerator instanziieren 
    hvsync_generator hvsync_gen(
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(video_active),
        .hpos(pix_x),
        .vpos(pix_y)
    );

    // Zeichne den Umriss der Katze
    wire cat_outline;
    assign cat_outline = (
        ((pix_y == 100) && (pix_x >= 150 && pix_x <= 300)) || // Oberkopf 
        ((pix_y >= 101 && pix_y <= 200) && (pix_x == 150 || pix_x == 300)) || // Seiten des Kopfes 
        ((pix_y == 200) && (pix_x >= 150 && pix_x <= 300)) || // Unterer Kopf 
        ((pix_y >= 50 && pix_y <= 100) && (pix_x == 175 || pix_x == 275))   // Ohren 
    );

    // Zeichne das Smiley-Gesicht mit einer Zunge, die den Mund berührt
    wire smiley_face;
    assign smiley_face = (
        ((pix_y >= 140 && pix_y <= 145) && (pix_x == 180 || pix_x == 270)) || // Augen
        ((pix_y == 170) && (pix_x >= 210 && pix_x <= 240)) ||                // Trauriger Mund
        ((pix_y >= 170 && pix_y <= 185) && (pix_x >= 220 && pix_x <= 230))   // Zunge, die den Mund berührt
    );

    // Zeichne den Körper ohne Füllung
    wire cat_body;
    assign cat_body = (
        ((pix_y == 201 || pix_y == 300) && (pix_x >= 170 && pix_x <= 280)) || // obere und untere Linie des Körpers
        ((pix_y >= 201 && pix_y <= 300) && (pix_x == 170 || pix_x == 280))    // linke und rechte Linie des Körpers
    );

    // Zeichne die Beine der Katze und trenne sie mit einem Strich
    wire cat_legs;
    assign cat_legs = (
        ((pix_y >= 301 && pix_y <= 350) && (pix_x == 190 || pix_x == 260)) || // linkes und rechtes Bein
        ((pix_y == 350) && (pix_x >= 190 && pix_x <= 260)) ||                 // untere Linie an den Beinen
        (pix_y >= 301 && pix_y <= 350 && pix_x == 225)                        // Trennstrich zwischen den Beinen
    );

    // Zeichne die Arme
    wire cat_arms;
    assign cat_arms = (
        ((pix_y >= 210 && pix_y <= 230) && (pix_x == 160)) ||    // linker Arm nach unten
        ((pix_y == 210) && (pix_x >= 160 && pix_x <= 180)) ||   // Winken mit dem linken Arm
        ((pix_y >= 210 && pix_y <= 230) && (pix_x == 290))      // rechter Arm nach oben
    );

    // Farbeinstellungen
    assign R = (video_active && (cat_outline || smiley_face || cat_body || cat_legs || cat_arms)) ? 2'b11 : 2'b00; // Rot auf max
    assign G = (video_active && (cat_outline || smiley_face || cat_body || cat_legs || cat_arms)) ? 2'b11 : 2'b00; // Grün auf max
    assign B = (video_active && (cat_outline || smiley_face || cat_body || cat_legs || cat_arms)) ? 2'b11 : 2'b00; // Blau auf max

    // Unterdrücke Warnungen für ungenutzte Signale
    wire _unused_ok = &{ena, ui_in, uio_in};

endmodule
