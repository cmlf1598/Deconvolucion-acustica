
function [X] = tapped_delay_mat_slow(x_n, window_sz)
    
    [duration, ch] = size(x_n);
    i = ch;
    X = zeros(window_sz, duration); 
    y = zeros(window_sz,1);
    x_n = num2cell(x_n'); 
    
    for ts = 1:duration
        y_prev = tapdelay(x_n,i,ts,0:min(window_sz-1, ts-1));       
        y(1:window_sz, 1) = [y_prev; zeros((window_sz - numel(y_prev)),1)];
        
        X(:, ts) = y;
    end
    
end

