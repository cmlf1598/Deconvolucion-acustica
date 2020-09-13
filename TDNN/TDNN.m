%TDNN (Time Delay Neural Network)
%Mini-batch gradient descent
%20-08-2020
%Carlos López (16016)

clear; clc;

%% Parámetros

train_network = false; %verdadero si se desea entrenar la red

%Parámetros de entrenamiento
signal_type = "track"; %tipo de señal ("deterministic" o "track").
order = "sequential"; %orden de las muestras de entrenamiento
beta = 0.1; %tasa de aprendizaje
batch_sz = 44100;

%Tipo de entrenamiento
training = "full_playlist_net";

if (train_network == true)
    switch training
        case "net_per_song"
            no_epochs = 5; %pasadas por canción
            no_cycles = 1; %repeticiones playlist
            save_parameters = false; %guardar los parámetros de la red 
        case "full_playlist_net"
            no_epochs = 1;
            no_cycles = 5;
            save_parameters = true; %guardar los parámetros de la red 
    end
else
    no_epochs = 1;
    no_cycles = 1;
    save_parameters = false;
end
%Parámetros de la arquitectura

%Funciones de activación disponibles
%tanh - tangente hiperbólico
%sine - sinusoide
%sigmoid - sigmoide
%RBF - función de base radial (gaussiana)

activation_functions = ["tanh", "sine", "sigmoid"];
activation_functions = activation_functions(3);

N = 1000; %orden del filtro 
n_h = 250; %cantidad de nodos de la capa oculta

%Opciones de guardado
save_graphs = true; %si se desea guardar los resultados
save_audio = false; %si se desea guardar los audios
save_numerical = true; 

%Path principal
main_path = "D:\UVG\Proyecto de investigacion\Deconvolucion-acustica\Audio data\Clips grabados y originales\";

switch signal_type
    case "deterministic"
        path = main_path + "data determinista\";       
        playlist =["sawtooth_250", "sawtooth_1000", "sawtooth_10000", "sine_250", "sine_1000", "sine_10000"...
                   "square_250", "square_1000", "square_10000", "AM", "FM", "AM_and_FM", "chirp20_10000"];
    case "track"
        path = main_path + "clips musicales\";     
        playlist = ["atlantic_limited", "lonely_cat", "karma_police", "blauen_donau", "bohemian_rhapsody", "cadence", "peru", "week_no_8"];
end

[~, no_tracks] = size(playlist);

%% 
for a = 1:numel(activation_functions)
    
