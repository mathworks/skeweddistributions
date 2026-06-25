classdef tInverseGamma < matlab.unittest.TestCase
% Copyright 2024 - 2026 The MathWorks, Inc.
    methods (Test)
        % Test methods

        function tRandFit(tc)

            fprintf("\nFitting Random Inverse Gammas:\n")
            for i = 1 : 10

                a = rand(1)*100;
                b =  rand*10;

                fprintf('  Fitting %0.2f %0.2f\n', a, b)
                pd = prob.InverseGammaDistribution(a,b);
                data = pd.random(10000,1);
                fitteddist = pd.fit(data);       

                tc.verifyEqual(fitteddist.a, a, AbsTol = 0.1*abs(a))
                tc.verifyEqual(fitteddist.b, b, AbsTol = 0.1*abs(b))
            end

        end

        function tSupportBoundary(tc)
            x = [-Inf; -1; 0];

            tc.verifyEqual(prob.InverseGammaDistribution.pdffunc(x, 3, 1), zeros(size(x)))
            tc.verifyEqual(prob.InverseGammaDistribution.logpdffunc(x, 3, 1), -inf(size(x)))
            tc.verifyEqual(prob.InverseGammaDistribution.cdffunc(x, 3, 1), zeros(size(x)))

            tc.verifyEqual(prob.InverseGammaDistribution.cdffunc(Inf, 3, 1), 1)
            tc.verifyTrue(isnan(prob.InverseGammaDistribution.pdffunc(NaN, 3, 1)))
            tc.verifyTrue(isnan(prob.InverseGammaDistribution.logpdffunc(NaN, 3, 1)))
            tc.verifyTrue(isnan(prob.InverseGammaDistribution.cdffunc(NaN, 3, 1)))
        end

        function tInverseCdfBoundary(tc)
            p = [0; 1e-6; 0.1; 0.5; 0.9; 1 - 1e-6; 1];
            x = prob.InverseGammaDistribution.invfunc(p, 3, 1);
            pBack = prob.InverseGammaDistribution.cdffunc(x, 3, 1);

            tc.verifyEqual(x(1), 0)
            tc.verifyEqual(x(end), Inf)
            tc.verifyEqual(pBack, p, AbsTol = 1e-12)
        end

    end

end
