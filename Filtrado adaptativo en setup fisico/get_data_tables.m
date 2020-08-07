%Obtener data 

clear; clc;

%Filtro seleccionado
%filter = "LMS_est";
%filter = "LMS_norm";
filter = "RLS";

%data = "last_ECM_";
%data = "max_W_";
data = ["last_ECM_", "max_W_"];
% 
% signal = ["250_sine", "1000_sine", "10000_sine",...
%           "250_square", "1000_square", "10000_square",...
%           "250_sawtooth", "1000_sawtooth", "10000_sawtooth",...
%           "AM", "FM", "AM_and_FM", "chirp20_10000",...
%           "bohemian_rhapsody", "cadence", "peru", "week_no_8",...
%           "lonely_cat", "karma_police", "atlantic_limited",...
%           "blauen_donau"];


% signal = ["250_sine", "1000_sine", "10000_sine",...
%           "250_square", "1000_square", "10000_square",...
%           "250_sawtooth", "1000_sawtooth", "10000_sawtooth",...
%           "AM", "FM", "AM_and_FM", "chirp20_10000"];
         
signal = ["bohemian_rhapsody", "cadence", "peru", "week_no_8",...
          "lonely_cat", "karma_police", "atlantic_limited",...
          "blauen_donau"];
%       
      
[~,k] = size(data);
[~,n] = size(signal);     
%total_ECM = cell(n, 2);
%total_max_W = cell(n, 2);
total = cell(n, 3);
total_num = zeros(n,2);

for j = 1:k
    
    for i = 1:n
        load([pwd, char("/results/"+filter+"/numerical/"+data(j)+filter+"_"+signal(i)+".mat")]);
        
        total{i,1} = signal(i);
        switch data(j)
            case "last_ECM_"
                
                total{i,2} = num2str(last_ECM);
                total_num(i,1) = last_ECM;
            case "max_W_"
                total{i,3} = num2str(max_W);
                total_num(i,2) = max_W;
        end

    end

end

%promedio
last_ECM_mean = mean(total_num(:,1));
max_W_mean = mean(total_num(:,2));

[last_ECM_mean, max_W_mean]
