%Forward propagation
%Inputs:
    %X - muestras de entrenamiento
    %parameters - array de celdas con parámetros inicializados
%Outputs:
    %A2 - resultado final del forward propagation
    %cache - valores a usar en backward propagation
function [A2, cache] = forwardPropagation(X, parameters)
    %Se cargan los parámetros
    W1 = parameters{1,1};
    b1 = parameters{2,1};
    W2 = parameters{3,1};
    b2 = parameters{4,1};
    
    %Se implementa forward propagation
    Z1 = W1*X + b1;
    A1 = tanh(Z1);
    Z2 = W2*A1 + b2;
    A2 = Z2;
    
    %Argumentos a usar en backward propagation
    cache = {Z1; A1; Z2; A2};
end