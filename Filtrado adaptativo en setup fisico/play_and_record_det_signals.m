%%Play and record tracks deterministic signals
%Reproducir y grabar señales deterministas
%Por Carlos Manuel López
%22-7-20

%A un volumen general de 30

%Señales disponibles:
%   -sinusoides
%   -barrido sinusoidal
%   -diente de sierra
%   -onda cuadrada

clear; clc;

%Señal
%mode:
%   simple
%   special
mode = 'special';
%signal = 'FM';

fs = 44100; %frecuencia de muestreo (Hz)
dt = 1/fs; %periodo de muestreo
bit_d = 24; %resolución de las muestras
ch = 1; %número de canales de grabación

%Test frequencies
%250 Hz - bass
%500 Hz - low midrange
%1 kHz - midrange
%2.5 kHz - upper midrange 
%5 kHz - presence
%10 kHz, 15kHz, 20kHz - brillance
%test_freq = [250, 500, 1e3, 2.5e3, 5e3, 10e3, 15e3, 20e3];
test_freq = [250, 1000, 2500, 10000];
%test_freq = 250;

%crear grabadora
rec_obj = audiorecorder(fs, bit_d, ch);

path = "/audio data/inputs/data determinista/";
%%
switch mode
    %Barrido sinusoidal
    case 'special'
        t0 = 0; %tiempo inicial (s)
        tf = 10; %tiempo final (s)
        t = 0:dt:(tf - dt);
        %
        fc = 2500;
        Ac = 1;
        f_low_AM = 0.5;
        f_low_FM = 10;
        switch signal
            case 'chirp'
                f0 = 20;
                f1 = 10e3;
                D = chirp(t, f0, t(end), f1);
                name = "chirp"+ f0 + "_" + f1;
            case 'AM'
                [D, ~] = modulated_sine(fs, tf, fc, Ac, f_low_AM, f_low_FM, 'AM');
                name = "AM";
            case 'FM'
                [D, ~] = modulated_sine(fs, tf, fc, Ac, f_low_AM, f_low_FM, 'FM');
                name = "FM";
            case 'AM_and_FM'
                [D, ~] = modulated_sine(fs, tf, fc, Ac, f_low_AM, f_low_FM, 'both');
                name = "AM_and_FM";
        end   
        
        %Reproducir y grabar
        disp('Playing & recording');
        sound(D, fs); %tic;
        recordblocking(rec_obj, tf); %toc;
        disp('Stopped');
        clear sound;
        X = getaudiodata(rec_obj);
        audiowrite([pwd, char(path+name+"_original"+".wav")], D, fs);
        audiowrite([pwd, char(path+name+"_recorded"+".wav")], X, fs); 
        
    case 'simple'
        t0 = 0; %tiempo inicial (s)
        tf = 5; %tiempo final (s)
        t = 0:dt:(tf - dt);
        [~,n] = size(test_freq);
        for i = 1:n
             switch signal
                 %Señal cuadrada
                 case 'square'
                     D = square(2*pi*test_freq(i)*t);
                     name = "square_"+test_freq(i);
                 %Diente de sierra
                 case 'sawtooth'
                     D = sawtooth(2*pi*test_freq(i)*t);
                     name = "sawtooth_"+test_freq(i);
                 %Sinusoide
                 case 'sine'
                     D = sin(2*pi*test_freq(i)*t);
                     name = "sine_"+test_freq(i);
             end
             
             %Reproducir y grabar
             disp('Playing & recording');
             sound(D, fs); %tic;
             recordblocking(rec_obj, tf); %toc;
             disp('Stopped');
             clear sound;
             X = getaudiodata(rec_obj);
             audiowrite([pwd, char(path+name+"_original"+".wav")], D, fs);
             audiowrite([pwd, char(path+name+"_recorded"+".wav")], X, fs);         
        end   
    
end

