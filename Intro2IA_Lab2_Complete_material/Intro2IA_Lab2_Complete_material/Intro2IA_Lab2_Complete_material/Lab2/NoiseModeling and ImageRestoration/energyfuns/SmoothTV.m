function tv=SmoothTV(X)
%function tv=SmoothTV(X)
% Totatal variation of X, tv=sum(abs(gradient(X)))
%  slightly smoothed at zero for faster optimer convergence

% parameter to smooth the absolute function at zero
beta=1e-3;

% Forward derivatives of image X
dx1 = X([2:end, end],:)-X;
dx2 = X(:,[2:end, end])-X;

TV = sqrt(dx1.^2 + dx2.^2 + beta^2);
tv=sum(TV(:));
