%% Red neuronal Focused gamma 
% Por Carlos Manuel López 
% Basado en el curso "Redes neurales y aprendizaje profundo" por Andrew Ng

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
    %mu = parameters{5,1};
    
    [~, m] = size(X); 
    [n_h, n_i] = size(W1);
    
    %Se implementa forward propagation
        
    switch act_func
        case "sine"
            Z1 = W1*X + b1;
            A1 = sin(Z1);
            D1 = cos(Z1); %primera derivada
        case "sigmoid"
            Z1 = W1*X + b1;
            A1 = (2./(1 + exp(-Z1)) - 1); %se necesita centrar en 0
            D1 = 2*(A1 - A1.^2); 
        case "tanh"
            Z1 = W1*X + b1;
            A1 = tanh(Z1);
            D1 = (1 - A1.^2);
        case "RBF"
            C1 = reshape(W1', n_i, 1, n_h); %matriz se separa en vectores. 
            Z1 = reshape(vecnorm(X - C1), n_h, m, 1); %se obtienen las normas ||x - c||
            A1 = exp(-(Z1.^2));
            D1 = -2*(Z1 - 1).*A1;
    end
   
    Z2 = W2*A1 + b2;
    A2 = Z2;
    
    %Argumentos a usar en backward propagation
    cache = {Z1; A1; Z2; A2; D1};
end