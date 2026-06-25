classdef LoggammaDistribution < prob.ToolboxFittableParametricDistribution
    %LogGammaDistribution Log Gamma probability distribution.
    %    An object of the LoggammaDistribution class represents an gamma
    %    probability distribution with specific values of the parameters A and B.
    %    If a random variable X ~ Gamma, then Y = exp(X) ~ Log Gamma
    %    This distribution object can be created directly
    %    using the MAKEDIST function or fit to data using the FITDIST function.
    %
    %    LoggammaDistribution methods:
    %       cdf                   - Cumulative distribution function
    %       icdf                  - Inverse cumulative distribution function
    %       iqr                   - Interquartile range
    %       mean                  - Mean
    %       median                - Median
    %       negloglik             - Negative log likelihood function
    %       paramci               - Confidence intervals for parameters
    %       pdf                   - Probability density function
    %       proflik               - Profile likelihood function
    %       random                - Random number generation
    %       std                   - Standard deviation
    %       truncate              - Truncation distribution to an interval
    %       var                   - Variance
    %
    %    LoggammaDistribution properties:
    %       DistributionName      - Name of the distribution
    %       a                     - Value of the a parameter
    %       b                     - Value of the b parameter
    %       NumParameters         - Number of parameters
    %       ParameterNames        - Names of parameters
    %       ParameterDescription  - Descriptions of parameters
    %       ParameterValues       - Vector of values of parameters
    %       Truncation            - Two-element vector indicating truncation limits
    %       IsTruncated           - Boolean flag indicating if distribution is truncated
    %       ParameterCovariance   - Covariance matrix of estimated parameters
    %       ParameterIsFixed      - Two-element boolean vector indicating fixed parameters
    %       InputData             - Structure containing data used to fit the distribution
    %
    %    See also fitdist, makedist.
    %
    %   Copyright 2024 - 2026 The MathWorks, Inc.

    properties(Constant)
        %DistributionName Name of distribution
        %    DistributionName is the name of this distribution.
        DistributionName = 'Loggamma';
    end

    % Optionally add your own properties here. For this distribution it's convenient
    % to be able to refer to the a and b parameters by name, and have them
    % connected to the proper element of the ParameterValues property. These are
    % dependent properties because they depend on ParameterValues.
    properties(Dependent=true)
        %a shape parameter
        %    A is the shape parameter for this distribution.
        a

        %b Scale parameter
        %    B is the scale parameter for this distribution.
        b
    end

    % All ParametricDistribution objects must specify values for the following
    % constant properties (they are the same for all instances of this class).
    properties(Constant)
        %NumParameters Number of parameters
        %    NumParameters is the number of parameters in this distribution.

        NumParameters = 2;

        %ParameterName Name of parameter
        %    ParameterName is a two-element cell array containing names
        %    of the parameters of this distribution.
        ParameterNames = {'a' 'b'};

        %ParameterDescription Description of parameter
        %    ParameterDescription is a two-element cell array containing
        %    descriptions of the parameters of this distribution.
        ParameterDescription = {'shape' 'scale'};
    end

    % All ParametricDistribution objects must include a ParameterValues property
    % whose value is a vector of the parameter values, in the same order as
    % given in the ParameterNames property above.
    properties(GetAccess='public',SetAccess='protected')
        %ParameterValues Values of the distribution parameters
        %    ParameterValues is a two-element vector containing a, and b
        %    values of this distribution.
        ParameterValues
    end

    methods
        % The constructor for this class can be called with a set of parameter
        % values or it can supply default values. These values should be
        % checked to make sure they are valid. They should be stored in the
        % ParameterValues property.
        function pd = LoggammaDistribution(a,b)
            arguments
                a (1,1) {mustBeNumeric, mustBeReal, mustBeGreaterThan(a, 0)} = 1
                b (1,1) {mustBeNumeric, mustBeReal, mustBeFinite, mustBeGreaterThan(b, 0)} = 1
            end

            pd.ParameterValues = [a b];

            % All FittableParametricDistribution objects must assign values
            % to the following two properties. When an object is created by
            % the constructor, all parameters are fixed and the covariance
            % matrix is entirely zero.
            pd.ParameterIsFixed = [true true];
            pd.ParameterCovariance = zeros(pd.NumParameters);
        end

        % Implement methods to compute the mean, variance, and standard
        % deviation.
        function m = mean(this)
            if this.b < 1
                % Use MGF
                m = (1 - this.b)^(-this.a);
            else
                m = NaN;
            end
        end

        function s = std(this)
            s = sqrt(var(this));
        end

        function v = var(this)
            if this.b < 0.5
                v = ((1 - 2*this.b)^(-this.a)) - (mean(this))^2;
            else
                v = NaN;
            end
        end
    end

    methods
        % If this class defines dependent properties to represent parameter
        % values, their get and set methods must be defined. The set method
        % should mark the distribution as no longer fitted, because any
        % old results such as the covariance matrix are not valid when the
        % parameters are changed from their estimated values.
        function this = set.a(this,a)
            arguments
                this
                a (1,1) {mustBeNumeric, mustBeReal, mustBeGreaterThan(a, 0)}
            end
            this.ParameterValues(1) = a;
            this = invalidateFit(this);
        end

        function this = set.b(this,b)
            arguments
                this
                b (1,1) {mustBeNumeric, mustBeReal, mustBeFinite, mustBeGreaterThan(b, 0)}
            end
            this.ParameterValues(2) = b;
            this = invalidateFit(this);
        end


        function a = get.a(this)
            a = this.ParameterValues(1);
        end

        function b = get.b(this)
            b = this.ParameterValues(2);
        end
    end

    methods(Static, Hidden)
        % All FittableDistribution classes must implement a fit method to fit
        % the distribution from data. This method is called by the FITDIST
        % function, and is not intended to be called directly
        function pd = fit(x,varargin)
            %FIT Fit from data
            %   P = prob.LoggammaDistribution.fit(x)

            % Get the optional arguments
            [x,cens,freq,options] = prob.ToolboxFittableParametricDistribution.processFitArgs(x,varargin{:});

            % This distribution was not written to support censoring or to process
            % a frequency vector. The following utility expands x by the frequency
            % vector, and displays an error message if there is censoring.
            x = prob.ToolboxFittableParametricDistribution.removeCensoring(x,cens,freq,'loggamma');
            
            mask = isfinite(x) & x > 1;
            x = x(mask);

            if isempty(x)
                error("LoggammaDistribution:NoValidData", ...
                    "Loggamma fit requires at least one finite observation greater than 1.");
            end

            freq = ones(size(x));

            % Estimate the parameters from the data using mle.
            y = log(x);
            params = gamfit(y, 0.05,[],freq,options);            
          
            % Create the distribution by calling the constructor.
            pd = prob.LoggammaDistribution(params(1),params(2));

            % Fill in remaining properties defined above
            pd.ParameterIsFixed = [false false];
            [nll, acov] = prob.LoggammaDistribution.likefunc(params,x);
            pd.ParameterCovariance = acov;

            % Assign properties required for the FittableDistribution class
            pd.NegativeLogLikelihood = nll;
            pd.InputData = struct('data',x,'cens',[],'freq',freq);
        end

        % The following static methods are required for the
        % ToolboxParametricDistribution class and are used by various
        % Statistics and Machine Learning Toolbox functions. These functions operate on
        % parameter values supplied as input arguments, not on the
        % parameter values stored in a LoggammaDistribution object. For
        % example, the cdf method implemented in a parent class invokes the
        % cdffunc static method and provides it with the parameter values.
        function [nll, acov] = likefunc(params,x) % likelihood function
            nll = -sum(prob.LoggammaDistribution.logpdffunc(x,params(1),params(2)));
            
            % Asymptotic parameter variance-covariance matrix. In the
            % absence of a closed-form expression for this, we can estimate
            % it using MLECOV.
            acov = mlecov(params,x,'logpdf',@prob.LoggammaDistribution.logpdffunc);
        end

        function y = cdffunc(x,a,b,uflag)          % cumulative distribution function
            y = zeros(size(x));
            posX = isfinite(x) & x > 1;

            doUpper = false;
            if nargin==4
                if ~strcmpi(uflag,'upper')
                    error(message('stats:cdf:UpperTailProblem'));
                end
                doUpper = true;
            end

            if doUpper
                % Slightly slower version but may be more stable
                %y(posX) = gamcdf(log(x(posX)), a, b, 'upper');
                y(posX) = gammainc(log(x(posX))/b, a, 'upper');
                y(~posX) = 1;
                y(isinf(x) & x > 0) = 0;
            else
                % Slightly slower version but may be more stable
                %y(posX) = gamcdf(log(x(posX)), a, b);
                y(posX) = gammainc(log(x(posX))/b, a);
                y(isinf(x) & x > 0) = 1;
            end
            y(isnan(x)) = NaN;
        end

        function y = pdffunc(x,a,b)         % probability density function
            arguments
                x (:,1) double {mustBeReal}
                a (1,1) double {mustBePositive} = 1
                b (1,1) double {mustBePositive} = 1
            end

            y = exp(prob.LoggammaDistribution.logpdffunc(x, a, b));
        end

        function y = logpdffunc(x, a, b)         % log probability density function
            %LOGPDFFUNC compute the log pdf
            arguments
                x (:,1) double {mustBeReal}
                a (1,1) double {mustBePositive} = 1
                b (1,1) double {mustBePositive} = 1
            end
            posX = isfinite(x) & x > 1;
            logx = log(x(posX));
            y = -inf(size(x));
            y(posX) = (a-1)*log(logx)-gammaln(a)-a*log(b)-(b+1)*logx/b;
            y(isnan(x)) = NaN;
        end

        function y = invfunc(p,a,b)         % inverse cdf
            arguments
                p double {mustBeInRange(p, 0, 1)} %#ok<MUSTINRANGE>
                a (1,1) {mustBeNumeric, mustBeReal, mustBeGreaterThan(a, 0)} = 1
                b (1,1) {mustBeNumeric, mustBeReal, mustBeFinite, mustBeGreaterThan(b, 0)} = 1
            end
            y = exp(gaminv(p, a, b));
        end

        function y = randfunc(a,b,varargin) % random number generator
            x = gamrnd(a, b, varargin{:});
            y = exp(x);
        end

        % All ToolboxDistributions must implement a getInfo static method
        % so that Statistics and Machine Learning Toolbox functions can get information about
        % the distribution.
        function info = getInfo()

            % First get default info from parent class
            info = getInfo@prob.ToolboxFittableParametricDistribution('prob.LoggammaDistribution');

            % Then override fields as necessary
            info.name = 'loggamma';
            info.code = 'loggamma';
            info.support = [1 Inf];
            info.optimopts = true;
        end
    end
end
