with Ada.Real_Time; use Ada.Real_Time;
with devicesFSS_V1; use devicesFSS_V1;

package Testing_colision is

    ---------------------------------------------------------------------
    ------ TIEMPOS DE EJECUCION DE LOS DISPOSITIVOS ---------------------
    ---------------------------------------------------------------------

    WCET_Distance: constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds(5);

    WCET_Light: constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds(5);

    WCET_Joystick: constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds(5);

    WCET_PilotPresence: constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds(5);

    WCET_PilotButton: constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds(5);

    WCET_Power: constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds(4);

    WCET_Speed: constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds(7);

    WCET_Altitude: constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds(18);

    WCET_Pitch: constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds(20);

    WCET_Roll: constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds(18);

    WCET_Display: constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds(15);

    WCET_Alarm: constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds(5);


    ---------------------------------------------------------------------
    ------ DISTANCIA AL OBSTACULO: PRUEBAS DE COLISION ------------------
    ---------------------------------------------------------------------

    cantidad_datos_Distancia: constant := 200;

    type Indice_Secuencia_Distancia is
        mod cantidad_datos_Distancia;

    type tipo_Secuencia_Distancia is
        array (Indice_Secuencia_Distancia)
        of Distance_Samples_Type;

    Distance_Simulation: tipo_Secuencia_Distancia :=
        (0 .. 29    => 5555,  -- 1-3 s: no hay obstaculo
         30 .. 49   => 4440,  -- 4-5 s: obstaculo detectado
         50 .. 59   => 3330,  -- 6 s: el obstaculo se aproxima
         60 .. 69   => 3000,  -- 7 s: menor distancia
         70 .. 79   => 2400,  -- 8 s: obstaculo proximo
         80 .. 89   => 1999,  -- 9 s: distancia reducida
         90 .. 99   => 1500,  -- 10 s: peligro creciente
         100 .. 109 => 990,   -- 11 s: peligro elevado
         110 .. 119 => 411,   -- 12 s: peligro de colision
         120 .. 199 => 5555); -- 13-20 s: obstaculo despejado


    ---------------------------------------------------------------------
    ------ INTENSIDAD DE LUZ: PRUEBAS DE VISIBILIDAD --------------------
    ---------------------------------------------------------------------

    cantidad_datos_Light: constant := 200;

    type Indice_Secuencia_Light is
        mod cantidad_datos_Light;

    type tipo_Secuencia_Light is
        array (Indice_Secuencia_Light)
        of Light_Samples_Type;

    Light_Intensity_Simulation: tipo_Secuencia_Light :=
        (0 .. 79    => 700,  -- 1-8 s: buena visibilidad
         80 .. 119  => 400,  -- 9-12 s: visibilidad reducida
         120 .. 199 => 700); -- 13-20 s: buena visibilidad


    ---------------------------------------------------------------------
    ------ JOYSTICK: ESCENARIO DE VELOCIDAD -----------------------------
    ---------------------------------------------------------------------

    cantidad_datos_Joystick: constant := 200;

    type Indice_Secuencia_Joystick is
        mod cantidad_datos_Joystick;

    type tipo_Secuencia_Joystick is
        array (Indice_Secuencia_Joystick)
        of Joystick_Samples_Type;

    Joystick_Simulation: tipo_Secuencia_Joystick :=
        (0 .. 19 =>
            (x => 0, y => 0),

         20 .. 39 =>
            (x => 3, y => -3),

         40 .. 59 =>
            (x => 4, y => 0),

         60 .. 79 =>
            (x => 0, y => -4),

         80 .. 99 =>
            (x => 10, y => 20),

         100 .. 119 =>
            (x => 50, y => -50),

         120 .. 139 =>
            (x => -40, y => 0),

         140 .. 159 =>
            (x => -20, y => 30),

         160 .. 179 =>
            (x => 6, y => 45),

         180 .. 199 =>
            (x => 0, y => 0));


    ---------------------------------------------------------------------
    ------ POTENCIA: ESCENARIO DE VELOCIDAD -----------------------------
    ---------------------------------------------------------------------

    cantidad_datos_Power: constant := 200;

    type Indice_Secuencia_Power is
        mod cantidad_datos_Power;

    type tipo_Secuencia_Power is
        array (Indice_Secuencia_Power)
        of Power_Samples_Type;

    Power_Simulation: tipo_Secuencia_Power :=
        (0 .. 9     => 500,
         10 .. 19   => 250,
         20 .. 29   => 251,
         30 .. 49   => 200,
         50 .. 69   => 500,
         70 .. 79   => 750,
         80 .. 89   => 500,
         90 .. 99   => 666,
         100 .. 109 => 667,
         110 .. 129 => 900,
         130 .. 139 => 832,
         140 .. 149 => 200,
         150 .. 169 => 100,
         170 .. 179 => 0,
         180 .. 189 => 1023,
         190 .. 199 => 600);


    ---------------------------------------------------------------------
    ------ PRESENCIA DEL PILOTO: PRUEBAS DE COLISION --------------------
    ---------------------------------------------------------------------

    cantidad_datos_PilotPresence: constant := 200;

    type Indice_Secuencia_PilotPresence is
        mod cantidad_datos_PilotPresence;

    type tipo_Secuencia_PilotPresence is
        array (Indice_Secuencia_PilotPresence)
        of PilotPresence_Samples_Type;

    PilotPresence_Simulation: tipo_Secuencia_PilotPresence :=
        (0 .. 79    => 1,  -- 1-8 s: piloto presente
         80 .. 119  => 0,  -- 9-12 s: piloto ausente
         120 .. 199 => 1); -- 13-20 s: piloto presente


    ---------------------------------------------------------------------
    ------ BOTON DEL PILOTO: ESCENARIO DE VELOCIDAD ---------------------
    ---------------------------------------------------------------------

    cantidad_datos_PilotButton: constant := 200;

    type Indice_Secuencia_PilotButton is
        mod cantidad_datos_PilotButton;

    type tipo_Secuencia_PilotButton is
        array (Indice_Secuencia_PilotButton)
        of PilotButton_Samples_Type;

    PilotButton_Simulation: tipo_Secuencia_PilotButton :=
        (0 .. 14    => 0,
         15 .. 17   => 1,
         18 .. 43   => 0,
         44 .. 47   => 1,
         48 .. 114  => 0,
         115 .. 119 => 1,
         120 .. 199 => 0);

end Testing_colision;

