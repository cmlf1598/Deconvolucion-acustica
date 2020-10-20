
function [sequences,Y,layers,options] = TDNN(params)

    fs = 44100; %frecuencia de muestreo
    tf = 5;

    %% Hiperparámetros
    
    %Capas
    i_n = params.input_layer_sz;
    L1_n = params.hidden_layer_sz;
    L2_n = params.hidden_layer_sz;
    L3_n = params.hidden_layer_sz;
    
    %
    initial_learning_rate = params.initial_learning_rate;
  
    %% Cargar data y otros ajustes
    data_folder = fullfile('D:\','UVG','Proyecto de investigacion','Deconvolucion-acustica', 'Audio data',...
                           'Clips grabados y originales','clips musicales',{'originales';'grabados'});
    %ads = audioDatastore(data_folder);
    ads_d_n = audioDatastore(data_folder{1}); 
    ads_x_n = audioDatastore(data_folder{2}); 

    %Señales 
    d_n = read(ads_d_n); %deseada
    x_n = read(ads_x_n); %perturbada

    %%
    [d_n, x_n] = pair_tracks(d_n, x_n); %emparejamiento temporal
    x_n = x_n(1:tf*fs);
    d_n = d_n(1:tf*fs);
    [X_prev] = tapped_delay_mat(x_n, i_n); %matriz TDNN
    Y = d_n';

    %% Data de entrenamiento y validación
    [duration, ~] = size(x_n);
    train_frac = 0.8;
    t_train = tf*train_frac;
    %t_validation = tf*(1 - train_frac);
    
    X = mat2cell(X_prev, i_n, fs*ones(1,tf))';
    %[m, ~] = size(X);
    
    %data de entrenamiento
    X_train = mat2cell(X(1:round(duration*train_frac)), i_n, fs*ones(1,t_train))'; 
    Y_train = mat2cell(Y(1:round(duration*train_frac)), 1, fs*ones(1,t_train))'; 
    [~, limit_index] = size(Y_train);
    
    %data de validación
    X_validation =  X_mat(limit_index:end); 
    Y_validation = Y(limit_index:end); 

    %%
    switch params.net_depth
        case 1
            layers = [...
                sequenceInputLayer(i_n)
                fullyConnectedLayer(L1_n, ...
                'WeightsInitializer', 'glorot', ... 
                'BiasInitializer', 'zeros')
                tanhLayer
                regressionLayer];
        case 2
            layers = [...
                sequenceInputLayer(i_n)
                fullyConnectedLayer(L1_n, ...
                'WeightsInitializer', 'glorot', ... 
                'BiasInitializer', 'zeros')
                tanhLayer
                fullyConnectedLayer(L2_n, ...
                'WeightsInitializer', 'glorot', ... 
                'BiasInitializer', 'zeros')
                tanhLayer
                regressionLayer];
        case 3
            layers = [...
                sequenceInputLayer(i_n)
                fullyConnectedLayer(L1_n, ...
                'WeightsInitializer', 'glorot', ... 
                'BiasInitializer', 'zeros')
                tanhLayer
                fullyConnectedLayer(L2_n, ...
                'WeightsInitializer', 'glorot', ... 
                'BiasInitializer', 'zeros')
                tanhLayer
                fullyConnectedLayer(L3_n, ...
                'WeightsInitializer', 'glorot', ... 
                'BiasInitializer', 'zeros')
                tanhLayer
                regressionLayer];
    end
    

    %%
    
    switch params.training_opts
        case 1
            options = trainingOptions('rmsprop', ...
                'InitialLearnRate', initial_learning_rate,...
                'ValidationData',{X_validation,Y_validation}, ...
                'MaxEpochs', 10,...            
                'ValidationFrequency', 1000, ...             
                'SquaredGradientDecayFactor', 0.9,...
                'Epsilon', 1e-7,...
                'L2Regularization', 0.0001);

        case 2
            options = trainingOptions('adam', ...
                'InitialLearnRate', initial_learning_rate,...
                'ValidationData',{X_validation,Y_validation}, ...
                'MaxEpochs', 10,...            
                'ValidationFrequency', 1000, ...   
                'GradientDecayFactor', 0.9,...
                'SquaredGradientDecayFactor', 0.999,...
                'Epsilon', 1e-7,...
                'L2Regularization', 0.0001);
    end
    


end


