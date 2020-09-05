%Focused Gamma Neural Network
%Mini-batch gradient descent
%20-08-2020
%Carlos López (16016)

clear; clc;

%% Parámetros

new_network = true; %si desea crear una nueva red, de lo contrario se carga la anterior.
train_network = true; %si se desea entrenar la red

%Parámetros de entrenamiento
signal_type = 'track'; %tipo de señal ("deterministic" o "track").
order = 'sequential'; %orden de las muestras de entrenamiento
beta = 0.1; %tasa de aprendizaje general
epsilon = (1e3)*beta; %tasa de aprendizaje de mu
mu_initial = 0.5;
batch_sz = 2205;  
no_epochs = 5; %número de interaciones de entrenamiento (epochs)

%Parámetros de la arquitectura
%Funciones de activación disponibles
%tanh - tangente hiperbólico
%sine - sinusoide
%RBF - función de base radial (gaussiana)
%sigmoid - sigmoide
activation_func = "tanh"; %función de activación
N = 1000; %orden del filtro 
n_h = 100; %cantidad de nodos de la capa oculta

%Opciones de guardado
save_parameters = true; %guardar los parámetros de la red 
save_graphs = true; %si se desea guardar los resultados
save_audio = true; %si se desea guardar los audios

%Path principal
main_path = "D:\UVG\Proyecto de investigacion\Deconvolucion-acustica\Audio data\Clips grabados y originales\";

switch signal_type
    case "deterministic"
        path = main_path + "data determinista\";
        %playlist = ["AM", "FM", "AM_and_FM", "chirp20_10000"];
        %playlist = ["AM", "FM"];
        playlist = ["AM_and_FM", "chirp20_10000"];
    case "track"
        path = main_path + "clips musicales\";
        playlist = ["bohemian_rhapsody", "cadence", "peru", "week_no_8"];
        %playlist = ["bohemian_rhapsody", "cadence"];
        %playlist = ["peru", "week_no_8"];
        %playlist = "bohemian_rhapsody";
        %playlist = "peru";
        %playlist = "week_no_8";
end

[~, no_tracks] = size(playlist);

