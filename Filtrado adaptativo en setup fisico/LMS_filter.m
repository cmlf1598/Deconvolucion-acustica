%% Filtro adaptativo por LMS
%Por Carlos Manuel López
%19-4-20

%Inputs:
    %beta - tasa de aprendizaje
    %N - número de coeficientes del filtro
    %normalized (logical) - si se desea la variante normalizada
%Outputs:
    %Y - señal de salida
    %E - error
    %W - magnitud del vector de pesos
    
function [Y,E,W] = LMS_filter(X, D, beta, N, normalized)
    
    [M, ~] = size(X);
    
    %Arrays de almacenamiento
    Y = zeros(M, 1);
    E = zeros(M, 1);
    W = zeros(M, 1);
    
    z = zeros(N, 1); %linea de delays
    w = zeros(N, 1); %array de pesos
    
    for k = 1:M

        %Muestras actuales
        x = X(k, 1);  
        d = D(k, 1);

        %Muestra actual se coloca al principio de la linea de delays
        z(1, 1) = x;

        y = w'*z; %señal de salida
        e = d - y; %error

        %Actualización de pesos w (en base a la estimación del gradiente)

        if (normalized == true)
            pow_2 = (z'*z);
            %Evitar división entre 0
            if pow_2 == 0
                pow_2 = 1e-20;
            end
            w = w + (1/(pow_2))*e*z;
        else 
            w = w + beta*e*z;
        end

        %Se realiza un corrimiento en la linea de delays
        z(2:N, 1) = z(1:N - 1, 1); 

        %Se guardan la muestras correspondientes
        Y(k, 1) = y;
        E(k, 1) = e;
        W(k, 1) = norm(w);
    end


end
