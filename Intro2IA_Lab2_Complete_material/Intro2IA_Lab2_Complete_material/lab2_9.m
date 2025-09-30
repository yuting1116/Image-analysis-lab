clear;clc;
img = imread("fundus.png");
imshow(img)
%% meadian filter
kernelSize = 3;

medianImg = medianFunc(img, kernelSize); % median filter

sigma = (kernelSize-1)/6;
h_gaussian = fspecial("gaussian", [kernelSize kernelSize], sigma); % gaussian filter
gaussianImg = imfilter(img, h_gaussian);

h_mean = fspecial('average', kernelSize); % mean filter
meanImg = imfilter(img, h_mean);

%% noise free image
imgNoiseFree = imread("fundus_ref.png");
figure(1)
imshow(imgNoiseFree)
title('noise free');

figure(2)
imshow(uint8(gaussianImg));
title('gaussian filter');


figure(3)
imshow(uint8(meanImg));
title('mean filter');

figure(4);
imshow(uint8(medianImg));
title('median filter');

figure(5)
imshow(imbilatfilt(img,'NeighborhoodSize', kernelSize))
title('bilateral filter');