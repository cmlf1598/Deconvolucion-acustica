%% TDNN (Time Delay Neural Network)
% Por Carlos Manuel López 
% Basado en el curso "Redes neurales y aprendizaje profundo" por Andrew Ng

%Backward propagation

function [grads] = backward_propagation(parameters, cache, X, Y, act_func)
    [~, m] = size(Y);
    
    W1 = parameters{1,1};
    W2 = parameters{3,1};
    
    A1 = cache{2,1};
    A2 = cache{4,1};
    D1 = cache{5,1};
    
    [n_h, n_i] = size(W1);
    
    %Se aplica backward propagation
    %Se promedia el cambio diferencial que aporta cada muestra
    %n_i = tamaño capa de entrada
    %n_h = tamaño capa de oculta
    %n_o = tamaño capa de salida
    dZ2 = -2*(Y - A2); %(n_o,m)
    dW2 = (dZ2*A1')/m; %(n_o,m)*(m,n_h) = (n_o, n_h)
    db2 = sum(dZ2, 2)/m; %(n_o,1)
    dZ1 = (W2'*dZ2).*(D1); %(n_h,n_o)*(n_o,m).*(n_h,m) = (n_h,m)
    
    switch act_func
        case "sine"            
            dW1 = (dZ1*X')/m; %(n_h,m)*(m,n_i)
            db1 = sum(dZ1,2)/m; %(n_h, 1) 
        case "sigmoid"
            dW1 = (dZ1*X')/m; %(n_h,m)*(m,n_i)
            db1 = sum(dZ1,2)/m; %(n_h, 1) 
        case "tanh"
            dW1 = (dZ1*X')/m; %(n_h,m)*(m,n_i)
            db1 = sum(dZ1,2)/m; %(n_h, 1) 
        case "RBF"
            dW1 = (dZ1*(-ones(m, n_i)))/m; %(n_h,m)*(m,n_i)
            db1 = zeros(n_h, 1); %(n_h, 1) 
    end
    
    
    
    grads ={dW1; db1; dW2; db2};
end