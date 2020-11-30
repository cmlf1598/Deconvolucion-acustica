%% Proyecto de deconvolución acústica 
% Carlos Manuel López (16016)

%Función para graficar en el dominio espectral. 
%   Entradas:        
%           -x_n, señal perturbada
%           -d_n, señal deseada. 
%           -y_n, señal de salida.
%   Salidas:
%           -grafica de la señales en el dominio espectral. 


function spectrograms_graph(x_n, d_n, y_n, fs)
    %set(figure(3), 'Position',  [0, 0, 560, 640]) %tamaño y posición fija.
    window = 2205;
    subplot(3, 1, 1);
    spectrogram(x_n, window, [], [], fs);
    title x[n]
    colormap bone;
    subplot(3, 1, 2);
    spectrogram(d_n, window, [], [], fs);
    title d[n]
    colormap bone;
    subplot(3, 1, 3);
    spectrogram(y_n, window, [], [], fs);
    title y[n]
    colormap bone;
end