clear; clc;

%Funciones de activación 
x = linspace(-pi,pi,100);
sine = sin(x);
x = linspace(-5,5,100);
hyper_tan = tanh(x);
sigmoid = 1./(1+exp(-x));
gaussian = exp(-x.^2);

%Graficando

figure(1);
set(figure(1), 'Position',  [100, 100, 200, 200]);
plot(linspace(-pi,pi,100), sine, 'k');
xlabel('x');
ylabel('f(x)');
%grid on;
saveas(figure(1), 'sine_act.eps');

figure(2);
set(figure(2), 'Position',  [500, 500, 200, 200]);
plot(x, hyper_tan, 'k');
xlabel('x');
ylabel('f(x)');
saveas(figure(2), 'tanh_act.eps');

figure(3);
set(figure(3), 'Position',  [100, 500, 200, 200]);
plot(x, sigmoid, 'k');
xlabel('x');
ylabel('f(x)');
saveas(figure(3), 'sigmoid_act.eps');

figure(4);
set(figure(4), 'Position',  [500, 100, 200, 200]);
plot(x, gaussian, 'k');
xlabel('x');
ylabel('f(x)');
saveas(figure(4), 'gaussian_act.eps');
