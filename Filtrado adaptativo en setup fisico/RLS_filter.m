%% Filtro adaptativo por RLS
%Por Carlos Manuel López

%Inputs:
    %lambda - factor de persistencia (varía entre 0 y 1). 
    %delta - puede ser el inverso del estimado de la señal de entrada.
    %N - número de coeficientes del filtro.
%Outputs:
    %Y - señal de salida
    %E - error
    %W - magnitud del vector de pesos
    
function [Y, E, W] = RLS_filter(X, D, lambda, delta, N)
    
    [M, ~] = size(X);
    
    %Incializaciones
    
    %Arrays de almacenamiento
    Y = zeros(M, 1);
    E = zeros(M, 1);
    W = zeros(M, 1);
    
    z = zeros(N, 1); %linea de delays

    S = delta*eye(N); %estimado de la matriz de correlación.
    p = zeros(N, 1); %vector de correlación cruzada.

    S_1 = S; %matriz S anterior.
    p_1 = p; %vector p anterior.

    for k = 1:M
        
        %Muestras actuales
        x = X(k, 1);  
        d = D(k, 1);

        %Muestra actual se coloca al principio de la linea de delays 
        %(este paso es parte del corrimiento)
        z(1, 1) = x;

        %Estimado de la matriz de correlación
        S = (1/lambda)*(S_1 - ( (S_1*(z*z')*S_1)/( (lambda) + z'*S_1*z) ));

        %Estimado del vector de correlación cruzada (cross-correlation).
        p = lambda*p_1 +  d*z;

        %Actualización de pesos w 
        w = S*p;

        y = w'*z; %señal de salida
        e = d - y; %error

        %Se realiza un corrimiento en la linea de delays
        z(2:N, 1) = z(1:N - 1, 1); 

        %Se guardan la muestras correspondientes
        Y(k, 1) = y;
        E(k, 1) = e;
        W(k, 1) = norm(w);

        %Se actualizan los estimados anteriores
        S_1 = S;
        p_1 = p;
    end

end