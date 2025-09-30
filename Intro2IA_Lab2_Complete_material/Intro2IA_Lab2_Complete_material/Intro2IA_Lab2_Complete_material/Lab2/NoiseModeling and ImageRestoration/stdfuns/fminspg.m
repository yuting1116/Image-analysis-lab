function [xnew,fval,exitflag,output] = fminspg(fun,gfun,proj,x0,options,params,varargin)
%FMINSPG Multidimensional projection-constrained (or unconstrained) nonlinear minimization
%   Optimization based on Spectral Projected Gradient (SPG), see [1,2].
%
%   X = FMINSPG(FUN,GFUN,[],X0) starts at X0 and attempts to find a local minimizer 
%   X of the function FUN, with gradient (Jacobian) GFUN.  FUN and GFUN are function handles.
%   FUN accepts input X and returns a scalar function value F evaluated at X.
%   GFUN accepts input X and returns a matrix of partial derivatives of FUN
%   X0 can be a scalar, vector or matrix.
%
%   X = FMINSPG(FUN,GFUN,PROJ,X0) constraints the minimization to the region
%   defined by PROJ(X0), where PROJ is a projection (i.e., an idempotent linear transform)
%
%   X = FMINSPG(...,X0,OPTIONS) minimizes with the default optimization
%   parameters replaced by values in the structure OPTIONS, created
%   with the OPTIMSET function.  See OPTIMSET for details.  FMINSPG uses
%   these options: Display, TolX, TolFun, MaxFunEvals, MaxIter, and OutputFcn.
%
%   OutputFcn is (if provided) called as (2nd param with FUN values is optional):
%    OutputFcn ({X0,X1,...,Xn},{f(X0),...,f(Xn)}) at start and after each iter.
%   Note: Similar to fminsearch, FMINSPG stops when it satisfies *both* TolFun and TolX.
%
%   X = FMINSPG(...,OPTIONS,PARAM) minimizes with internal parameters of cell
%   array PARAMS = {theta_min, theta_max, gamma, sigma1, sigma2} 
%    where: 0<thetamin<thetamax, 0<gamma<1, 0<sigma1<sigma2<1
%
%   [X,FVAL]= FMINSPG(...) returns the value of the objective function,
%   described in FUN, at X.
%
%   [X,FVAL,EXITFLAG] = FMINSPG(...) returns an EXITFLAG that describes
%   the exit condition. Possible values of EXITFLAG and the corresponding
%   exit conditions are
%
%    1  Maximum coordinate difference between two consecutive points is
%       less than or equal to TolX, and corresponding 
%       difference in function values is less than or equal to TolFun.
%    0  Maximum number of function evaluations or iterations reached.
%
%   [X,FVAL,EXITFLAG,OUTPUT] = FMINSPG(...) returns a structure
%   OUTPUT with the number of iterations taken in OUTPUT.iterations, the
%   number of function evaluations in OUTPUT.funcCount, the algorithm name 
%   in OUTPUT.algorithm, the steps and function values passed in OUTPUT.x
%   and OUTPUT.fval, and the exit message in OUTPUT.message.
%
%    Examples
%      FUN can be specified using @:
%         X = fminsearch(@sin,@cos,[],3)
%      finds a minimum of the SIN function near 3.
%      In this case, SIN is a function that returns a scalar function value
%      SIN evaluated at X and COS is its derivative at X.
% 
%      FUN can be a parameterized function. Use an anonymous function to
%      capture the problem-dependent parameters:
%         f = @(x,c) x(1).^2+c.*x(2).^2;  % The parameterized function.
%         g = @(x,c) [2*x(1); c.*2*x(2)]; % The parameterized gradient.
%         c = 1.5;                        % The parameter.
%         X = fminspg(@(x) f(x,c),@(x) g(x,c),[],[0.3;1])
%
%   FMINSPG uses the Spectral Projected Gradient (SPG) method.
%
%   See also OPTIMSET, FMINSEARCH
%
%
% (C) Joakim Lindblad and Tibor Lukic, 2011-2018
%
%
% [1] E. Birgin, J. Martinez, M. Raydan. Nonmonotone spectral projected gradient methods
%  on convex sets. SIAM Journal on Optimization, 10(4), pp. 1196-1211, 2000
% [2] T. Lukic, N. Sladoje, J. Lindblad. Deterministic Defuzzification based on Spectral
%  Projected Gradient Optimization. In Proc. of DAGM, LNCS-5096, pp. 476-485, 2008
%  doi:10.1007/978-3-540-69321-5_48


defaultopt = struct('Display','iter','MaxIter',2000,...
	'MaxFunEvals',inf,'TolX',1e-4,'TolFun',1e-4, ...
	'OutputFcn',[]);

% If just 'defaults' passed in, return the default options in X
if nargin==1 && nargout <= 1 && strcmpi(fun,'defaults')
    xnew = defaultopt;
    return
end

if nargin<5, options = []; end

if nargin<6 || isempty(params), params = {0.001,1000,0.0001,0.1,0.9}; end
[thetamin,thetamax,gamma,sigma1,sigma2]=deal(params{:});

