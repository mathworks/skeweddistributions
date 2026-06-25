classdef tEpsilonSkewNormal < matlab.unittest.TestCase
% Copyright 2024 - 2026 The MathWorks, Inc.
    methods (Test)
        % Test methods

        function tRandFit(tc)

            fprintf('\nFitting Random Epsilon Skewed Normals\n')
            for i = 1 : 10

                Theta = rand(1)*100;
                Sigma =  rand*10;
                Epsilon = rand*2-1;
                pd = prob.EpsilonSkewNormalDistribution(Theta, Sigma, Epsilon);
                data = pd.random(100000,1);
                fitteddist = pd.fit(data);                
                fprintf('  Fitting %0.2f %0.2f %0.2f\n', Theta, Sigma, Epsilon)
                tc.verifyEqual(fitteddist.Theta, Theta, AbsTol = 0.1*max(abs(Theta),1))
                tc.verifyEqual(fitteddist.Sigma, Sigma, AbsTol = 0.1*max(abs(Sigma),1))
                tc.verifyEqual(fitteddist.Epsilon, Epsilon, AbsTol = 0.1*max(abs(Epsilon),1))

            end

        end

    end

end