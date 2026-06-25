# Inverse Gamma Distribution

The **Inverse‑Gamma distribution** is a continuous probability distribution
commonly used to model positive-valued random variables and as a prior in
Bayesian statistics.

This class implements the inverse-gamma distribution as a subclass of `prob.ToolboxFittableParametricDistribution`, making it compatible with MATLAB's
Statistics and Machine Learning Toolbox.

---

## Class
```matlab
prob.InverseGammaDistribution
```

## Parameters

| Name | Description | Constraint |
|------|-------------|------------|
| a | Shape | $a > 0$ |
| b | Scale | $b > 0$ |

## Support
$x \in (0, \infty)$

## Probability Density Function (PDF)
The PDF of the Inverse-Gamma distribution is given by:

$$
f(x) = \frac{b^a}{\Gamma(a)} x^{-(a+1)} e^{-b/x}
$$

## Cumulative Distribution Function (CDF)

The cumulative distribution function is given by the upper incomplete Gamma function:

$$ F(x) = \frac{\Gamma\left(a, \frac{b}{a}\right)}{\Gamma(a)}$$

## Cumulative Distribution Function (CDF)

The CDF is expressed in terms of the incomplete Gamma function:

$$F(x)=\Gamma\left(a,\frac{\log⁡(x+1)}{b}\right), \qquad x\geq 0 $$

Both lower and upper tail probabilities are supported.

## Moments
Moments exist only under specific parameter conditions.
### Mean

The mean exists only for

$$a > 1$$

In that case

$$
\mathbb{E}[X] = \frac{b}{a - 1}
$$

Otherwise, the mean is undefined and returned as NaN.

## Variance

The variance exists only for:

$$a > 2$$

In that case

$$
\mathrm{Var}(X) = \frac{b^2}{(a-2)(a-1)^2}Var(X)=(a−2)(a−1)2b2​
$$

Otherwise, the variance is undefined and returned as NaN.

## Construction

Fixed-parameter construction

```matlab
pd = makedist("InverseGamma", a, b); 
```
If constructed explicitly:

- Parameters are treated as fixed
- ParameterIsFixed = [true, true]
- ParameterCovariance = 0

## Fitting to Data

The Inverse-Gamma distribution supports maximum likelihood estimation
using fitdist.

```matlab 
pdHat = fitdist(x, "InverseGamma"); 
```

## Example Usage

```matlab
% Create a distribution object
pd = makedist("InverseGamma", 5, 1);

% Evaluate the PDF
x = linspace(0, 5, 200);
y = pdf(pd, x);

% Random sampling
r = random(pd, 10000, 1);

% Fit a distribution to data
pdHat = fitdist(r, 'InverseGamma');

% plot the fitted results
figure(Color = "w");
histogram(r, 100, Normalization = "pdf")
hold on; 
x = linspace(0, 5, 1000);
y = pdf(pdHat, x);
line(x, y, LineWidth = 2)
title('Inverse Gamma Distribution')
xlim([0 1.5])
```

## Supported Methods

### Distribution Functions
- `pdf`
- `cdf`
- `icdf`
- `random`
- `truncate`

### Statistical Measures
- `mean`
- `median`
- `var`
- `std`
- `iqr`

### Inference
- `fit`
- `paramci`
- `proflik`
- `negloglik`

## Random Number Generation

Random values are generated using inverse transform sampling:

```matlab
r = random(pd, n, 1); 
```

## Notes

- Widely used as a prior for variance parameters
- Heavy‑tailed distribution
- Mean and variance exist only above shape thresholds
