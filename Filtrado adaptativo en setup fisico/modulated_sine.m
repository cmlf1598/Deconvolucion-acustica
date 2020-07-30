%%Modulated sine
%Por Carlos Manuel L�pez
%30-7-20

%Funci�n para generar una se�al sinusoidal modulada
%Inputs:
    % fs - frecuencia de muestreo
    % tf - duraci�n deseada
    % fc - frecuencia central (Hz)
    % f_low- frecuencia del oscilador de baja frecuencia
    % Ac - amplitud central 
    % mod - tipo de modulaci�n, AM o FM
%Outputs:
    % Y - se�al sinusoidal modulada
    % t - eje temporal

function [Y, t] = modulated_sine(fs, tf, fc, Ac, f_low, mod)
    dt = 1/fs;
    
    phi = 0;
    t = 0:dt:(tf - dt);
    LFO = sin(2*pi*f_low*t);
    switch mod
        case 'AM'
            Y = LFO.*(Ac*sin( (2*pi*fc*t) + (phi)*(pi/180) ));
        case 'FM'
            Y = (Ac*sin( (2*pi*fc*t) + (phi + LFO*90)*(pi/180) ));
    end
end

