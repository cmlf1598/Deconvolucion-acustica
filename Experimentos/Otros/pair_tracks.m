%% Proyecto de deconvolución acústica 
% Carlos Manuel López (16016)

%Función para emparejar dos señales de audio. 
%   Entradas:
%           -y_n, señal adeltantada.
%           -x_n, señal atrasada.
%   Salidas:
%           -y_n, x_n, señales emparejadas. 

function [y_n, x_n] = pair_tracks(y_n, x_n)
    
    m = size(x_n,1); %tamaño inicial de la señal de atrasada.
    delay = finddelay(y_n, x_n); %delay (cantidad de muestras) de desfase.
    x_n = x_n(delay:m); %recortar señal atrasada. 
    m = size(x_n,1); %nuevo tamaño de la señal.
    y_n = y_n(1:m); %hacer coincidir y_n en tamaño con x_n. 

end

