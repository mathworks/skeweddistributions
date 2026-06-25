classdef tSkewN < matlab.unittest.TestCase
% Copyright 2024 - 2026 The MathWorks, Inc.

    methods (Test)

        function tRandFit(tc)

            fprintf("\nFitting Random Skew Normals:\n")
            for i = 1 : 10

                xi = rand*2;
                omega = randi(10);
                alpha = randi(10);

                fprintf('  Fitting %0.2f %0.2f %0.2f\n', xi, omega, alpha)

                pd = prob.SkewNormalDistribution(xi, omega, alpha);
                data = pd.random(10000, 1);
                fitteddist = pd.fit(data);

                tc.verifyEqual(fitteddist.xi, xi, 'bad xi', AbsTol = 3*sqrt(fitteddist.ParameterCovariance(1,1)))
                tc.verifyEqual(fitteddist.alpha, alpha, 'bad alpha', AbsTol = 3*sqrt(fitteddist.ParameterCovariance(3,3)))
                tc.verifyEqual(fitteddist.omega, omega, 'bad omega', AbsTol = 3*sqrt(fitteddist.ParameterCovariance(2,2)))

            end

        end

        function tRandFitNAlpha(tc)

            fprintf("\nFitting Random Skew Normals:\n")
            for i = 1 : 10

                xi = rand*2;
                omega = randi(10);
                alpha = -randi(10);

                fprintf('  Fitting %0.2f %0.2f %0.2f\n', xi, omega, alpha)

                pd = prob.SkewNormalDistribution(xi, omega, alpha);
                data = pd.random(10000, 1);
                fitteddist = pd.fit(data);

                tc.verifyEqual(fitteddist.xi, xi, 'bad xi', AbsTol = 3*sqrt(fitteddist.ParameterCovariance(1,1)))
                tc.verifyEqual(fitteddist.alpha, alpha, 'bad alpha', AbsTol = 3*sqrt(fitteddist.ParameterCovariance(3,3)))
                tc.verifyEqual(fitteddist.omega, omega, 'bad omega', AbsTol = 3*sqrt(fitteddist.ParameterCovariance(2,2)))

            end

        end

        function tInverse(tc)

            % Define a skew-t distribution
            pd = makedist('SkewN');
            pd.xi = 2;
            pd.omega = 0.5;
            pd.alpha = 3;

            % 1) Round-trip consistency: cdf(icdf(p)) ≈ p
            p = linspace(0, 1, 2000)';  % avoid exact 0/1 for numeric stability
            x = icdf(pd, p);
            p_back = cdf(pd, x);
            tc.verifyEqual(max(abs(p_back - p)), 0, RelTol = 1e-14, AbsTol = 1e-14);

        end

    end

end