% recomended choice for parameters
%thetamin = 0.001;
%thetamax = 1000;
%gamma= 0.0001;
%sigma1 = 0.1;
%sigma2 = 0.9;


printtype = optimget(options,'Display',defaultopt,'fast');
tolx = optimget(options,'TolX',defaultopt,'fast');
tolf = optimget(options,'TolFun',defaultopt,'fast');
maxfun = optimget(options,'MaxFunEvals',defaultopt,'fast');
maxiter = optimget(options,'MaxIter',defaultopt,'fast');

switch printtype
	case {'none','off'}
		prnt = 0;
% Not implemented
%	case {'notify','notify-detailed'}
%		prnt = 1;
	case {'final','final-detailed'}
		prnt = 2;
	case {'iter','iter-detailed'}
		prnt = 3;
	otherwise
		warning('fminspg','Unknown printtype');
		prnt = 3;
end

% Handle the output
outputfcn = optimget(options,'OutputFcn',defaultopt,'fast');
if ~isempty(outputfcn)
	outputfcn=@(varargin) outputfcn(varargin{1:nargin(outputfcn)}); %ignore additional parameters
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xold = x0;
fold=fun(xold,varargin{:}); %initial objective function value of xold
fval=fold; %start fun

grold=gfun(xold,varargin{:}); %gradient of objective function
if isempty (proj)
	dold=-grold;
else
	dold=proj(xold-grold)-xold;
end

if nargout>3 || ~isempty(outputfcn) %to store intermediate steps or not (may be memory hungry)
	xx={x0};

	S=whos('x0');
	big_x = S.bytes>10000; %if larger than 10kB, then only keep last x point
	clear S;
else
	xx={};
end
if maxiter<1, xnew=x0; end %ensure we have an output

if ~isempty(outputfcn), outputfcn(xx,fval,'init'); end %at start


%% Main optimization loop
func_evals=1; %done above for fold
for j=1:maxiter
	if func_evals>=maxfun, break; end

	if prnt==3
		fprintf('\rIterations: %4d, E: %6.4f -> %6.4f%30s',j-1, fval(1), fold,' '); %Keep printing on the same row
   end

	xnew=xold+dold; %take step
	ksi=1;
	delta=grold(:)'*dold(:);

	func_evals=func_evals+1;
	fnew=fun(xnew,varargin{:}); %objective function of xnew

	while fnew > fold + gamma*ksi*delta
		ksitsl=-0.5*(ksi^2)*delta/(fnew-fold-ksi*delta);
		if (ksitsl >= sigma1)  && (ksitsl <= sigma2*ksi)
			ksi=ksitsl;
		else
			ksi=ksi/2;
		end

		xnew=xold+ksi*dold;
		func_evals=func_evals+1;
		fnew=fun(xnew,varargin{:}); %update function value, since we updated xnew
	end

	if ~isempty(xx)
		if big_x, xx{j}=[]; end %to not run out of memory
		xx{j+1}=xnew;
	end
	fval(j+1)=fnew;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	s=xnew(:)-xold(:); %difference

   if (j>2 && norm(fnew-fold,inf)<tolf && norm(s,inf)<tolx)
		exitflag=1;
		if ~isempty(outputfcn), outputfcn(xx,fval,'done'); end
		break;
	else
%		fprintf('Norm: %f\n',norm(s,inf));
		if ~isempty(outputfcn), outputfcn(xx,fval,'iter'); end
	end

	grnew=gfun(xnew,varargin{:});
	y=grnew(:)-grold(:); %diff of gradient

	p=s'*y;
	if (p<=0)
		theta = thetamax;
	else
		theta = min(thetamax,max(thetamin,(s'*s)/p));
	end
	
	if isempty (proj)
		dnew = -theta*grnew;
	else
		dnew = proj(xnew-theta*grnew)-xnew;
	end

	xold=xnew;
	dold=dnew;

	fold=fnew; %we already computed it, let's use it for next round
	grold=grnew;
end
if prnt==3
	fprintf('\r%80s\r',' '); %clear the line with 80 spaces
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

output.iterations = j;
output.funcCount = func_evals;
output.algorithm = 'Spectral Projected Gradient optimization';
output.fval=fval; fval=fval(end);
output.x=xx;

if output.funcCount >= maxfun
    msg = sprintf('fminspg: ExitingMaxFunctionEvals (%d): Fval=%f',maxfun,fval);
    if prnt > 0
        fprintf('\n%s\n',msg);
    end
    exitflag = 0;
elseif output.iterations >= maxiter
    msg = sprintf('fminspg: ExitingMaxIterations (%d): Fval=%f',maxiter,fval);
    if prnt > 0
        fprintf('\n%s\n',msg);
    end
    exitflag = 0;
else
    msg = sprintf('fminspg: OptimizationTerminated: X satisfies tolerance criteria (%g,%g), Fval=%f',tolx,tolf,fval);
    if prnt > 1
        fprintf('\n%s\n',msg);
    end
    exitflag = 1;
end
output.message = msg;
