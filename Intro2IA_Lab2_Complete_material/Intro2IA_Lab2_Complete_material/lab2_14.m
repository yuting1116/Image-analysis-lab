close all;
clear all;
clc;
%% read the VTK volume
v = readVTK('hydrogen.vtk');

%% create several noise image
noiseImgs = zeros([size(v),27], 'uint8');
for i = 1 : 27
    noiseImgs(:,:,:,i) = imnoise(v,'gaussian',0,.00001);
end

meanImg = mean(noiseImgs,4, "native");

PSNR = psnr(meanImg,v);
SSIM = ssim(meanImg,v);
%%
volrender(meanImg)
title('multi-image averaging')