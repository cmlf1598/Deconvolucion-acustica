%Inicialización de parámetros
%Inputs:
    %n_x - tamaño de la capa de entrada
    %n_h - tamaño de la capa oculta
    %n_o - tamaño de la capa de salida
    %x - data de entrada 
%Output:
    %parameters - array de celdas con parámetros inicializados.
function [parameters] = initialize_parameters_and_centers(n_x, n_h, n_y, x)

    m = size(x, 1);
    %probar usar d en vez de x
    x_rand_ind = randi(m-n_x, 1, n_h); %indices aleatorios 
    
    W1 = zeros(n_h, n_x);
    for i = 1:n_h
        W1(i,:) = x(x_rand_ind(i):x_rand_ind(i) + n_x - 1)';
    end

    %Se escogen valores aleatorios
    %W1 = 0.2*rand(n_h, n_x); %0.1
    b1 = zeros(n_h, 1);
    W2 = 0.2*rand(n_y, n_h);
    b2 = zeros(n_y,1);
    
    parameters = {W1; b1; W2; b2};
end