`default_nettype none

module tt_um_vga_red_car(
    input wire [7:0] ui_in, // Dedizierte Eingänge
    output wire [7:0] uo_out, // Dedizierte Ausgänge
    input wire [7:0] uio_in, // IOs: Eingangs-Pfad
    output wire [7:0] uio_out, // IOs: Ausgangs-Pfad
    output wire [7:0] uio_oe, // IOs: Enable-Pfad (aktiv High: 0=Eingang, 1=Ausgang)
    input wire ena, // immer 1, solange das Design mit Strom versorgt ist - kann ignoriert werden
    input wire clk, // Takt
    input wire rst_n // reset_n - Low = Reset
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

    // Bewegungssignale und Zähler für die Geschwindigkeit
    reg [9:0] car_pos_x; // Aktuelle X-Position der linken oberen Ecke des Autos
    reg [20:0] speed_counter; // Zähler für die Geschwindigkeit

    // VGA-Ausgänge zuweisen
    assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

    // Ungenutzte Ausgänge auf 0 setzen
    assign uio_out = 0;
    assign uio_oe  = 0;

    // Unterdrücke Warnungen für ungenutzte Signale
    wire _unused_ok = &{ena, uio_in};

    // VGA-Signalgenerator-Modul instanziieren
    hvsync_generator hvsync_gen(
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(video_active),
        .hpos(pix_x),
        .vpos(pix_y)
    );

    // Steuerung der Autobewegung
    always @(posedge clk) begin
        if (~rst_n) begin
            car_pos_x <= 10'd100; // Startposition des Autos
            speed_counter <= 0; // Zähler zurücksetzen
        end else begin
            if (speed_counter == 21'd2_000_000) begin // Beispielwert für langsame Bewegung
                speed_counter <= 0; // Zähler zurücksetzen

                if (ui_in[0]) // Wenn Pin 0 auf high
                    car_pos_x <= car_pos_x - 1; // Bewege nach links
                else if (ui_in[1]) // Wenn Pin 1 auf high
                    car_pos_x <= car_pos_x + 1; // Bewege nach rechts
            end else begin
                speed_counter <= speed_counter + 1; // Zähler erhöhen
            end
        end
    end

    // Auto und weiße Straße darstellen
    // Auto besteht aus einem rechteckigen Körper und zwei Rädern
    wire car_body = (pix_x >= car_pos_x) && (pix_x < car_pos_x + 40) && (pix_y >= 110) && (pix_y < 130);
    wire car_wheel1 = (pix_x >= car_pos_x + 5) && (pix_x < car_pos_x + 15) && (pix_y >= 130) && (pix_y < 140);
    wire car_wheel2 = (pix_x >= car_pos_x + 25) && (pix_x < car_pos_x + 35) && (pix_y >= 130) && (pix_y < 140);

    wire road_line = (pix_y >= 145) && (pix_y < 150); // Weiße Linie der Straße

    // Logik, um sicherzustellen, dass das Auto angezeigt wird
    wire car_on = car_body || car_wheel1 || car_wheel2;

    assign R = video_active ? (car_on ? 2'b11 : (road_line ? 2'b11 : 2'b00)) : 2'b00;
    assign G = video_active ? (car_on ? 2'b00 : (road_line ? 2'b11 : 2'b00)) : 2'b00;
    assign B = video_active ? (car_on ? 2'b00 : (road_line ? 2'b11 : 2'b00)) : 2'b00;

endmodule
