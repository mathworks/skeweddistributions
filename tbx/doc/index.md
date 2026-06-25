# Skewed Probability Distributions

This toolbox contains a collection of skewed, and split **parametric probability distributions** often used in 
tail-risk applications.

---

## Contents

The toolbox currently includes the following parametric distributions:

### Skewed and Asymmetric Distributions

- [**Epsilon–Skew–Normal**](./EpsilonSkewNormalDistribution.md)
  A bounded-skewness extension of the normal distribution, suitable for mild asymmetry.

- [**Skew–Normal**](./SkewTDistribution.md)  
  A normal-based distribution with unbounded skewness controlled by a shape parameter.

- [**Split–Normal**](./SplitNormalDistribution.md)
  A two-piece normal distribution with different left and right standard deviations.

- [**Skew–t**](./SkewTDistribution.md)
  A heavy-tailed, asymmetric distribution combining skewness and Student's t behavior.

### Positive-Support Distributions

- [**Log–Gamma**](./LoggammaDistribution.md)
  A right-skewed distribution derived from an exponential transformation of a Gamma random variable.

- [**Inverse–Gamma**](./InverseGammaDistribution.md)
  A heavy-tailed distribution on positive values, commonly used in Bayesian modeling.

---

## Typical Use Cases

- Modeling asymmetric data while retaining normal-like structure
- Capturing skewness together with heavy tails
- Bayesian priors for scale and variance parameters
- Flexible likelihood models beyond standard Gaussian assumptions

---

## Before you start

Make sure that you have either the project opened or the toolbox installed. 

Then, run once the following command to refresh the MATLAB state:

```matlab
makedist -reset
```
You do not have to re-run this command unless you install an update or make any changes to the code

## Quick start

1. Create a distribution object

```matlab
pd = makedist('skewnormal', 0, 1, 2);
```

2. Evaluate the PDF

```matlab 
x = linspace(-5, 5, 200);
y = pdf(pd, x);
```

3. Fit to data

```matlab
r = random(pd, 2000, 1);
pdHat = fitdist(r, 'SkewNormal');
```

4. Random sampling

```matlab
z = random(pdHat, 2, 1);
```
---