classdef tSplitN < matlab.unittest.TestCase
    % Copyright 2024 - 2026 The MathWorks, Inc.

    methods (Test)

        function tRandFit(tc)

            fprintf("\nFitting Random Split Normals: \n")
            n = 100000;
            for i = 1 : 10

                loc = rand*2;
                sigma1 = randi(10);
                sigma2 = randi(10);

                fprintf('  Fitting %0.2f %0.2f %0.2f\n', loc, sigma1, sigma2)

                pd = prob.SplitNormalDistribution(loc, sigma1, sigma2);
                data = pd.random(n, 1);
                fitteddist = pd.fit(data);
                
                % mu's std-error scales with sigma/sqrt(n); allow ~5 std-errors of slack
                muTol = 12 * max(sigma1,sigma2) / sqrt(n);
                tc.verifyEqual(fitteddist.mu, loc, AbsTol = muTol)
                tc.verifyEqual(fitteddist.sigma1, sigma1, RelTol = 0.1)
                tc.verifyEqual(fitteddist.sigma2, sigma2, RelTol = 0.1)

            end


        end

        function tBasic(tc)

            pd = prob.SplitNormalDistribution(0, 1, 2);

            % Monotone increasing CDF:
            x  = linspace(-10,10,1000)';
            Fx = prob.SplitNormalDistribution.cdffunc(x, pd.mu, pd.sigma1, pd.sigma2);
            tc.verifyTrue(all(diff(Fx) >= -1e-12)); % allow tiny numerical noise

            % Mean/Var close to theoretical:
            m_theory = pd.mean();
            v_theory = pd.var();
          
            r = pd.random( 2e6, 1 );
            tc.verifyTrue(abs(mean(r)-m_theory) <  1e-2);
            tc.verifyTrue(abs(var(r)-v_theory) < 1e-2);

        end


    end

end