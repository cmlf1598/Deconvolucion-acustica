%% Proyecto de deconvolución acústica 
% Carlos Manuel López (16016)

%Programa para visualizar las señales generadas de las redes entrenadas
%por el Experiment Manager. 

%Cargar la red deseada
net_name = "in_100_H1_100_single_LSTM_guitar_riff";
load(net_name+".mat");

%Señal de prueba
signal_type = "musical_clip";
track_no = 2;
fs = 44100; %frecuencia de muestreo

%% Obtener las señales 
switch signal_type
    case "musical_clip"
        tf = 8; %duración
        data_folder = fullfile('D:\','UVG','Proyecto de investigacion','Deconvolucion-acustica', 'Audio data',...
                               'Clips grabados y originales','clips musicales',{'originales';'grabados'});
    case "deterministic"
        tf = 7; %duración
        data_folder = fullfile('D:\','UVG','Proyecto de investigacion','Deconvolucion-acustica', 'Audio data',...
                               'Clips grabados y originales','data determinista',{'originales';'grabados'});
end 

%Definir audio data store para cada tipo de señal. 
ads_d_n = audioDatastore(data_folder{1}); 
ads_x_n = audioDatastore(data_folder{2}); 

%Señales 
[d_n, ~] = audioread(char(ads_d_n.Files(track_no))); %señal deseada.
[x_n, ~] = audioread(char(ads_x_n.Files(track_no))); %señal perturbada.

%% Otros ajustes
[d_n, x_n] = pair_tracks(d_n, x_n); %emparejamiento temporal.
x_n = x_n(1:tf*fs); %recorte de x_n.
d_n = d_n(1:tf*fs); %recorte de d_n.
[X] = tapped_delay_mat(x_n, 100); %matriz tapped-delay.

%% Emplear la red neuronal en feedforward
Y = predict(in_100_H1_100_single_LSTM_guitar_riff, X);
y_n = Y;

%% Graficando

%Dominio temporal
figure(1);
signals_graph(x_n, d_n, y_n);

%Dominio frecuencial
figure(2);
spectrograms_graph(x_n, d_n, y_n, fs);