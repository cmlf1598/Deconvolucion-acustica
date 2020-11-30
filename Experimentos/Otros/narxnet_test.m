%% Proyecto de deconvolución acústica 
% Carlos Manuel López (16016)

%Programa para probar la NARXNET de Matlab.

%Basado en:
%https://la.mathworks.com/help/deeplearning/ug/design-time-series-narx-feedback-neural-networks.html

clear; clc;
%% Parámetros generales

%Señal de prueba
signal_type = "musical_clip";
track_no = 2;
fs = 44100; %frecuencia de muestreo

%% Cargar data 

switch signal_type
    case "musical_clip"
        tf = 20; %duración
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
d1 = 1:10; d2 = 1:10; %delays
hidden_units = 10;
narx_net = narxnet(d1,d2,hidden_units);
narx_net.divideFcn = '';
narx_net.trainParam.min_grad = 1e-10;
narx_net.trainParam.epochs = 25;
[p,Pi,Ai,t] = preparets(narx_net,x_n_train,{},d_n_train);

%% Entrenamiento
narx_net = train(narx_net,p,t,Pi);

%% Se calcula el error
yp = sim(narx_net,p,Pi);
e = cell2mat(yp)-cell2mat(t);
plot(e)

%% Pasar a lazo cerrado
narx_net_closed = closeloop(narx_net);
view(narx_net_closed)

d_n_test = d_n; x_n_test = x_n;
d_n_test = num2cell(d_n_test'); x_n_test = num2cell(x_n_test');

[p1,Pi1,Ai1,t1] = preparets(narx_net_closed,x_n_test,{},d_n_test);
yp1 = narx_net_closed(p1,Pi1,Ai1);
TS = size(t1,2);
plot(1:TS,cell2mat(t1),'b',1:TS,cell2mat(yp1),'r') %línea roja es predicción

%% De celdas a matrices
x_n = cell2mat(x_n_test');
d_n = cell2mat(d_n_test');
y_n = cell2mat(yp1');

%% Graficando 

%Dominio temporal
figure(1);
signals_graph(x_n, d_n, y_n);

%Dominio frecuencial
figure(2);
spectrograms_graph(x_n, d_n, y_n, fs);
