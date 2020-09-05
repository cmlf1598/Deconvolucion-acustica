%Inicializaci�n de par�metros
%Inputs:
    %n_x - tama�o de la capa de entrada
    %n_h - tama�o de la capa oculta
    %n_o - tama�o de la capa de salida
%Output:
    %parameters - array de celdas con par�metros inicializados.
function [parameters] = initialize_parameters(n_x, n_h, n_y, mu_initial)
    
    %Se escogen valores aleatorios
    W1 = 0.1*rand(n_h, n_x);
    b1 = zeros(n_h, 1);
    W2 = 0.1*rand(n_y, n_h);
    b2 = zeros(n_y,1);
    %mu = zeros(n_x - 1, 1); %memoria gamma
    mu = mu_initial*ones(n_x - 1, 1); %memoria gamma
    
    parameters = {W1; b1; W2; b2; mu};
end