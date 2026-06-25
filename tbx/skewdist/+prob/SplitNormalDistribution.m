classdef SplitNormalDistribution < prob.ToolboxFittableParametricDistribution
    %    An object of the SplitNormal class represents a Split Normal
    %    probability distribution with a specific location parameter MU and
    %    scale parameter SIGMA1 and SIGMA2. This distribution object can be created directly
    %    using the MAKEDIST function or fit to data using the FITDIST function.
    %
    %    SplitNormal methods:
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
    %    SplitNormal properties:
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

    % All ProbabilityDistribution objects must specify a DistributionName
    properties(Constant)
        %DistributionName Name of distribution
        %    DistributionName is the name of this distribution.
        DistributionName = 'splitnormal';
    end

    % Optionally add your own properties here. For this distribution it's convenient
    % to be able to refer to the mu and sigma parameters by name, and have them
    % connected to the proper element of the ParameterValues property. These are
    % dependent properties because they depend on ParameterValues.
    properties(Dependent=true)
        %MU Mode parameter
        %    MU is the mode parameter for this distribution.
        mu

        %SIGMA1 STD parameter
        %    SIGMA1 is the left-hand side standard deviation
        sigma1


        %SIGMA2 STD parameter
        %    SIGMA2 is the right-hand side standard deviation
        sigma2
    end

    % All ParametricDistribution objects must specify values for the following
    % constant properties (they are the same for all instances of this class).
    properties(Constant)
        %NumParameters Number of parameters
        %    NumParameters is the number of parameters in this distribution.

        NumParameters = 3;

        %ParameterName Name of parameter
        %    ParameterName is a two-element cell array containing names
        %    of the parameters of this distribution.
        ParameterNames = {'mu' 'sigma1' 'sigma2'};

        %ParameterDescription Description of parameter
        %    ParameterDescription is a two-element cell array containing
        %    descriptions of the parameters of this distribution.
        ParameterDescription = {'mode' 'std1' 'std2'};
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

    methods
        % The constructor for this class can be called with a set of parameter
        % values or it can supply default values. These values should be
        % checked to make sure they are valid. They should be stored in the
        % ParameterValues property.
        function pd = SplitNormalDistribution(mu,sigma1,sigma2)
            arguments
                mu (1,1) double {mustBeReal} = 0
                sigma1 (1,1) double {mustBePositive} = 1
                sigma2 (1,1) double {mustBePositive} = 2
            end

            pd.ParameterValues = [mu, sigma1, sigma2];

            % All FittableParametricDistribution objects must assign values
            % to the following two properties. When an object is created by
            % the constructor, all parameters are fixed and the covariance
            % matrix is entirely zero.
            pd.ParameterIsFixed = [true true true];
            pd.ParameterCovariance = zeros(pd.NumParameters);
        end

        % Implement methods to compute the mean, variance, and standard
        % deviation.
        function m = mean(this)
            m = this.mu + sqrt(2/pi)*(this.sigma2 - this.sigma1);
        end
        function s = std(this)
            s = sqrt(this.var);
        end
        function v = var(this)
            v = (1-2/pi)*(this.sigma2-this.sigma1)^2+this.sigma1*this.sigma2;
        end
    end
    methods
        % If this class defines dependent properties to represent parameter
        % values, their get and set methods must be defined. The set method
        % should mark the distribution as no longer fitted, because any
        % old results such as the covariance matrix are not valid when the
        % parameters are changed from their estimated values.
        function this = set.mu(this,mu)
            arguments
                this
                mu (1,1) double {mustBeReal}
            end
            this.ParameterValues(1) = mu;
            this = invalidateFit(this);
        end
        function this = set.sigma1(this,sigma1)
            arguments
                this
                sigma1 (1,1) double {mustBePositive}
            end
            this.ParameterValues(2) = sigma1;
            this = invalidateFit(this);
        end
        function this = set.sigma2(this,sigma2)
            arguments
                this
                sigma2 (1,1) double {mustBePositive}
            end
            this.ParameterValues(3) = sigma2;
            this = invalidateFit(this);
        end
        function mu = get.mu(this)
            mu = this.ParameterValues(1);
        end
        function sigma1 = get.sigma1(this)
            sigma1 = this.ParameterValues(2);
        end
        function sigma2 = get.sigma2(this)
            sigma2 = this.ParameterValues(3);
        end
    end
    methods(Static, Hidden)
        % All FittableDistribution classes must implement a fit method to fit
        % the distribution from data. This method is called by the FITDIST
        % function, and is not intended to be called directly
        function pd = fit(x,varargin)
            %FIT Fit from data
            %   P = prob.SplitNormalDistribution.fit(x)
            %   P = prob.SplitNormalDistribution.fit(x, NAME1,VAL1, NAME2,VAL2, ...)
            %   with the following optional parameter name/value pairs:
            %
            %          'censoring'    Boolean vector indicating censored x values
            %          'frequency'    Vector indicating frequencies of corresponding
            %                         x values
            %          'options'      Options structure for fitting, as create by
            %                         the STATSET function
            %
            % Get the optional arguments. The fourth output would be the
            % options structure, but this function doesn't use that.
            [x,cens,freq,options] = prob.ToolboxFittableParametricDistribution.processFitArgs(x,varargin{:});

            % This distribution was not written to support censoring or to process
            % a frequency vector. The following utility expands x by the frequency
            % vector, and displays an error message if there is censoring.
            x = prob.ToolboxFittableParametricDistribution.removeCensoring(x,cens,freq,'splitnormal');
            freq = ones(size(x));

            % Estimate the parameters from the data. If this is an iterative procedure,
            % use the values in the opt argument.
            m = median(x);

            f = @(data, mu, sigma1, sigma2) prob.SplitNormalDistribution.logpdffunc(data, mu, sigma1, sigma2);
            lb = [-inf 0 0];
            ub = [inf inf inf];
            if isempty(options)
                options = statset;
                options.MaxIter = 1e5;
                options.MaxFunEvals = 1e5;
                options.TolFunc = 1e-10;
            end
            params = mle(x, 'logpdf', f, ...
                'start', [m 1 1], ...
                'LowerBound', lb, ...
                'UpperBound', ub, Options=options);

            % Create the distribution by calling the constructor.
            pd = prob.SplitNormalDistribution(params(1), params(2), params(3));

            % Fill in remaining properties defined above
            pd.ParameterIsFixed = [false false false];
            [nll,acov] = prob.SplitNormalDistribution.likefunc(params,x);
            pd.ParameterCovariance = acov;

            % Assign properties required for the FittableDistribution class
            pd.NegativeLogLikelihood = nll;
            pd.InputData = struct('data',x,'cens',[],'freq',freq);
        end

        % The following static methods are required for the
        % ToolboxParametricDistribution class and are used by various
        % Statistics and Machine Learning Toolbox functions. These functions operate on
        % parameter values supplied as input arguments, not on the
        % parameter values stored in a SplitNormal object. For
        % example, the cdf method implemented in a parent class invokes the
        % cdffunc static method and provides it with the parameter values.
        function [nll,acov] = likefunc(params,x) % likelihood function
            mu = params(1);
            sigma1 = params(2);
            sigma2 = params(3);

            nll = -sum(prob.SplitNormalDistribution.logpdffunc(x, mu, sigma1, sigma2));

            % Asymptotic parameter variance-covariance matrix. In the
            % absence of a closed-form expression for this, we can estimate
            % it using MLECOV.
            acov = mlecov(params,x,'logpdf',@prob.SplitNormalDistribution.logpdffunc);
        end
        function y = cdffunc(x, mu, sigma1, sigma2)          % cumulative distribution function
            %CDFFUNC compute the cdf
            arguments
                x (:,1) double {mustBeReal}
                mu (1,1) double {mustBeReal} = 0
                sigma1 (1,1) double {mustBePositive} = 1
                sigma2 (1,1) double {mustBePositive} = 2
            end

            idx = x<=mu;
            y = zeros(numel(x), 1);
            y(idx) = sigma1*2/(sigma1+sigma2)*normcdf(x(idx), mu, sigma1);
            y(~idx) = 1-sigma2*2/(sigma1+sigma2)*(1-normcdf(x(~idx), mu, sigma2));
        end
        function y = pdffunc(x, mu, sigma1, sigma2)         % probability density function
            %PDFFUNC compute the pdf
            arguments
                x (:,1) double {mustBeReal}
                mu (1,1) double {mustBeReal} = 0
                sigma1 (1,1) double {mustBePositive} = 1
                sigma2 (1,1) double {mustBePositive} = 2
            end
            A = sqrt(2/pi)/(sigma1+sigma2);

            idx = x<=mu;
            y = zeros(numel(x),1);

            y(idx) = A*exp(-(x(idx)-mu).^2/(2*sigma1.^2));
            y(~idx) = A*exp(-(x(~idx)-mu).^2/(2*sigma2.^2));
        end

        function y = logpdffunc(x, mu, sigma1, sigma2)         % log probability density function
            %LOGPDFFUNC compute the log pdf
            arguments
                x (:,1) double {mustBeReal}
                mu (1,1) double {mustBeReal} = 0
                sigma1 (1,1) double {mustBePositive} = 1
                sigma2 (1,1) double {mustBePositive} = 2
            end
            A = log(sqrt(2/pi)) - log(sigma1+sigma2);

            idx = x<=mu;
            y = zeros(numel(x),1);

            y(idx) = A + -(x(idx)-mu).^2/(2*sigma1.^2);
            y(~idx) = A + -(x(~idx)-mu).^2/(2*sigma2.^2);
        end

        function y = invfunc(p, mu, sigma1, sigma2)         % inverse cdf
            %INVFUNC compute the quantiles of a split normal distribution
            arguments
                p double {mustBeInRange(p, 0, 1)} %#ok<MUSTINRANGE>
                mu (1,1) double {mustBeReal} = 0
                sigma1 (1,1) double {mustBePositive} = 1
                sigma2 (1,1) double {mustBePositive} = 2 
            end

            idx = p <= sigma1 / (sigma1 + sigma2);
            y = zeros(size(p));

            C = 2/(sigma1+sigma2);
            y(idx) = mu + sigma1*norminv(p(idx)/(sigma1*C));
            y(~idx) = mu + sigma2*norminv(1-(1-p(~idx))/(C*sigma2));

        end
        function y = randfunc(mu,sigma1,sigma2,varargin) % random number generator
            % RANDFUNC random numbers from a split normal
            y = prob.SplitNormalDistribution.invfunc(rand(varargin{:}), mu, sigma1, sigma2);
        end

        % All ToolboxDistributions must implement a getInfo static method
        % so that Statistics and Machine Learning Toolbox functions can get information about
        % the distribution.
        function info = getInfo

            % First get default info from parent class
            info = getInfo@prob.ToolboxFittableParametricDistribution('prob.SplitNormalDistribution');

            % Then override fields as necessary
            info.name = 'SplitNormal';
            info.code = 'splitnormal';
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
            % line. For example, for a
            % distribution on positive
            % values use [0, Inf].
            % info.closedbound = [false false] % Set the Jth value to
            % true if the distribution
            % allows x to be equal to the
            % Jth element of the support
            % vector.
            % info.iscontinuous = true       % Set to false if x can take
            % only integer values.
            info.islocscale = false;          % Set to true if this is a
            % location/scale distribution
            % (no other parameters).
            % info.uselogpp = false          % Set to true if a probability
            % plot should be drawn on the
            % log scale.
            info.optimopts = true;         % Set to true if the fit method can be called with an options structure.
            % info.logci = [false true];     % Set to true for a parameter
            % that should have its Wald
            % confidence interval computed
            % using a normal approximation
            % on the log scale.
        end
    end
end % classdef