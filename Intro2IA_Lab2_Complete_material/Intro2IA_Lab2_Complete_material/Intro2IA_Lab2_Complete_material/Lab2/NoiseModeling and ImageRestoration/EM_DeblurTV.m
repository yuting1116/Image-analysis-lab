function X=EM_DeblurTV(S,PSF,mu,OutputFcn,MaxIter)
%function X=EM_DeblurTV(S,PSF,mu[,OutputFcn])
% Debluring by TV-regularized energy minimization using SPG
%  Non-FFT version (expressing convolution as matrix multiplication)
%
% Input:   S - Sensed image
%        PSF - Approximate point spread function (as default 'imfilter', i.e., zero boundary and 'corr')
%         mu - Regularization weight
%  OutputFcn - Optional function called during minimization (see FMINSPG)
%               if 'show', then displaying every 10th iteration using imshow
%
% Output: X - Deblurred image
%
%
%  Example:
%
%     I=im2double(imread('cameraman.tif'));    % doubles in range [0,1]
%     N=0.01*randn(size(I));                   % normal distributed noise
%     PSF=fspecial('gaussian',3*ceil(3)+1,3);  % gaussian shaped PSF with sigma=3
%     S=imfilter(I,PSF)+N;                     % "sensed" blurred noisy image
%     X=EM_DeblurTV(S,PSF,0.0004,'show');      % compute deblurred image X
%     fprintf('PSNR: %.2f->%.2f dB, SSIM: %.3f->%.3f\n',psnr(S,I),psnr(X,I),ssim(S,I),ssim(X,I));  % performance measures
%
% Author: Joakim Lindblad
%
% [1] L.I. Rudin, S. Osher. "Total variation based image restoration with free local constraints"
%  Proc. ICIP, vol. 1, pp. 31-35, 1994.
% [2] B. Bajic, J. Lindblad, and N. Sladoje. "An Evaluation of Potential Functions for Regularized Image Deblurring"
%  Proc. ICIAR, LNCS-8814, pp. 150-158, 2014. doi:10.1007/978-3-319-11758-4_17

assert(isfloat(S),'Input has to be floating point type'); % Integers not supported

addpath('stdfuns');
addpath('energyfuns');

T=convmtx2_shape(rot90(PSF,2),size(S),'same'); % Matrix corresponding to convolution with the flipped PSF
% This holds, bar floating point differences:  imfilter(S,PSF) == reshape(T*S(:), size(S))
%  f1 = imfilter(S,PSF);  f2 = reshape(T*S(:), size(S));
%  fprintf('max_diff between imfilter and matrix mult. is %f.\n', max(abs(f1(:)-f2(:))));

% It is possible to perform FFT based convolutions to make things faster
En=@(X) L2_DataTermLinop(X,T,S) + mu*SmoothTV(X); %Energy function
dEn=@(X) dL2_DataTermLinop(X,T,S) + mu*dSmoothTV(X); %Gradient of energy function

opt=fminspg('defaults');
if nargin>=4
	if strcmpi(OutputFcn,'show')
   	opt.OutputFcn=@showfun;
	else
		opt.OutputFcn=OutputFcn;
	end
end
if nargin>=5, opt.MaxIter=MaxIter; end
X = fminspg(En,dEn,[],S,opt); %Starting guess is input image


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showfun(X,fval,state)
if ~strcmp(state,'iter') || mod(numel(X),10)==1
	imshow(X{end},[]);
	title(sprintf('Iteration: %d,  Energy: %.4f',numel(X)-1,fval(end)))
	drawnow;
end
