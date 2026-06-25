classdef tLogGamma < matlab.unittest.TestCase
% Copyright 2024 - 2026 The MathWorks, Inc.
    methods (Test)
        % Test methods

        function tRandFit(tc)

            fprintf("\nFitting Random LogGammas:\n")
            for i = 1 : 10

                a = rand(1)*10+0.2;
                b =  rand*10;
                fprintf('  Fitting %0.2f %0.2f\n', a, b)

                pd = prob.LoggammaDistribution(a,b);
                data = pd.random(100000,1);
                fitteddist = pd.fit(data);
                
                tc.verifyEqual(fitteddist.a, a, AbsTol = 0.1*abs(a))
                tc.verifyEqual(fitteddist.b, b, AbsTol = 0.1*abs(b))


            end
            

        end

        function tSmallShapeBoundaryBehavior(tc)
            pd = prob.LoggammaDistribution(0.05, 1.5);
            data = pd.random(100000, 1);

            tc.verifyGreaterThan(nnz(data == 1), 0)
            tc.verifyEqual(prob.LoggammaDistribution.pdffunc(1, pd.a, pd.b), 0)
            tc.verifyEqual(prob.LoggammaDistribution.logpdffunc(1, pd.a, pd.b), -Inf)
            tc.verifyEqual(prob.LoggammaDistribution.cdffunc(1, pd.a, pd.b), 0)
        end

        function tSupportBoundary(tc)
            x = [-Inf; 0; 1; Inf; NaN];

            tc.verifyEqual(prob.LoggammaDistribution.pdffunc(x, 2, 0.5), ...
                [0; 0; 0; 0; NaN])
            tc.verifyEqual(prob.LoggammaDistribution.logpdffunc(x, 2, 0.5), ...
                [-Inf; -Inf; -Inf; -Inf; NaN])
            tc.verifyEqual(prob.LoggammaDistribution.cdffunc(x, 2, 0.5), ...
                [0; 0; 0; 1; NaN])
            tc.verifyEqual(prob.LoggammaDistribution.cdffunc(x, 2, 0.5, 'upper'), ...
                [1; 1; 1; 0; NaN])
        end

        function tGammaTransformAccuracy(tc)
            a = 5;
            b = 2;
            y = linspace(0.01, 20, 200)';
            x = exp(y);

            tc.verifyEqual(prob.LoggammaDistribution.pdffunc(x, a, b), ...
                gampdf(y, a, b)./x, RelTol = 1e-12, AbsTol = 1e-14)
            tc.verifyEqual(prob.LoggammaDistribution.cdffunc(x, a, b), ...
                gamcdf(y, a, b), RelTol = 1e-12, AbsTol = 1e-14)
            tc.verifyEqual(prob.LoggammaDistribution.cdffunc(x, a, b, 'upper'), ...
                gamcdf(y, a, b, 'upper'), RelTol = 1e-12, AbsTol = 1e-14)
        end

        function tLargeParameterPdfAccuracy(tc)
            a = 200;
            b = 0.5;
            y = linspace(60, 140, 200)';
            x = exp(y);

            expectedPdf = gampdf(y, a, b)./x;
            expectedLogPdf = log(gampdf(y, a, b)) - y;
            p = prob.LoggammaDistribution.pdffunc(x, a, b);
            lp = prob.LoggammaDistribution.logpdffunc(x, a, b);

            tc.verifyFalse(any(isnan(p)))
            tc.verifyFalse(any(isnan(lp)))
            tc.verifyGreaterThan(min(p), 0)
            tc.verifyEqual(p, expectedPdf, RelTol = 5e-13)
            tc.verifyEqual(lp, expectedLogPdf, RelTol = 5e-13)
        end

        function tSpecial(tc)
            a = 2.89;
            b = 0.01;
            pd = makedist('LogGamma', a , b );
            data = pd.random(100000,1);
            fitteddist = pd.fit(data);
            tc.verifyEqual(fitteddist.a, a, AbsTol = 0.1*abs(a))
            tc.verifyEqual(fitteddist.b, b, AbsTol = 0.1*abs(b))
        end

    end

end
