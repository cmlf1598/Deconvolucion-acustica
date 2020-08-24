%Actalización de parámetros
function [parameters] = updateParameters(parameters, grads, learningRate)
    
    %Se cargan los parámetros
    W1 = parameters{1,1};
    b1 = parameters{2,1};
    W2 = parameters{3,1};
    b2 = parameters{4,1};
    
    %Se obtienen los gradientes
    dW1 = grads{1,1};
    db1 = grads{2,1};
    dW2 = grads{3,1};
    db2 = grads{4,1};
    
    %Se actualizan los parámetros
    W1 = W1 - learningRate*dW1; 
    b1 = b1 - learningRate*db1;
    W2 = W2 - learningRate*dW2;
    b2 = b2 - learningRate*db2;
    
    parameters = {W1; b1; W2; b2};
end