%%Audio tracks filtering
%Por Carlos Manuel López
%19-4-20

clear; clc;
%
path = "/audio data/inputs/clips musicales/";

% playlist = ["cadence", "week_no_8", "in_my_place", "evil", "peru", "atlantic_limited",...
%             "bohemian_rhapsody", "lonely_cat", "unconditional", "super_trouper", "el_sol_no_es_para_todos"];

% playlist = ["cadence", "evil", "peru", "atlantic_limited",...
%             "bohemian_rhapsody", "super_trouper", "lonely_cat"];

playlist = "el_sol_no_es_para_todos";

[~, no_tracks] = size(playlist);

for i = 1:no_tracks
    %Clips de audio
    [D, fs] = audioread([pwd, char(path+playlist(i)+"_original.wav")]); %señal original
    [X, ~] = audioread([pwd, char(path+playlist(i)+"_recorded.wav")]); %señal grabada

    [m,~] = size(D);
   
    %Selección del filtro
    filters = ["LMS_est", "LMS_norm", "RLS"];
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
                beta = 0.01; 
                %N = 1000; 
                N = 100;
                normalized = false; 

                %Se aplica el filtro
                [Y,E,W] = LMS_filter(X, D, beta, N, normalized);

            case "LMS_norm"
                %Parámetros del filtro
                beta = 0.01; 
                %N = 1000; 
                N = 100;
                normalized = true; 

                %Se aplica el filtro
                [Y,E,W] = LMS_filter(X, D, beta, N, normalized);


        end

        %Se grafican las señales de interés 
        clf();figure(1);
        subplot(3, 1, 1);
        plot(X, 'color', [0, 0.4470, 0.7410]);
        legend x[n]
        subplot(3, 1, 2);
        plot(D, 'r');
        legend d[n]
        subplot(3, 1, 3);
        plot(Y, 'color', [0.9290, 0.6940, 0.1250]);
        yaxis(-1,1);
        legend y[n]
        saveas(figure(1), [pwd char("/results/"+selected_filter+"/"+"Signals_"+selected_filter+"_"+playlist(i)+".eps")] );
        saveas(figure(1), [pwd char("/results/"+selected_filter+"/"+"png/"+"Signals_"+selected_filter+"_"+playlist(i)+".png")] );
        
        %Se grafica el vector w
        clf; figure(2);
        plot(W);
        legend norm(w);
        saveas(figure(2), [pwd char("/results/"+selected_filter+"/"+"W_vector_"+selected_filter+"_"+playlist(i)+".eps")] );
        saveas(figure(2), [pwd char("/results/"+selected_filter+"/"+"png/"+"W_vector_"+selected_filter+"_"+playlist(i)+".png")] );
        
        %Error cuadrático medio
        clf();figure(3);
        ecm_h_axis = linspace(1,m,m);
        ecm = cumsum(E.^2)./(ecm_h_axis');
        plot(ecm);
        
        legend ECM;
        saveas(figure(3), [pwd char("/results/"+selected_filter+"/"+"ECM_"+selected_filter+"_"+playlist(i)+".eps")] );
        saveas(figure(3), [pwd char("/results/"+selected_filter+"/"+"png/"+"ECM_"+selected_filter+"_"+playlist(i)+".png")] );

        %Generación de espectogramas
        %2205 para una frecuencia mínima de 20 Hz
        clf();figure(4);
        set(figure(4), 'Position',  [0, 0, 560, 640])
        window = 2205;
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
        saveas(figure(4), [pwd char("/results/"+selected_filter+"/"+"spectrogram_"+selected_filter+"_"+playlist(i)+".eps")] );
        saveas(figure(4), [pwd char("/results/"+selected_filter+"/"+"png/"+"spectrogram_"+selected_filter+"_"+playlist(i)+".png")] );
        
        audiowrite( [pwd char("/audio data/output/clips musicales/"+selected_filter+"_"+playlist(i)+".wav")], Y, fs);
    end
end


