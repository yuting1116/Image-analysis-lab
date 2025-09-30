function T=convmtx2_shape(H,M,N,shape)
%function T=convmtx2_shape(H,M,N,shape)
%function T=convmtx2_shape(H,[M,N],shape)
%
% Like convmtx2 but with desired output shape in {'full','same','valid'}
%
% Author: Joakim Lindblad

if nargin<4 %called with size vector [M,N]
	[M,N,shape]=deal(M(1),M(2),N);
end
T=convmtx2(H,M,N);
T(~shape_mask([M,N],size(H),'full',shape),:)=[]; %Remove rows of T that should not be in given shape
