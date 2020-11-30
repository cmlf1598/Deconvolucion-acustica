%% Proyecto de deconvolución acústica 
% Carlos Manuel López (16016)

%Función para graficar en el dominio temporal. 
%   Entradas:        
%           -x_n, señal perturbada
%           -d_n, señal deseada. 
%           -y_n, señal de salida.
%   Salidas:
%           -grafica de la señales en el dominio temporal. 

function signals_graph(x_n, d_n, y_n)
    subplot(3,1,1);
    plot(x_n, 'color', [0, 0.4470, 0.7410]);
    legend x[n];
    subplot(3,1,2);
    plot(d_n, 'red');
    legend d[n];    
    subplot(3,1,3);
    plot(y_n, 'color', [0.9290, 0.6940, 0.1250]);
    legend y[n];
end