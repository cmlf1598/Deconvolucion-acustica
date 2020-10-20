%Basado en:
%https://la.mathworks.com/videos/forecast-electrical-load-using-the-regression-learner-app-1536231842528.html

%clc; clear;

training_audio = 4;
switch training_audio
    case 1
        D_training_name = "AM_original.wav";
        X_training_name = "AM_recorded.wav";
    case 2
        D_training_name = "sawtooth_2500_original.wav";
        X_training_name = "sawtooth_2500_recorded.wav";
    case 3
        D_training_name = "FM_original.wav";
        X_training_name = "FM_recorded.wav";
    case 4
        D_training_name = "atlantic_limited_original.wav";
        X_training_name = "atlantic_limited_recorded.wav";
end

test_audio = 1;
switch test_audio
    case 1
        D_test_name = "peru_original.wav";
        X_test_name = "peru_recorded.wav";
end


[D_training, fs] = audioread(D_training_name);
[X_training, ~] = audioread(X_training_name);

[D_test, ~] = audioread(D_test_name);
[X_test, ~] = audioread(X_test_name);
%%
t0 = 0;
tf = 10;
[X_training,D_training] = pair_and_clip(fs, X_training, D_training, t0, tf);
[X_test,D_test] = pair_and_clip(fs, X_test, D_test, t0, tf);

%% Extracción de features de audio (training)
[features_ext_training] = feature_extractor(fs, X_training);
%% Extracción de features de audio (test)
[features_ext_test] = feature_extractor(fs, X_test);


%%
data_set_training = [D_training, features_ext_training];
data_set_test = [D_test, features_ext_test];

%% 

test_data_plot = false;

if test_data_plot 
    Y_prediction = trained_fine_tree.predictFcn(features_ext_test);
    x_n = X_test; 
    d_n = D_test;

else
    Y_prediction = trained_fine_tree.predictFcn(features_ext_training);
    x_n = X_training;
    d_n = D_training;
end

y_n = Y_prediction;

%% Graficando
figure(1);
subplot(3,1,1);
plot(x_n, 'color', [0, 0.4470, 0.7410]);
legend x[n];
subplot(3,1,2);
plot(d_n, 'red');
legend d[n];    
subplot(3,1,3);
plot(y_n, 'color', [0.9290, 0.6940, 0.1250]);
legend y[n];

%%
figure(2);
%set(figure(3), 'Position',  [0, 0, 560, 640])
window = 2205;
subplot(3, 1, 1);
spectrogram(x_n, window, [], [], fs);
title x[n]
colormap bone;
subplot(3, 1, 2);
spectrogram(d_n, window, [], [], fs);
title d[n]
colormap bone;
subplot(3, 1, 3);
spectrogram(y_n, window, [], [], fs);
title y[n]
colormap bone;





