`default_nettype none

module tt_um_vga_unicorn(
    input wire [7:0] ui_in,   // Dedizierte Eingänge
    output wire [7:0] uo_out, // Dedizierte Ausgänge
    input wire [7:0] uio_in,  // IOs: Eingangs-Pfad
    output wire [7:0] uio_out,// IOs: Ausgangs-Pfad
    output wire [7:0] uio_oe, // IOs: Enable-Pfad
    input wire ena,           // ignorierbar, immer 1
    input wire clk,           // Takt
    input wire rst_n          // Reset, aktives Low
);

    // VGA-Signale
    wire hsync;
    wire vsync;
    wire [1:0] R;  // Rot-Komponente
    wire [1:0] G;  // Grün-Komponente
    wire [1:0] B;  // Blau-Komponente
    wire video_active;
    wire [9:0] pix_x;
    wire [9:0] pix_y;

    // VGA-Ausgänge zuweisen
    assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

    // Ungenutzte Ausgänge auf 0 setzen
    assign uio_out = 0;
    assign uio_oe  = 0;

    // Unterdrücke Warnungen für ungenutzte Signale
    wire _unused_ok = &{ena, ui_in, uio_in};

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

    // Einhorn-Teile definieren
    reg unicorn_body_active;
    reg unicorn_head_active;
    reg unicorn_mane_active;
    reg unicorn_tail_active;
    reg unicorn_eye_active;
    reg unicorn_ear_active;
    reg unicorn_horn_active;
    reg unicorn_leg_active;
    reg unicorn_hoof_active;

    // Karottenbewegung animieren
    reg [9:0] carrot_y_pos;

    // Variable für Explosionszustand
    reg explosion_active;

    // Karotten-Teile definieren
    reg carrot_body_active;
    reg carrot_leaves_active;

    // Initiale Y-Position der Karotte
    initial begin
        carrot_y_pos = 90;  // Startposition der Karotte
        explosion_active = 0; // Anfangszustand keine Explosion
    end

    // Bewegung der Karotte bei jedem vertikalen Sync-Impuls
    always @(posedge vsync) begin
        if (~rst_n) begin
            carrot_y_pos <= 90;
            explosion_active <= 0;
        end else if (!explosion_active && carrot_y_pos < 290) begin
            carrot_y_pos <= carrot_y_pos + 1;
        end else if (carrot_y_pos >= 290) begin
            explosion_active <= 1; // Explosion erzeugen
        end
    end

    // Bestimme die Bereiche für die Einhorn- und Karotten-Teile
    always @(posedge clk) begin
        if (~rst_n) begin
            unicorn_body_active <= 0;
            unicorn_head_active <= 0;
            unicorn_mane_active <= 0;
            unicorn_tail_active <= 0;
            unicorn_eye_active <= 0;
            unicorn_ear_active <= 0;
            unicorn_horn_active <= 0;
            unicorn_leg_active <= 0;
            unicorn_hoof_active <= 0;
            carrot_body_active <= 0;
            carrot_leaves_active <= 0;
        end else begin
            // Einhorn
            // Körper: kürzer in Relation zu den Beinen
            unicorn_body_active <= (pix_x >= 180 && pix_x < 360 && pix_y >= 280 && pix_y < 320);

            // Längerer Kopf
            unicorn_head_active <= (pix_x >= 360 && pix_x < 410 && pix_y >= 260 && pix_y < 300);

            // Lange weiße Mähne
            unicorn_mane_active <= (pix_x >= 350 && pix_x < 360 && pix_y >= 230 && pix_y < 300);

            // Weißer Schweif
            unicorn_tail_active <= (pix_x >= 160 && pix_x < 180 && pix_y >= 280 && pix_y < 480);

            // Runde Augen
            unicorn_eye_active <= ((pix_x >= 380 && pix_x < 385 && pix_y >= 270 && pix_y < 275));

            // Spitze Ohren
            unicorn_ear_active <= ((pix_x >= 390 && pix_x < 400 && pix_y >= 250 && pix_y < 260));

            // Langes lilanes Horn
            unicorn_horn_active <= (pix_x >= 405 && pix_x < 410 && pix_y >= 240 && pix_y < 260);

            // Lange Beine
            unicorn_leg_active <= ((pix_x >= 200 && pix_x < 220 && pix_y >= 320 && pix_y < 460) ||
                                   (pix_x >= 240 && pix_x < 260 && pix_y >= 320 && pix_y < 460) ||
                                   (pix_x >= 300 && pix_x < 320 && pix_y >= 320 && pix_y < 460) ||
                                   (pix_x >= 340 && pix_x < 360 && pix_y >= 320 && pix_y < 460));

            // Graue Hufe
            unicorn_hoof_active <= ((pix_x >= 200 && pix_x < 220 && pix_y >= 460 && pix_y < 470) ||
                                    (pix_x >= 240 && pix_x < 260 && pix_y >= 460 && pix_y < 470) ||
                                    (pix_x >= 300 && pix_x < 320 && pix_y >= 460 && pix_y < 470) ||
                                    (pix_x >= 340 && pix_x < 360 && pix_y >= 460 && pix_y < 470));

            // Karotte
            if (!explosion_active) begin
                // Lange, spitze Karotte
                carrot_body_active <= (pix_x >= 365 && pix_x < 375 && pix_y >= carrot_y_pos && pix_y < (carrot_y_pos + 30));
                // Grüne Blätter
                carrot_leaves_active <= ((pix_x >= 360 && pix_x < 380 && pix_y >= (carrot_y_pos - 20) && pix_y < carrot_y_pos));
            end else begin
                // Explosion in Vierecken darstellen
                carrot_body_active <= ((pix_x >= 360 && pix_x < 365 && pix_y >= 295 && pix_y < 300) ||
                                       (pix_x >= 370 && pix_x < 375 && pix_y >= 295 && pix_y < 300) ||
                                       (pix_x >= 365 && pix_x < 370 && pix_y >= 285 && pix_y < 290) ||
                                       (pix_x >= 365 && pix_x < 370 && pix_y >= 305 && pix_y < 310));
                carrot_leaves_active <= 0; // Blätter verschwinden bei Explosion
            end
        end
    end

    // Farben zuweisen
    // Pinker Körper: (R, G, B) = (2'b11, 2'b01, 2'b10)
    // Weiße Mähne und Schweif: (R, G, B) = (2'b11, 2'b11, 2'b11)
    // Lilanes Horn: (R, G, B) = (2'b10, 2'b00, 2'b10)
    // Augen: Schwarz (R, G, B) = (2'b00, 2'b00, 2'b00)
    // Ohren: Pink wie der Körper
    // Graue Hufe: (R, G, B) = (2'b01, 2'b01, 2'b01)
    // Karotte: Orange (R, G, B) = (2'b11, 2'b10, 2'b00)
    // Karottenblätter: Grün (R, G, B) = (2'b01, 2'b11, 2'b00)
    wire unicorn_active = unicorn_body_active || unicorn_head_active || unicorn_mane_active || 
                          unicorn_tail_active || unicorn_eye_active || unicorn_ear_active || 
                          unicorn_horn_active || unicorn_leg_active || unicorn_hoof_active ||
                          carrot_body_active || carrot_leaves_active;

    assign R = (video_active && unicorn_active) ? 
               ((unicorn_mane_active || unicorn_tail_active) ? 2'b11 : 
               (unicorn_horn_active ? 2'b10 : 
               (unicorn_eye_active ? 2'b00 : 
               (unicorn_hoof_active ? 2'b01 : 
               (carrot_body_active ? 2'b11 : 
               (carrot_leaves_active ? 2'b01 : 2'b11)))))) : 2'b00;
    
    assign G = (video_active && unicorn_active) ? 
               ((unicorn_mane_active || unicorn_tail_active) ? 2'b11 : 
               (unicorn_horn_active ? 2'b00 : 
               (unicorn_eye_active ? 2'b00 : 
               (unicorn_hoof_active ? 2'b01 : 
               (carrot_body_active ? 2'b10 : 
               (carrot_leaves_active ? 2'b11 : 2'b01)))))) : 2'b00;
    
    assign B = (video_active && unicorn_active) ? 
               ((unicorn_mane_active || unicorn_tail_active) ? 2'b11 : 
               (unicorn_horn_active ? 2'b10 : 
               (unicorn_eye_active ? 2'b00 : 
               (unicorn_hoof_active ? 2'b01 : 
               (carrot_body_active ? 2'b00 : 
               (carrot_leaves_active ? 2'b00 : 2'b10)))))) : 2'b00;

endmodule
