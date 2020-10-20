
function [X] = tapped_delay_mat(x_n, window_sz)
    
    [duration, ~] = size(x_n);
    x_n = [zeros(window_sz-1, 1); x_n];

    X = zeros(window_sz, duration);

    for i = 1:duration
        X(:,i) = flip(x_n(i:(window_sz-1+i)), 1);
    end

end