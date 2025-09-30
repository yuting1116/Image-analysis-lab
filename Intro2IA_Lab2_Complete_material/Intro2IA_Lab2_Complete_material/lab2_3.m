clear;clc;
img = imread('van.tif');

sigma1 = 5;
sigma2 = 1;
kernelSize1 = 6*sigma1 + 1;
kernelSize2 = 6*sigma2 + 1;
maxKernelSize = max(kernelSize1, kernelSize2);

%% 1-3
h1 = fspecial("gaussian", [maxKernelSize maxKernelSize], sigma1);
h2 = fspecial("gaussian", [maxKernelSize maxKernelSize], sigma2);

DoG1 = imfilter(img, h1 - h2);
figure();
imshow(DoG1);
title('DoG: sigma ratio = 5');

%% 1-4
h1 = fspecial("gaussian", [kernelSize1 kernelSize1], sigma1);
h2 = fspecial("gaussian", [kernelSize2 kernelSize2], sigma2);
imgGaussian1 = imfilter(img, h1);
imgGaussian2 = imfilter(img, h2);
DoG = imgGaussian1 - imgGaussian2;

figure();
subplot(1, 3, 1);
imshow(imgGaussian1);
title('gaussian sigma = 10');

subplot(1, 3, 2);
imshow(imgGaussian2);
title('gaussian sigma = 1');

subplot(1, 3, 3);
imshow(DoG);
title('DoG: sigma ratio = 10');

%%
sum(DoG - DoG1, "all")
