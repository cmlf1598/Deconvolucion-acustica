%Combinaci�n de una red neuronal regresiva y filtro LMS 
%17-05-2020
%Carlos L�pez (16016)

clear;

%%

%Escoger la naturaleza de las se�ales. Ya sea se�ales deterministas 
%(sinusoides)o estoc�sticas (pista de audio).

signal_type = 'track';

switch signal_type
    case 'sines'
        
        fs = 100; %frecuencia de muestreo
        dt = 1/fs; %periodo de muestreo
        t0 = 0; %tiempo inicial en seg
        tf = 10; %tiempo final en seg
        M = (tf - t0)/dt; %n�mero de iteraciones

        freq_x = 1; %frecuencia de la se�al original en Hz
        freq_d = 2; %frecuencia de la se�al deseada en Hz

        A_x = 10; %amplitud de la se�al original
        A_d = 2; %amplitud de la se�al deseada

        phase_x = 90; %en grados
        phase_d = 0; %en grados
        
        X_prev = zeros(M, 1); 
        D_prev = zeros(M, 1);
    
        for j = 0:M-1
            %Generaci�n de se�ales
            X_prev(j+1, 1) = A_x*sin( (2*pi*freq_x*j/fs) + phase_x*(pi/180) );
            D_prev(j+1, 1) = A_d*sin( (2*pi*freq_d*j/fs) + phase_d*(pi/180) );
        end
        
    case 'track'
        %Se�ales (vectores columna)
        [D_prev, fs] = audioread('The_Blue_Danube_original_30s.wav'); %se�al original
        [X_prev, ~] = audioread('The_Blue_Danube_recording_30s.wav'); %se�al grabada

        %Tiempo final de recorte
        tf = 0.1;
        initial_sample = 5*fs;
        final_sample = initial_sample + fs*0.1 - 1;
        
        %Recortar se�ales
         D_prev = D_prev(initial_sample:final_sample,:);
         X_prev = X_prev(initial_sample:final_sample,:);

end


%Orden del filtro 
N = 500;

%Tama�o de la se�al de entrada (cantidad de muestras).
m = size(X_prev,1);

%Una ventana de largo N (orden del filtro) se va desplanzando una muestra a
%la vez, capturando datos. Estas capturas se guardar�n en X.

%Ya que los delays unitarios inician en cero, se deben concatenar al
%principio de la se�al.
X_prev = [zeros(N-1, 1); X_prev];

%Inicializaci�n
X = zeros(N,m);

%Cada captura se va concatenando en vectores columna, una a la par de la
%otra.
for i = 1:m
    X(:,i) = flip(X_prev(i:(N-1+i)), 1);
end

%La se�al original 
Y = D_prev';

%Muestras en orden aleatorio u ordenadas
order = 'sequential';

%Indices (secuenciales)
train_ind = (1:m/2);
test_ind = (m/2)+1:m; 

%Se�ales de comparaci�n, contra las muestras de prueba
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

%Se obtiene el tama�o de las capas de entrada y salida
%Se consigue el n�mero de muestras de entrenamiento
[n_x,~] = size(Xtrain);
[n_y,~] = size(Ytrain);

%Se define la cantidad de nodos de la capa oculta
n_h = 200;

%N�mero de interaciones
k = 1000;

%Se inicializan los par�metros
[parameters] = initializeParameters(n_x, n_h, n_y);

for i = 1:k
    
    %Se aplica forward propagation
    [A2, cache] = forwardPropagation(Xtrain, parameters);

    %Se obtiene el resultado de la funci�n costo
    [cost_train] = getCost(A2, Ytrain);
    
    %Se aplica backward propagation
    [grads] = backwardPropagation(parameters, cache, Xtrain, Ytrain);
    
    %Actualizaci�n de par�metros
    parameters = updateParameters(parameters, grads, 0.05);
    
    fprintf("Iteracion %5i | Costo = %10.10f\n",i,cost_train);
    
end
%% Se prueba la RNA

data = 'test';

switch data
    case 'train'
        [A2, ~] = forwardPropagation(Xtrain, parameters);
        x_n = x_comp_tr; %se�al grabada 
        d_n = Ytrain; %se�al deseada 
        [cost_test] = getCost(A2, Ytrain);
    case 'test'
        [A2, ~] = forwardPropagation(Xtest, parameters);
        x_n = x_comp_ts; %se�al grabada 
        d_n = Ytest; %se�al deseada 
        [cost_test] = getCost(A2, Ytest);

        
end

Y_predict = A2';

%Se imprime el resultado de la funci�n costo
fprintf("Costo: %10.10f\n",cost_test);

gain = 1;

y_n = gain*Y_predict; %se�al predicha

%% Reproducir resultados en audio
%Usar >> clear sound si desea dejar de reproducir.
%%
sound(x_n,fs);
%%
sound(y_n,fs);

%% Graficando

clf(); figure(1);
subplot(3, 1, 1);
plot(x_n, 'blue');
legend x[n];
subplot(3, 1, 2);
plot(d_n, 'red');
legend d[n];
subplot(3, 1, 3);
plot(y_n,  'green');
%yaxis(-1,1);
legend y[n];

%% Espectrogramas

%2205 para una frecuencia m�nima de 20 Hz
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


