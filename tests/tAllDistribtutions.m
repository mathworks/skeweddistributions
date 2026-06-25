classdef tAllDistribtutions < matlab.unittest.TestCase
    % Copyright 2024 - 2026 The MathWorks, Inc.
    properties (TestParameter)
        DistName = {'SkewT','SkewNormal','EpsilonSkewNormal','Loggamma','SplitNormal', 'InverseGamma'}
    end

    methods (Test)
        function tRandomSize(tc, DistName)
            pd = makedist(DistName);
            data = pd.random(4, 5, 2);
            tc.verifySize(data, [4,5,2])
        end

        function tMean(tc, DistName)
            pd = makedist(DistName);
            if DistName == "Loggamma"
                pd.a = 0.1;
                pd.b = 0.1;
                data = pd.randfunc(pd.a, pd.b, 1e6, 1);
            elseif DistName == "InverseGamma"
                pd.a = 3;
                pd.b = 0.5;
                data = pd.randfunc(pd.a, pd.b, 1e6, 1);
            else
                data = random(pd, 1e6, 1);
            end
            tc.verifyEqual(mean(data), pd.mean, 'AbsTol', 1e-2);
        end

        function tVar(tc, DistName)
            pd = makedist(DistName);
            if DistName == "Loggamma"
                pd.a = 0.1;
                pd.b = 0.1;
                data = pd.randfunc(pd.a, pd.b, 1e6, 1);
            elseif DistName == "InverseGamma"
                pd.a = 3;
                pd.b = 0.5;
                data = pd.randfunc(pd.a, pd.b, 1e6, 1);
            else
                data = random(pd, 1e6, 1);
            end
            tc.verifyEqual(var(data), pd.var, 'AbsTol', 1e-2);
        end


        function tPdfLogpdfConsistency(tc, DistName)
            
            if DistName == "Loggamma"
                pd = makedist(DistName, 1, 0.2);
                x = linspace(1+eps, pd.mean + 10*sqrt(pd.var), 5000);
            elseif DistName == "InverseGamma"
                pd = makedist(DistName);
                x = linspace(eps, pd.mean + 10*sqrt(pd.var), 5000);
            else
                pd = makedist(DistName);
                x = linspace(pd.mean - 6*sqrt(pd.var), pd.mean + 6*sqrt(pd.var), 2000);
            end
            args = num2cell(pd.ParameterValues);
            p  = pd.pdf(x); lp = pd.logpdffunc(x, args{:});
            mask = isfinite(lp) & (p>0);
            tc.verifyLessThan(max(abs(log(p(mask)) - lp(mask))), 1e-10);
        end

        function tCdfMonotoneAndLimits(tc, DistName)
            pd = makedist(DistName);
            if DistName == "Loggamma"
                pd.a = 0.1;
                pd.b = 0.1;
                x = linspace(0, pd.mean + 10*sqrt(pd.var), 5000);
                F = pd.cdffunc(x, pd.a, pd.b);
            elseif DistName == "InverseGamma"
                pd.a = 3;
                pd.b = 0.5;
                x = linspace(0, pd.mean + 10*sqrt(pd.var), 5000);
                F = pd.cdffunc(x, pd.a, pd.b);
            else
                x = linspace(pd.mean - 10*sqrt(pd.var), pd.mean + 10*sqrt(pd.var), 5000);
                F = pd.cdf(x);
            end
            tc.verifyEqual(F(1), 1e-6, 'AbsTol', 1e-2);
            tc.verifyEqual(F(end), 1-1e-6, 'AbsTol', 1e-2);
        end

    end

end