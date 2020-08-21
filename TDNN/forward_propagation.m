%Forward propagation
%Inputs:
    %X - muestras de entrenamiento (muestras como vectores columna, una a
    %la par de la otra)
    %parameters - array de celdas con parámetros inicializados
    %act_func - función de activación escogida
%Outputs:
    %A2 - resultado final del forward propagation
    %cache - valores a usar en backward propagation
function [A2, cache] = forward_propagation(X, parameters, act_func)
    %Se cargan los parámetros
    W1 = parameters{1,1};
    b1 = parameters{2,1};
    W2 = parameters{3,1};
    b2 = parameters{4,1};
    
    %Se implementa forward propagation
    Z1 = W1*X + b1;
    
    switch act_func
        case 'sine'
            A1 = sin(Z1);
            D1 = cos(Z1); %primera derivada
        case 'tanh'
            A1 = tanh(Z1);
    end
   
    Z2 = W2*A1 + b2;
    A2 = Z2;
    
    %Argumentos a usar en backward propagation
    cache = {Z1; A1; Z2; A2; D1};
end