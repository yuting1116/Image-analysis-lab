function X=EM_DenoiseTV(S,mu,OutputFcn,MaxIter)
%function X=EM_DenoiseTV(S,mu[,OutputFcn])
% Denoising by TV-regularized energy minimization using SPG
%
% Input:   S - Sensed image
%         mu - Regularization weight
%  OutputFcn - Optional function called during minimization (see FMINSPG)
%               if 'show', then displaying every 10th iteration using imshow
%
% Output: X - Denoised image
%
%
%  Example:
%
%     I=im2double(imread('cameraman.tif'));    % doubles in range [0,1]
%     N=0.1*randn(size(I));                    % normal distributed noise
%     S=I+N;                                   % "sensed" noisy image
%     X=EM_DenoiseTV(S,0.1);                   % compute denoise image X
%     fprintf('PSNR: %.2f->%.2f dB, SSIM: %.3f->%.3f\n',psnr(S,I),psnr(X,I),ssim(S,I),ssim(X,I));  % performance measures
%
% Author: Joakim Lindblad
%
% [1] L. Rudin, S. Osher, E. Fatemi. "Nonlinear total variation based noise removal algorithms". Physica D. 60:259-268, 1992
% [2] T. Lukic, J. Lindblad, N. Sladoje. "Regularized image denoising based on spectral gradient optimization".
%  Inverse Problems, Vol. 27, No. 8, pp. 085010, 2011. doi:10.1088/0266-5611/27/8/085010

assert(isfloat(S),'Input has to be floating point type'); % Integers not supported

addpath('stdfuns');
addpath('energyfuns');

En=@(X) L2_DataTerm(X,S) + mu*SmoothTV(X); %Energy function
dEn=@(X) dL2_DataTerm(X,S) + mu*dSmoothTV(X); %Gradient of energy function

opt=fminspg('defaults');
if nargin>=3
	if strcmpi(OutputFcn,'show')
   	opt.OutputFcn=@showfun;
	else
		opt.OutputFcn=OutputFcn;
	end
end
if nargin>=4, opt.MaxIter=MaxIter; end
X = fminspg(En,dEn,[],S,opt); %Starting guess is input image


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showfun(X,fval,state)
if ~strcmp(state,'iter') || mod(numel(X),10)==1
	imshow(X{end},[]);
	title(sprintf('Iteration: %d,  Energy: %.4f',numel(X)-1,fval(end)))
	drawnow;
end
