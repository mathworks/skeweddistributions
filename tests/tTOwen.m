classdef tTOwen < matlab.unittest.TestCase
% Copyright 2024 - 2026 The MathWorks, Inc.
    methods (Test)
        function tZeroA(tc)
            r = prob.SkewNormalDistribution.TOwen(4, 0);
            tc.verifyEqual(r, 0); 

            r = prob.SkewNormalDistribution.TOwen([-10 2 4], 0);
            tc.verifyEqual(r, [0 0 0]'); 
        end

        function tZeroH(tc)
            r = prob.SkewNormalDistribution.TOwen(0, 3);
            tc.verifyEqual(r, atan(3)/(2*pi),RelTol = 1e-15, AbsTol = 1e-15);

            r = prob.SkewNormalDistribution.TOwen(0, 0);
            tc.verifyEqual(r, 0);

            r = prob.SkewNormalDistribution.TOwen(0, -3);
            tc.verifyEqual(r, atan(-3)/(2*pi),RelTol = 1e-15, AbsTol = 1e-15);
        end

        function tSymmetry(tc)
            r = prob.SkewNormalDistribution.TOwen(3, 3);
            r2 = prob.SkewNormalDistribution.TOwen(-3, 3);
            
            tc.verifyEqual(r, r2);
        end

        function tAntiSymmetry(tc)
            r = prob.SkewNormalDistribution.TOwen(3, -3);
            r2 = prob.SkewNormalDistribution.TOwen(3, 3);
            
            tc.verifyEqual(r, -r2, RelTol = 1e-15, AbsTol = 1e-15);
        end
    end
end