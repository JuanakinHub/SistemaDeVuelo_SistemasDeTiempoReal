----------------------------------------------------------------------
------------- Integrantes Equipo
-- Yzan Martinez Manzano
-- Luis Tereso Silva
-- Juan Manuel Jimenez Pascual
-- Alvaro Alonso Bayarriz
----------------------------------------------------------------------

----------------------------------------------------------------------
------------- Tareas y Objetos implementados
--
-- Tareas:
-- Tarea_Altitud: Control de cabeceo, altitud y alabeo.
-- Tarea_Velocidad: Control de velocidad y motores.
-- Tarea_Colision: Deteccion de obstaculos y maniobras de evasion.
--
-- Objetos protegidos:
-- Cabeceo_Compartido: comparte el valor de cabeceo.
-- Alabeo_Compartido: comparte el valor de alabeo.
-- Control_Colision: comparte el estado de alarma y maniobra.
----------------------------------------------------------------------

with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;

with Tools; use Tools;
with devicesFSS_V1; use devicesFSS_V1;

package body fss is

    ------------------------------------------------------------------
    -- Procedure exported
    ------------------------------------------------------------------

    procedure Background is
    begin
        loop
            null;
        end loop;
    end Background;

    ------------------------------------------------------------------
    -- Objetos protegidos: cabeceo y alabeo
    ------------------------------------------------------------------

    protected Cabeceo_Compartido is
        procedure Fijar (Valor : in Pitch_Samples_Type);
        function Obtener return Pitch_Samples_Type;
    private
        Cabeceo_Guardado : Pitch_Samples_Type := 0;
    end Cabeceo_Compartido;

    protected body Cabeceo_Compartido is

        procedure Fijar (Valor : in Pitch_Samples_Type) is
        begin
            Cabeceo_Guardado := Valor;
        end Fijar;

        function Obtener return Pitch_Samples_Type is
        begin
            return Cabeceo_Guardado;
        end Obtener;

    end Cabeceo_Compartido;


    protected Alabeo_Compartido is
        procedure Fijar (Valor : in Roll_Samples_Type);
        function Obtener return Roll_Samples_Type;
    private
        Alabeo_Guardado : Roll_Samples_Type := 0;
    end Alabeo_Compartido;

    protected body Alabeo_Compartido is

        procedure Fijar (Valor : in Roll_Samples_Type) is
        begin
            Alabeo_Guardado := Valor;
        end Fijar;

        function Obtener return Roll_Samples_Type is
        begin
            return Alabeo_Guardado;
        end Obtener;

    end Alabeo_Compartido;


    ------------------------------------------------------------------
    -- Objeto protegido: control de colision
    ------------------------------------------------------------------

    protected Control_Colision is
        procedure Iniciar_Maniobra (Fin : in Time);
        procedure Finalizar_Maniobra;
        procedure Marcar_Alarma;
        procedure Reiniciar_Alarma;

        function Maniobra_Activa return Boolean;
        function Alarma_Emitida return Boolean;
        function Fin_Maniobra return Time;

    private
        Activa : Boolean := False;
        Alarma_Realizada : Boolean := False;
        Instante_Fin : Time := Clock;
    end Control_Colision;


    protected body Control_Colision is

        procedure Iniciar_Maniobra (Fin : in Time) is
        begin
            Activa := True;
            Instante_Fin := Fin;
        end Iniciar_Maniobra;

        procedure Finalizar_Maniobra is
        begin
            Activa := False;
        end Finalizar_Maniobra;

        procedure Marcar_Alarma is
        begin
            Alarma_Realizada := True;
        end Marcar_Alarma;

        procedure Reiniciar_Alarma is
        begin
            Alarma_Realizada := False;
        end Reiniciar_Alarma;

        function Maniobra_Activa return Boolean is
        begin
            return Activa;
        end Maniobra_Activa;

        function Alarma_Emitida return Boolean is
        begin
            return Alarma_Realizada;
        end Alarma_Emitida;

        function Fin_Maniobra return Time is
        begin
            return Instante_Fin;
        end Fin_Maniobra;

    end Control_Colision;


    ------------------------------------------------------------------
    -- Declaracion de tareas
    ------------------------------------------------------------------

    task Tarea_Altitud is
        pragma Priority (15);
    end Tarea_Altitud;

    task Tarea_Velocidad is
        pragma Priority (10);
    end Tarea_Velocidad;

    task Tarea_Colision is
        pragma Priority (20);
    end Tarea_Colision;


    ------------------------------------------------------------------
    -- Tarea de control de altitud, cabeceo y alabeo
    ------------------------------------------------------------------

    task body Tarea_Altitud is

        Proximo_Inicio : Time := Clock;

        Joystick_Actual : Joystick_Samples_Type :=
          (x => 0, y => 0);

        Altitud_Actual : Altitude_Samples_Type :=
          Initial_Altitude;

        Cabeceo_Objetivo : Pitch_Samples_Type := 0;
        Alabeo_Objetivo : Roll_Samples_Type := 0;

    begin
        loop
            Start_Activity ("Tarea_Altitud");

            Read_Joystick (Joystick_Actual);
            Altitud_Actual := Read_Altitude;

            -- Control del cabeceo
            Cabeceo_Objetivo :=
              Pitch_Samples_Type (Joystick_Actual (x));

            if abs Cabeceo_Objetivo <= 3 then
                Cabeceo_Objetivo := 0;
            elsif Cabeceo_Objetivo > 30 then
                Cabeceo_Objetivo := 30;
            elsif Cabeceo_Objetivo < -30 then
                Cabeceo_Objetivo := -30;
            end if;

            -- Limites de cabeceo segun la altitud
            if Altitud_Actual <= 2000
              and then Cabeceo_Objetivo < 0
            then
                Cabeceo_Objetivo := 0;
            end if;

            if Altitud_Actual >= 10000
              and then Cabeceo_Objetivo > 0
            then
                Cabeceo_Objetivo := 0;
            end if;

            -- Control del alabeo
            Alabeo_Objetivo :=
              Roll_Samples_Type (Joystick_Actual (y));

            if abs Alabeo_Objetivo <= 3 then
                Alabeo_Objetivo := 0;
            elsif Alabeo_Objetivo > 45 then
                Alabeo_Objetivo := 45;
            elsif Alabeo_Objetivo < -45 then
                Alabeo_Objetivo := -45;
            end if;

            -- Compartir las ordenes calculadas
            Cabeceo_Compartido.Fijar (Cabeceo_Objetivo);
            Alabeo_Compartido.Fijar (Alabeo_Objetivo);

            -- Aplicar las ordenes a la aeronave
            Set_Aircraft_Pitch (Cabeceo_Objetivo);
            Set_Aircraft_Roll (Alabeo_Objetivo);

            -- Mostrar los valores
            Display_Altitude (Altitud_Actual);
            Display_Joystick (Joystick_Actual);
            Display_Pitch (Read_Pitch);
            Display_Roll (Read_Roll);

            -- Indicador luminoso de altitud
            if Altitud_Actual < 2500
              or else Altitud_Actual > 9500
            then
                Light_1 (On);
            else
                Light_1 (Off);
            end if;

            -- Aviso de alabeo elevado
            if abs Alabeo_Objetivo > 35 then
                Display_Message ("Alabeo superior a 35 grados");
            end if;

            Finish_Activity ("Tarea_Altitud");

            Proximo_Inicio :=
              Proximo_Inicio + Milliseconds (200);

            delay until Proximo_Inicio;
        end loop;
    end Tarea_Altitud;


    ------------------------------------------------------------------
    -- Tarea de control de velocidad y motores
    ------------------------------------------------------------------

    task body Tarea_Velocidad is

        Proximo_Inicio : Time := Clock;

        Potencia_Actual : Power_Samples_Type := 0;
        Orden_Cabeceo : Pitch_Samples_Type := 0;
        Orden_Alabeo : Roll_Samples_Type := 0;

        Velocidad_Calculada : Integer := 0;
        Incremento : Integer := 0;
        Limitada : Boolean := False;

    begin
        loop
            Start_Activity ("Tarea_Velocidad");

            Read_Power (Potencia_Actual);

            Orden_Cabeceo := Cabeceo_Compartido.Obtener;
            Orden_Alabeo := Alabeo_Compartido.Obtener;

            -- Calcular incremento de velocidad
            if Orden_Cabeceo > 0 and Orden_Alabeo /= 0 then
                Incremento := 200;
            elsif Orden_Cabeceo > 0 then
                Incremento := 150;
            elsif Orden_Alabeo /= 0 then
                Incremento := 100;
            else
                Incremento := 0;
            end if;

            -- Calcular velocidad
            Velocidad_Calculada :=
              Integer (Float (Potencia_Actual) * 1.2)
              + Incremento;

            Limitada := False;

            -- Limitar la velocidad al intervalo 300-1000
            if Velocidad_Calculada >= 1000 then
                Velocidad_Calculada := 1000;
                Limitada := True;
            elsif Velocidad_Calculada <= 300 then
                Velocidad_Calculada := 300;
                Limitada := True;
            end if;

            Set_Speed (
              Speed_Samples_Type (Velocidad_Calculada)
            );

            Display_Pilot_Power (Potencia_Actual);
            Display_Speed (
              Speed_Samples_Type (Velocidad_Calculada)
            );

            -- Indicador luminoso de limitacion
            if Limitada then
                Light_2 (On);
            else
                Light_2 (Off);
            end if;

            Finish_Activity ("Tarea_Velocidad");

            Proximo_Inicio :=
              Proximo_Inicio + Milliseconds (300);

            delay until Proximo_Inicio;
        end loop;
    end Tarea_Velocidad;


    ------------------------------------------------------------------
    -- Tarea de deteccion de obstaculos y colisiones
    ------------------------------------------------------------------

    task body Tarea_Colision is

        Proximo_Inicio : Time := Clock;

        Distancia_Obstaculo : Distance_Samples_Type := 0;
        Velocidad_Actual : Speed_Samples_Type := 0;
        Asiento_Piloto : PilotPresence_Samples_Type := 0;
        Intensidad_Luz : Light_Samples_Type := 0;

        Tiempo_Colision : Float := 0.0;
        Limite_Aviso : Float := 10.0;
        Limite_Maniobra : Float := 5.0;

        Fin_Desvio : Time := Clock;

    begin
        loop
            Start_Activity ("Tarea_Colision");

            -- Leer sensores
            Read_Distance (Distancia_Obstaculo);	--5A
            Velocidad_Actual := Read_Speed;
            Read_Light_Intensity (Intensidad_Luz);
            Asiento_Piloto := Read_PilotPresence;

            -- Si no hay obstaculo, reiniciar la alarma
            if Distancia_Obstaculo > 5000 then		--5B
                Control_Colision.Reiniciar_Alarma;

            -- Si hay obstaculo y la velocidad es positiva
            elsif Velocidad_Actual > 0 then

                -- Tiempo hasta el obstaculo.
                -- Distancia en metros y velocidad en km/h.
                Tiempo_Colision := Float (Distancia_Obstaculo) * 3.6 / Float (Velocidad_Actual); --5F

                -- Ajustar umbrales por visibilidad o ausencia del piloto
                if Intensidad_Luz < 500			--5E
                  or else Asiento_Piloto = 0
                then
                    Limite_Aviso := 15.0;
                    Limite_Maniobra := 10.0;
                else
                    Limite_Aviso := 10.0;
                    Limite_Maniobra := 5.0;
                end if;

                -- Iniciar maniobra si el tiempo de colision es reducido
                if Tiempo_Colision < Limite_Maniobra	--5D y 5I
                  and then not Control_Colision.Maniobra_Activa
                then
                    Fin_Desvio := Clock + Milliseconds (3000);

                    Control_Colision.Iniciar_Maniobra (Fin_Desvio);

                    Set_Aircraft_Roll (45);		--5G
                end if;

                -- Activar alarma de volumen 4
                if Tiempo_Colision < Limite_Aviso	--5C
                  and then not Control_Colision.Alarma_Emitida
                then
                    Alarm (4);
                    Control_Colision.Marcar_Alarma;
                end if;
            end if;

            -- Mostrar la distancia al obstaculo
            Display_Distance (Distancia_Obstaculo);	--5A

            -- Finalizar la maniobra despues de 3 segundos
            if Control_Colision.Maniobra_Activa		--5G
              and then Clock >= Control_Colision.Fin_Maniobra
            then
                Set_Aircraft_Roll (0);
                Control_Colision.Finalizar_Maniobra;
            end if;

            Finish_Activity ("Tarea_Colision");

            -- Periodo de deteccion: 250 ms
            Proximo_Inicio := Proximo_Inicio + Milliseconds (250); --5H

            delay until Proximo_Inicio;				   --5H
        end loop;
    end Tarea_Colision;

end fss;


