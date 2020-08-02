%%Play and record tracks
%Reproducir y grabar las canciones deseadas
%Por Carlos Manuel L�pez
%26-7-20

clear; clc;

%Pruebas a un volumen general de 60

%Par�metros de grabaci�n
bit_d = 24; %resoluci�n de las muestras
ch = 1; %n�mero de canales de grabaci�n

%Playlist (y tiempo final de grabaci�n (en segundos))
%Instrumentos individuales
%track = "bohemian_rhapsody"; tf = 12;
%track = "cadence"; tf = 12;
%track = "peru"; tf = 30;
%track = "week_no_8"; tf = 30;
%track  = "evil"; tf = 7;
%Combinaciones
%track = "lonely_cat"; tf = 45;
%track = "atlantic_limited"; tf = 45;
%track = "el_sol_no_es_para_todos"; tf = 60;
track = "karma_police"; tf = 60;
%track = "blauen_donau"; tf = 60;

path = "D:\UVG\Proyecto de investigacion\Deconvolucion-acustica\Canciones\";

%Cargar canci�n
[Original, fs] = audioread(path+track+".flac"); %se�al original

%Asergurar que la frecuencia de muestreo sea la indicada
if fs == 44100
    disp('fs = 44100');
    rec_obj = audiorecorder(fs, bit_d, ch);
end


%% Reproducir y grabar la canci�n
disp('Playing & recording');
sound(Original(:,1), fs); %tic;
recordblocking(rec_obj, tf); %toc;
disp('Stopped');
clear sound;

%% Reproducir lo que fue grabado
play(rec_obj);

%%
X = getaudiodata(rec_obj); %obtener la se�al perturbada
[D, fs] = clipping(Original, fs, 0, tf); %obtener la se�al deseada (se�al original recortada)

%Graficar
clf(); figure(1);
subplot(2, 1, 1);
plot(X, 'r');
legend x[n];
subplot(2, 1, 2);
plot(D, 'b');
legend d[n];
%% Guardar se�al perturbada
audiowrite([pwd, char("/audio data/inputs/clips musicales/"+track+"_recorded"+".wav")], X, fs);

%% Guardar se�al original
audiowrite([pwd, char("/audio data/inputs/clips musicales/"+track+"_original"+".wav")], D, fs);
