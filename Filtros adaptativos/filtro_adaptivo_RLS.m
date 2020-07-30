%%Filtro adaptativo por RLS
%Por Carlos Manuel López
%10-4-20

clear;

fs = 100; %frecuencia de muestreo
dt = 1/fs; %periodo de muestreo
t0 = 0; %tiempo inicial en seg
tf = 4; %tiempo final en seg
M = (tf - t0)/dt; %número de iteraciones

%Parámetros de las señales

random = true; %si se desea que las señales sean aleatorias

freq_x = 2; %frecuencia de la señal original en Hz
freq_d = 1; %frecuencia de la señal deseada en Hz

A_x = 1; %amplitud de la señal original
A_d = 1; %amplitud de la señal deseada

phase_x = 90; %en grados
phase_d = 0; %en grados

%Arrays de almacenamiento
X = zeros(M, 1); 
D = zeros(M, 1);
Y = zeros(M, 1);
E = zeros(M, 1);


lambda = 0.5; %factor de persistencia (varía entre 0 y 1). 
delta = 2; %puede ser el inverso del estimado de la señal de entrada.
N = 21; %número de coeficientes del filtro

%Inicializaciones

z = zeros(N, 1); %linea de delays
w = zeros(N, 1); %array de pesos

S = delta*eye(N); %estimado de la matriz de correlación.
p = zeros(N, 1); %vector de correlación cruzada.

S_1 = S;
p_1 = p;


for k = 0:M
    
    if random == true
        B_x = rand(1);
        B_d = rand(1);
    else 
        B_x = 1;
        B_d = 1;
    end
    
    %Generació1n de señales
    X(k+1, 1) = B_x*A_x*sin( (2*pi*freq_x*k/fs) + phase_x*(pi/180) );
    D(k+1, 1) = B_d*A_d*sin( (2*pi*freq_d*k/fs) + phase_d*(pi/180) );
    
    %Muestras actuales
    x = X(k+1, 1);  
    d = D(k+1, 1);
    
    %Muestra actual se coloca al principio de la linea de delays 
    %(este paso es parte del corrimiento)
    z(1, 1) = x;
    
    %Estimado de la matriz de correlación
    S = (1/lambda)*(S_1 - ( (S_1*(z*z')*S_1)/( (lambda) + z'*S_1*z) ));

    %Estimado del vector de correlación cruzada (cross-correlation).
    p = lambda*p_1 +  d*z;

    %Actualización de pesos w 
    w = S*p;

    y = w'*z; %señal de salida
    e = d - y; %error

    %Se realiza un corrimiento en la linea de delays
    z(2:N, 1) = z(1:N - 1, 1); 
    
    %Se guardan la muestras correspondientes
    Y(1+k, 1) = y;
    E(1+k, 1) = e;
    
    %Se actualizan los estimados anteriores
    S_1 = S;
    p_1 = p;
end

T = linspace(t0, tf, M + 1); %eje temporal

cut = M;

%Se grafican la señales de interés
clf(); figure(1);
plot(T(1:cut),X(1:cut)');
hold on 
plot(T(1:cut),D(1:cut)');
hold on
plot(T(1:cut), Y(1:cut)');
legend ("x[n]", "d[n]", "y[n]");
grid on;

%Se grafica el error
figure(2);
plot(T(1:cut), E(1:cut)');
title Error;
legend e[n];
