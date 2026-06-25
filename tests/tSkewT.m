classdef tSkewT < matlab.unittest.TestCase
% Copyright 2024 - 2026 The MathWorks, Inc.

    methods (Test)

        function tRandFit(tc)

            fprintf("\nFitting Random Skew T:\n")
            for i = 1 : 10

                xi = rand*2;
                omega = randi(3);
                alpha = randi(4);
                nu = rand*10+1;
                pd = prob.SkewTDistribution(xi, omega, alpha, nu);
                data = pd.random(10000, 1);
                fitteddist = pd.fit(data);

                fprintf('  Fitting %0.2f %0.2f %0.2f %0.2f\n', xi, omega, alpha, nu)
                tc.verifyEqual(fitteddist.xi, xi, 'bad xi', AbsTol = 3*sqrt(fitteddist.ParameterCovariance(1,1)))
                tc.verifyEqual(fitteddist.omega, omega, 'bad omega', AbsTol = 3*sqrt(fitteddist.ParameterCovariance(2,2)))
                tc.verifyEqual(fitteddist.alpha, alpha, 'bad alpha', AbsTol = 3*sqrt(fitteddist.ParameterCovariance(3,3)))
                tc.verifyEqual(fitteddist.nu, nu, 'bad nu', AbsTol = 3*sqrt(fitteddist.ParameterCovariance(4,4)))
            end
           
        end

        function tInverse(tc)

            % 1) Round-trip consistency: cdf(icdf(p)) ≈ p
            % Define a skew-t distribution
            pd = makedist('SkewT');
            pd.xi = -1;
            pd.omega = 0.8;
            pd.alpha = 1;
            pd.nu = 3;

            p = 0.7;
            x = icdf(pd, p);
            p2 = cdf(pd, x);

            tc.verifyEqual(p, p2, RelTol = 1e-15, AbsTol = 1e-15)

            pd.nu = Inf;

            p = 0.5;
            x = icdf(pd, p);
            p2 = cdf(pd, x);
            tc.verifyEqual(p, p2, RelTol = 1e-15, AbsTol = 1e-15)
            
            pd.xi = 2;
            pd.omega = 0.5;
            pd.alpha = 3;
            pd.nu = 2;

            
            p = linspace(0, 1, 1000)';  % avoid exact 0/1 for numeric stability
            x = icdf(pd, p);
            p_back = cdf(pd, x);
            tc.verifyEqual(p_back, p, RelTol = 1e-14, AbsTol = 1e-14);


            % non integer nu
            pd.xi = 2;
            pd.omega = 0.5;
            pd.alpha = 3;
            pd.nu = 2.3;

            p = linspace(0, 1, 1000)'; 
            x = icdf(pd, p);
            p_back = cdf(pd, x);
            tc.verifyEqual(p_back, p, RelTol = 1e-14, AbsTol = 1e-14);

        end

        function tInverseNuInf(tc)

            % Define a skew-t distribution
            pd = makedist('SkewT');
            pd.xi = -2;
            pd.omega = 0.9;
            pd.alpha = 1;
            pd.nu = Inf;

            % 1) Round-trip consistency: cdf(icdf(p)) ≈ p
            p = linspace(0, 1, 2000)';  % avoid exact 0/1 for numeric stability
            x = icdf(pd, p);
            p_back = cdf(pd, x);
            tc.verifyEqual(max(abs(p_back - p)), 0, RelTol = 1e-14, AbsTol = 1e-14);

        end


    end

end