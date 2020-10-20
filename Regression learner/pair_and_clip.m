function [X,D] = pair_and_clip(fs, X, D, t0, tf)

    % Emparejamiento temporal 

    m = size(X,1); %tamaño de las señales (X)

    delay = finddelay(D, X); %delay entre señales
    X = X(delay:m); 
    m = size(X,1);
    D = D(1:m); 
    
    %% Clipping 
    range = (t0*fs) + 1:(tf*fs);

    X = X(range);
    D = D(range);
end
