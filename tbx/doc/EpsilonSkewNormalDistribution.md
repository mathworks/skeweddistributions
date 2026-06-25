# Epsilon-Skew-Normal distribution

The **Epsilon-Skew-Normal distribution** is a skewed extension of the normal distribution controlled by a single skewness parameter $\epsilon$.

This class implements the epsilon-skew-normal distribution as a subclass of `prob.ToolboxFittableParametricDistribution`, making it compatible with MATLAB's
Statistics and Machine Learning Toolbox.

## Class
```matlab
prob.EpsilonSkewNormalDistribution
```

## Parameters
| Name | Description | Constraint |
|------|-------------|------------|
| $\theta$ | Location | $-\infty < \theta < \infty$ |
| $\sigma$ | Scale | $0 < \sigma < \infty$ |
| $\epsilon$ | Skewness | $-1 < $\epsilon < 1$ |

- $\epsilon = 0$ reduces the distribution to a standard normal (up to location/scale).
- Positive $\epsilon$ induces right skewness; negative $\epsilon$ induces left skewness.

## Support
$x \in (-\infty, \infty)$

## Probability Density Function (PDF)
Let

$$ u = \frac{x - \theta}{\sigma} $$

The canonical PDF $(\theta = 0, \; \sigma = 1)$ is defined as:

$$
f(u)=\left\{\begin{array}{cl} 
\frac{1}{\sqrt{2\pi}}\exp\left(-\frac{u^2}{2(1+\epsilon)^2}\right), & u<0 \\  
\frac{1}{\sqrt{2\pi}}\exp\left(-\frac{u^2}{2(1-\epsilon)^2}\right), & u\geq0\end{array}\right.
$$

## Cumulative Distribution Function (CDF)

The canonical CDF is defined as:

$$
F(u)=\left\{\begin{array}{cl} 
(1+\epsilon)\Phi\left(\frac{u}{1+\epsilon}\right), & u<0 \\  
\epsilon + (1-\epsilon)\Phi\left(\frac{u}{1-\epsilon}\right), & u\geq0\end{array}\right.
$$

where $\Phi$ is the standard normal CDF.

## Moments

### Mean

$$
\mathbb E[X] = \theta − \frac{4\sigma\epsilon}{\sqrt{2\pi}}
$$

### Variance
$$
Var(X) = \frac{σ²}{\pi}\left[\left(3\pi−8\right)\epsilon^2+\pi\right]
$$

## Construction

Fixed-parameter construction

```matlab
pd = makedist("EpsilonSkewNormal", theta, sigma, epsilon); 
```
If constructed explicitly:

- Parameters are treated as fixed
- ParameterIsFixed = [true, true, true]
- ParameterCovariance = 0

## Fitting to Data

The distribution supports maximum likelihood estimation via fitdist.

```matlab 
pdHat = fitdist(x, "EpsilonSkewNormal"); 
```

## Example Usage

```matlab
% Create a distribution object
pd = makedist("EpsilonSkewNormal", 0, 1, 0.5);

% Evaluate the PDF
x = linspace(-5, 5, 200);
y = pdf(pd, x);

% Random sampling
r = random(pd, 10000, 1);

% Fit a distribution to data
pdHat = fitdist(r, 'EpsilonSkewNormal');

% plot the fitted results
figure(Color = "w");
histogram(r, 100, Normalization = "pdf")
hold on; 
x = linspace(-6, 5, 200);
y = pdf(pdHat, x);
line(x, y, LineWidth = 2)
title('Epsilon Skew Normal Distribution')
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

- The distribution is continuous and unimodal
- No closed-form expression is used for the Fisher information matrix; an asymptotic approximation is employed
- Numerical stability is handled via log-density calculations

