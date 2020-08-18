function y = convreverb(x, h)
%genero vectores espaciados que dependen de la longitud de la entrada e 
%impulso
n1 = linspace(0, length(h), length(h) + 1);
nx = linspace(0, length(x), length(x) + 1)';

%realizo la convolución entre la entrada y el impulso
[o,no] = conv_m(x,nx,h,n1);

%Encuentro los valores máximo y mínimo de mi señal de salida ya 
%convolucionada
lim_max = max(o);

lim_min = min(o); 

%Creo un array de ceros del tamaño de mi salida
y = zeros(size(o));

%Me aseguro que la salida final se encuentre en un rango entre -1 y 1
for n = 0:size(o)-1
    
    if o(n+1, 1) < 0
        y(n+1, 1) = o(n+1, 1)/-lim_min;
    else 
        y(n+1, 1) = o(n+1, 1)/lim_max;
    end
    
end    
    
    
end
