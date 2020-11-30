%% Red neuronal Focused gamma 
% Por Carlos Manuel López 
% Basado en el curso "Redes neurales y aprendizaje profundo" por Andrew Ng

%Función que calcula el costo
%Inputs:
    %A2 - resultado del forward propagation
    %Y - valores correspondientes a la ecuación de la recta original
%Outputs:
    %cost - costo obtenido en base a la varianza
    
function [cost] = get_cost(A2, Y)
    
    %Se obtiene la cantidad de muestras
    [~, m] = size(Y);
    
    %Pérdidas por cada una de las muestras (error cuadrático medio)
    loss = (Y - A2).^2;
    
    %Costo promedio 
    cost = sum(loss, 2)/m;
    
end