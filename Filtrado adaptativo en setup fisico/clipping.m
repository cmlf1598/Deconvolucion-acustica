%%Clipping
%Por Carlos Manuel L�pez
%19-4-20

%Funci�n para extraer un clip de alg�n archivo de audio. 
%Inputs:
    %X - audio
    %t0 - tiempo inicial de recorte (en seg).
    %tf - tiempo final de recorte (en seg).
%Outputs:
    %Y - clip generado, en forma matricial.
    %fs - frecuencia de muestreo.
    
function [Y, fs] = clipping(X, fs, t0, tf)
    
    [n, ~] = size(X); %dimensiones del archivo de audio le�do.
    
    s0 = (fs*t0) + 1; %muestra inicial
    sf = fs*tf; %muestra final
    
    %Tiempos de recorte no deben exceder duraci�n del audio original.
    
    if (s0 > n) 
        disp("Tiempo inicial excede duraci�n total.");
    end
    
    if (sf > n)
        disp("Tiempo final excede duraci�n total.");
    end
    
    %Clip resultante (primer canal, sonido mono)
    Y = X(s0:sf, 1);
   
end 

