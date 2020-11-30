
%y_n - señal adeltantada
%x_n - señal atrasada

function [y_n, x_n] = pair_tracks(y_n, x_n)
    
    m = size(x_n,1); %tamaño inicial de la señal de atrasada
    delay = finddelay(y_n, x_n); %delay (cantidad de muestras) de desfase
    x_n = x_n(delay:m);
    m = size(x_n,1);
    y_n = y_n(1:m);

end

