function dE=dL2_DataTermLinop(X,M,Y)
%function dE=dL2_DataTermLinop(X,M,Y)
% Derivative of DataTerm which includes a linear operator M
%
% X=current image 
% M=linear operator (e.g. from convmtx2) applied to X
% Y=sensed image
dE=reshape(transpose(M)*(M*X(:)-Y(:)), size(X));
