clear;clc;
img = imread('van.tif');
imshow(img)

%%
h = fspecial("gaussian", [1 6], 0.5); %create gaussian kernel 3*3
plot(0:5,h)

%%
% Parameters
sigma = 2;               % Standard deviation of the Gaussian
hsize = 6*sigma;         % Kernel size (6 times sigma is common)
kernel_size = round(6*sigma); % Size of the kernel for fspecial

% Define a range of values to sample the continuous 1D Gaussian function
x = -hsize:hsize;        % Discrete x values (1 pixel step)
G_cont = (1/sqrt(2*pi*sigma^2)) * exp(-x.^2 / (2*sigma^2)); % Continuous 1D Gaussian

% Discrete 1D Gaussian filter using fspecial
h = fspecial('gaussian', [1 kernel_size], sigma); % 1D filter

% Plot continuous Gaussian and discrete Gaussian filter
figure;
sgtitle('gaussian:sigma=2')
subplot(1, 2, 1);
plot(x, G_cont, 'LineWidth', 2);
title('Continuous 1D Gaussian');
xlabel('x');
ylabel('G(x)');
grid on;

subplot(1, 2, 2);
plot(-5.5:5.5, h, 'LineWidth', 2);
title('Discrete 1D Gaussian Filter (fspecial)');
xlabel('x');
ylabel('Filter Value');
grid on;

