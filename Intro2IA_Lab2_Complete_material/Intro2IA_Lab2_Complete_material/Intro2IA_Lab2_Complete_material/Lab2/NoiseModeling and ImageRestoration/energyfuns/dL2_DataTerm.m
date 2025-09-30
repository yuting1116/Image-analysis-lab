function dE=dL2_DataTerm(X,Y)
%function dE=dL2_DataTerm(X,Y)
% Derivative matrix of the "plain" DataTerm
%
% X=current image 
% Y=sensed image
dE=X-Y;
