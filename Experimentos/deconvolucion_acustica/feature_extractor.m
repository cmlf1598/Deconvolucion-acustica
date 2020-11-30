%% Proyecto de deconvolución acústica 
% Carlos Manuel López (16016)

%Función para extraer features de audio de alguna señal. 
%   Entradas:
%           -fs, frecuencia de muestreo. 
%           -x_n, señal a la cual se le desea extraer features. 
%   Salidas:
%           -feaures_ext, features generados. 

function [features_ext] = feature_extractor(fs, x_n)
    
    %Features a extraer. 
    afe = audioFeatureExtractor("SampleRate",fs, ...
        "SpectralDescriptorInput","barkSpectrum", ...
        "spectralCentroid",true, ...    	 %centro de gravedad del espectro.
        "spectralSpread", true, ...          %qué tan esparcidas están las frecuencias (incremeneta cuando dos tonos divergen).
        "spectralSkewness", true,...         %(positivo cuando los tonos bajos dominan).
        "spectralKurtosis",true, ...         %mide "flatness" (decrece cuando aunmenta el ruido blanco).
        "spectralEntropy", true, ...         %mide el desorden (audio con voz tienen menor entropía que secciones sin voz). 
        "spectralFlux", true, ...            %qué tanto varía el espectro (alto flujo espectral en una pista de batería).
        "spectralDecrease", true, ...        %(usado en el análisis de música).
        "spectralRolloffPoint", true, ...    %mide el ancho de banda de la señal (usado en clasificación de géneros musicales).
        "pitch",true);

    features = extract(afe, x_n); %extraer features anteriores de la señal seleccionada
    features = (features - mean(features,1))./std(features,[],1); %nomalizar features
    
    duration = size(x_n,1)/fs; %duración de la señal (en segundos).
    
    %Ejes temporales
    t_X = linspace(0,duration,size(x_n,1));    
    t_features = linspace(0,duration,size(features,1));
    
    %Interpolación lineal de los features
    features_ext = interp1(t_features,features,t_X);
    
end