classdef SkewNormalDistribution < prob.ToolboxFittableParametricDistribution
    % SKEWNORMAL An object of the SkewNormal class represents a Skew Normal
    % probability distribution with a specific location parameter XI, a scale
    % parameter OMEGA, and a shape parameter ALPHA. This distribution object
    % can be created directly using the MAKEDIST function or fit to data using
    % the FITDIST function.
    %
    %    SkewNormal methods:
    %       cdf                   - Cumulative distribution function
    %       fit                   - Fit distribution to data
    %       icdf                  - Inverse cumulative distribution function
    %       iqr                   - Interquartile range
    %       mean                  - Mean
    %       median                - Median
    %       paramci               - Confidence intervals for parameters
    %       pdf                   - Probability density function
    %       proflik               - Profile likelihood function
    %       random                - Random number generation
    %       std                   - Standard deviation
    %       truncate              - Truncation distribution to an interval
    %       var                   - Variance
    %
    %    SkewNormal properties:
    %       DistributionName      - Name of the distribution
    %       mu                    - Value of the mu parameter
    %       sigma                 - Value of the sigma parameter
    %       NumParameters         - Number of parameters
    %       ParameterNames        - Names of parameters
    %       ParameterDescription  - Descriptions of parameters
    %       ParameterValues       - Vector of values of parameters
    %       Truncation            - Two-element vector indicating truncation limits
    %       IsTruncated           - Boolean flag indicating if distribution is truncated
    %       ParameterCovariance   - Covariance matrix of estimated parameters
    %       ParameterIsFixed      - Two-element boolean vector indicating fixed parameters
    %       InputData             - Structure containing data used to fit the distribution
    %       NegativeLogLikelihood - Value of negative log likelihood function
    %
    %    See also fitdist, makedist.
    %
    %   Copyright 2024 - 2026 The MathWorks, Inc.

    properties(Constant)
        DistributionName = 'skewnormal';
    end
   
    properties(Dependent=true)
        %XI Location parameter
        xi

        %OMEGA Scale parameter
        omega

        %ALPHA Shape parameter
        alpha
    end
    
    properties(Constant)
        %NumParameters Number of parameters
        %    NumParameters is the number of parameters in this distribution.
        NumParameters = 3;

        %ParameterName Name of parameter
        %    ParameterName is a two-element cell array containing names
        %    of the parameters of this distribution.
        ParameterNames = {'xi' 'omega' 'alpha'};

        %ParameterDescription Description of parameter
        %    ParameterDescription is a two-element cell array containing
        %    descriptions of the parameters of this distribution.
        ParameterDescription = {'location' 'scale' 'shape'};
    end

    % All ParametricDistribution objects must include a ParameterValues property
    % whose value is a vector of the parameter values, in the same order as
    % given in the ParameterNames property above.
    properties(GetAccess='public',SetAccess='protected')
        %ParameterValues Values of the distribution parameters
        %    ParameterValues is a two-element vector containing the mu and sigma
        %    values of this distribution.
        ParameterValues
    end

    properties (Dependent, Access = private)
        delta
    end

    methods
        % The constructor for this class can be called with a set of parameter
        % values or it can supply default values. These values should be
        % checked to make sure they are valid. They should be stored in the
        % ParameterValues property.
        function pd = SkewNormalDistribution(xi,omega,alpha)
            %SkewNormal Construct a skew normal distribution object
            %
            %   PD = SkewNormal returns a SkewNormal distribution object with
            %   default parameters xi = 0, omega = 1, alpha = 1.
            %
            %   PD = SkewNormal(XI,OMEGA,ALPHA) constructs a SkewNormal
            %   distribution with location parameter XI, scale parameter
            %   OMEGA (>0), and shape parameter ALPHA.
            %
            %   The created object has its ParameterValues set to
            %   [xi omega alpha], ParameterIsFixed set to [true true true],
            %   and ParameterCovariance initialized to a zero matrix.
            %
            %   Example:
            %       pd = SkewNormal(0,2,5);
            %
            %   See also fitdist, makedist, prob.Distribution.
            
            arguments
                xi (1,1) double {mustBeReal} = 0
                omega (1,1) double {mustBePositive} = 1
                alpha (1,1) double {mustBeReal} = 1
            end

            pd.ParameterValues = [xi omega alpha];

            % All FittableParametricDistribution objects must assign values
            % to the following two properties. When an object is created by
            % the constructor, all parameters are fixed and the covariance
            % matrix is entirely zero.
            pd.ParameterIsFixed = [true true true];
            pd.ParameterCovariance = zeros(pd.NumParameters);
        end

        function m = mean(this)
            m = this.xi + this.omega*this.delta*sqrt(2/pi);
        end
        function s = std(this)
            s = sqrt(this.var);
        end
        function v = var(this)
            v = this.omega^2*(1-2*this.delta^2/pi);
        end
    end
    methods
        % If this class defines dependent properties to represent parameter
        % values, their get and set methods must be defined. The set method
        % should mark the distribution as no longer fitted, because any
        % old results such as the covariance matrix are not valid when the
        % parameters are changed from their estimated values.
        function delta = get.delta(this)
            delta = this.alpha/sqrt(1+this.alpha^2);
        end

        function this = set.xi(this,xi)
            arguments
                this
                xi (1,1) double {mustBeReal}
            end
            this.ParameterValues(1) = xi;
            this = invalidateFit(this);
        end
        function this = set.omega(this,omega)
            arguments
                this
                omega (1,1) double {mustBePositive}
            end
            this.ParameterValues(2) = omega;
            this = invalidateFit(this);
        end
        function this = set.alpha(this,alpha)
            arguments
                this
                alpha (1,1) double {mustBeReal}
            end
            this.ParameterValues(3) = alpha;
            this = invalidateFit(this);
        end
        function xi = get.xi(this)
            xi = this.ParameterValues(1);
        end
        function omega = get.omega(this)
            omega = this.ParameterValues(2);
        end
        function alpha = get.alpha(this)
            alpha = this.ParameterValues(3);
        end
    end

    methods(Static, Hidden)
   
        function pd = fit(x,varargin)
            %FIT Fit from data
            %   P = prob.LaplaceDistribution.fit(x)
            %   P = prob.LaplaceDistribution.fit(x, NAME1,VAL1, NAME2,VAL2, ...)
            %   with the following optional parameter name/value pairs:
            %
            %          'censoring'    Boolean vector indicating censored x values
            %          'frequency'    Vector indicating frequencies of corresponding
            %                         x values
            %          'options'      Options structure for fitting, as create by
            %                         the STATSET function

            % Get the optional arguments. The fourth output would be the
            % options structure, but this function doesn't use that.
            [x,cens,freq,options] = prob.ToolboxFittableParametricDistribution.processFitArgs(x,varargin{:});

            % This distribution was not written to support censoring or to process
            % a frequency vector. The following utility expands x by the frequency
            % vector, and displays an error message if there is censoring.
            x = prob.ToolboxFittableParametricDistribution.removeCensoring(x,cens,freq,'skewnormal');
            freq = ones(size(x));

            % Estimate the parameters from the data. If this is an iterative procedure,
            % use the values in the opt argument.
            M1 = mean(x);
            STD = std(x);
            G1 = skewness(x);

            G1P = abs(G1)^(2/3);
            sG1 = sign(G1);
            delta = sG1*min(sqrt(pi/2*G1P/(G1P+((4-pi)/2)^(2/3))), 1-eps);
            alpha = delta/sqrt(1-delta^2);
            omega = STD/sqrt(1-2*delta^2/pi);
            xi = M1-omega*delta*sqrt(2/pi);

            % Perform the MLE to estimate the distribution parameters.
            f = @(data, xi, omega, alpha) ...
                prob.SkewNormalDistribution.logpdffunc(...
                data, xi, omega, alpha);

            params0 = [xi; omega; sG1*min(abs(alpha), 100)];

            lb = [-Inf; eps; -Inf];
            ub = [Inf; Inf; Inf];

            if isempty(options)
                options = statset;
                options.MaxIter = 1e5;
                options.MaxFunEvals = 1e5;
            end

            params = mle(x, 'logpdf', f, ...
                'start', params0, ...
                'LowerBound', lb, ...
                'UpperBound', ub, Options=options);

            pd = prob.SkewNormalDistribution(params(1),params(2), params(3));

            % Fill in remaining properties defined above
            pd.ParameterIsFixed = [false false false];
            [nll,acov] = prob.SkewNormalDistribution.likefunc([params(1) params(2) params(3)],x);
            pd.ParameterCovariance = acov;

            % Assign properties required for the FittableDistribution class
            pd.NegativeLogLikelihood = nll;
            pd.InputData = struct('data',x,'cens',[],'freq',freq);
        end

        function [nll,acov] = likefunc(params,x) % likelihood function
            %LIKEFUNC likelihood function
            %   [nll,acov] = likefunc(params,x)

            xi = params(1);
            omega = params(2);
            alpha = params(3);

            nll = -sum(prob.SkewNormalDistribution.logpdffunc(x, xi, omega, alpha));

            % Asymptotic parameter variance-covariance matrix. In the
            % absence of a closed-form expression for this, we can estimate
            % it using MLECOV.
            acov = mlecov(params,x,'logpdf',@prob.SkewNormalDistribution.logpdffunc);
        end

        function y = cdffunc(x,xi,omega,alpha)
            %CDFFUNC cumulative distribution function
            %   y = cdffunc(x,xi,omega,alpha)

            arguments
                x (:,1) double {mustBeReal}
                xi (1,1) double {mustBeReal} = 0
                omega (1,1) double {mustBePositive} = 1
                alpha (1,1) double {mustBeReal} = 1
            end
            z = (x - xi)/omega;
            y = normcdf(z)-2*prob.SkewNormalDistribution.TOwen(z, alpha);
        end

        function y = pdffunc(x,xi,omega,alpha)         
            %PDFFUNC probability density function
            %   y = pdffunc(x,xi,omega,alpha)   

            arguments
                x (:,1) double {mustBeReal}
                xi (1,1) double {mustBeReal} = 0
                omega (1,1) double {mustBePositive} = 1
                alpha (1,1) double {mustBeReal} = 1
            end
            z = (x-xi)/omega;
            y = 2*normpdf(z).*normcdf(alpha*z)/omega;
        end

        function y = logpdffunc(x,xi,omega,alpha)         
            %LOGPDFFUNC probability density function
            %   y = logpdffunc(x,xi,omega,alpha)         
            arguments
                x (:,1) double {mustBeReal}
                xi (1,1) double {mustBeReal} = 0
                omega (1,1) double {mustBePositive} = 1
                alpha (1,1) double {mustBeReal} = 1
            end

            z=(x-xi)./omega;
            az = alpha.*z;
            lncdf = log(normcdf( az ));

            % Underflow stability, when normcdf tends to 0, log goes to
            % -Inf, use asymptotic behavior.
            idx = isinf(lncdf);
            if any(idx)                
                lncdf(idx) = -0.5*az(idx).^2 - log(-az(idx)) - 0.5*log(2*pi);
            end

            y = log(2) - log(sqrt(2*pi)) - z.^2/2 + lncdf - log(omega);
        end

        function q = invfunc(p,xi, omega, alpha, opts)         
            %INVFUNC inverse cdf
            %   q = invfunc(p,xi, omega, alpha, options)         
            arguments
                p (:,1) double {mustBeInRange(p, 0, 1)} %#ok<MUSTINRANGE>
                xi (1,1) double {mustBeReal} = 0
                omega (1,1) double {mustBePositive} = 1
                alpha (1,1) double {mustBeReal} = 1
                opts.options (1,1) struct = optimset('Display','off')
            end

            x = NaN(numel(p), 1);
            x(p == 0) = -Inf;
            x(p == 1) = Inf;

            idx = p~=0 & p~= 1 & ~isnan(p);
            toSolve = p(idx);
            n = numel(toSolve);
 
            solved = zeros(n, 1);
            for i = 1:n
                p = toSolve(i);
                x0 = norminv(p);
                func = @(x) prob.SkewNormalDistribution.cdffunc(x,0,1,alpha)-p;
                solved(i) = fzero( func, x0, opts.options);
            end
            x(idx) = solved;
           
            q=xi+omega.*x;
        end

        function y = randfunc(xi, omega, alpha, varargin) 
            %RANDFUNC random number generator
            %   y = randfunc(xi, omega, alpha, n)
            arguments
                xi (1,1) double {mustBeReal}
                omega (1,1) double {mustBePositive}
                alpha (1,1) double {mustBeReal}
            end

            arguments (Repeating)
                varargin
            end

            u1=normrnd(0,1,varargin{:});
            u2=normrnd(0,1,varargin{:});
            id=(u2>alpha*u1);
            u1(id)=-u1(id);
            y=xi+omega.*u1;
        end

        % All ToolboxDistributions must implement a getInfo static method
        % so that Statistics and Machine Learning Toolbox functions can get information about
        % the distribution.
        function info = getInfo
            %GETINFO get information about the distribution
            % info = getInfo

            % First get default info from parent class
            info = getInfo@prob.ToolboxFittableParametricDistribution('prob.SkewNormalDistribution');

            % Then override fields as necessary
            info.name = 'SkewNormal';
            info.code = 'skewnormal';
            % info.hasconfbounds = false     % Set to true if the cdf and icdf methods can return lower and upper bounds as their 2nd and 3rd outputs.
            % censoring = false              % Set to true if the fit method supports censoring. 
            info.islocscale = false;
            info.optimopts = true;           % Set to true if the fit method can be called with an options structure.
            % info.logci = [false true];     % Set to true for a parameter should have its Wald confidence interval computed using a normal approximation  on the log scale.
        end
    end

    methods (Static)

        function v = TOwen(h,a)
            % TOWEN Owen's function. It Evaluates funtion T(h,a) studied by D.B.Owen
            %
            % V = TOwen(h, a) returns a numerical vector containing the values of
            % Owen's T function.
            %
            % h	a numerical vector. Missing values (NaN) and Inf are allowed. a	a
            % numerical scalar. Inf is allowed.
            %
            %Owen, D. B. (1956). Tables for computing bivariate normal probabilities.
            %Ann. Math. Statist. 27, 1075-1090.
            %
            %   Copyright 2024 - 2026 The MathWorks, Inc.

            arguments
                h (:,1) double
                a (1,1) double {mustBeReal}
            end

            nh = numel(h);
            v = 1/(2*pi)*atan(a)*ones(nh, 1);

            idx = isnan(h);
            v(idx) = NaN;

            for i = 1 : nh
                if h(i) ~= 0 && ~isnan(h(i))
                    v(i) = 1/(2*pi)*integral(@(x) exp(-0.5*h(i)^2.*(1+x.^2))./(1+x.^2), 0, a);
                end
            end

        end

    end

end % classdef