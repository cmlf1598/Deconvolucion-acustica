%% Proyecto de deconvolución acústica 
% Carlos Manuel López (16016)

%Función para graficar en el dominio temporal. 
%   Entradas:        
%           -x_n, señal seleccionada. 
%           -window_sz, tamaño de la línea de delays. 
%   Salidas:
%           -X, matriz de entrada para una TDNN. 

function [X] = tapped_delay_mat(x_n, window_sz)
    
    [duration, ~] = size(x_n); %tamaño de la señal seleccionada. 
    x_n = [zeros(window_sz-1, 1); x_n]; %linea de delays empieza vacía. 
    X = zeros(window_sz, duration); %tamaño final de la matriz X.
    
    %Tomar recortes de la señal y colocarlos como columnas en X.
    for i = 1:duration
        X(:,i) = flip(x_n(i:(window_sz-1+i)), 1);
    end

end