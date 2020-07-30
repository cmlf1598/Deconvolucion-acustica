%%Play and record tracks
%Reproducir y grabar las canciones deseadas
%Por Carlos Manuel López
%26-7-20

clear; clc;

%Parámetros de grabación
bit_d = 24; %resolución de las muestras
ch = 1; %número de canales de grabación

%Playlist (y tiempo final de grabación (en segundos))
%track = "cadence"; tf = 12;
%track = "week_no_8"; tf = 40;
%track = "in_my_place"; tf = 5;
%track  = "evil"; tf = 7;
%track = "peru"; tf = 20;
%track = "atlantic_limited"; tf = 20;
%track = "bohemian_rhapsody"; tf = 12;
%track = "lonely_cat"; tf = 25;
%track = "unconditional"; tf = 40;
%track = "super_trouper"; tf = 14;
track = "el_sol_no_es_para_todos"; tf = 30;

path = "D:\UVG\Proyecto de investigacion\Deconvolucion acustica basada en filtros adaptativos y redes neuronales regresivas\Canciones\";

%Cargar canción
[Original, fs] = audioread(path+track+".flac"); %señal original

%Asergurar que la frecuencia de muestreo sea la indicada
if fs == 44100
    disp('fs = 44100');
    rec_obj = audiorecorder(fs, bit_d, ch);
end


%% Reproducir y grabar la canción
disp('Playing & recording');
sound(Original(:,1), fs); %tic;
recordblocking(rec_obj, tf); %toc;
disp('Stopped');
clear sound;

%% Reproducir lo que fue grabado
play(rec_obj);

%%
X = getaudiodata(rec_obj); %obtener la señal perturbada
[D, fs] = clipping(Original, fs, 0, tf); %obtener la señal deseada (señal original recortada)

%Graficar
clf(); figure(1);
subplot(2, 1, 1);
plot(X, 'r');
legend x[n];
subplot(2, 1, 2);
plot(D, 'b');
legend d[n];
%% Guardar señal perturbada
audiowrite([pwd, char("/audio data/inputs/clips musicales/"+track+"_recorded"+".wav")], X, fs);

%% Guardar señal original
audiowrite([pwd, char("/audio data/inputs/clips musicales/"+track+"_original"+".wav")], D, fs);
