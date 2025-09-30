close all;
clear all;
clc;
%% read the VTK volume
v = readVTK('hydrogen.vtk');
volrender(v)
%% add noise (gaussian / pepper)
gaussianNoiseImg = imnoise(v,'gaussian',0,.00001);
spNoiseImg = imnoise(v,'salt & pepper',.01);


%% denoise by ordfilt3D (median filter)
denoiseSPImgByOrdFilt3D = ordfilt3D(spNoiseImg,14);
denoiseGaussianImgByOrdFilt3D = ordfilt3D(gaussianNoiseImg,14);

%% denoise by imfilter (mean filter)
kernelSize = [3, 3, 3];
h_mean = fspecial3('average', kernelSize);%%3d operation
denoiseSPImgByImfilter = imfilter(spNoiseImg,h_mean);
denoiseGaussianImgByImfilter = imfilter(gaussianNoiseImg,h_mean);

% %%
% volrender(denoiseSPImgByOrdFilt3D)
% %%
% volrender(denoiseSPImgByImfilter)

%% PSNR
SP_PSNR_Imfilter = psnr(denoiseSPImgByImfilter,v);
SP_PSNR_OrdFilt3D = psnr(denoiseSPImgByOrdFilt3D,v);

GN_PSNR_Imfilter = psnr(denoiseGaussianImgByImfilter,v);
GN_PSNR_OrdFilt3D = psnr(denoiseGaussianImgByOrdFilt3D,v);
%% SSIM
SP_SSIM_Imfilter = ssim(denoiseSPImgByImfilter,v);
SP_SSIM_OrdFilt3D = ssim(denoiseSPImgByOrdFilt3D,v);

GN_SSIM_Imfilter = ssim(denoiseGaussianImgByImfilter,v);
GN_SSIM_OrdFilt3D = ssim(denoiseGaussianImgByOrdFilt3D,v);
