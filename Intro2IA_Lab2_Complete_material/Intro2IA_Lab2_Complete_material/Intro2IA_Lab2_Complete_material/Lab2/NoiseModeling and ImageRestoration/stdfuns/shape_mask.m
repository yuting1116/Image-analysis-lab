function mask=shape_mask(sizA,sizB,inshape,outshape)
%function mask=shape_mask(sizA,sizB,inshape,outshape)
% return mask that cuts out appropriate central part
% 'shape' param is like for conv2
%
% E.g. x=conv2(A,B,'full'); x(shape_mask(size(A),size(B),'full','same'))==vector(conv2(A,B,'same'));
%
% Author: Joakim Lindblad

switch inshape
	case 'full'
		inbeg=-floor(sizB/2);
		insiz=sizA+sizB-1;
	case 'same'
		inbeg=zeros(size(sizA));
		insiz=sizA;
	case 'valid'
		inbeg=sizB-1-floor(sizB/2);
		insiz=sizA-sizB+1;
end

switch outshape
	case 'full'
		outbeg=-floor(sizB/2);
		outsiz=sizA+sizB-1;
	case 'same'
		outbeg=zeros(size(sizA));
		outsiz=sizA;
	case 'valid'
		outbeg=sizB-1-floor(sizB/2);
		outsiz=sizA-sizB+1;
end

start=outbeg-inbeg;

% For now only 2D...
mask=false(insiz);
mask( 1+start(1):start(1)+outsiz(1), 1+start(2):start(2)+outsiz(2) ) = true;
