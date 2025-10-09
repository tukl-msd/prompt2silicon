`default_nettype none

module tt_um_vga_blue_car(
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

    // Startposition des "Autos"
    reg [9:0] car_x = 0;
    reg [9:0] car_y = 200; // Konstante Y-Position für die "Straße"
    reg moving_left;
    reg moving_right;

    // Zähler zur Steuerung der Bewegungsgeschwindigkeit
    reg [24:0] speed_counter;

    // Geschwindigkeitseinstellungen
    localparam integer TICKS_PER_SECOND = 50_000_000; // Annahme: 50 MHz Takt
    localparam integer FAST_TOTAL_TICKS = TICKS_PER_SECOND * 3; // Anpassung für 3 Sekunden
    localparam integer FAST_STEP_TICKS = FAST_TOTAL_TICKS / 640;

    // TinyVGA PMOD
    assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

    // Ungenutzte Ausgänge werden auf 0 gesetzt
    assign uio_out = 0;
    assign uio_oe  = 0;

    // Unterdrücken von Warnungen nicht genutzter Signale
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

    // Funktion zur Zeichnung des Autos basierend auf Position
    wire car_body = (pix_x >= car_x + 10 && pix_x < car_x + 60 && pix_y >= car_y + 20 && pix_y < car_y + 40);
    wire car_top = (pix_x >= car_x + 20 && pix_x < car_x + 50 && pix_y >= car_y + 10 && pix_y < car_y + 20);
    wire car_wheel1 = (pix_x >= car_x + 15 && pix_x < car_x + 25 && pix_y >= car_y + 40 && pix_y < car_y + 45);
    wire car_wheel2 = (pix_x >= car_x + 45 && pix_x < car_x + 55 && pix_y >= car_y + 40 && pix_y < car_y + 45);

    // Funktion zur Zeichnung der Straße
    wire road = (pix_y >= car_y + 46 && pix_y < car_y + 50);

    // Wenn innerhalb der Parameter, wird die Straße in Grau und das Auto in Blau gezeichnet
    assign R = (video_active && (car_body || car_top || car_wheel1 || car_wheel2)) ? 2'b00 :
               (video_active && road) ? 2'b01 : 2'b00;
    assign G = (video_active && (car_body || car_top || car_wheel1 || car_wheel2)) ? 2'b00 :
               (video_active && road) ? 2'b01 : 2'b00;
    assign B = (video_active && (car_body || car_top || car_wheel1 || car_wheel2)) ? 2'b11 :
               (video_active && road) ? 2'b01 : 2'b00;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            car_x <= 0; // Startposition des Autos
            speed_counter <= 0;
            moving_left <= 0;
            moving_right <= 0;
        end else begin
            // Bewegungslogik für die linke Richtung
            if (ui_in[0] == 1'b1) begin
                moving_left <= 1;
            end else begin
                moving_left <= 0;
            end

            // Bewegungslogik für die rechte Richtung
            if (ui_in[1] == 1'b1) begin
                moving_right <= 1;
            end else begin
                moving_right <= 0;
            end

            if (moving_left) begin
                speed_counter <= speed_counter + 1;
                if (speed_counter >= FAST_STEP_TICKS) begin
                    speed_counter <= 0;
                    if (car_x > 0) car_x <= car_x - 1; // Bewege das Auto nach links
                end
            end else if (moving_right) begin
                speed_counter <= speed_counter + 1;
                if (speed_counter >= FAST_STEP_TICKS) begin
                    speed_counter <= 0;
                    if (car_x < 590) car_x <= car_x + 1; // Bewege das Auto nach rechts
                end
            end
        end
    end

endmodule
