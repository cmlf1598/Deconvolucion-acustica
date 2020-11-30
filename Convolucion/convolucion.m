% =========================================================================
% CONVOLUCIÓN
% =========================================================================
% Basado en el código de MSc. Miguel Zea  para el curso de Procesamiento de
% Señales

clear; clc;
path_track = "D:\UVG\Proyecto de investigacion\Deconvolucion-acustica\Audio data\Pistas originales\";
path_ir = "D:\UVG\Proyecto de investigacion\Deconvolucion-acustica\Audio data\IR\";

%Cargo respuestas impulsionales en un array cada una
[ir_1,fs] = audioread(path_ir+"ir_church.wav");
[ir_2,~] = audioread(path_ir+"ir_pyramid.wav");

%Cargo riff de guitarra
[D, ~] = audioread(path_track+"guitar_riff_1.wav");
[m,~] = size(D);

%Vector temporal (pista original)
t = 0:(1/fs):( (m/fs)-(1/fs) );
t_tag = 'Time (secs)';

%% Aplicar reverberación (ir 1)
out_1 = convreverb(D, ir_1);
[n1,~] = size(out_1);
t_out_1 = 0:(1/fs):( (n1/fs)-(1/fs) );

%Graficando
figure;
subplot(3, 1, 1);
plot(t, D, 'blue');
title('Audio original');
axis on;

subplot(3, 1, 2);
plot(ir_1, 'red');
title('Respuesta impulsional (church)');
axis on;

subplot(3, 1, 3);
plot(t_out_1(1:m), out_1(1:m), 'green');
title('Salida con reverberación');
axis on;
%% Escuchar y guardar pista generada (ir 1)
sound(out_1(1:m), fs);
audiowrite( [pwd char("/audio output/"+"guitar_riff_in_church.wav")], out_1(1:m), fs);
%% Aplicar reverberación (ir 2)
out_2 = convreverb(D, ir_2);
[n2,~] = size(out_2);
t_out_2 = 0:(1/fs):( (n2/fs)-(1/fs) );

%Graficando
figure;
subplot(3, 1, 1);
plot(t, D, 'blue');
title('Audio original');
axis on;

subplot(3, 1, 2);
plot(ir_2, 'red');
title('Respuesta impulsional(pringles)');
axis on;

subplot(3, 1, 3);
plot(t_out_2, out_2, 'green');
title('Salida con reverberación');
axis on;

%% Escuchar pista generada (ir 2)
sound(out_2, fs);
