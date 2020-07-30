%%Filtro adaptativo por LMS
%Por Carlos Manuel López

clear;

normalized = true; %si se desea la variante normalizada

beta = 0.01; %tasa de aprendizaje
N = 21; %número de coeficientes del filtro

fs = 100; %frecuencia de muestreo
dt = 1/fs; %periodo de muestreo
t0 = 0; %tiempo inicial en seg
tf = 10; %tiempo final en seg
M = (tf - t0)/dt; %número de iteraciones

%Parámetros de las señales

random = false; %si se desea que las señales sean aleatorias

freq_x = 1; %frecuencia de la señal original en Hz
freq_d = 1; %frecuencia de la señal deseada en Hz

A_x = 10; %amplitud de la señal original
A_d = 2; %amplitud de la señal deseada

phase_x = 90; %en grados
phase_d = 0; %en grados

%Arrays de almacenamiento
X = zeros(M, 1); 
D = zeros(M, 1);
Y = zeros(M, 1);
E = zeros(M, 1);

z = zeros(N, 1); %linea de delays
w = zeros(N, 1); %array de pesos


for k = 0:M
    
    if random == true
        B_x = rand(1);
        B_d = rand(1);
    else 
        B_x = 1;
        B_d = 1;
    end
    
    %Generación de señales
    X(k+1, 1) = B_x*A_x*sin( (2*pi*freq_x*k/fs) + phase_x*(pi/180) );
    D(k+1, 1) = B_d*A_d*sin( (2*pi*freq_d*k/fs) + phase_d*(pi/180) );
    
    %Muestras actuales
    x = X(k+1, 1);  
    d = D(k+1, 1);
    
    %Muestra actual se coloca al principio de la linea de delays
    z(1, 1) = x;
    
    y = w'*z; %señal de salida
    e = d - y; %error
    
    %Actualización de pesos w (en base a la estimación del gradiente)
    
    if (normalized == true)
        w = w + (1/(z'*z))*e*z;
    else 
        w = w + beta*e*z;
    end
    
    
    %Se realiza un corrimiento en la linea de delays
    z(2:N, 1) = z(1:N - 1, 1); 
    
    %Se guardan la muestras correspondientes
    Y(k+1, 1) = y;
    E(k+1, 1) = e;
end

T = linspace(t0, tf, M + 1); %eje temporal

%Se grafican la señales de interés
clf(); figure(1);
plot(T,X);
hold on 
plot(T,D');
hold on
plot(T, Y');
legend ("x[n]", "d[n]", "y[n]");

%Se grafica el error
figure(2);
plot(T, E');
title Error;
legend e[n];








