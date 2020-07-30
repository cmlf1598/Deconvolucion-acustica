%Red neuronal artificial para regresión de 1 capa oculta
%Carlos López (16016)
%Basado en la lección de la tercera semana del curso "Neural Networks and 
%Deep Learning" por Andrew Ng

clear;

%Se crean las muestras de entrenamiento y de prueba

%Mantener valores que se generaron aleatoriamente 
rng('default');
s = rng;

%Número de muestras
m = 50;

%La ecuación de la recta es y = 5x + 3/2
%Coordenadas deben de estar normalizadas
X = linspace(-1,1,m);
Y = 5*X + 3/2;

%Vector de índices aleatorios
randIndex = randperm(numel(X));

%Se agrupa por muestras de entrenamiento y de prueba
Xtrain = X(randIndex(1:m/2));
Ytrain = Y(randIndex(1:m/2));
Xtest = X(randIndex((m/2)+1:m));
Ytest = Y(randIndex((m/2)+1:m));

%Se implementa el modelo de la red neuronal

%Se obtiene el tamaño de las capas de entrada y salida
%Se consigue el número de muestras de entrenamiento
[n_x,~] = size(Xtrain);
[n_y,m] = size(Ytrain);

%Se define la cantidad de nodos de la capa oculta
n_h = 10;

%Número de interaciones
k = 5000;

%Se inicializan los parámetros
[parameters] = initializeParameters(n_x, n_h, n_y);

for i = 1:k
    
    %Se aplica forward propagation
    [A2, cache] = forwardPropagation(Xtrain, parameters);

    %Se obtiene el resultado de la función costo
    [cost] = getCost(A2, Ytrain);
    
    %Se aplica backward propagation
    [grads] = backwardPropagation(parameters, cache, Xtrain, Ytrain);
    
    %Actualización de parámetros
    parameters = updateParameters(parameters, grads, 0.01);
    
    if mod(i, k/10) == 0
        display(cost);
    end
end

%Graficando
[predictions,~] = forwardPropagation(Xtest, parameters);
scatter(Xtest, Ytest,'bo');
hold on;
scatter(Xtest, predictions, 'r*');
legend('Valor real', 'Predicción')



