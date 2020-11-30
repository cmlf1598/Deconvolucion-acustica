function [features_ext] = feature_extractor(fs, x_n)

    afe = audioFeatureExtractor("SampleRate",fs, ...
        "SpectralDescriptorInput","barkSpectrum", ...
        "spectralCentroid",true, ...    	 %centro de gravedad del espectro.
        "spectralSpread", true, ...          %qué tan esparcidas están las frecuencias (incremeneta cuando dos tonos divergen).
        "spectralSkewness", true,...         %(positivo cuando los tonos bajos dominan).
        "spectralKurtosis",true, ...         %mide "flatness" (decrece cuando aunmenta el ruido blanco).
        "spectralEntropy", true, ...         %mide el desorden (audio con voz tienen menor entropía que secciones sin voz). 
        "spectralFlux", true, ...            %qué tanto variía el espectro (alto flujo espectral en una pista de batería).
        "spectralDecrease", true, ...        %(usado en el análisis de música).
        "spectralRolloffPoint", true, ...    %mide el ancho de banda de la señal (usado en clasificación de géneros musicales).
        "pitch",true);

    features = extract(afe, x_n);
    features = (features - mean(features,1))./std(features,[],1); %nomalizar features
    
    %idx = info(afe);
    duration = size(x_n,1)/fs;
    
    %Ejes temporales
    t_X = linspace(0,duration,size(x_n,1));    
    t_features = linspace(0,duration,size(features,1));
    
    %Interpolación lineal de los features
    features_ext = interp1(t_features,features,t_X);
    
       
%     if graph
%         
%         figure;
%         subplot(2,1,1)
%         plot(t_X, x_n)
% 
%         subplot(2,1,2)
%         plot(t_X,features_ext(:,idx.spectralCentroid), ...
%              t_X,features_ext(:,idx.spectralDecrease), ...
%              t_X,features_ext(:,idx.spectralEntropy), ...
%              t_X,features_ext(:,idx.spectralFlux), ...
%              t_X,features_ext(:,idx.spectralKurtosis), ...
%              t_X,features_ext(:,idx.spectralRolloffPoint), ...
%              t_X,features_ext(:,idx.spectralSkewness), ...
%              t_X,features_ext(:,idx.spectralSpread), ...
%              t_X,features_ext(:,idx.pitch));
%         legend("Spectral Centroid", "Spectral Decrease", "Spectral Entropy",...
%                "Spectral Flux", "Spectral Kurtosis", "Spectral RolloffPoint",...
%                "Spectral Skewness", "Spectral Spread", "Pitch")
%         xlabel("Time (s)")
%     end
end