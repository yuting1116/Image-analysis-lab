function dTV=dSmoothTV(X)
%function dTV=dSmoothTV(X)
% Gradient of SmoothTV(X)

% parameter to smooth the absolute function at zero
beta=1e-3;

%repeat edge elements -> no gradient
u_up = X([1,1:end-1],:);
u_dn = X([2:end,end],:);
u_le = X(:,[1,1:end-1]);
u_ri = X(:,[2:end,end]);

dx1 = u_dn-X;
dx2 = u_ri-X;

d = 1./sqrt(dx1.^2+dx2.^2+beta^2); 
d_up = d([1,1:end-1],:);
d_le = d(:,[1,1:end-1]);

dTV = X.*(2*d+d_le+d_up) - u_le.*d_le - u_up.*d_up - d.*(u_ri+u_dn);
