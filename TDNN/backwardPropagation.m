%Backward propagation
function [grads] = backwardPropagation(parameters, cache, X, Y)
    [~, m] = size(Y);
    
    W2 = parameters{3,1};
    
    A1 = cache{2,1};
    A2 = cache{4,1};
    
    %Se aplica backward propagation
    %Se promedia el cambio diferencial que aporta cada muestra
    %n_i = tamaño capa de entrada
    %n_h = tamaño capa de oculta
    %n_o = tamaño capa de salida
    dZ2 = -2*(Y - A2); %(n_o,m)
    dW2 = (dZ2*A1')/m; %(n_o,m)*(m,n_h)
    db2 = sum(dZ2, 2)/m; %(n_o,1)
    dZ1 = (W2'*dZ2).*(1 - A1.^2); %(n_h,n_o)*(n_o,m).*(n_h,m) = (n_h,m)
    dW1 = (dZ1*X')/m; %(n_h,m)*(m,n_i)
    db1 = sum(dZ1,2)/m; %(n_h, 1) 
    
    grads ={dW1; db1; dW2; db2};
end