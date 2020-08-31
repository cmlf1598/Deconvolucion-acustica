%Inicialización de parámetros
%Inputs:
    %n_x - tamaño de la capa de entrada
    %n_h - tamaño de la capa oculta
    %n_o - tamaño de la capa de salida
%Output:
    %parameters - array de celdas con parámetros inicializados.
function [parameters] = initialize_parameters(n_x, n_h, n_y, act_func)
    %rng(1,'twister');
    %s = rng;
    
    %Se escogen valores aleatorios
    %rng(s);
    W1 = 0.1*rand(n_h, n_x); 
    b1 = zeros(n_h, 1);
    %rng(s);
    W2 = 0.1*rand(n_y, n_h);
    b2 = zeros(n_y,1);
    
    parameters = {W1; b1; W2; b2};
end