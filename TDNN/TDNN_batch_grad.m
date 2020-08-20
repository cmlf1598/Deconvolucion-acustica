%TDNN (Time Delay Neural Network)
%Batch gradient descent
%17-05-2020
%Carlos López (16016)

clear; clc;

%%

%Parámetros de entrada

signal_type = 'track'; %tipo de señal (sinusoide o pista de audio).
N = 50; %orden del filtro 
order = 'sequential'; %orden de las muestras de entrenamiento
n_h = 25; %cantidad de nodos de la capa oculta
k = 1000; %número de interaciones de entrenamiento (epoch)
beta = 0.1; %tasa de aprendizaje

%Path disponibles
path = "D:\UVG\Proyecto de investigacion\Deconvolucion-acustica\Audio data\Clips grabados y originales\data determinista\";
%path = "D:\UVG\Proyecto de investigacion\Deconvolucion-acustica\Audio data\Clips grabados y originales\clips musicales\";
%path_d = "D:\UVG\Proyecto de investigacion\Deconvolucion-acustica\Audio data\Pistas originales\";
%path_x = "D:\UVG\Proyecto de investigacion\Deconvolucion-acustica\Audio data\Convolucionadas\";

switch signal_type
    case 'sines'
        
        fs = 100; %frecuencia de muestreo
        dt = 1/fs; %periodo de muestreo
        t0 = 0; %tiempo inicial en seg
        tf = 10; %tiempo final en seg
        M = (tf - t0)/dt; %número de iteraciones

        freq_x = 1; %frecuencia de la señal original en Hz
        freq_d = 2; %frecuencia de la señal deseada en Hz

        A_x = 10; %amplitud de la señal original
        A_d = 2; %amplitud de la señal deseada

        phase_x = 90; %en grados
        phase_d = 0; %en grados
        
        X_prev = zeros(M, 1); 
        D_prev = zeros(M, 1);
    
        for j = 0:M-1
            %Generación de señales
            X_prev(j+1, 1) = A_x*sin( (2*pi*freq_x*j/fs) + phase_x*(pi/180) );
            D_prev(j+1, 1) = A_d*sin( (2*pi*freq_d*j/fs) + phase_d*(pi/180) );
        end
        
    case 'track'
        
        %Selección de pista de audio
        
        %Señales (vectores columna)
        %[D_prev, fs] = audioread(path+"cadence_original.wav"); %señal original
        %[X_prev, ~] = audioread(path+"cadence_recorded.wav"); %señal grabada
        
        [D_prev, fs] = audioread(path+"sine_1000_original.wav"); %señal original
        [X_prev, ~] = audioread(path+"sine_1000_recorded.wav"); %señal grabada
        
        %[D_prev, fs] = audioread(path_d+"guitar_riff_1.wav"); %señal original
        %[X_prev, ~] = audioread(path_x+"guitar_riff_in_church.wav"); %señal
        
        %Recorte de señales
        initial_sample = 1;
        final_sample = initial_sample + fs*0.1 - 1;
               
        %D_prev = D_prev(initial_sample:final_sample,:);
        %X_prev = X_prev(initial_sample:final_sample,:);

end

%Tamaño de la señal de entrada (cantidad de muestras).
m = size(X_prev,1);

%Vector temporal
t = 0:(1/fs):( (m/fs)-(1/fs)  );
t = t';
t_tag = 'Time (secs)';

%%
%Una ventana de largo N (orden del filtro) se va desplanzando una muestra a
%la vez, capturando datos. Estas capturas se guardarán en X.

%Ya que los delays unitarios inician en cero, se deben concatenar al
%principio de la señal.
X_prev = [zeros(N-1, 1); X_prev];

%Inicialización
X = zeros(N,m);

%Cada captura se va concatenando en vectores columna, una a la par de la
%otra.
for i = 1:m
    X(:,i) = flip(X_prev(i:(N-1+i)), 1);
end

%La señal original 
Y = D_prev';

%%

%Indices (secuenciales)
train_ind = (1:m/2);
test_ind = (m/2)+1:m; 

%Señales a comparar, contra las muestras de prueba
x_comp_tr = X_prev(N + train_ind,:);
x_comp_ts = X_prev(N + test_ind - 1,:);

switch order
    case 'sequential'  
        %Muestras de entrenamiento y de prueba
        Xtrain = X(:,train_ind);
        Ytrain = Y(:,train_ind);
    case 'random'
        %Indices
        rand_ind = randperm(m);
        %Muestras de entrenamiento y de prueba
        Xtrain = X(:,rand_ind(1:m/2));
        Ytrain = Y(:,rand_ind(1:m/2));
end

Xtest = X(:,test_ind);
Ytest = Y(:,test_ind);

%% Se entrena a la red neuronal artificial

%Se obtiene el tamaño de las capas de entrada y salida
%Se consigue el número de muestras de entrenamiento
[n_x,~] = size(Xtrain);
[n_y,~] = size(Ytrain);

%Se inicializan los parámetros
[parameters] = initializeParameters(n_x, n_h, n_y);

for i = 1:k
    
    
    %Se aplica forward propagation
    [A2, cache] = forwardPropagation(Xtrain, parameters);

    %Se obtiene el resultado de la función costo
    [cost_train] = getCost(A2, Ytrain);
    
    %Se aplica backward propagation
    [grads] = backwardPropagation(parameters, cache, Xtrain, Ytrain);
    
    %Actualización de parámetros
    parameters = updateParameters(parameters, grads, beta);
    
    fprintf("Iteracion %5i | Costo = %10.10f\n",i,cost_train);
    
end
%% Se prueba la RNA

data = 'test';

switch data
    case 'train'
        [A2, ~] = forwardPropagation(Xtrain, parameters);
        x_n = x_comp_tr; %señal grabada 
        d_n = Ytrain; %señal deseada 
        [cost_test] = getCost(A2, Ytrain);        
        t = t(1:m/2);
    case 'test'
        [A2, ~] = forwardPropagation(Xtest, parameters);
        x_n = x_comp_ts; %señal grabada 
        d_n = Ytest; %señal deseada 
        [cost_test] = getCost(A2, Ytest);
        t = t((m/2)+1:m);
        
end

Y_predict = A2';

%Se imprime el resultado de la función costo
fprintf("Costo: %10.10f\n",cost_test);

gain = 1;

y_n = gain*Y_predict; %señal predicha

%% Reproducir resultados en audio
%Usar >> clear sound si desea dejar de reproducir.
%%
sound(x_n,fs);
%%
sound(y_n,fs);

%%
sound(d_n,fs);
%% Graficando

zoom_in_range = fs/100;
%zoom_in_range = m/2;

clf(); figure(1);
subplot(3, 1, 1);
plot(t(1:zoom_in_range), x_n(1:zoom_in_range), 'blue');
legend x[n];
subplot(3, 1, 2);
plot(t(1:zoom_in_range), d_n(1:zoom_in_range), 'red');
legend d[n];
subplot(3, 1, 3);
plot(t(1:zoom_in_range), y_n(1:zoom_in_range),  'green');
%yaxis(-1,1);
legend y[n];

%% Espectrogramas

%2205 para una frecuencia mínima de 20 Hz
window = 2205;
figure(2);
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


