function volrender(img)
%%
% volrender(img), where img is the 3D image to render
%
% volrender is a wrapper for vol3d(). volrender will open a figure window 
% and sets texture to 3D and a black bakground, grid on, colormap cool and 
% a view angle.
%
%%
figure;
h = vol3d('cdata',img,'texture','3D'); 
view([10 10 0]); 
vol3d(h);
grid on;
colormap(cool); 
set(gca,'color','black');