%% 
for n = 1:no_tracks
    
    %Adquisición de las señales 
    [D_prev, fs] = audioread(path+playlist(n)+"_original.wav"); %señal original
    [X_prev, ~] = audioread(path+playlist(n)+"_recorded.wav"); %señal grabada

    %Emparejamiento temporal de las señales 
    
    m = size(X_prev,1); %tamaño inicial de la señal de entrada.

    delay = finddelay(D_prev, X_prev); %delay entre señales
    X_prev = X_prev(delay:m); 
    m = size(X_prev,1);
    D_prev = D_prev(1:m); 
    
    X_zero_p = [zeros(N-1, 1); X_prev]; %zero padding
    Y = D_prev'; 

    %% Entrenamiento de la gamma
           
    no_batches = (m - mod(m,batch_sz))/batch_sz; %número de batches

    %Historial de costo
    C = zeros(1,no_epochs*no_batches);

    if new_network == true
        %Se inicializan los parámetros
        if activation_func == "RBF"
            [parameters] = initialize_parameters_and_centers(N, n_h, 1, X_prev);
        else
            [parameters] = initialize_parameters(N, n_h, 1, mu_initial);
        end      
        
    else 
        %Cargar red neuronal anterior 
        load parameters;
    end
        
    if train_network == true
        
        for i = 1:no_epochs

            for j = 1:no_batches

                %Se inicializa el batch
                X_batch = zeros(N, batch_sz);
                X_line = X_prev((1 + (batch_sz)*(j-1)):(batch_sz*j));
                Y_line = Y((1 + (batch_sz)*(j-1)):(batch_sz*j) );   
                Y_batch = Y(1, (1 + (batch_sz)*(j-1)):(batch_sz*j) );      
                %
                dX_dMU = zeros(N-1, batch_sz);
                
                delay_line = zeros(N,1);
                alfa = zeros(N,1);
                
                %Memoria gamma
                mu = parameters{5,1};
                
                %Se crea el batch 
                for k = 1:batch_sz
                    
                    delay_line(1:N-1) = mu.*delay_line(1:N-1) + (1-mu).*delay_line(2:N); %recursión gamma
                    
                    delay_line(2:N) = delay_line(1:N-1, 1); %corrimiento en la linea de delays
                    delay_line(1) = X_line(k); %muestra actual al principio de la linea
                    
                    alfa(2:N) = (1-mu).*alfa(2:N) + mu.*alfa(1:N-1) + (delay_line(1:N-1) - delay_line(2:N));
                    dX_dMU(:, k) = alfa(2:N);
                    
                    %dX_dMU(:, k) = delay_line(2:N) + delay_line(1:N-1)./mu; %y[n-1] + (1/mu)x[n];
                    
                    %delay_line(1:N-1) = delay_line(1:N-1) + mu.*delay_line(2:N); %recursión gamma
                    
                    
                    %dX_dMU(:, k) = dX_dMU(1:N-1, k) + delay_line(1:N-1)./mu; %y[n-1] - (1/mu)y[n] +(1/mu)x[n]
                    
                    
                    
                    X_batch(:,k) = delay_line; %orden secuencial
 
                    
                end

                %Se aplica forward propagation
                [A2, cache] = forward_propagation(X_batch, parameters, activation_func);

                %Se obtiene el resultado de la función costo
                [cost] = get_cost(A2, Y_batch);

                %Se aplica backward propagation
                [grads] = backward_propagation(parameters, cache, X_batch, Y_batch, activation_func, dX_dMU);

                %Actualización de parámetros
                parameters = update_parameters(parameters, grads, beta, epsilon);

                C(1, (j + (i-1)*(no_batches))) = cost; %guardar costo

                %fprintf("Batch %4j | Costo = %10.10f\n",j,cost);
            end

            fprintf("Epoch %4i | Costo = %10.10f\n",i,cost);
        end
    end
    %% Se prueba la gamma
    
    Y_est = zeros(1, (no_batches*batch_sz));

    for j = 1:no_batches
        X_batch = zeros(N, batch_sz);

        for k = 1:batch_sz
            delay_line = flip(X_zero_p( (k + (batch_sz*(j-1))):((N-1+k)+(batch_sz*(j-1))) ), 1);
            X_batch(:,k) = delay_line;
        end

        %Se aplica forward propagation
        [A2, ~] = forward_propagation(X_batch, parameters, activation_func);

        Y_est(1 + (batch_sz*(j-1)):j*batch_sz) = A2;
    end
    
    %Señales de interés
    x_n = X_prev(1:(no_batches*batch_sz), 1);
    d_n = D_prev(1:(no_batches*batch_sz), 1);
    y_n = Y_est';
    
    if save_parameters == true
        save parameters.mat parameters;
    end

    %% Graficando
    
    clf; figure(1);
    plot((1:no_epochs*no_batches), C);
    xlabel('Batch'); 
    ylabel('Cost');
    if save_graphs == true
        saveas(figure(1), [pwd char("\results\"+activation_func+"\"+"cost_"+playlist(n)+"_gamma_"+activation_func+".eps")] );
        saveas(figure(1), [pwd char("\results\"+activation_func+"\"+"png\"+"cost_"+playlist(n)+"_gamma_"+activation_func+".png")] );
    end
    
    %Vector temporal
    t = 0:(1/fs):( (no_batches*batch_sz/fs)-(1/fs)  );
    t = t';
    t_tag = 'Time (secs)';
    
    t0 = t(2);
    tf = t(end);
    
    if signal_type == "deterministic"
        t0 = t(end)/2;
        tf = (t(end)/2) + 0.02;
    end
    
    clf; figure(2);
    subplot(3, 1, 1);
    plot(t(t0*fs:tf*fs), x_n(t0*fs:tf*fs), 'color', [0, 0.4470, 0.7410]);
    %plot(t, x_n,'color', [0, 0.4470, 0.7410]);
    legend x[n];
    xlabel(t_tag); 
    subplot(3, 1, 2);
    plot(t(t0*fs:tf*fs), d_n(t0*fs:tf*fs), 'red');
    %plot(t, d_n, 'red');
    legend d[n];
    xlabel(t_tag); 
    subplot(3, 1, 3);
    plot(t(t0*fs:tf*fs), y_n(t0*fs:tf*fs), 'color', [0.9290, 0.6940, 0.1250]);
    %plot(t, y_n, 'color', [0.9290, 0.6940, 0.1250]);
    %yaxis(-1,1);
    legend y[n];
    xlabel(t_tag);
    if save_graphs == true
        saveas(figure(2), [pwd char("\results\"+activation_func+"\"+"signals_"+playlist(n)+"_gamma_"+activation_func+".eps")] );
        saveas(figure(2), [pwd char("\results\"+activation_func+"\"+"png\"+"signals_"+playlist(n)+"_gamma_"+activation_func+".png")] );
    end
    %% Espectrogramas

    %2205 para una frecuencia mínima de 20 Hz    
    clf; figure(3);
    set(figure(3), 'Position',  [0, 0, 560, 640])
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
    if save_graphs == true
        saveas(figure(3), [pwd char("\results\"+activation_func+"\"+"spectrogram_"+playlist(n)+"_gamma_"+activation_func+".eps")] );
        saveas(figure(3), [pwd char("\results\"+activation_func+"\"+"png\"+"spectrogram_"+playlist(n)+"_gamma_"+activation_func+".png")] );
    end
    
    if save_audio == true
        audiowrite( [pwd char("\audio data\"+activation_func+"\"+playlist(n)+"_gamma_"+activation_func+".wav")], y_n, fs);
    end
end

