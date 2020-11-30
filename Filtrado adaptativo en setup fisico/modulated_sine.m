%% Modulated sine
%Por Carlos Manuel L�pez
%30-7-20

%Funci�n para generar una se�al sinusoidal modulada
%Inputs:
    % fs - frecuencia de muestreo
    % tf - duraci�n deseada
    % fc - frecuencia central (Hz)
    % f_low_AM - frecuencia del oscilador que modulo amplitud
    % f_low_FM - frecuencia del oscilador que modulo frecuencia
    % Ac - amplitud central 
    % mod - tipo de modulaci�n, AM, FM o ambos
%Outputs:
    % Y - se�al sinusoidal modulada
    % t - eje temporal

function [Y, t] = modulated_sine(fs, tf, fc, Ac, f_low_AM, f_low_FM, mod)
    dt = 1/fs;
    
    phi = 0;
    t = 0:dt:(tf - dt);
    LFO_A = sin(2*pi*f_low_AM*t);
    LFO_F = sin(2*pi*f_low_FM*t);
    switch mod
        case 'AM'
            Y = LFO_A.*(Ac*sin( (2*pi*fc*t) + (phi)*(pi/180) ));
        case 'FM'
            Y = (Ac*sin( (2*pi*fc*t) + (phi + LFO_F*90)*(pi/180) ));
        case 'both'
            Y = LFO_A.*(Ac*sin( (2*pi*fc*t) + (phi + LFO_F*90)*(pi/180) ));
    end
    
end

