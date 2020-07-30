%%Audio tracks filtering
%Por Carlos Manuel López
%19-4-20

clear;
%
path = "/audio data/inputs/data determinista/";

signal = "sine";

%test_freq = ["250", "500", "1000", "2500", "5000", "10000", "15000", "20000"];
test_freq = "250";

[~, no_tracks] = size(test_freq);

for i = 1:no_tracks
    %Clips de audio
    [D, fs] = audioread([pwd, char(path+signal+"_"+test_freq(i)+"_original.wav")]); %señal original
    [X, ~] = audioread([pwd, char(path+signal+"_"+test_freq(i)+"_recorded.wav")]); %señal grabada

    [m,~] = size(D);
   
    %Selección del filtro

    filters = ["LMS_est", "LMS_norm", "RLS"];
    %filters = ["LMS_est"];
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
        saveas(figure(1), [pwd char("/results/"+selected_filter+"/"+"Signals_"+selected_filter+"_"+test_freq(i)+".eps")] );
        saveas(figure(1), [pwd char("/results/"+selected_filter+"/"+"png/"+"Signals_"+selected_filter+"_"+test_freq(i)+".png")] );
        
        %Se grafica el vector w
        clf; figure(2);
        plot(W);
        legend norm(w);
        saveas(figure(2), [pwd char("/results/"+selected_filter+"/"+"W_vector_"+selected_filter+"_"+test_freq(i)+".eps")] );
        saveas(figure(2), [pwd char("/results/"+selected_filter+"/"+"png/"+"W_vector_"+selected_filter+"_"+test_freq(i)+".png")] );
        
        %Error cuadrático medio
        clf();figure(3);
        ecm_h_axis = linspace(1,m,m);
        ecm = cumsum(E.^2)./(ecm_h_axis');
        plot(ecm);
        legend ECM;
        %[pwd '/filters output/figures/t1.png']
        saveas(figure(3), [pwd char("/results/"+selected_filter+"/"+"ECM_"+selected_filter+"_"+test_freq(i)+".eps")] );
        saveas(figure(3), [pwd char("/results/"+selected_filter+"/"+"png/"+"ECM_"+selected_filter+"_"+test_freq(i)+".png")] );

        audiowrite( [pwd char("/audio data/output/data determinista/"+selected_filter+"_"+test_freq(i)+".wav")], Y, fs);
    end
end


