%TDNN (Time Delay Neural Network)
%Mini-batch gradient descent
%17-05-2020
%Carlos López (16016)

clear; clc;

%% Parámetros

%Parámetros de entrenamiento
signal_type = 'deterministic'; %tipo de señal ("deterministic" o "track").
order = 'sequential'; %orden de las muestras de entrenamiento
beta = 0.1; %tasa de aprendizaje
batch_sz = 2205;  
no_epochs = 5; %número de interaciones de entrenamiento (epochs)

%Parámetros de la arquitectura
N = 1000; %orden del filtro 
n_h = 100; %cantidad de nodos de la capa oculta

%Path principal
main_path = "D:\UVG\Proyecto de investigacion\Deconvolucion-acustica\Audio data\Clips grabados y originales\";

%path_d = "D:\UVG\Proyecto de investigacion\Deconvolucion-acustica\Audio data\Pistas originales\";
%path_x = "D:\UVG\Proyecto de investigacion\Deconvolucion-acustica\Audio data\Convolucionadas\";

%% Adquisición de las señales 
switch signal_type
    case 'deterministic'
        
        path = main_path + "data determinista\";
        
        [D_prev, fs] = audioread(path+"sine_250_original.wav"); %señal original
        [X_prev, ~] = audioread(path+"sine_250_recorded.wav"); %señal grabada
        
    case 'track'
        
        path = main_path + "clips musicales\";
        
        %Señales (vectores columna)
        [D_prev, fs] = audioread(path+"cadence_original.wav"); %señal original
        [X_prev, ~] = audioread(path+"cadence_recorded.wav"); %señal grabada     
        
end       

%% Emparejamiento temporal de las señales 

m = size(X_prev,1); %tamaño inicial de la señal de entrada.

delay = finddelay(D_prev, X_prev); %delay entre señales
X_prev = X_prev(delay:m); 
m = size(X_prev,1);
D_prev = D_prev(1:m); 

clf(); figure(1);
subplot(2, 1, 1);
plot(X_prev, 'blue');
legend x[n];
subplot(2, 1, 2);
plot(D_prev, 'red');
legend d[n];


%%

%[D_prev, fs] = audioread(path_d+"guitar_riff_1.wav"); %señal original
%[X_prev, ~] = audioread(path_x+"guitar_riff_in_church.wav"); %señal

%Recorte de señales
%initial_sample = 1;
%final_sample = initial_sample + fs*0.1 - 1;

%D_prev = D_prev(initial_sample:final_sample,:);
%X_prev = X_prev(initial_sample:final_sample,:);





%%

%Zero padding
X_zero_p = [zeros(N-1, 1); X_prev];

%%
switch order
    case 'sequential'  
        seq_ind = 1:m;
        Y = D_prev';
    case 'random'
        rand_ind = randperm(m);
        Y = D_prev';
        Y = Y(:, rand_ind(1:m));
end

%Xtest = X(:,test_ind);
%Ytest = Y(:,test_ind);

%% Se entrena a la TDNN

%
no_batches = (m - mod(m,batch_sz))/batch_sz;


%Se inicializan los parámetros
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
                case 'sequential'  
                    X_batch(:,k) = sample;
                case 'random'
                    k_rand = rand_ind(1, k + (batch_sz)*(j - 1) );
                    X_batch(:, k_rand) = sample;
            end
        end
       
        
        %Se aplica forward propagation
        [A2, cache] = forwardPropagation(X_batch, parameters);

        %Se obtiene el resultado de la función costo
        [cost_train] = getCost(A2, Y_batch);

        %Se aplica backward propagation
        [grads] = backwardPropagation(parameters, cache, X_batch, Y_batch);

        %Actualización de parámetros
        parameters = updateParameters(parameters, grads, beta);
        
    end
    
    fprintf("Epoch %4i | Costo = %10.10f\n",i,cost_train);
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
    [A2, ~] = forwardPropagation(X_batch, parameters);
    
    Y_est(1 + (batch_sz*(j-1)):j*batch_sz) = A2;
end

x_n = X_prev(1:(no_batches*batch_sz), 1);
d_n = D_prev(1:(no_batches*batch_sz), 1);
y_n = Y_est';



%% Reproducir resultados en audio
%Usar >> clear sound si desea dejar de reproducir.
%%
sound(x_n,fs);
%%
sound(y_n,fs);

%%
sound(d_n,fs);
%% Graficando

%Vector temporal
t = 0:(1/fs):( (no_batches*batch_sz/fs)-(1/fs)  );
t = t';
t_tag = 'Time (secs)';

t0 = 1;
tf = 1.05;

%zoom_in_range = m/2;

clf(); figure(2);
subplot(3, 1, 1);
plot(t(t0*fs:tf*fs), x_n(t0*fs:tf*fs), 'blue');
legend x[n];
subplot(3, 1, 2);
plot(t(t0*fs:tf*fs), d_n(t0*fs:tf*fs), 'red');
legend d[n];
subplot(3, 1, 3);
plot(t(t0*fs:tf*fs), y_n(t0*fs:tf*fs),  'green');
%yaxis(-1,1);
legend y[n];

%% Espectrogramas

%2205 para una frecuencia mínima de 20 Hz
window = 2205;
figure(3);
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
%view(-45,65);


