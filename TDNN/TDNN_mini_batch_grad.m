%TDNN (Time Delay Neural Network)
%Mini-batch gradient descent
%20-08-2020
%Carlos L�pez (16016)

clear; clc;

%% Par�metros

save_data = false; %si se desea guardar los resultados

%Par�metros de entrenamiento
signal_type = "track"; %tipo de se�al ("deterministic" o "track").
order = "sequential"; %orden de las muestras de entrenamiento
beta = 0.1; %tasa de aprendizaje
batch_sz = 2205;  
no_epochs = 5; %n�mero de interaciones de entrenamiento (epochs)

%Par�metros de la arquitectura
%Funciones de activaci�n disponibles
%tanh - tangente hiperb�lico
%sine - sinusoide
%RBF - funci�n de base radial (gaussiana)
%sigmoid - sigmoide
activation_func = "sine"; %funci�n de activaci�n
N = 1000; %orden del filtro 
n_h = 20; %cantidad de nodos de la capa oculta

%Path principal
main_path = "D:\UVG\Proyecto de investigacion\Deconvolucion-acustica\Audio data\Clips grabados y originales\";

switch signal_type
    case "deterministic"
        path = main_path + "data determinista\";
        playlist = ["AM", "FM", "AM_and_FM", "chirp20_10000"];
        %playlist = ["AM", "FM"];
    case "track"
        path = main_path + "clips musicales\";
        playlist = ["bohemian_rhapsody", "cadence", "peru", "week_no_8"];
end

[~, no_tracks] = size(playlist);

%% 
for n = 1:no_tracks
    
    %Adquisici�n de las se�ales 
    [D_prev, fs] = audioread(path+playlist(n)+"_original.wav"); %se�al original
    [X_prev, ~] = audioread(path+playlist(n)+"_recorded.wav"); %se�al grabada

    %Emparejamiento temporal de las se�ales 
    
    m = size(X_prev,1); %tama�o inicial de la se�al de entrada.

    delay = finddelay(D_prev, X_prev); %delay entre se�ales
    X_prev = X_prev(delay:m); 
    m = size(X_prev,1);
    D_prev = D_prev(1:m); 
    
    X_zero_p = [zeros(N-1, 1); X_prev]; %zero padding
    Y = D_prev'; 

    %% Entrenamiento de la TDNN

    no_batches = (m - mod(m,batch_sz))/batch_sz; %n�mero de batches
    
    %Generaci�n de indices aleatorios

    epoch_rand_ind = zeros(1, no_batches*batch_sz); 

    for j = 1:no_batches
        batch_rand_ind = randperm(batch_sz);
        epoch_rand_ind(1, (1 + (batch_sz)*(j-1)):(batch_sz*j)) = batch_rand_ind;
    end
    
    %Historial de costo
    C = zeros(1,no_epochs*no_batches);
    
    %Se inicializan los par�metros
    [parameters] = initializeParameters(N, n_h, 1);

    for i = 1:no_epochs

        for j = 1:no_batches

            %Se inicializa el batch
            X_batch = zeros(N, batch_sz);
            Y_batch = Y(1, (1 + (batch_sz)*(j-1)):(batch_sz*j) );          

            %Se crea el batch 
            for k = 1:batch_sz

                sample = flip(X_zero_p( (k + (batch_sz*(j-1))):((N-1+k)+(batch_sz*(j-1))) ), 1);

                switch order
                    case "sequential"  
                        X_batch(:,k) = sample;
                    case "random"
                        k_rand = epoch_rand_ind(1, k + (batch_sz)*(j - 1) );
                        X_batch(:, k_rand) = sample;
                        Y_batch(:, k_rand) = Y_batch(1,k);
                end
            end


            %Se aplica forward propagation
            [A2, cache] = forward_propagation(X_batch, parameters, activation_func);

            %Se obtiene el resultado de la funci�n costo
            [cost] = get_cost(A2, Y_batch);

            %Se aplica backward propagation
            [grads] = backward_propagation(parameters, cache, X_batch, Y_batch, activation_func);

            %Actualizaci�n de par�metros
            parameters = updateParameters(parameters, grads, beta);
                    
            C(1, (j + (i-1)*(no_batches))) = cost; %guardar costo
            
            %fprintf("Batch %4j | Costo = %10.10f\n",j,cost);
        end

        fprintf("Epoch %4i | Costo = %10.10f\n",i,cost);
    end
    %% Se prueba la TDNN

    Y_est = zeros(1, (no_batches*batch_sz));

    for j = 1:no_batches
        X_batch = zeros(N, batch_sz);

        for k = 1:batch_sz
            sample = flip(X_zero_p( (k + (batch_sz*(j-1))):((N-1+k)+(batch_sz*(j-1))) ), 1);
            X_batch(:,k) = sample;
        end

        %Se aplica forward propagation
        [A2, ~] = forward_propagation(X_batch, parameters, activation_func);

        Y_est(1 + (batch_sz*(j-1)):j*batch_sz) = A2;
    end
    
    %Se�ales de inter�s
    x_n = X_prev(1:(no_batches*batch_sz), 1);
    d_n = D_prev(1:(no_batches*batch_sz), 1);
    y_n = Y_est';

    %% Graficando
    
    figure(1);
    plot((1:no_epochs*no_batches), C);
    xlabel('Batch'); 
    ylabel('Cost');
    if save_data == true
        saveas(figure(1), [pwd char("/results/"+activation_func+"/"+"cost_"+playlist(n)+"_TDNN_"+activation_func+".eps")] );
        saveas(figure(1), [pwd char("/results/"+activation_func+"/"+"png/"+"cost_"+playlist(n)+"_TDNN_"+activation_func+".png")] );
    end
    
    %Vector temporal
    t = 0:(1/fs):( (no_batches*batch_sz/fs)-(1/fs)  );
    t = t';
    t_tag = 'Time (secs)';

    %tf = (no_batches*batch_sz/fs)-(1/fs) ;

    figure(2);
    subplot(3, 1, 1);
    %plot(t(1:tf*fs), x_n(1:tf*fs), 'blue');
    plot(t, x_n,'color', [0, 0.4470, 0.7410]);
    legend x[n];
    xlabel(t_tag); 
    subplot(3, 1, 2);
    %plot(t(1:tf*fs), d_n(1:tf*fs), 'red');
    plot(t, d_n, 'red');
    legend d[n];
    xlabel(t_tag); 
    subplot(3, 1, 3);
    %plot(t(1:tf*fs), y_n(1:tf*fs),  'green');
    plot(t, y_n, 'color', [0.9290, 0.6940, 0.1250]);
    yaxis(-1,1);
    legend y[n];
    xlabel(t_tag);
    if save_data == true
        saveas(figure(2), [pwd char("/results/"+activation_func+"/"+"signals_"+playlist(n)+"_TDNN_"+activation_func+".eps")] );
        saveas(figure(2), [pwd char("/results/"+activation_func+"/"+"png/"+"signals_"+playlist(n)+"_TDNN_"+activation_func+".png")] );
    end
    %% Espectrogramas

    %2205 para una frecuencia m�nima de 20 Hz    
    figure(3);
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
    if save_data == true
        saveas(figure(3), [pwd char("/results/"+activation_func+"/"+"spectrogram_"+playlist(n)+"_TDNN_"+activation_func+".eps")] );
        saveas(figure(3), [pwd char("/results/"+activation_func+"/"+"png/"+"spectrogram_"+playlist(n)+"_TDNN_"+activation_func+".png")] );
    end
end

