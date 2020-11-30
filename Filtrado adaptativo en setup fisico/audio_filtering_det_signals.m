%%Deterministic signals filtering
%Por Carlos Manuel López
%19-4-20

clear; 
path = "/audio data/inputs/data determinista/";

%% Seleccionar el tipo de señal deseada
%signal = "sine";
%signal = "square";
signal = "sawtooth";

%Frecuencia o frecuencias deseadas
%test_freq = ["250", "500", "1000", "2500", "5000", "10000", "15000", "20000"];
%test_freq = ["250", "1000", "2500", "10000"];
%
%test_freq = "250";
%test_freq = "1000";
%test_freq = "2500";
%test_freq = "10000";

[~, no_tracks] = size(test_freq);

%% Filtrado
for i = 1:no_tracks
    %Clips de audio
    [D, fs] = audioread([pwd, char(path+signal+"_"+test_freq(i)+"_original.wav")]); %señal original
    [X, ~] = audioread([pwd, char(path+signal+"_"+test_freq(i)+"_recorded.wav")]); %señal grabada

    [m,~] = size(D);
    
    %Vector temporal
    t = 0:(1/fs):( (m/fs)-(1/fs) );
    t_tag = 'Time (secs)';
    
    %Selección de uno o varios filtros
    %filters = ["LMS_est", "LMS_norm", "RLS"];
    %filters = "LMS_est";
    %filters = "LMS_norm";  
    filters = "RLS";
    
    [~, no_filters] = size(filters);
    
    for j = 1:no_filters
        
        selected_filter = filters(j);
        switch selected_filter
            case "RLS"
                %Parámetros del filtro
                lambda = 0.5; 
                delta = 2;
                N = 20; 

                %Se aplica el filtro
                [Y, E, W] = RLS_filter(X, D, lambda, delta, N);
                
            case "LMS_est"
                %Parámetros del filtro
                beta = 0.1; 
                N = 50; 
                normalized = false; 

                %Se aplica el filtro
                [Y,E,W] = LMS_filter(X, D, beta, N, normalized);

            case "LMS_norm"
                %Parámetros del filtro
                beta = 0.1; 
                N = 50; 
                normalized = true; 

                %Se aplica el filtro
                [Y,E,W] = LMS_filter(X, D, beta, N, normalized);


        end
        
        %Se grafica el vector w
        figure(2);
        %plot(t, W);
        plot(t(1:fs/20), W(1:fs/20)); %para mejor visualización
        legend norm(w);
        xlabel(t_tag); 
        max_W = max(W); %magnitud maxima del vector w
        save(char("results/"+selected_filter+"/"+"numerical/"+"max_W_"+selected_filter+"_"+test_freq(i)+"_"+signal+".mat"),'max_W');
        saveas(figure(2), [pwd char("/results/"+selected_filter+"/"+"W_vector_"+selected_filter+"_"+test_freq(i)+"_"+signal+".eps")] );
        saveas(figure(2), [pwd char("/results/"+selected_filter+"/"+"png/"+"W_vector_"+selected_filter+"_"+test_freq(i)+"_"+signal+".png")] );
        
        %Error cuadrático medio
        figure(3);
        ecm_h_axis = linspace(1,m,m);
        ecm = cumsum(E.^2)./(ecm_h_axis');
        %plot(t, ecm);
        plot(t(1:fs/20), ecm(1:fs/20)); %para mejor visualización
        legend ECM;
        xlabel(t_tag);
        last_ECM = ecm(end); %ultimo valor ECM
        save(char("results/"+selected_filter+"/"+"numerical/"+"last_ECM_"+selected_filter+"_"+test_freq(i)+"_"+signal+".mat"),'last_ECM');
        saveas(figure(3), [pwd char("/results/"+selected_filter+"/"+"ECM_"+selected_filter+"_"+test_freq(i)+"_"+signal+".eps")] );
        saveas(figure(3), [pwd char("/results/"+selected_filter+"/"+"png/"+"ECM_"+selected_filter+"_"+test_freq(i)+"_"+signal+".png")] );
        
        %Generación de espectogramas
        %2205 para una frecuencia mínima de 20 Hz
        figure(4);
        set(figure(4), 'Position',  [0, 0, 560, 640])
        window = 2205; %ventana de tamaño fijo, en cantidad de muestras 
        figure(4);
        subplot(3, 1, 1);
        spectrogram(X, window, [], [], fs);
        title x[n]
        colormap bone;
        subplot(3, 1, 2);
        spectrogram(D, window, [], [], fs);
        title d[n]
        colormap bone;
        subplot(3, 1, 3);
        spectrogram(Y, window, [], [], fs);
        title y[n]
        colormap bone;
        saveas(figure(4), [pwd char("/results/"+selected_filter+"/"+"spectrogram_"+selected_filter+"_"+test_freq(i)+"_"+signal+".eps")] );
        saveas(figure(4), [pwd char("/results/"+selected_filter+"/"+"png/"+"spectrogram_"+selected_filter+"_"+test_freq(i)+"_"+signal+".png")] );
        
        audiowrite( [pwd char("/audio data/output/data determinista/"+selected_filter+"_"+test_freq(i)+"_"+signal+".wav")], Y, fs);
    end
end


