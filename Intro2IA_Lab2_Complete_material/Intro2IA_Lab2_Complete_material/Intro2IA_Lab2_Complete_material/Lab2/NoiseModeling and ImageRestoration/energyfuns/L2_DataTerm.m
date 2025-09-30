function e=L2_DataTerm(X,Y)
%function e=L2_DataTerm(X,Y)
% Plain quadratic DataTerm, e=0.5*|X-Y|^2 
%  Good for Gaussian/Normal distributed noise
%
% X=current image 
% Y=sensed image
e=0.5*sum((X(:)-Y(:)).^2);
