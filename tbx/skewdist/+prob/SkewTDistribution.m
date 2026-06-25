classdef SkewTDistribution < prob.ToolboxFittableParametricDistribution
    % SKEWT An object of the SkewT class represents a Skew T student
    % probability distribution with a specific location parameter XI, scale
    % parameter OMEGA, shape parameter ALPHA, and degrees of freedom NU.
    % This distribution object can be created directly using the MAKEDIST
    % function or fit to data using the FITDIST function.
    %
    %    SkewT methods:
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
    %    SkewT properties:
    %       DistributionName      - Name of the distribution
    %       nu                    - Value of the nu parameter
    %       omega                 - Value of the omega parameter
    %       NumParameters         - Number of parameters
    %       ParameterNames        - Names of parameters
    %       ParameterDescription  - Descriptions of parameters
    %       ParameterValues       - Vector of values of parameters
    %       Truncation            - Four-element vector indicating truncation limits
    %       IsTruncated           - Boolean flag indicating if distribution is truncated
    %       ParameterCovariance   - Covariance matrix of estimated parameters
    %       ParameterIsFixed      - Four-element boolean vector indicating fixed parameters
    %       InputData             - Structure containing data used to fit the distribution
    %       NegativeLogLikelihood - Value of negative log likelihood function
    %
    %    See also fitdist, makedist.
    %
    %   Copyright 2024 - 2026 The MathWorks, Inc.

    % All ProbabilityDistribution objects must specify a DistributionName
    properties(Constant)
        %DistributionName Name of distribution
        %    DistributionName is the name of this distribution.
        DistributionName = 'SkewT';
    end

    % Optionally add your own properties here. For this distribution it's convenient
    % to be able to refer to the nu and omega parameters by name, and have them
    % connected to the proper element of the ParameterValues property. These are
    % dependent properties because they depend on ParameterValues.
    properties(Dependent=true)
        %XI Location
        xi

        %omega Scale parameter
        %    omega is the scale parameter for this distribution.
        omega

        %lambda Shape parameter
        %    lambda is the Shape parameter for this distribution.
        alpha

        %NU Degress of Freedom
        %    NU are the degrees of freedom
        nu
    end

    % All ParametricDistribution objects must specify values for the following
    % constant properties (they are the same for all instances of this class).
    properties(Constant)
        %NumParameters Number of parameters
        %    NumParameters is the number of parameters in this distribution.

        NumParameters = 4;

        %ParameterName Name of parameter
        %    ParameterName is a two-element cell array containing names
        %    of the parameters of this distribution.
        ParameterNames = {'xi', 'omega', 'alpha', 'nu'};

        %ParameterDescription Description of parameter
        %    ParameterDescription is a two-element cell array containing
        %    descriptions of the parameters of this distribution.
        ParameterDescription = {'location', 'scale', 'shape', 'freedom'};
    end

    % All ParametricDistribution objects must include a ParameterValues property
    % whose value is a vector of the parameter values, in the same order as
    % given in the ParameterNames property above.
    properties(GetAccess='public',SetAccess='protected')
        %ParameterValues Values of the distribution parameters
        %    ParameterValues is a two-element vector containing the nu and lambda
        %    values of this distribution.
        ParameterValues
    end

    methods
        % The constructor for this class can be called with a set of parameter
        % values or it can supply default values. These values should be
        % checked to make sure they are valid. They should be stored in the
        % ParameterValues property.
        function pd = SkewTDistribution(xi, omega, alpha, nu)
            arguments
                xi (1,1) double = 0
                omega (1,1) double {mustBePositive} = 1
                alpha (1,1) double = 0
                nu (1,1) double  {mustBeReal, mustBePositive} = Inf
            end

            pd.ParameterValues = [xi omega, alpha, nu];

            % All FittableParametricDistribution objects must assign values
            % to the following two properties. When an object is created by
            % the constructor, all parameters are fixed and the covariance
            % matrix is entirely zero.
            pd.ParameterIsFixed = [true true true true];
            pd.ParameterCovariance = zeros(pd.NumParameters);
        end

        % Implement methods to compute the mean, variance, and standard
        % deviation.
        function m = mean(this)
            if this.nu <= 1
                m = NaN;
            else
                delta = (this.alpha)./sqrt(1+this.alpha.^2);
                if isinf(this.nu)
                    mu = delta*sqrt(2/pi);
                else
                    mu = delta*sqrt(this.nu/pi)*exp(gammaln(0.5*(this.nu-1)) - gammaln(0.5*this.nu));
                end
                m = this.xi + this.omega*mu;
            end
        end
        function s = std(this)
            s = sqrt(this.var);
        end
        function v = var(this)
            if this.nu <= 2
                v = NaN; % variance not defined below 2 in t-student
            else
                mu = (this.mean() - this.xi)/this.omega;
                if isinf(this.nu)
                    v = this.omega^2*(1-mu.^2);
                else
                    v = this.omega^2*(this.nu/(this.nu-2)-mu.^2);
                end
                
            end
        end
    end
    methods
        % If this class defines dependent properties to represent parameter
        % values, their get and set methods must be defined. The set method
        % should mark the distribution as no longer fitted, because any
        % old results such as the covariance matrix are not valid when the
        % parameters are changed from their estimated values.
        function this = set.xi(this,xi)
            arguments
                this
                xi (1,1) double
            end
            this.ParameterValues(1) = xi;
            this = invalidateFit(this);
        end
        function this = set.omega(this,omega)
            arguments
                this
                omega (1,1) double
            end
            this.ParameterValues(2) = omega;
            this = invalidateFit(this);
        end
        function this = set.alpha(this,alpha)
            arguments
                this
                alpha (1,1) double
            end
            this.ParameterValues(3) = alpha;
            this = invalidateFit(this);
        end
        function this = set.nu(this,nu)
            arguments
                this
                nu (1,1) double
            end
            this.ParameterValues(4) = nu;
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
        function nu = get.nu(this)
            nu = this.ParameterValues(4);
        end
    end
    methods(Static, Hidden)

        function pd = fit(x,varargin)
            %FIT Fit from data
            %   P = prob.SkewTDistribution.fit(x)
            %   P = prob.SkewTDistribution.fit(x, NAME1,VAL1, NAME2,VAL2, ...)
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
            x = prob.ToolboxFittableParametricDistribution.removeCensoring(x,cens,freq,'skewt');
            freq = ones(size(x));

            params0 = [median(x); iqr(x)/1.349;  2 / sqrt( 1 + 2^2); 10];

            % Perform the MLE to estimate the distribution parameters.
            f = @(data, xi, omega, alpha, nu) ...
                prob.SkewTDistribution.logpdffunc(...
                data, xi, omega, alpha, nu);

            lb = [-Inf; eps; -Inf; 0];
            ub = [Inf; Inf; Inf; Inf];
      

            if isempty(options)
                options = statset;
                options.MaxIter = 1e6;
                options.MaxFunEvals = 1e6;
            end
            params = mle(x, 'logpdf', f, ...
                'start', params0, ...
                'LowerBound', lb, ...
                'UpperBound', ub, Options=options);

            % Create the distribution by calling the constructor.
            pd = prob.SkewTDistribution(params(1),params(2), params(3), params(4));

            % Fill in remaining properties defined above
            pd.ParameterIsFixed = [false false false false];
            [nll,acov] = prob.SkewTDistribution.likefunc([params(1) params(2) params(3) params(4)],x);
            pd.ParameterCovariance = acov;

            % Assign properties required for the FittableDistribution class
            pd.NegativeLogLikelihood = nll;
            pd.InputData = struct('data',x,'cens',[],'freq',freq);
        end

        % The following static methods are required for the
        % ToolboxParametricDistribution class and are used by various
        % Statistics and Machine Learning Toolbox functions. These functions operate on
        % parameter values supplied as input arguments, not on the
        % parameter values stored in a SkewT object. For
        % example, the cdf method implemented in a parent class invokes the
        % cdffunc static method and provides it with the parameter values.
        function [nll,acov] = likefunc(params,x) % likelihood function
            xi = params(1);
            omega = params(2);
            alpha = params(3);
            nu = params(4);

            nll = -sum(prob.SkewTDistribution.logpdffunc(x, xi, omega, alpha, nu));

            % Asymptotic parameter variance-covariance matrix. In the
            % absence of a closed-form expression for this, we can estimate
            % it using MLECOV.
            acov = mlecov(params,x,'logpdf',@prob.SkewTDistribution.logpdffunc);
        end

        function y = cdffunc(x, xi, omega, alpha, nu)          % cumulative distribution function

            arguments
                x (:,1) double
                xi (1,1) double = 0
                omega (1,1) double {mustBePositive} = 1
                alpha (1,1) double = 0
                nu (1,1) double  {mustBeReal, mustBePositive} = Inf
            end

            if isinf(nu)
                y = prob.SkewNormalDistribution.cdffunc(x,xi,omega,alpha);
            else
                z = (x-xi)./omega;

                %Get the correlation matrix from the covariance matrix Omega
                delta = alpha / sqrt( 1 + alpha^2);

                % Correlation matrix with unit variances and correlation -delta
                Sigma = [1, -delta; -delta, 1];

                % Upper bounds for each row: [0, z_i]
                U = [zeros(numel(z),1), z];

                % Compute 2 * bivariate t CDF
                % mvtcdf treats rows as separate upper bound vectors; lower defaults to -Inf.
                y = 2 * mvtcdf(U, Sigma, nu);

                % For numerical safety, clamp to [0,1]
                y = min(max(y, 0), 1);

            end


        end

        function y = pdffunc(x, xi, omega, alpha, nu)         % probability density function

            arguments
                x (:,1) double
                xi (1,1) double = 0
                omega (1,1) double {mustBePositive} = 1
                alpha (1,1) double = 0
                nu (1,1) double {mustBePositive} = Inf
            end

            %Define the standardized random variable
            z=(x-xi)./omega;
            if nu==Inf
                y=2.*normpdf(z).*normcdf( alpha.*z)./omega;
            else
                y=2.*tpdf(z,nu).*tcdf(alpha.*z.*sqrt((1+nu)./(z.^2+nu)),nu+1)./omega;
            end

        end

        function y = logpdffunc(x, xi, omega, alpha, nu)
            %LOGPDFFUNC probability density function
            %  y = logpdffunc(x, xi, omega, alpha, nu)

            arguments
                x (:,1) double
                xi (1,1) double = 0
                omega (1,1) double {mustBePositive} = 1
                alpha (1,1) double = 0
                nu (1,1) double  {mustBeReal, mustBePositive} = Inf
            end

            z=(x-xi)./omega;
            if nu==Inf
                y = log(2) + log(1/sqrt(2*pi)) - z.^2/2 + log(normcdf( alpha.*z)) - log(omega);
            else
                y = log(2) + log(tpdf(z,nu)) + log(tcdf(alpha.*z.*sqrt((1+nu)./(z.^2+nu)),nu+1)) - log(omega);
            end

        end

        function y = invfunc(p, xi, omega, alpha, nu, nvp)
            %INVFUNC inverse cdf
            %   q = invfunc(p, xi, omega, alpha, nu, options)

            arguments
                p (:,1) double {mustBeInRange(p, 0, 1)} %#ok<MUSTINRANGE>
                xi (1,1) double = 0
                omega (1,1) double {mustBePositive} = 1
                alpha (1,1) double = 0
                nu (1,1) double  {mustBeReal, mustBePositive} = Inf
                nvp.options (1,1) struct = optimset('Display','off')
            end

            y = NaN(numel(p), 1);
            y(p == 1) = Inf;
            y(p == 0) = -Inf;

            idx = p~=0 & p~= 1 & ~isnan(p);
            toSolve = p(idx);
            n = numel(toSolve);

            solved = zeros(n, 1);
            if isinf(nu)

                for i = 1 : n
                    x0 = norminv(toSolve(i));
                    func = @(x) prob.SkewNormalDistribution.cdffunc(x,0,1,alpha)-toSolve(i);
                    solved(i) = fzero(func, x0, nvp.options);
                end

            else

                for i = 1 : n
                    x0 = tinv(toSolve(i), nu);
                    func = @(x) prob.SkewTDistribution.cdffunc(x,0,1,alpha,nu)-toSolve(i);
                    solved(i) = fzero(func, x0, nvp.options);
                end

            end
            y(idx) = xi+omega*solved;

        end

        function y = randfunc( xi, omega, alpha, nu, varargin) % random number generator

            arguments
                xi (1,1) double = 0
                omega (1,1) double {mustBePositive} = 1
                alpha (1,1) double = 0
                nu (1,1) double  {mustBeReal, mustBePositive} = Inf
            end

            arguments (Repeating)
                varargin
            end

            z=prob.SkewNormalDistribution.randfunc(0,omega,alpha,varargin{:});
            if nu==Inf
                %Creates a (1*n) matrix with random numbers from a skew normal distribution
                %where the location parameter is set equal to zero
                y=z+xi;
            else
                %Creates a (1*n) matrix with random numbers from a skew normal distribution
                %where the location parameter is set equal to zero

                v=chi2rnd(nu,varargin{:})./nu;
                y=z./sqrt(v)+xi;
            end

        end

        % All ToolboxDistributions must implement a getInfo static method
        % so that Statistics and Machine Learning Toolbox functions can get information about
        % the distribution.
        function info = getInfo

            % First get default info from parent class
            info = getInfo@prob.ToolboxFittableParametricDistribution('prob.SkewTDistribution');

            % Then override fields as necessary
            info.name = 'SkewT';
            info.code = 'SkewT';
            % info.pnames is obtained from the ParameterNames property
            % info.pdescription is obtained from the ParameterDescription property
            % info.prequired = [false false] % Change if any parameter must
            % be specified before fitting.
            % An example would be the N
            % parameter of the binomial
            % distribution.
            % info.hasconfbounds = false     % Set to true if the cdf and
            % icdf methods can return
            % lower and upper bounds as
            % their 2nd and 3rd outputs.
            % censoring = false              % Set to true if the fit
            % method supports censoring.
            % info.support = [-Inf, Inf]     % Set to other lower and upper
            % bounds if the distribution
            % doesn't cover the whole real
            % line. For example, for afi
            % distribution on positive
            % values use [0, Inf].
            % info.closedbound = [false false] % Set the Jth value to
            % true if the distribution
            % allows x to be equal to the
            % Jth element of the support
            % vector.
            % info.iscontinuous = true       % Set to false if x can take
            % only integer values.
            info.islocscale = false; % Set to true if this is a location/scale distribution
            % (no other parameters).
            % info.uselogpp = false          % Set to true if a probability
            % plot should be drawn on the
            % log scale.
            info.optimopts = true;           % Set to true if the fit method can be called with an options structure.
            % info.logci = [false true];       % Set to true for a parameter that should have its Wald
            % confidence interval computed
            % using a normal approximation
            % on the log scale.
        end
    end
end % classdef