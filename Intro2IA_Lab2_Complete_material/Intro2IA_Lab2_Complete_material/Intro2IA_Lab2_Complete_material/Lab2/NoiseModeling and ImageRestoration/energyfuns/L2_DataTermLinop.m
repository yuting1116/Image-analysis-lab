function e=L2_DataTermLinop(X,M,Y)
%function e=L2_DataTermLinop(X,M,Y)
% Quadratic DataTerm which includes a linear operator M,  e=0.5*|M*X-Y|^2 
%
% X=current image 
% M=linear operator (e.g. from convmtx2) applied to X
% Y=sensed image
e=0.5*sum((M*X(:)-Y(:)).^2);
