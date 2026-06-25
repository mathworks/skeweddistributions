classdef InverseGammaDistribution < prob.ToolboxFittableParametricDistribution
    %    An object of the InverseGamma class represents an Inverse Gamma
    %    probability distribution with a specific shape parameter a and
    %    scale parameter b. This distribution object can be created directly
    %    using the MAKEDIST function or fit to data using the FITDIST function.
    %
    %    InverseGamma methods:
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
    %       var                   - Variance
    %
    %    InverseGamma properties:
    %       DistributionName      - Name of the distribution
    %       a                 - Value of the a parameter
    %       b                  - Value of the b parameter
    %       NumParameters         - Number of parameters
    %       ParameterNames        - Names of parameters
    %       ParameterDescription  - Descriptions of parameters
    %       ParameterValues       - Vector of values of parameters
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
        DistributionName = 'inversegamma';
    end

    % Optionally add your own properties here. For this distribution it's convenient
    % to be able to refer to the a and b parameters by name, and have them
    % connected to the proper element of the ParameterValues property. These are
    % dependent properties because they depend on ParameterValues.
    properties(Dependent=true)
        %a shape parameter
        %    a is the shape parameter for this distribution.
        a

        %Scale parameter
        %    b is the scale parameter for this distribution.
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
        %    ParameterValues is a two-element vector containing the a and sigma
        %    values of this distribution.
        ParameterValues
    end

    methods
        % The constructor for this class can be called with a set of parameter
        % values or it can supply default values. These values should be
        % checked to make sure they are valid. They should be stored in the
        % ParameterValues property.
        function pd = InverseGammaDistribution(a, b)
            arguments
                a (1,1) {mustBeNumeric, mustBeReal, mustBeGreaterThan(a, 0)} = 3
                b (1,1) {mustBeNumeric, mustBeReal, mustBeGreaterThan(b, 0)} = 1
            end

            pd.ParameterValues = [a, b];

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
            if 1 < this.a
                m = this.b/(this.a-1);
            else 
                m = NaN;
            end 
        end
        function s = std(this)
            s = sqrt(this.var);
        end
        function v = var(this)
            if 2 < this.a
            v = (this.b)^2/((this.a-2)*(this.a-1)^2);
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
                a (1,1) double {mustBeNumeric, mustBeReal, mustBeGreaterThan(a, 0)}
            end
            this.ParameterValues(1) = a;
            this = invalidateFit(this);
        end
        function this = set.b(this,b)
            arguments
                this
                b (1,1) double {mustBeNumeric, mustBeReal, mustBeGreaterThan(b, 0)} 
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
            %   P = prob.InverseGammaDistribution.fit(x)
            %   P = prob.InverseGammaDistribution.fit(x, NAME1,VAL1, NAME2,VAL2, ...)
            %   with the following optional parameter name/value pairs:
            %
            %          'censoring'    Boolean vector indicating censored x values
            %          'frequency'    Vector indicating frequencies of corresponding
            %                         x values
            %          'options'      Options structure for fitting, as create by
            %                         the STATSET function
            %
            % Get the optional arguments.
            [x,cens,freq,options] = prob.ToolboxFittableParametricDistribution.processFitArgs(x,varargin{:});

            % This distribution was not written to support censoring or to process
            % a frequency vector. The following utility expands x by the frequency
            % vector, and displays an error message if there is censoring.
            x = prob.ToolboxFittableParametricDistribution.removeCensoring(x,cens,freq,'inversegamma');
            freq = ones(size(x));

            % Estimate the parameters from the data using mle. Use method of 
            % moments on to get initial estimates            
            if isempty(options)
                options = statset;
                options.MaxIter = 1e5;
                options.MaxFunEvals = 1e5;
            end

            % If X ~ InverseGamma(a, b) 
            % then
            % Y = 1 ./ X ~ Gamma(shape = a, scale = 1/b)
            phat = gamfit(1./x);
            params = [phat(1), 1/phat(2)];
            
            % Create the distribution by calling the constructor.
            pd = prob.InverseGammaDistribution(params(1),params(2));            

            % Fill in remaining properties defined above
            pd.ParameterIsFixed = [false false];
            [nll,acov] = prob.InverseGammaDistribution.likefunc(params,x);
            pd.ParameterCovariance = acov;

            % Assign properties required for the FittableDistribution class
            pd.NegativeLogLikelihood = nll;
            pd.InputData = struct('data',x,'cens',[],'freq',freq);
        end

        % The following static methods are required for the
        % ToolboxParametricDistribution class and are used by various
        % Statistics and Machine Learning Toolbox functions. These functions operate on
        % parameter values supplied as input arguments, not on the
        % parameter values stored in a InverseGamma object. For
        % example, the cdf method implemented in a parent class invokes the
        % cdffunc static method and provides it with the parameter values.
        function [nll,acov] = likefunc(params,x) % likelihood function
            a = params(1);
            b = params(2);

            nll = -sum(prob.InverseGammaDistribution.logpdffunc(x, a, b));

            % Asymptotic parameter variance-covariance matrix. In the
            % absence of a closed-form expression for this, we can estimate
            % it using MLECOV.
            acov = mlecov(params,x,'logpdf',@prob.InverseGammaDistribution.logpdffunc);
        end
        function y = cdffunc(x, a, b)          % cumulative distribution function
            %CDFFUNC compute the cdf
            arguments
                x (:,1) double {mustBeReal} 
                a (1,1) double {mustBePositive} = 3
                b (1,1) double {mustBePositive} = 1
            end

            y = zeros(size(x));
            posX = x > 0;
            y(posX) = gammainc(b./x(posX), a, 'upper');
            y(isnan(x)) = NaN;
        end
        function y = pdffunc(x, a, b)         % probability density function
            %PDFFUNC compute the pdf
            arguments
                x (:,1) double {mustBeReal}
                a (1,1) double {mustBePositive} = 3
                b (1,1) double {mustBePositive} = 1
            end

            y = zeros(size(x));
            posX = x > 0;
            y(posX) = exp(a*log(b) - gammaln(a) - (a+1).*log(x(posX)) - b./x(posX));
            y(isnan(x)) = NaN;
        end

        function y = logpdffunc(x, a, b)         % log probability density function
            %LOGPDFFUNC compute the log pdf
            arguments
                x (:,1) double {mustBeReal}
                a (1,1) double {mustBePositive} = 3
                b (1,1) double {mustBePositive} = 1
            end
            y = -inf(size(x));
            posX = x > 0;
            logx = log(x(posX));
            A = a*log(b)-gammaln(a);
            y(posX) = A - (a+1).*logx - b./x(posX);
            y(isnan(x)) = NaN;
            
        end

        function y = invfunc(p, a, b)         % inverse cdf
            %INVFUNC compute the quantiles of a split normal distribution
            arguments
                p double {mustBeInRange(p, 0, 1)} %#ok<MUSTINRANGE>
                a (1,1) double {mustBePositive} = 3
                b (1,1) double {mustBePositive} = 1
            end
            y = zeros(size(p));
            y(p == 1) = Inf;

            idx = p > 0 & p < 1;
            y(idx) = 1./gaminv(1 - p(idx), a, 1/b);
        end
        
        function y = randfunc(a,b,varargin) % random number generator
            % RANDFUNC random numbers from a split normal
            y = prob.InverseGammaDistribution.invfunc(rand(varargin{:}), a, b);
        end

        % All ToolboxDistributions must implement a getInfo static method
        % so that Statistics and Machine Learning Toolbox functions can get information about
        % the distribution.
        function info = getInfo

            % First get default info from parent class
            info = getInfo@prob.ToolboxFittableParametricDistribution('prob.InverseGammaDistribution');

            % Then override fields as necessary
            info.name = 'InverseGamma';
            info.code = 'InverseGamma';
            info.support = [0 Inf];                        
            info.islocscale = false;                     
            info.optimopts = true;
            % info.logci = [false true];     % Set to true for a parameter
            % that should have its Wald
            % confidence interval computed
            % using a normal approximation
            % on the log scale.
        end
    end
end % classdef
