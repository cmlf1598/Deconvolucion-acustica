
%% Parámetros generales
clear; clc;

%Señal de prueba
signal_type = "musical_clip";
track_no = 1;

fs = 44100; %frecuencia de muestreo


%% Hiperparámetros

%Capas
i_n = 20;
L1_n = 10;
o_n = 1;

%
initial_learning_rate = 0.01;
beta_1 = 0.9;
%% Cargar data 

switch signal_type
    case "musical_clip"
        tf = 15; %duración
        data_folder = fullfile('D:\','UVG','Proyecto de investigacion','Deconvolucion-acustica', 'Audio data',...
                               'Clips grabados y originales','clips musicales',{'originales';'grabados'});
    case "determista"
        tf = 7; %duración
        data_folder = fullfile('D:\','UVG','Proyecto de investigacion','Deconvolucion-acustica', 'Audio data',...
                               'Clips grabados y originales','data determinista',{'originales';'grabados'});
end 

ads_d_n = audioDatastore(data_folder{1}); 
ads_x_n = audioDatastore(data_folder{2}); 

%Señales 
[d_n, ~] = audioread(char(ads_d_n.Files(track_no))); %deseada
[x_n, ~] = audioread(char(ads_x_n.Files(track_no))); %perturbada

%% Otros ajustes
[d_n, x_n] = pair_tracks(d_n, x_n); %emparejamiento temporal
x_n = x_n(1:tf*fs);
d_n = d_n(1:tf*fs);
[X] = tapped_delay_mat(x_n, i_n); %matriz tapped-delay
Y = d_n';

%% Data de entrenamiento y validación
[duration, ~] = size(x_n);
train_frac = 0.8;
%t_train = tf*train_frac;
%t_validation = tf*(1 - train_frac);

%data de entrenamiento
X_train = X(:, 1:round(duration*train_frac)); 
Y_train = Y(:, 1:round(duration*train_frac)); 
[~, limit_index] = size(Y_train);

%% data de validación
X_validation =  X(:, limit_index:end); 
Y_validation = Y(:, limit_index:end); 

%%

layers = [...
    sequenceInputLayer(i_n)
    fullyConnectedLayer(L1_n)
    tanhLayer
    fullyConnectedLayer(size(Y,1))
    regressionLayer];

%%

options = trainingOptions('adam', ...
    'MaxEpochs', 50,...
    'ValidationData',{X_validation,Y_validation}, ...
    'ValidationFrequency', 60, ...
    'InitialLearnRate', initial_learning_rate);
%%

net = trainNetwork(X_train,Y_train,layers,options);