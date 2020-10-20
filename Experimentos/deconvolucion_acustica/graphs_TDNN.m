
load three_layer_TDNN.mat
i_n = 100;
fs = 44100; %frecuencia de muestreo
tf = 15;

% Cargar data y otros ajustes
data_folder = fullfile('D:\','UVG','Proyecto de investigacion','Deconvolucion-acustica', 'Audio data',...
                       'Clips grabados y originales','clips musicales',{'originales';'grabados'});
%ads = audioDatastore(data_folder);
ads_d_n = audioDatastore(data_folder{1}); 
ads_x_n = audioDatastore(data_folder{2}); 

%Señales 
d_n = read(ads_d_n); %deseada
x_n = read(ads_x_n); %perturbada

[d_n, x_n] = pair_tracks(d_n, x_n); %emparejamiento temporal

%Clipping
x_n = x_n(1:tf*fs);
d_n = d_n(1:tf*fs);

%Audio features
[X] = tapped_delay_mat(x_n, i_n); 

%%
Y = predict(three_layer_TDNN, X);

y_n = Y;
%% Graficando
figure(1);
subplot(3,1,1);
plot(x_n, 'color', [0, 0.4470, 0.7410]);
legend x[n];
subplot(3,1,2);
plot(d_n, 'red');
legend d[n];    
subplot(3,1,3);
plot(y_n, 'color', [0.9290, 0.6940, 0.1250]);
legend y[n];

%
figure(2);
%set(figure(3), 'Position',  [0, 0, 560, 640])
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



