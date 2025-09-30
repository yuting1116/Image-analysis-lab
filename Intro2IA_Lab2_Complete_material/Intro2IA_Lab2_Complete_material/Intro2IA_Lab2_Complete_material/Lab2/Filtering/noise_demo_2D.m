close all;
clear all;

%% read the VTK volume
v = readVTK('hydrogen.vtk');

%% gets the middle (in z-direction) 2D slice
v_slice = v(:,:,32);

%% adding 'salt & pepper' and Gaussian noise
v_slice_sp=imnoise(v_slice,'salt & pepper',.01);
v_slice_g=imnoise(v_slice,'gaussian',0,.001);

%% filtering
I_medfilt_spn = medfilt2(v_slice_sp,[7 7]);
I_gaussfilt_gn = imfilter(v_slice_g,fspecial('gaussian',[7 7],1));
I_medfilt_gn = medfilt2(v_slice_g,[7 7]);
I_gaussfilt_spn = imfilter(v_slice_sp,fspecial('gaussian',[7 7],1));

%% showing the result
figure;
imshow(v_slice,[],'InitialMagnification',500);
title('Original image');

figure;
subplot(2,3,1)
imshow(v_slice_g,[],'InitialMagnification',500);
title('Gaussian noise');
subplot(2,3,4);
imshow(v_slice_sp,[],'InitialMagnification',500);
title('Salt & Pepper noise');
subplot(2,3,2);
imshow(I_gaussfilt_gn,[],'InitialMagnification',500);
title('Gaussian filtered Gaussian noise');
subplot(2,3,5);
imshow(I_medfilt_spn,[],'InitialMagnification',500);
title('Median filtered Salt & Pepper noise');
subplot(2,3,3);
imshow(I_medfilt_gn,[],'InitialMagnification',500);
title('Median filtered Gaussian noise');
subplot(2,3,6);
imshow(I_gaussfilt_spn,[],'InitialMagnification',500);
title('Gaussian filtered Salt & Pepper noise');
