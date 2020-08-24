%Funci�n que calcula el costo
%Inputs:
    %A2 - resultado del forward propagation
    %Y - valores correspondientes a la ecuaci�n de la recta original
%Outputs:
    %cost - costo obtenido en base a la varianza
function [cost] = getCost(A2, Y)
    
    %Se obtiene la cantidad de muestras
    [~, m] = size(Y);
    
    %P�rdidas por cada una de las muestras (error cuadr�tico medio)
    loss = (Y - A2).^2;
    
    %Costo promedio 
    cost = sum(loss, 2)/m;
    
end