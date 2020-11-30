%% Proyecto de deconvolución acústica 
% Carlos Manuel López (16016)

%Programa para probar la función "timedelaynet" de Matlab.

% Basado en:
% https://la.mathworks.com/help/deeplearning/ref/timedelaynet.html

clear; clc;
%% Parámetros generales

%Señal de prueba
signal_type = "musical_clip";
track_no = 2;
fs = 44100; %frecuencia de muestreo

%% Cargar data 
switch signal_type
    case "musical_clip"
        tf = 28; %duración
        data_folder = fullfile('D:\','UVG','Proyecto de investigacion','Deconvolucion-acustica', 'Audio data',...
                               'Clips grabados y originales','clips musicales',{'originales';'grabados'});
    case "deterministic"
        tf = 8; %duración
        data_folder = fullfile('D:\','UVG','Proyecto de investigacion','Deconvolucion-acustica', 'Audio data',...
                               'Clips grabados y originales','data determinista',{'originales';'grabados'});
end 

%Definir audio data store para cada tipo de señal. 
ads_d_n = audioDatastore(data_folder{1}); 
ads_x_n = audioDatastore(data_folder{2}); 

%Señales 
[d_n, ~] = audioread(char(ads_d_n.Files(track_no))); %deseada
[x_n, ~] = audioread(char(ads_x_n.Files(track_no))); %perturbada

%% Otros ajustes
[d_n, x_n] = pair_tracks(d_n, x_n); %emparejamiento temporal
x_n_train = x_n(1:tf*fs); d_n_train = d_n(1:tf*fs);%recorte, data de entrenamiento.
x_n_train = num2cell(x_n_train'); d_n_train = num2cell(d_n_train'); %a celdas

%% Párametros y entrenamiento de la red
d = 1:10; 
hidden_units = 10;
net = timedelaynet(d, hidden_units);
net.divideFcn = '';
net.trainParam.min_grad = 1e-10;
net.trainParam.epochs = 75;
[Xs,Xi,Ai,Ts] = preparets(net,x_n_train,d_n_train);
net = train(net,Xs,Ts,Xi,Ai);
view(net)

%% Calcular performance de la red. 
[Y,Xf,Af] = net(Xs,Xi,Ai);
perf = perform(net,Ts,Y);
[netc,Xic,Aic] = closeloop(net,Xf,Af);
view(netc)

%% Salida de la red
y2 = netc(x_n_train,Xic,Aic);

%% De celdas a matrices
x_n = cell2mat(x_n_train');
d_n = cell2mat(d_n_train');
y_n = cell2mat(y2');

%% Graficando
%Dominio temporal
figure(1);
signals_graph(x_n, d_n, y_n);

%Dominio frecuencial
figure(2);
spectrograms_graph(x_n, d_n, y_n, fs);

%audiowrite(filename,y_n,fs)