activation_func = activation_functions(a); %función de activación

    for c = 1:no_cycles

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

            %% Entrenamiento de la TDNN

            no_batches = (m - mod(m,batch_sz))/batch_sz; %número de batches

            %Generación de indices aleatorios

            epoch_rand_ind = zeros(1, no_batches*batch_sz); 

            for j = 1:no_batches
                batch_rand_ind = randperm(batch_sz);
                epoch_rand_ind(1, (1 + (batch_sz)*(j-1)):(batch_sz*j)) = batch_rand_ind;
            end

            %Historial de costo
            C = zeros(1,no_epochs*no_batches);

            if ((n == 1) || (training == "net_per_song")) && (c == 1) && (train_network == true)
                %Se inicializan los parámetros
                if activation_func == "RBF"
                    [parameters] = initialize_parameters_and_centers(N, n_h, 1, X_prev);
                else
                    [parameters] = initialize_parameters(N, n_h, 1);
                end      

            else 
                %Cargar red neuronal anterior 
                if (train_network == false)
                    load([pwd, char("\results\"+activation_func+"\numerical\"+"full_playlist_net_"+activation_func+".mat")]);
                else
                    load parameters;
                end
                
            end

            if train_network == true

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

                        %Se obtiene el resultado de la función costo
                        [cost] = get_cost(A2, Y_batch);

                        %Se aplica backward propagation
                        [grads] = backward_propagation(parameters, cache, X_batch, Y_batch, activation_func);

                        %Actualización de parámetros
                        parameters = update_parameters(parameters, grads, beta);

                        C(1, (j + (i-1)*(no_batches))) = cost; %guardar costo

                        %fprintf("Batch %4j | Costo = %10.10f\n",j,cost);
                    end

                    fprintf("Epoch %4i | Costo = %10.10f\n",i,cost);
                end
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

            %Señales de interés
            x_n = X_prev(1:(no_batches*batch_sz), 1);
            d_n = D_prev(1:(no_batches*batch_sz), 1);
            y_n = Y_est';

            if save_numerical == true
                %Error
                error = abs(d_n - y_n);
                mean_error = mean(error);
                accumulated_error = sum(error);
                save(char("results\"+activation_func+"\"+"numerical\"+"mean_error_"+activation_func+"_"+playlist(n)+".mat"),'mean_error');
                save(char("results\"+activation_func+"\"+"numerical\"+"accumulated_error_"+activation_func+"_"+playlist(n)+".mat"),'accumulated_error');
            end
            
            %Guardar net anterior
            if save_parameters == true
                save parameters.mat parameters;
            end

            %% Graficando
            batch_axis = 1:no_epochs*no_batches;

            if ((training == "full_playlist_net") && (train_network == true))
                if ((n == 1) && (c == 1))
                    C_cycles = C;
                    batch_axis_cycles = batch_axis;
                else
                    C_cycles = [C_cycles, C];
                    batch_axis_cycles = [batch_axis_cycles, (batch_axis_cycles(end) + batch_axis)];
                end  
            end

            if (training == "net_per_song")
                clf; figure(1);
                plot(batch_axis, C);
                xlabel('Batch'); 
                ylabel('Cost');
                if save_graphs == true
                    saveas(figure(1), [pwd char("\results\"+activation_func+"\"+"cost_"+playlist(n)+"_TDNN_"+activation_func+".eps")] );
                    saveas(figure(1), [pwd char("\results\"+activation_func+"\"+"png\"+"cost_"+playlist(n)+"_TDNN_"+activation_func+".png")] );
                end
            end

            %Vector temporal
            t = 0:(1/fs):( (no_batches*batch_sz/fs)-(1/fs)  );
            t = t';
            t_tag = 'Time (secs)';

            t0 = t(2);
            tf = t(end);

            if signal_type == "deterministic"
                t0 = t(end)/2;
                tf = (t(end)/2) + 0.005;
            end

            clf; figure(2);
            subplot(3, 1, 1);
            plot(t(t0*fs:tf*fs), x_n(t0*fs:tf*fs), 'color', [0, 0.4470, 0.7410]);
            if signal_type == "deterministic"
                xaxis(t0, tf);
            end
            legend x[n];
            xlabel(t_tag); 
            subplot(3, 1, 2);
            plot(t(t0*fs:tf*fs), d_n(t0*fs:tf*fs), 'red');
            if signal_type == "deterministic"
                xaxis(t0, tf);
            end
            legend d[n];
            xlabel(t_tag); 
            subplot(3, 1, 3);
            plot(t(t0*fs:tf*fs), y_n(t0*fs:tf*fs), 'color', [0.9290, 0.6940, 0.1250]);
            if signal_type == "deterministic"
                xaxis(t0, tf);
            end
            %yaxis(-1,1);
            legend y[n];
            xlabel(t_tag);
            if save_graphs == true
                saveas(figure(2), [pwd char("\results\"+activation_func+"\"+"signals_"+playlist(n)+"_TDNN_"+activation_func+".eps")] );
                saveas(figure(2), [pwd char("\results\"+activation_func+"\"+"png\"+"signals_"+playlist(n)+"_TDNN_"+activation_func+".png")] );
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
                saveas(figure(3), [pwd char("\results\"+activation_func+"\"+"spectrogram_"+playlist(n)+"_TDNN_"+activation_func+".eps")] );
                saveas(figure(3), [pwd char("\results\"+activation_func+"\"+"png\"+"spectrogram_"+playlist(n)+"_TDNN_"+activation_func+".png")] );
            end

            if save_audio == true
                audiowrite( [pwd char("\audio data\"+activation_func+"\"+playlist(n)+"_TDNN_"+activation_func+".wav")], y_n, fs);
            end
        end

    end

    if ((training == "full_playlist_net") && (train_network == true))
        clf; figure(4);
        plot(batch_axis_cycles, C_cycles);
        xlabel('Batch'); 
        ylabel('Cost');
        saveas(figure(4), [pwd char("\results\"+activation_func+"\"+"general_cost_"+"_TDNN_"+activation_func+".eps")] );
        saveas(figure(4), [pwd char("\results\"+activation_func+"\"+"png\"+"general_cost_"+"_TDNN_"+activation_func+".png")] );
        
        %Guardar net final
        save(char("results\"+activation_func+"\"+"numerical\"+"full_playlist_net_"+activation_func+".mat"),'parameters');
    end
    
end